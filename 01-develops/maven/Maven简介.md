## What Is Maven？

We wanted:

- **a standard way to build the projects**;
- **a clear definition of what the project consisted of;**
- **an easy way to publish project information;**
- **a way to share JARs across several projects.**

The result is a tool –Maven–that can now be used for building and managing any Java-based project.

Maven 基于 **Project Object Model (POM)** 的概念。



### Maven’s Objectives

Maven’s **主要目标**是让开发人员在最短的时间内**了解开发工作的完整状态**。为了达到这个目标，Maven 有如下几个小目标:

- **Making the build process easy**；
- **Providing a uniform build system**；
- **Providing quality project information**；
- **Encouraging better development practices**.



## Project Object Model

### What is a POM

A Project Object Model or POM is the fundamental unit of work in Maven. It is an **XML file that contains information about the project and configuration details** used by Maven to build the project. 

Some of the configuration that can be specified in the POM are the **project dependencies, the plugins or goals that can be executed, the build profiles**, and so on. Other information such as the **project version, description, developers, mailing lists** and such can also be specified.

POM 就是将 **Project 看做是一个对象**，方便管理，包含：

1. **对象的信息**：version，description，developers，name ……
2. **对象的行为**：dependencies，plugins，build goals ……



### Super POM

POM 既然类似一个对象，POM是可以继承的。

The Super POM is Maven's **default POM**. **All POMs extend the Super POM** unless explicitly set, meaning the configuration specified in the Super POM is inherited by the POMs you created for your projects.

You can see the [Super POM for Maven 3.6.3](https://maven.apache.org/ref/3.6.3/maven-model-builder/super-pom.html) in Maven Core reference documentation.



### Minimal POM

The minimum requirement for a POM are the following:

- `project` root
- `modelVersion` - should be set to 4.0.0
- `groupId` - the id of the project's group.
- `artifactId` - the id of the artifact (project)
- `version` - the version of the artifact under the specified group

Here's an example:

```xml
<project>
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.mycompany.app</groupId>
  <artifactId>my-app</artifactId>
  <version>1</version>
</project>
```

A POM requires that its groupId, artifactId, and version be configured. These three values form the project's **fully qualified artifact name. This is in the form of <groupId>:<artifactId>:<version>**. As for the example above, its fully qualified artifact name is "com.mycompany.app:my-app:1".

其他没有定义的属性使用默认值，或者从 父POM 中继承。



### Project Inheritance

Directory：

```
.
 |-- my-module
 |   `-- pom.xml
 `-- parent
     `-- pom.xml
```

To address this directory structure (or any other directory structure), we would have to add the **`<relativePath>`** element to our parent section.

```xml
<project>
  <modelVersion>4.0.0</modelVersion>
 
  <parent>
    <groupId>com.mycompany.app</groupId>
    <artifactId>my-app</artifactId>
    <version>1</version>
    <relativePath>../parent/pom.xml</relativePath>
  </parent>
 
  <artifactId>my-module</artifactId>
</project>
```

子pom文件不是一旦继承了父pom就会无条件地继承它所有的依赖关系，即插件、类库等。

如果子pom想继承父pom的某个插件，只需要引入**父pom中该插件的groupId与artifactId信息**（不用写该插件其它的配置信息）即可。这样子pom是可以有选择性的继承它自己所需要的东西。



### Project Aggregation

即大项目中一般会有一个空的Maven项目（只有pom文件，没有Java代码）作为父项目，该项目的Pom文件（Modules标签中）聚合了其它子项目的Pom文件，然后只要构建父项目就能够构建所有的子项目了.

Directory Structure

```
.
 |-- my-module
 |   `-- pom.xml
 `-- pom.xml
```

If we are to aggregate my-module into my-app, we would only have to modify my-app.

```xml
<project>
  <modelVersion>4.0.0</modelVersion>
 
  <groupId>com.mycompany.app</groupId>
  <artifactId>my-app</artifactId>
  <version>1</version>
  <packaging>pom</packaging>
 
  <modules>
    <module>my-module</module>
  </modules>
</project>
```

