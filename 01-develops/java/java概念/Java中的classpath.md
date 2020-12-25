# java项目中的classpath到底是什么

在java项目中，你一定碰到过classpath，通常情况下，我们是用它来指定配置/资源文件的路径。在刚开始学习的时候，自己也糊里糊涂，但是现在，是时候弄清楚它到底是指什么了。

**顾名思义**，classpath就是class的path，也就是类文件(*.class的路径)。一谈到文件的路径，我们就很有必要了解一个java项目（通常也是web项目）它在真正运行时候，这个项目内部的目录、文件的结构；这样，我们才好分析、理解classpath。



## 开发时期的web项目结构

web目录结构一般分为**开发时的编译目录结构**、在servlet 容器等部署时的**发布目录结构**。发布目录结构是servlet 部署发布时的**统一标准目录**，**由不同的构建工具（如ant maven gradle等）将编译目录结构构建后的结果，因此编译目录结构可能不同**。

下面，我以一个 ssm 的项目为例，我先把开发时候的项目的目录结构图放出来。根据maven的约定，一般我们的**编译项目结构**就像下面这样。

![ssm工程项目结构](.\ssm工程项目结构.png)



## classpath用在哪里了？

而我们经常用到classpath的地方，就是在指定一些配置/资源文件的时候会使用到。比如说，我们在web.xml中指定springmvc的配置文件，如下图，我们使用：`classpath:entry/dev/spring-mvc.xml`；再比如，当我们把 Mapper.xml 文件放在了 `main/java/../mapping/` 文件夹下时，在mybatis 的配置文件中配置其位置，我们使用：

```
classpath*:**/mapper/mapping/*Mapper.xml
```

![image-20201215142619930](.\web-xml中配置.png)



很显然，上面这2个classpath的配置，是为了告诉配置文件，去哪里寻找我们要指定的配置文件。要想弄清楚为什么是上面这样写的，我们就要来看看项目运行时（或者是发布后）的目录结构了。



## web项目发布后的目录结构

我们使用IDEA对项目进行打包，**一种是war包，一种是explorer的文件夹，war包解压后就是explorer了**。我们来对解压后的目录结构进行分析。

![war解压后的结构](.\war解压后的结构.png)



经过对比，我们要注意到，开发时期的项目里，`src/main/`下面的`java`和`resources`文件夹都被(编译)打包到了生产包的`WEB-INF/classes/`目录下；而原来WEB-INF下面的views和web.xml则仍然还是在WEB-INF下面。同时由maven引入的依赖都被放入到了`WEB-INF/lib/`下面。**最后，编译后的class文件和资源文件都放在了classes目录下。**



![ssm工程编译前后的目录对应](.\ssm工程编译前后的目录对应.png)



## classpath原来是这个

在编译打包后的项目中，根目录是`META-INF`和`WEB-INF` 。这个时候，我们可以看到classes这个文件夹，它就是我们要找的classpath。

在第1个例子里，`classpath:entry/dev/spring-mvc.xml` 中，classpath就是指`WEB-INF/classes/`这个目录的路径。需要声明的一点是，使用`classpath:`这种前缀，**就只能代表一个文件**。

在第2个例子里，`classpath*:**/mapper/mapping/*Mapper.xml`，使用`classpath*:`这种前缀，**则可以代表多个匹配的文件**；`**/mapper/mapping/*Mapper.xml`，双星号`**`表示在任意目录下，也就是说在`WEB-INF/classes/`下任意层的目录，只要符合后面的文件路径，都会被作为资源文件找到。





**发布目录结构解释**：

webapps下目录有：

| META-INF        | 存放清单文件、services等配置信息            |
| --------------- | ------------------------------------------- |
| WEB-INF         | 网站配置文件目录，存放WEB.XML等配置信息     |
| WEB-INF/classes | 未打包的项目编译代码，禁止手工修改。        |
| WEB-INF/conf    | 存放struts,spring,hibernate,JSF等的配置文件 |
| WEB-INF/lib     | 存放第三方JAR包，使用MAVEN构建时此目录      |
| WEB-INF/pages   | 高安全性的网页目录，如登录信息维护等        |