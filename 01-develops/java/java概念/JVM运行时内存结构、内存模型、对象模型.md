# JVM 运行时内存结构

## 结构简介

java代码运行在 JVM 上，JVM在执行java程序过程中会把管理的内存划分为具有不同用处的若干数据区域。有些区域随着JVM进程启动而建立，有些依赖用户线程的启动和结束而建立和销毁。在《java虚拟机规范(Java SE 8)》中描述的 JVM 运行时内存区域结构如下：

![image-20201214145221567](.\JVM内存结构.png)

### 注意点

- 以上是 java 虚拟机规范，不同的虚拟机实现可能会有不同；
- 规范定义的方法区只是一种概念上的区域，并说明了应该有什么功能，但是没有定义这个区域到底在何处。不同的 JVM 实现有一定的自由。
- 不同版本的方法区所处位置不同，图中为逻辑区域，并不是绝对的物理区域。
- 运行时常量池用于存放编译器生成的各种字面量和符号应用。但java并不要求常量一定要求常量在编译器产生，在运行期间，String.intern 也会把新的常量放入内存池。
- 除了上面介绍的 JVM 运行时内存外，还有一块内存区域可使用–直接内存。JVM 规范并没有定义该区域，因此，其并不由JVM管理，其是利用 native 方法直接在 heap 外申请内存区域。
- 堆和栈的数据划分也不绝对。

## 划分

### 程序计数器PC

程序计数器PC，当前线程所执行的字节码行号指示器。每个线程都有自己计数器，是私有内存空间，该区域是整个内存中较小的一块。

当线程正在执行一个Java方法时，PC计数器记录的是正在执行的虚拟机字节码的地址；当线程正在执行的一个Native方法时，PC计数器则为空（Undefined）。



### 虚拟机栈

**虚拟机栈，生命周期与线程相同**，是Java方法执行的内存模型。每个方法(不包含native方法)执行的同时都会创建一个栈帧结构，**方法执行过程，对应着虚拟机栈的入栈到出栈的过程**。

**栈帧(Stack Frame)结构**

栈帧是用于支持虚拟机进行方法执行的数据结构，是属性运行时数据区的虚拟机栈的栈元素。 栈帧包括：

1. 局部变量表 (locals大小，编译期确定)，一组变量存储空间， 容量以slot为最小单位。
2. 操作栈(stack大小，编译期确定)，操作栈元素的数据类型必须与字节码指令序列严格匹配
3. **动态连接， 指向运行时常量池中该栈帧所属方法的引用，为了 动态连接使用**。
   - 前面的解析过程其实是静态解析；
   - 对于运行期转化为直接引用，称为动态解析。
4. **方法返回地址**
   - 正常退出，执行引擎遇到方法返回的字节码，将返回值传递给调用者
   - 异常退出，遇到Exception,并且方法未捕捉异常，那么不会有任何返回值。
5. 额外附加信息，虚拟机规范没有明确规定，由具体虚拟机实现。

**异常(Exception)**

Java虚拟机规范规定该区域有两种异常：

- StackOverFlowError：当线程请求栈深度超出虚拟机栈所允许的深度时抛出
- OutOfMemoryError：当Java虚拟机动态扩展到无法申请足够内存时抛出



### 本地方法栈

本地方法栈则为虚拟机使用到的**Native方法提供内存空间**，而前面讲的虚拟机栈是为Java方法提供内存空间。有些虚拟机的实现直接把本地方法栈和虚拟机栈合二为一，比如非常典型的Sun HotSpot虚拟机。

**异常(Exception)**：Java虚拟机规范规定该区域可抛出StackOverFlowError和OutOfMemoryError。



### Java堆

Java堆，是Java虚拟机管理的最大的一块内存，也是GC的主战场，**里面存放的是几乎所有的对象实例和数组数据**。JIT编译器有栈上分配、标量替换等优化技术的实现导致部分对象实例数据不存在Java堆，而是栈内存。

- 从内存回收角度，Java堆被分为新生代和老年代；这样划分的好处是为了更快的回收内存；
- 从内存分配角度，Java堆可以划分出线程私有的分配缓冲区(Thread Local Allocation Buffer,TLAB)；这样划分的好处是为了更快的分配内存；

**对象创建的过程是在堆上分配着实例对象**，那么对象实例的具体结构如下

![java_object](.\java_object.png)

对于填充数据不是一定存在的，仅仅是为了字节对齐。HotSpot VM的自动内存管理要求对象起始地址必须是8字节的整数倍。对象头本身是8的倍数，当对象的实例数据不是8的倍数，便需要填充数据来保证8字节的对齐。该功能类似于高速缓存行的对齐。

另外，关于在堆上内存分配是并发进行的，虚拟机采用CAS加失败重试保证原子操作，或者是采用每个线程预先分配TLAB内存.

**异常(Exception)**：Java虚拟机规范规定该区域可抛出OutOfMemoryError。



### 方法区

方法区主要存放的是已被虚拟机加载的类信息、常量、静态变量、编译器编译后的代码等数据。GC在该区域出现的比较少。

**异常(Exception)**：Java虚拟机规范规定该区域可抛出OutOfMemoryError。



###  运行时常量池

运行时常量池也是方法区的一部分，用于存放编译器生成的各种字面量和符号引用。运行时常量池除了编译期产生的Class文件的常量池，还可以在运行期间，将新的常量加入常量池，比较常见的是String类的intern()方法。

- 字面量：与Java语言层面的常量概念相近，包含文本字符串、声明为final的常量值等。
- 符号引用：编译语言层面的概念，包括以下3类：
  - 类和接口的全限定名
  - 字段的名称和描述符
  - 方法的名称和描述符

但是该区域不会抛出OutOfMemoryError异常。



# Java 内存模型

## JMM(Java  Memory Model) 由来

从内存模型可以看到，java heap 和 方法区是多线程共享的区域，也就是多个线程可以操作保存在heap或者方法区的同一个数据，这就是常说的 “**Java的线程间通过共享内存通信**”

JMM 不像 JVM 内存结构一样是真实存在的，JMM 是一组规则或者说规范，在 [**JSR-133 Java Memory Model and Thread Specification**](https://download.oracle.com/otndocs/jcp/memory_model-1.0-pfd-spec-oth-JSpec/) 定义。

```A memory model describes, given a program and an execution trace of that program, whether the execution trace is a legal execution of the rogram. Java’s memory model works by examining each read in an execution trace and checking that the write observed by that read is valid```

也就是说 JMM 描述了一个给定程序执行过程是否合法。JMM 检查程序执行中每个写操作是否对读操作可见。



Java Memory Model(Java内存模型)， 围绕着在**并发过程中如何处理可见性、原子性、有序性这三个特性而建立的模型**。

JMM**定义了程序中各个共享变量的访问规则**,即在虚拟机中将变量存储到内存和从内存读取变量这样的底层细节。 JMM 屏蔽各种硬件和操作系统的内存访问差异,以实现让Java程序**在各种平台下达到一致的内存访问效果**。



## java 并发编程

### 缓存一致性

在CPU和主存之间增加缓存，在多线程场景下就可能存在**缓存一致性问题**：在多核CPU中，每个核的自己的缓存中，关于同一个数据的缓存内容可能不一致。



### 处理器优化和编译器指令重排

为了使处理器内部的运算单元能够尽量的被充分利用，**处理器可能会对输入代码进行乱序执行处理**。这就是**处理器优化**。

除了现在很多流行的处理器会对代码进行优化乱序处理，很多编程语言的编译器也会有类似的优化，比如Java虚拟机的即时编译器（JIT）也会做**指令重排**。



### Java 并发编程

并发编程，为了保证数据的安全，需要满足以下三个特性：

**原子性**是指在一个操作中就是cpu不可以在中途暂停然后再调度，既不被中断操作，要不执行完成，要不就不执行。

**可见性**是指当多个线程访问同一个变量时，一个线程修改了这个变量的值，其他线程能够立即看得到修改的值。

**有序性**即程序执行的顺序按照代码的先后顺序执行。



**缓存一致性问题**其实就是**可见性问题**。而**处理器优化**是可以导致**原子性问题**的。**指令重排**即会导致**有序性问题**。



### JMM 实际作用

Java内存模型规定了**所有的变量都存储在主内存**中，每条线程还有自己的工作内存，**线程的工作内存中保存了该线程中是用到的变量的主内存副本拷贝**，线程对变量的所有操作都必须在工作内存中进行，而**不能直接读写主内存。**

不同的线程之间也无法直接访问对方工作内存中的变量，线程间变量的传递均需要自己的工作内存和主存之间进行数据同步进行。

而 JMM 就作用于**工作内存和主存之间数据同步过程**。他规定了如何做数据同步以及什么时候做数据同步。



**综上，JMM是一种规范，目的是解决由于多线程通过共享内存进行通信时，存在的本地内存数据不一致、编译器会对代码指令重排序、处理器会对代码乱序执行等带来的问题。**



### JMM 实现

**Java内存模型，除了定义了一套规范，还提供了一系列原语，封装了底层实现后，供开发者直接使用。**

如`volatile`、`synchronized`、`final`、`concurren`包



#### 原子性

在Java中，为了保证原子性，提供了两个高级的字节码指令`monitorenter`和`monitorexit`。在[synchronized的实现原理](http://www.hollischuang.com/archives/1883)文章中，介绍过，这两个字节码，在Java中对应的关键字就是`synchronized`。

因此，在Java中可以使用`synchronized`来保证方法和代码块内的操作是原子性的。



#### 可见性

Java内存模型是通过在变量修改后将新值同步回主内存，在变量读取前从主内存刷新变量值的这种依赖主内存作为传递媒介的方式来实现的。

Java中的`volatile`关键字提供了一个功能，那就是被其修饰的变量在被修改后可以立即同步到主内存，被其修饰的变量在每次是用之前都从主内存刷新。因此，可以使用`volatile`来保证多线程操作时变量的可见性。

除了`volatile`，Java中的`synchronized`和`final`两个关键字也可以实现可见性。只不过实现方式不同，这里不再展开了。



#### 有序性

在Java中，可以使用`synchronized`和`volatile`来保证多线程之间操作的有序性。实现方式有所区别：

`volatile`关键字会禁止指令重排。`synchronized`关键字保证同一时刻只允许一条线程操作。



`synchronized`关键字可以同时满足以上三种特性，这其实也是很多人滥用`synchronized`的原因。**但是`synchronized`是比较影响性能的**，虽然编译器提供了很多锁优化技术，但是也不建议过度使用。



# Java 对象模型

**Java 对象模型 描述了 Java对象在JVM中表现形式**。

在内存中，一个**Java对象包含三部分：对象头、实例数据和对齐填充**。而对象头中又包含锁状态标志、线程持有的锁等标志。

## **oop-klass model**

**OOP（Ordinary Object Pointer）指的是普通对象指针，而Klass用来描述对象实例的具体类型**。

oop体系:

```c
//定义了oops共同基类
typedef class   oopDesc*                     oop;
//表示一个Java类型实例
typedef class   instanceOopDesc*            instanceOop;
//表示一个Java方法
typedef class   methodOopDesc*              methodOop;
//表示一个Java方法中的不变信息
typedef class   constMethodOopDesc*          constMethodOop;
//记录性能信息的数据结构
typedef class   methodDataOopDesc*            methodDataOop;
//定义了数组OOPS的抽象基类
typedef class   arrayOopDesc*                arrayOop;
//表示持有一个OOPS数组
typedef class   objArrayOopDesc*            objArrayOop;
//表示容纳基本类型的数组
typedef class   typeArrayOopDesc*            typeArrayOop;
//表示在Class文件中描述的常量池
typedef class   constantPoolOopDesc*         constantPoolOop;
//常量池告诉缓存
typedef class   constantPoolCacheOopDesc*  constantPoolCacheOop;
//描述一个与Java类对等的C++类
typedef class   klassOopDesc*           klassOop;
//表示对象头
typedef class   markOopDesc*         markOop;
```

如上面代码所示, oops模块包含多个子模块, 每个子模块对应一个类型, 每一个类型的oop都代表一个在JVM内部使用的特定对象的类型。其中有一个变量oop的类型oopDesc是oops模块的共同基类型。而oopDesc类型又包含instanceOopDesc (类实例)、arrayOopDesc (数组)等子类类型。其中instanceOopDesc 中主要包含以下几部分数据：markOop _mark和union _metadata 以及一些不同类型的 field。

**在java程序运行过程中, 每创建一个新的java对象, 在JVM内部就会相应的创建一个对应类型的oop对象来表示该java对象**。而在HotSpot虚拟机中, 对象在内存中包含三块区域: 对象头、实例数据和对齐填充。其中对象头包含两部分内容：_mark和_metadata，而实例数据则保存在oopDesc中定义的各种field中。

**_mark:**

**_mark这一部分用于存储对象自身的运行时数据**, 如哈希码、GC分代年龄、锁状态标志、线程持有的锁、偏向线程ID、偏向时间戳等, 这部分数据的长度在32位和64位的虚拟机(未开启压缩指针)中分别为32bit和64bit, 官方称它为 "Mark Word"。对象需要存储的运行时数据很多, 其实已经超出了32位和64位Bitmap结构所能记录的限度, 但是对象头信息是与对象自身定义的数据无关的额外存储成本, 考虑到虚拟机的空间效率, Mark Word被设计成一个非固定的数据结构以便在极小的空间内存储尽量多的信息, 它会根据对象的状态复用自己的存储空间。 

**_metadata:**

**_metadata这一部分是类型指针, 即对象指向它的类元数据的指针, 虚拟机通过这个指针来确定这个对象是哪个类的实例**。并不是所有的虚拟机实现都必须在对象数据上保留类型指针, 换句话说查找对象的元数据信息并不一定要经过对象本身, 其取决于虚拟机实现的对象访问方式。目前主流的访问方式有使用句柄和直接指针两种, 两者方式的不同这里先暂不做介绍。另外, 如果对象是一个Java数组, 那么在对象头中还必须有一块用于记录数组长度的数据, 因为虚拟机可以通过普通java对象的元数据信息确定java对象的大小, 但是从数组的元数据中却无法确定数组的大小。 

## **klass**

Klass体系:

```java
//klassOop的一部分，用来描述语言层的类型
class  Klass;
//在虚拟机层面描述一个Java类
class   instanceKlass;
//专有instantKlass，表示java.lang.Class的Klass
class     instanceMirrorKlass;
//专有instantKlass，表示java.lang.ref.Reference的子类的Klass
class     instanceRefKlass;
//表示methodOop的Klass
class   methodKlass;
//表示constMethodOop的Klass
class   constMethodKlass;
//表示methodDataOop的Klass
class   methodDataKlass;
//作为klass链的端点，klassKlass的Klass就是它自身
class   klassKlass;
//表示instanceKlass的Klass
class     instanceKlassKlass;
//表示arrayKlass的Klass
class     arrayKlassKlass;
//表示objArrayKlass的Klass
class       objArrayKlassKlass;
//表示typeArrayKlass的Klass
class       typeArrayKlassKlass;
//表示array类型的抽象基类
class   arrayKlass;
//表示objArrayOop的Klass
class     objArrayKlass;
//表示typeArrayOop的Klass
class     typeArrayKlass;
//表示constantPoolOop的Klass
class   constantPoolKlass;
//表示constantPoolCacheOop的Klass
class   constantPoolCacheKlass;
```

和oopDesc是其他oop类型的父类一样，Klass类是其他klass类型的父类。

Klass向JVM提供两个功能:

- 实现语言层面的Java类（在Klass基类中已经实现）
- 实现Java对象的分发功能（由Klass的子类提供虚函数实现）

HotSpot JVM的设计者因为不想让每一个对象中都含有一个虚函数表, 所以设计了oop-klass模型, 将对象一分为二, 分为klass和oop。其中**oop主要用于表示对象的实例数据, 所以不含有任何虚函数。而klass为了实现虚函数多态, 所以提供了虚函数表**。所以，关于Java的多态，其实也有c++虚函数的影子在。

## **InstanceClass**

**JVM在运行时，需要一种用来标识Java内部类型的机制**。在HotSpot中的解决方案是：**为每一个已加载的Java类创建一个InstanceClass对象，用来在JVM层表示Java类**。

InstanceClass内部结构:

```java
//类拥有的方法列表
objArrayOop     _methods;
//描述方法顺序
typeArrayOop    _method_ordering;
//实现的接口
objArrayOop     _local_interfaces;
//继承的接口
objArrayOop     _transitive_interfaces;
//域
typeArrayOop    _fields;
//常量
constantPoolOop _constants;
//类加载器
oop             _class_loader;
//protected域
oop             _protection_domain;
    ....
```

在JVM中，对象在内存中的基本存在形式就是oop。那么，对象所属的类，在JVM中也是一种对象，因此它们实际上也会被组织成一种oop，即klassOop。同样的，对于klassOop，也有对应的一个klass来描述，它就是klassKlass，也是klass的一个子类。klassKlass作为oop的klass链的端点, 它的klass就是它自身。

## **内存存储**

我们首先来看看下面这段代码的存储结构。

```java
class Model
{
    public static int a = 1;
    public int b;

    public Model(int b) {
        this.b = b;
    }
}

public static void main(String[] args) {
    int c = 10;
    Model modelA = new Model(2);
    Model modelB = new Model(3);
}
```

存储结构如下:

![img](.\OOP-Klass模型.png)

由此我们能得出结论: **对象的实例（instantOopDesc)保存在堆上，对象的元数据（instantKlass）保存在方法区，对象的引用保存在栈上**。

## **小结**

在JVM加载java类的时候, JVM会给这个类**创建一个instanceKlass并保存在方法区,** 用来在JVM层表示该java类。

当我们使用**new关键字创建一个对象时, JVM会创建一个instanceOopDesc对象**, 这个对象包含了对象头和元数据两部分信息。对象头中有一些运行时数据, 其中就包括和多线程有关的锁的信息。而元数据维护的则是指向对象所属的类的InstanceKlass的指针。