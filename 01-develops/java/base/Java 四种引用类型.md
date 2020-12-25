# 四种引用类型

## 简介

**主要是为了更好的进行内存管理而设置的一套机制，简单说就是不同的引用垃圾回收的力度不同。**

![img](.\四种引用类型.jpg)



## 强引用（StrongReference）

**只要引用存在，垃圾回收器永远不会回收**。代码示例

```java
Object obj = new Object();//可直接通过obj取得对应的对象 如 obj.equels(new Object());
```

默认引用类型

obj 对象对后面 new Object 的一个强引用，只有当 obj 引用被释放之后，对象才会被释放掉，这也是我们经常所用到的编码形式。

 

## 软引用（SoftReference）

**非必须引用，内存将要溢出之前进行回收**。代码示例

```java
Object obj = new Object();
SoftReference<Object> sf = new SoftReference<Object>(obj);
obj = null;
sf.get();//有时候会返回null
```


这时候 sf 是对 obj 的一个软引用，通过 sf.get() 方法可以取到这个对象，当然，当这个对象被标记为需要回收的对象时，则返回null；

**软引用可用来实现内存敏感的高速缓存**，在内存足够的情况下直接通过软引用取值，无需从繁忙的真实来源查询数据，提升速度；当内存不足时，自动删除这部分缓存数据，从真正的来源查询这些数据。

软引用可以和一个**引用队列（ReferenceQueue）**联合使用，如果软引用所引用的对象被垃圾回收器回收，Java虚拟机就会把这个软引用加入到与之关联的引用队列中。

 

## 弱引用（WeakReference）

**当发现只有弱引用没有其他引用时回收**。代码示例

```java
Object obj = new Object();
WeakReference<Object> wf = new WeakReference<Object>(obj);
obj = null;
wf.get();//有时候会返回null
wf.isEnQueued();//返回是否被垃圾回收器标记为即将回收的垃圾
```

弱引用是在回收器发现只有弱引用时回收，短时间内通过弱引用取对应的数据，可以取到，当执行过第二次垃圾回收时，将返回null。

**弱引用主要用于监控对象是否已经被 *垃圾回收器*  标记为即将回收的垃圾**，可以通过弱引用的 isEnQueued 方法返回对象是否被垃圾回收器标记。

弱引用可以和一个**引用队列（ReferenceQueue）**联合使用，如果弱引用所引用的对象被垃圾回收，Java虚拟机就会把这个弱引用加入到与之关联的引用队列中。

弱引用与软引用的**区别**在于：

只具有弱引用的对象拥有更短暂的生命周期。在垃圾回收器线程扫描它所管辖的内存区域的过程中，一旦**发现了只具有弱引用的对象**，不管当前内存空间足够与否，**都会回收它的内存**。不过，由于垃圾回收器是一个优先级很低的线程，因此不一定会很快发现那些只具有弱引用的对象。

 

## 虚引用（PhantomReference）

**垃圾回收时回收**，无法通过引用取到对象值。代码示例

```java
Object obj = new Object();
PhantomReference<Object> pf = new PhantomReference<Object>(obj);
obj=null;
pf.get();//永远返回null
pf.isEnQueued();//返回是否从内存中已经删除
```

虚引用是每次垃圾回收的时候都会被回收，通过虚引用的get方法永远获取到的数据为null，因此也被成为幽灵引用。

**虚引用主要用于检测对象是否已经从内存中删除。**

虚引用与软引用和弱引用的一个区别在于：

**虚引用必须和引用队列 （ReferenceQueue）联合使用**。当垃圾回收器准备回收一个对象时，如果发现它还有虚引用，就会在回收对象的内存之前，把这个虚引用加入到与之 关联的引用队列中。



## 用软引用构建敏感数据缓存

### 为什么需要使用软引用

首先，我们看一个雇员信息查询系统的实例。

我们将使用一个 Java 语言实现的**雇员信息查询系统**查询存储在磁盘文件或者数据库中的雇员人事档案信息。

作为一个用户，我们完全有可能需要**回头去查看几分钟甚至几秒钟前查看过的雇员档案信息**(同样，我们在浏览WEB页面的时候也经常会使用“后退”按钮)。这时我们通常会有两种程序实现方式:

- 一种是把过去查看过的雇员**信息保存在内存中**，每一个存储了雇员档案信息的Java对象的生命周期贯穿整个应用程序始终;
- 另一种是当用户开始查看其他雇员的档案信息的时候，把存储了当前所查看的雇员档案信息的 **Java 对象结束引用**，使得垃圾收集线程可以回收其所占用的内存空间，当用户再次需要浏览该雇员的档案信息的时候，**重新构建该雇员的信息**。

很显然，**第一种实现方法将造成大量的内存浪费**

第二种实现的缺陷在于当垃圾收集线程**还没有进行垃圾收集**，包含雇员档案信息的对象此时仍然完好地保存在内存中，应用程序**也要重新构建一个对象**。

我们知道，**访问磁盘文件**、**访问网络资源**、**查询数据库**等操作都是影响应用程序执行性能的重要因素，如果能**重新获取那些尚未被回收的Java对象的引用**，必将减少不必要的访问，大大提高程序的运行速度。



### 使用软引用

SoftReference的**特点**是它的一个实例保存对一个Java对象的软引用，该**软引用的存在不妨碍垃圾收集线程对该Java对象的回收**。

一旦 SoftReference保 存了对一个Java对象的软引用后，在垃圾线程对这个Java对象**回收前，SoftReference类的 get() 方法返回 Java 对象的强引用**。另外，一旦垃圾线程回收该Java对象之后，**get()方法将返回null**。
看下面代码:

```java
MyObject aRef = new MyObject();
SoftReference aSoftRef=new SoftReference(aRef); 
```

此时，对于这个 **MyObject 对象，有两个引用路径**：一个是来自SoftReference对象的软引用，一个来自变量aReference的强引用。

此时 MyObject 对象是强引用对象。随即，我们可以结束 aReference 对这个MyObject实例的强引用:

```java
aRef = null;
```

此时 MyObject 对象成为了**软引用对象**。

如果垃圾收集线程进行内存垃圾收集，并不会因为有一个 SoftReference 对该对象的引用而始终保留该对象。

Java虚拟机的垃圾收集线程对**软引用对象和其他一般Java对象进行了区别对待**：

软可及对象的清理是由垃圾收集线程**根据其特定算法按照内存需求决定**的。也就是说，垃圾收集线程会在虚拟机抛出 OutOfMemoryError 之前回收软引用对象，而且 JVM 会尽可能**优先回收长时间闲置不用的软引用对象**，对那些刚刚构建的或刚刚使用过的“新”软可反对象会被虚拟机尽可能保留。在回收这些对象之前，我们可以通过:

```java
MyObject anotherRef=(MyObject)aSoftRef.get(); 
```

**重新获得对该实例的强引用**。而回收之后，调用get()方法就只能得到null了。



##  ReferenceQueue清除多余引用

以 SoftReference  为例：

作为一个Java对象，SoftReference 对象除了具有保存软引用的特殊性之外，也具有Java对象的一般性。

所以，当**软引用对象被回收**之后，SoftReference 对象的 get() 方法返回null，**此时 SoftReference 对象已经不再具有存在的价值**，需要一个适当的清除机制，**避免大量SoftReference对象带来的内存泄漏**。

在 java.lang.ref 包里还提供了ReferenceQueue。如果在创建SoftReference对象的时候，**使用一个 ReferenceQueue 对象作为参数提供给 SoftReference 的构造方法**，如:

```java
ReferenceQueue queue = new ReferenceQueue();
SoftReference ref=new SoftReference(aMyObject, queue); 
```



那么当 **SoftReference 所软引用的 aMyOhject 被垃圾收集器回收的同时，ref 所强引用的 SoftReference 对象被列入ReferenceQueue。**

也就是说，ReferenceQueue 中保存的对象是 Reference 对象，而且是已经失去了它所软引用的对象的Reference对象。

另外从ReferenceQueue这个名字也可以看出，**它是一个队列**，当我们调用它的poll()方法的时候，如果这个队列中不是空队列，那么将返回队列前面的那个 Reference 对象。
在任何时候，我们都可以调用ReferenceQueue的 **poll() 方法来检查是否有它所关心的非强引用对象被回收。**

如果队列为空，将返回一个null,否则该方法返回队列中前面的一个Reference对象。**利用这个方法，我们可以检查哪个 SoftReference 所软引用的对象已经被回收。我们可以把这些失去所软引用的对象的SoftReference对象清除掉**。常用的方式为:

```java
SoftReference ref = null;
while ((ref = (EmployeeRef) q.poll()) != null) {
// 清除ref
}
```



