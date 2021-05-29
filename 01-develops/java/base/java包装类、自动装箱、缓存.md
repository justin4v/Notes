# 包装类

## 基本数据类型

基本类型，或者叫做**内置类型**，是 Java 中不同于类(Class)的特殊类型。

**Java 是一种强类型语言，编译器会进行类型检查**，第一次声明变量必须**说明数据类型**，第一次变量赋值称为变量的初始化。

Java 基本类型共有八种，基本类型可以分为三类：

> 字符类型 `char`
>
> 布尔类型 `boolean`
>
> 数值类型 `byte`、`short`、`int`、`long`、`float`、`double`。

数值类型又可以分为整数类型 `byte`、`short`、`int`、`long` 和浮点数类型 `float`、`double`。

**Java 中的数值类型都是有符号的**，它们的**取值范围是固定的**，不会随着机器硬件环境或者操作系统的改变而改变。

实际上，Java 中还存在**另外一种基本类型** `void`，它也有对应的**包装类 `java.lang.Void`**，不过我们无法直接对它们进行操作。



### 基本数据类型优点

我们都知道在 Java 语言中，**`new` 一个对象是存储在堆里**的，**通过栈中的引用来使用这些对象**；所以，对象本身来说是比较消耗资源的。

对于经常用到的类型，如 int 等，如果我们每次使用这种变量的时候都需要 new 一个 Java 对象的话，就会比较笨重。所以，和 C++ 一样，Java 提供了**基本数据类型**，变量不需要使用 new 创建，他们不会在堆上创建，而是**直接在栈内存中存储**，因此会**更加高效，性能更好**。



### 整型的取值范围

Java 中的整型主要包含`byte`、`short`、`int`和`long`这四种，表示的数字范围也是从小到大的，之所以表示范围不同主要和他们存储数据时所占的字节数有关。

- byte：byte 用 **1 个字节**来存储，范围为 -128(-2^7) 到 127(2^7-1)，在变量初始化的时候，byte 类型的默认值为 0。
- short：short 用 **2 个字节**存储，范围为 -32,768(-2^15) 到 32,767(2^15-1)，在变量初始化的时候，short 类型的默认值为 0，一般情况下，因为 Java 本身转型的原因，可以直接写为 0。
- int：int 用 **4 个字节**存储，范围为 -2,147,483,648(-2^31) 到 2,147,483,647(2^31-1)，在变量初始化的时候，int 类型的默认值为 0。
- long：long 用 **8 个字节**存储，范围为 -9,223,372,036,854,775,808(-2^63) 到 9,223,372,036, 854,775,807(2^63-1)，在变量初始化的时候，long 类型的默认值为 0L 或 0l，也可直接写为 0。

**Java 中每种数据类型的长度是固定的，不会随着硬件或者操作系统的不同而变化**，这也是为了 Java 能够**跨平台**运行而设计的特性之一。



### 溢出

上面说过了，整型中，每个类型都有一定的表示范围，但是，在程序中有些计算会导致超出表示范围，即溢出。如以下代码：

```java
    int i = Integer.MAX_VALUE;
    int j = Integer.MAX_VALUE;

    int k = i + j;
    System.out.println("i (" + i + ") + j (" + j + ") = k (" + k + ")");
```

输出结果：i (2147483647) + j (2147483647) = k (-2)

**不管是基本数据类型还是包装类型，都会发生溢出，溢出的时候并不会抛异常，也没有任何提示**。所以，在程序中，使用同类型的数据进行运算的时候，**一定要注意数据溢出的问题。**



### 为什么需要包装类

因为 **Java 是一种面向对象语言**，很多地方都需要**使用对象而不是基本数据类型**。比如，我们是无法**将 int 、double 等类型放进集合类**去的。因为**集合的容器要求元素是 Object 类型（java中 当且仅当继承了Object 才能称之为对象）**。

为了让基本类型也具有对象的特征，就出现了包装类型，它相当于将基本类型“**包装起来**”，使得它具有了对象的性质，并且为其添加了属性和方法，丰富了基本类型的操作。



## 自动拆箱与自动装箱

在 Java SE5 中，为了减少开发人员的工作，Java 提供了**自动拆箱与自动装箱**功能。

**自动装箱**: 就是将基本数据类型自动转换成对应的包装类。

**自动拆箱**：就是将包装类自动转换成对应的基本数据类型。



## 自动装箱与自动拆箱的实现原理

我们有以下自动拆装箱的代码：

```java
    public static  void main(String[]args){
        Integer integer=1; //装箱
        int i=integer; //拆箱
    }
```

对以上代码进行反编译后可以得到以下代码：

```java
    public static  void main(String[]args){
        Integer integer=Integer.valueOf(1);
        int i=integer.intValue();
    }
```

从上面反编译后的代码可以看出，int 的**自动装箱都是通过 `Integer.valueOf()` 方法来实现**的，Integer 的**自动拆箱都是通过 `integer.intValue` 来实现**的。

如果读者感兴趣，可以试着将八种类型都反编译一遍 ，你会发现以下规律：

> **自动装箱都是通过包装类的 `valueOf()` 方法来实现的.自动拆箱都是通过包装类对象的 `xxxValue()` 来实现的。**



## 使用包装类还是基础类型

**对象的默认值是`null`，boolean基本数据类型的默认值是`false`** 

使用包装类，没有赋值的对象**默认是null**，在使用时会**抛出NPE**，以阻止继续进行操作。

基本类型没有赋值**默认是基本类型的“零值”**，如 0，所以可以正常运行，但是**会得到意想不到的结果**，这不是我们期望的。

所以，**POJO和RPC中一律要使用包装类型**



### 阿里巴巴开发规范

8. 关于基本数据类型与包装数据类型的使用标准如下：
1 ） 【强制】所有的 POJO 类属性必须使用包装数据类型。
2 ） 【强制】 RPC 方法的返回值和参数必须使用包装数据类型。
3 ） 【推荐】所有的局部变量使用基本数据类型。
说明： POJO 类属性没有初值是提醒使用者在需要使用时，必须自己显式地进行赋值，**任何NPE 问题，或者入库检查，都由使用者来保证**。
正例：数据库的查询结果可能是 null ，因为自动拆箱，用基本数据类型接收有 NPE 风险。
反例：比如显示成交总额涨跌情况，即正负 x %， x 为基本数据类型，调用的 RPC 服务，调用不成功时，返回的是默认值，页面显示为 0%，这是不合理的，应该显示成中划线。所以包装数据类型的 null 值，能够表示额外的信息，如：远程调用失败，异常退出



## 其他

布尔类型的变量，到底应该是用 success 还是 isSuccess 来给属性变量命名呢？

有如下规定：

**POJO中布尔类型的变量一律不加 is 前缀**

在IDEA中，为变量生成方法，有如下规律：

- **基本类型自动生成的getter和setter方法，名称都是`isXXX()`和`setXXX()`形式的**。
- **包装类型自动生成的getter和setter方法，名称都是`getXXX()`和`setXXX()`形式的**。



### **Java Bean中关于setter/getter的规范**

关于Java Bean中的getter/setter方法的定义其实是有明确的规定的，根据[JavaBeans(TM) Specification](https://download.oracle.com/otndocs/jcp/7224-javabeans-1.01-fr-spec-oth-JSpec/)规定，如果是**普通的参数propertyName**，要以以下方式定义其setter/getter：

```java
public <PropertyType> get<PropertyName>();
public void set<PropertyName>(<PropertyType> a);
```

但是，**布尔类型**的变量 propertyName 则是单独定义的：

```java
public boolean is<PropertyName>();
public void set<PropertyName>(boolean m);
```

变量名为isSuccess，如果严格按照规范定义的话，他的getter方法应该叫isIsSuccess。但是很多IDE都会**默认生成为isSuccess**。

那这样做会带来什么问题呢。

在一般情况下，其实是没有影响的。但是有一种特殊情况就会有问题，**那就是发生序列化的时候**



### 序列化

**fastjson**和**jackson**在把对象序列化成json字符串的时候，是通过**反射遍历出该类中的所有getter方法**，得到getHollis和isSuccess，然后**根据JavaBeans规则**，他会认为这是两个属性hollis和success的值。直接序列化成json:{"hollis":"hollischuang","success":true}

但是**Gson**并不是这么做的，他是通过**反射遍历该类中的所有属性，并把其值序列化成json:{"isSuccess":true}**

可以看到，由于**不同的序列化工具**，在进行序列化的时候使用到的策略是不一样的，所以，对于同一个类的同一个对象的序列化**结果可能是不同**的。 **这样就可能导致难以预料的结果。**



所以，**在定义POJO中的布尔类型的变量时，不要使用is前缀！**



# Java缓存

在Java 5中，在Integer的操作上引入了一个新功能来**节省内存和提高性能**。整型对象通过使用相同的对象引用实现了缓存和重用



## 整数型 Integer

适用于整数值**区间-128 至 +127**。

只适用于**自动装箱**。使用**构造函数创建对象不适用**。

### 自动装箱

Java的编译器把**基本数据类型自动转换成封装类对象**的过程叫做`自动装箱`，相当于**使用`valueOf`方法**。

例如：

```java
Integer a = 10; //this is autoboxing 自动装箱
Integer b = Integer.valueOf(10); //under the hood 实际机制
```



### 源码

**Java build 1.8.0_77-b03** 中 valueOf 源码如下：

```java
/**
 * Returns an {@code Integer} instance representing the specified
 * {@code int} value.  If a new {@code Integer} instance is not
 * required, this method should generally be used in preference to
 * the constructor {@link #Integer(int)}, as this method is likely
 * to yield significantly better space and time performance by
 * caching frequently requested values.
 *
 * This method will always cache values in the range -128 to 127,
 * inclusive, and may cache other values outside of this range.
 *
 * @param  i an {@code int} value.
 * @return an {@code Integer} instance representing {@code i}.
 * @since  1.5
 */
public static Integer valueOf(int i) {
    if (i >= IntegerCache.low && i <= IntegerCache.high)
        return IntegerCache.cache[i + (-IntegerCache.low)];
    return new Integer(i);
}
```

可以看到其中使用了 **缓存** 。IntegerCache 源码如下：

```java
/**
 * Cache to support the object identity semantics of autoboxing for values between
 * -128 and 127 (inclusive) as required by JLS.
 *
 * The cache is initialized on first usage.  The size of the cache
 * may be controlled by the {@code -XX:AutoBoxCacheMax=<size>} option.
 * During VM initialization, java.lang.Integer.IntegerCache.high property
 * may be set and saved in the private system properties in the
 * sun.misc.VM class.
 */

private static class IntegerCache {
    static final int low = -128;
    static final int high;
    static final Integer cache[];

    static {
        // high value may be configured by property
        int h = 127;
        String integerCacheHighPropValue =
            sun.misc.VM.getSavedProperty("java.lang.Integer.IntegerCache.high");
        if (integerCacheHighPropValue != null) {
            try {
                int i = parseInt(integerCacheHighPropValue);
                i = Math.max(i, 127);
                // Maximum array size is Integer.MAX_VALUE
                h = Math.min(i, Integer.MAX_VALUE - (-low) -1);
            } catch( NumberFormatException nfe) {
                // If the property cannot be parsed into an int, ignore it.
            }
        }
        high = h;

        cache = new Integer[(high - low) + 1];
        int j = low;
        for(int k = 0; k < cache.length; k++)
            cache[k] = new Integer(j++);

        // range [-128, 127] must be interned (JLS7 5.1.7)
        assert IntegerCache.high >= 127;
    }
    private IntegerCache() {}
}
```

可以在 java doc 中看到，该机制主要是为了遵循 **JLS** 规范而设计的，同时也可以节省内存和提高性能。

## JLS

在[Boxing Conversion](http://docs.oracle.com/javase/specs/jls/se8/html/jls-5.html#jls-5.1.7)部分的**Java语言规范**(JLS （[Java® Language Specification](https://docs.oracle.com/javase/specs/jls/se8/html/index.html)）)规定如下：

如果一个变量p的值是：

> -128至127之间的整数(§3.10.1)
>
> true 和 false的布尔值 (§3.10.3)
>
> ‘\u0000’至 ‘\u007f’之间的字符(§3.10.4)

中时，将p**包装成a和b两个对象时**，可以**直接使用a==b判断a和b的值是否相等**。

在具体实现上，就是上文所述的缓存。



## 其他缓存对象

这种缓存行为**不仅适用于Integer对象**。针对**所有的整数类型的类都有类似的缓存机制**。

> 有ByteCache用于缓存Byte对象
>
> 有ShortCache用于缓存Short对象
>
> 有LongCache用于缓存Long对象
>
> 有CharacterCache用于缓存Character对象

`Byte`, `Short`, `Long`有**固定范围: -128 到 127**。对于`Character`, **范围是 0 到 127**。

**除了`Integer`以外，这个范围都不能改变。**



