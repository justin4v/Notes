# Concurrent Modify Exception

## 现象

测试用例：

```java
package main.java.mo.basic;
import java.util.ArrayList;

public class ConcurrentModificationExceptionTest {
    public static void main(String[] args) {
        ArrayList<String> strings = new ArrayList<String>();
        strings.add("a");
        strings.add("b");
        strings.add("c");
        strings.add("d");
        strings.add("e");
        for (String string : strings) {
            if ("a".equals(string)) {
                strings.remove(string);
            }
        }
    }
}
```

**执行结果**

```java
Exception in thread "main" java.util.ConcurrentModificationException
	at java.util.ArrayList$Itr.checkForComodification(ArrayList.java:859)
	at java.util.ArrayList$Itr.next(ArrayList.java:831)
	at main.java.mo.basic.ConcurrentModificationExceptionTest.main(ConcurrentModificationExceptionTest.java:17)
```



## 原因

### 背景

**增强 for 循环**（for (String string : strings)）其实现原理就是 **Iterator** 接口。会调用 Iterator 实现类的两个方法，**hasNext()** 和 **next()**。



首先，查看 ArrayList.remove(Object o)的源码;

```java
public boolean remove(Object o) {
        if (o == null) {
            for (int index = 0; index < size; index++)
                if (elementData[index] == null) {
                    fastRemove(index);
                    return true;
                }
        } else {
            for (int index = 0; index < size; index++)
                if (o.equals(elementData[index])) {
                    fastRemove(index);
                    return true;
                }
        }
        return false;
    }

/*
     * Private remove method that skips bounds checking and does not
     * return the value removed.
     */
    private void fastRemove(int index) {
        modCount++;
        int numMoved = size - index - 1;
        if (numMoved > 0)
            System.arraycopy(elementData, index+1, elementData, index,
                             numMoved);
        elementData[--size] = null; // clear to let GC do its work
    }
```

其中 关键点在于 **modCount（modified count）**   从 **AbstractList** 继承的属性。

``` protected transient int modCount = 0;``` 

**modCount**  --- The number of times this list has been ***structurally modified***. **Structural modifications** are those that change the ***size of the list***, or otherwise perturb（disorder） it in such a fashion that iterations in progress may yield incorrect results.

This field is used by the **iterator** and **list iterator implementation** returned by the iterator and list Iterator methods. If the value of this field changes unexpectedly, **the iterator (or list iterator)** will throw a ConcurrentModificationException in response to the *next, remove, previous, set or add operations*. 

This provides ***fail-fast*** behavior, rather than non-deterministic behavior in the face of concurrent modification during iteration.

modCount 主要是用来记录对 list 的结构改变的操作次数。提供 ***快速失败*** 机制（通过对 modCount 值的校验）。

**可以看到**，在 fastRemove method 中对 modCount 进行了自增操作。



### 分析

增强 for (String string : strings) 在底层实际使用了 Iterator 的 **next() hasNext()** 方法。相当于调用 ArrayList 的 **Iterator<E> iterator()** ，返回 Iterator<E> , 实际返回内部类 private class **Itr implements Iterator<E>** 的对象。

源码如下：

```java
/**
     * An optimized version of AbstractList.Itr
     */
    private class Itr implements Iterator<E> {
        int cursor;       // index of next element to return
        int lastRet = -1; // index of last element returned; -1 if no such
        int expectedModCount = modCount;

        public boolean hasNext() {
            return cursor != size;
        }

        @SuppressWarnings("unchecked")
        public E next() {
            checkForComodification();
            int i = cursor;
            if (i >= size)
                throw new NoSuchElementException();
            Object[] elementData = ArrayList.this.elementData;
            if (i >= elementData.length)
                throw new ConcurrentModificationException();
            cursor = i + 1;
            return (E) elementData[lastRet = i];
        }

        public void remove() {
            if (lastRet < 0)
                throw new IllegalStateException();
            checkForComodification();

            try {
                ArrayList.this.remove(lastRet);
                cursor = lastRet;
                lastRet = -1;
                expectedModCount = modCount;
            } catch (IndexOutOfBoundsException ex) {
                throw new ConcurrentModificationException();
            }
        }

        @Override
        @SuppressWarnings("unchecked")
        public void forEachRemaining(Consumer<? super E> consumer) {
            Objects.requireNonNull(consumer);
            final int size = ArrayList.this.size;
            int i = cursor;
            if (i >= size) {
                return;
            }
            final Object[] elementData = ArrayList.this.elementData;
            if (i >= elementData.length) {
                throw new ConcurrentModificationException();
            }
            while (i != size && modCount == expectedModCount) {
                consumer.accept((E) elementData[i++]);
            }
            // update once at end of iteration to reduce heap write traffic
            cursor = i;
            lastRet = i - 1;
            checkForComodification();
        }

        final void checkForComodification() {
            if (modCount != expectedModCount)
                throw new ConcurrentModificationException();
        }
    }
```

可以看到，**next() 中每次都会调用 checkForComodification()进行 expectedModCount 和 modCount 的比较校验**。当二者值不相同时就会抛出 **ConcurrentModificationException**

在示例中，当调用  strings.remove(string); 时**实际调用 fastRemove modeCount 会自增**。当在 **增强 for** 中**再次调用 next()** 方法时由于 expectedModCount 只会进行一次初始化 ```int expectedModCount = modCount;``` **二者值不相同**，所以抛出了 异常。



### 注意



**删除倒数第二个元素，并不会报ConcurrentModificationException异常**。这是因为：

- 在最后一个元素遍历的时候，经过 Iterator 的 next() 方法，游标 **cursor = i + 1** ，cursor指向了最后一个，比如 size = 4，此时 cursor 为 3。

- 然后执行 remove操作，modCount ++，但是**remove 不会进行 modCount 检查**。**remove 后 size 减1** size = 3。

- 继续进行下一次遍历，首先调用 hasNext() ，此时 **由于 cursor == size = 3，所以 hasNext() 返回false**。不再进行遍历，直接退出，不会抛出异常。

**删除倒数第一个元素，会抛出异常**，因为：

- 在最后一个元素遍历的时候，经过 Iterator 的 next() 方法，游标 **cursor = i + 1** ，cursor指向了最后一个，比如 size = 4，此时 cursor 为 4。

- 然后执行 remove操作，modCount ++，但是**remove 不会进行 modCount 检查**。**remove 后 size 减1** size = 3。

- 继续进行下一次遍历，首先调用 **hasNext()** ，此时 **由于 cursor =4 而 size = 3，所以 hasNext() 返回true**，**继续进行遍历**。
- 然后调用 **next()**  方法获取下一个元素，next() 中首先进行 checkForComodification() 检查。此时由于remove是 modCount ++ 已经和原始值不同，**所以ConcurrentModificationException异常**。





### 设计目的

设计者认为 一个 **Iterator** 作为 ArrayList 的 **操作者**，那它 应该能通过 **Iterator()** 来 操作完整的 ArrayList 数据，当外界ArrayLit发生改变，而又无法通知到 Iterator时，这时将会**引发很多不可确定性**，给语言的使用者、使用目的 带来困扰。 因此设计者仅仅是通过抛出一个 运行时异常，来 **禁止开发者这样调用**。这样**至少保证了程序的功能没有问题**。



## 解决

上述问题的出现是因为 **删除** 和 **遍历**  的**方式不一致** ，导致 modCount 校验失败。

解决方案如下：

1. 都使用 **原始方式** ，**不使用 Iterator** 。需要自己维护 index。
2. 都使用  **Iterator** 
3. 不进行遍历，直接 removeAll
4. 不进行 **更改结构**的 操作，只是遍历。
5. 多线程环境： **加锁**  或者 使用**并发容器 CopyOnWriteA**





### 注意

Iterator 每次都会**返回**一个**新实例对象**，意味着每次返回的 Iterator 都是不同的。也即是说 **expectedModCount** 是**每个线程私有**。

如果**删除的是最后的一个元素**，**不会抛出异常**。因为最后的 **hasNext()** **为 false**，不会调用 next() 方法，也就**不会进行 checkForComodification() 校验**



### 多线程情况

都使用 **Iterator** 进行遍历的情况下，假若此时有**2个线程**，线程1在进行遍历，线程2在进行修改，那么很有可能导致线程2修改后导致 List 中的 modCount 自增了，线程2的expectedModCount也自增了，**但是线程1的expectedModCount没有自增**，此时**线程1遍历**时就会出现 expectedModCount 不等于modCount的情况了，**仍然会抛出** Concurrent Modify Exception 异常

一般有2种**解决办**法：

　　1）在使用iterator迭代的时候使用**synchronized**或者**Lock**进行**同步**；

　　2）使用并发容器**CopyOnWriteArrayList**代替ArrayList



## Transient 关键字

将不需要序列化的属性前添加关键字transient，序列化对象的时候，这个属性就不会被序列化。

一些敏感信息（如密码，银行卡号等），为了安全起见，不希望在**网络操作**（主要涉及到**序列化**操作，本地序列化缓存也适用）中被传输，这些信息对应的变量就可以加上transient关键字。换句话说，这个字段的生命周期**仅存于调用者的内存中**而**不会写到磁盘里持久化**。

1）一旦变量被transient修饰，变量将不再是对象持久化的一部分，该变量内容**在序列化后无法获得访问**。

2）transient关键字**只能修饰变量**，而不能修饰方法和类。注意，本地变量是不能被transient关键字修饰的。变量如果是用户**自定义类**变量，则该类需要**实现 Serializable 接口**。

3）被transient关键字修饰的变量不再能被序列化，一个**静态变量不管是否被transient修饰，均不能被序列化**

静态变量在全局区,本来序列化流里面就没有写入静态变量。JVM查找这个静态变量的值，是从**全局区**查找的，而不是序列化后存放的**磁盘**上。



## Fail-Fast

In systems design, a fail-fast system is one which immediately reports at its interface any condition that is likely to indicate a failure. 

Fail-fast systems are usually designed to **stop normal operation rather than attempt to continue a possibly flawed process**. Such designs often check the system's state at several points in an operation, so any failures can be detected early. The **responsibility** of a fail-fast module is **detecting errors, then letting the next-highest level of the system handle them**.

做系统设计的时候先考虑异常情况，一旦发生异常，直接停止并上报。

通常说的Java中的**fail-fast**机制，默认指的是**Java集合的一种错误检测机制**。当多个线程对部分集合进行结构上的改变的操作时，有可能会产生fail-fast机制，这个时候就会抛出**ConcurrentModificationException**（后文用CME代替）。



### 多线程

多线程下主要有如下两种解决方案：

**方案一**：在遍历过程中所有涉及到改变 modCount 值的地方全部**加上 synchronized** 或者直接**使用 Collections.synchronizedList** （同步，阻塞遍历操作），这样就可以解决。但是不推荐，因为增删造成的同步锁可能会阻塞遍历操作。

**方案二**：使用**CopyOnWriteArrayList**来替换ArrayList。推荐使用该方案。



### Copy-On-Write

CopyOnWriterArrayList所代表的核心概念就是：**任何对array在结构上有所改变的操作（add、remove、clear等），CopyOnWriterArrayList都会copy现有的数据**，再在copy的数据上修改，这样就不会影响COWIterator中的数据了，**修改完成之后改变原有数据的引用**即可。同时这样造成的代价就是产生大量的对象，同时数组的copy也是相当有损耗的。

CopyOnWrite容器是一种**读写分离**的思想，读和写不同的容器。

可以对CopyOnWrite容器**进行并发的读**，当然，这里读到的数据可能不是最新的。因为写时复制的思想是通过**延时更新**的策略来实现数据的**最终一致性**的，并**非强一致性**。



## Fail-Safe

为了避免触发fail-fast机制，导致异常，我们可以使用Java中提供的一些采用了 **fail-safe** 机制的集合类。

这样的集合容器在遍历时**不是直接在集合内容上访问**的，而是先复制原有集合内容，**在拷贝的集合上进行**遍历。

**java.util.concurrent** 包下的容器都是 fail-safe 的，可以在**多线程**下并发使用，并发修改。同时也可以在foreach中进行add/remove.

