# T 和 Object 转换

## 基本类型

### T转Object

基本类型及其包装类型。如Integer Long Double Striing等

1. **Object是所有类的子类**
2. **java中类型提升是自动完成的**

所以，所有类转换为Object都是自动（隐式）完成的

### Object转T

Obejct转T 一般有如下几种方案

1. 强制类型转换，(T) Object
2. 使用包装类中的 valueOf 方法。如 String.valueOf(Object)

**注意：** 在第一种方案中需要保证 Object 确实是 T 类型。否则会报错 ClassCastException。在第二种方案中可以注意一下 不同包装类中 valueOf 方法对于空值的处理



## Collection<T> 和 Map<K,V>

### 转 Object

由于 Collection<Object> 并不是 Collection<String> 的父类，所以在 Collection<String> 转 Collection<Object> 的时候无法自动完成。有如下几种方案：

1. 使用 forEach 或者 Stream API，对其中的每个元素单个转换并且放入一个新的 Collection<Object>  中
2. new 一个 Collection 并且将现在的 Collection<T> 作为参数传入，使用java **类型自动推断机制**

**注意：** 

- 不要使用 Collections.singleton() Collections.singletonList() Collections.singletonMap() 将 List或者 Map 转换为 Collection<Object> 或者 Map<Object,Object>。因为这样会得到一个 **固定长度为1 不可变 的单例对象** 。传入的是 new 的对象或者 有数据的对象，都会变成**固定长度为1**，其余数据会丢失。

### 解决

该问题 应该使用 **泛型类型** 解决