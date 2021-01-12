# Builder

## 文档

A method annotated with `@Builder` (from now on called the *target*) causes the following 7 things to be generated:

- An inner static class named `FooBuilder`, with the same type arguments as the static method (called the *builder*).
- In the *builder*: One private non-static non-final field for each parameter of the *target*.
- In the *builder*: A package private no-args empty constructor.
- In the *builder*: A 'setter'-like method for each parameter of the *target*: It has the same type as that parameter and the same name. It returns the builder itself, so that the setter calls can be chained, as in the above example.
- In the *builder*: A `build()` method which calls the method, passing in each field. It returns the same type that the *target* returns.
- In the *builder*: A sensible `toString()` implementation.
- In the class containing the *target*: A `builder()` method, which creates a new instance of the *builder*.

 applying `@Builder` to a class is as if you added `@AllArgsConstructor(access = AccessLevel.PACKAGE)` to the class and applied the `@Builder` annotation to this all-args-constructor. This only works if you haven't written any explicit constructors yourself. If you do have an explicit constructor, put the `@Builder` annotation on the constructor instead of on the class. Note that if you put both `@Value` and `@Builder` on a class, the package-private constructor that `@Builder` wants to generate 'wins' and suppresses the constructor that `@Value` wants to make.

## toBuilder

关于Builer的 toBuilder 属性有如下描述：

If using `@Builder` to generate builders to produce instances of your own class (this is always the case unless adding `@Builder` to a method that doesn't return your own type), you can use `@Builder(toBuilder = true)` to also generate an instance method in your class called `toBuilder()`; **it creates a new builder that starts out with all the values of this instance**. You can put the `@Builder.ObtainVia` annotation on the parameters (in case of a constructor or method) or fields (in case of `@Builder` on a type) to indicate alternative means by which the value for that field/parameter is obtained from this instance. For example, you can specify a method to be invoked: `@Builder.ObtainVia(method = "calculateFoo")`.

表明 toBuilder  其实是 new 了一个 Builder ，最后新建一个 instance，只是新建的 instance 复制了调用者 instance 的所有属性值。也就是说：**toBuilder 相当于当前 instance 调用了 copy 方法，生成了一个新的对象。而不是在当前对象上修改属性。**



## 反编译源码

### 源码

```java
@Builder(toBuilder = true)
@EqualsAndHashCode(of = {"reportCount","studyCount"})
@ToString
public class UCloudCardinality implements ValueObject<UCloudCardinality> {
	private Long reportCount;
	private Long studyCount;
	@JsonInclude(JsonInclude.Include.NON_DEFAULT)
	private String timeStr;

	@Override
	public boolean sameAs(UCloudCardinality other) {
		return false;
	}
}
```



### 反编译

**反编译后的文件在 compile 后的 target 目录下查找**

```java
public class UCloudCardinality implements ValueObject<UCloudCardinality> {
    private Long reportCount;
    private Long studyCount;
    @JsonInclude(Include.NON_DEFAULT)
    private String timeStr;

    public boolean sameAs(UCloudCardinality other) {
        return false;
    }

    UCloudCardinality(Long reportCount, Long studyCount, String timeStr) {
        this.reportCount = reportCount;
        this.studyCount = studyCount;
        this.timeStr = timeStr;
    }

    public static UCloudCardinality.UCloudCardinalityBuilder builder() {
        return new UCloudCardinality.UCloudCardinalityBuilder();
    }

    public UCloudCardinality.UCloudCardinalityBuilder toBuilder() {
        return (new UCloudCardinality.UCloudCardinalityBuilder()).reportCount(this.reportCount).studyCount(this.studyCount).timeStr(this.timeStr);
    }
    // .......
    public static class UCloudCardinalityBuilder {
        private Long reportCount;
        private Long studyCount;
        private String timeStr;

        UCloudCardinalityBuilder() {
        }

        public UCloudCardinality.UCloudCardinalityBuilder reportCount(Long reportCount) {
            this.reportCount = reportCount;
            return this;
        }

        public UCloudCardinality.UCloudCardinalityBuilder studyCount(Long studyCount) {
            this.studyCount = studyCount;
            return this;
        }

        public UCloudCardinality.UCloudCardinalityBuilder timeStr(String timeStr) {
            this.timeStr = timeStr;
            return this;
        }

        public UCloudCardinality build() {
            return new UCloudCardinality(this.reportCount, this.studyCount, this.timeStr);
        }

        public String toString() {
            return "UCloudCardinality.UCloudCardinalityBuilder(reportCount=" + this.reportCount + ", studyCount=" + this.studyCount + ", timeStr=" + this.timeStr + ")";
        }
    }
    
```



### 分析

从反编译代码可以看出：

- **内部类的 build() 方法都是返回一个新的 instance；**
- **toBuilder()  为实例方法；**
- **和 builder() 相比 toBuilder() 方法返回的 内部 Builder 多了当前实例的属性值；**
- **生成了包含全部属性参数的构造方法。**



## 结论

1. **@Builder 注解只用于新建实例并方便的给属性赋值**；
2. **toBuilder() 尽量不使用，使用也只是当做 copy 方法使用**；
3. **@Builder 要求具有全参的构造函数，使用后没有无参构造函数**。如果全参和无参构造函数都想有，需要再加上如下两个注解：@NoArgsConstructor
   @AllArgsConstructor 