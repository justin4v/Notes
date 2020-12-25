# Spring 家族

## Spring

Spring 是一个**生态体系**（也可以说是**技术体系**），是集大成者

它包含了 **Spring Framework、Spring Boot、Spring Cloud** 等（还包括**Spring Cloud data flow、spring data、spring integration、spring batch、spring security、spring hateoas**）



[参考](https://spring.io/projects)

## Spring Framework

**Spring Framework 是整个 spring 生态的基石**，它取代了 Java 官方主推的企业级开发标准 EJB。

Spring官方对 Spring Framework 简短描述：为**依赖注入**、**事务管理**、**WEB应用开发**、**数据访问**等提供了**核心支持**。

**Spring Framework** 是一个一站式的**轻量级的 java 开发框架**，核心是控制反转（**IoC**）和面向切面（**AOP**），针对于开发的WEB层(**springMVC**)、业务层(**IoC**)、持久层(**jdbcTemplate**)等都提供了多种配置解决方案。



无论 Spring Framework 接口如何简化，设计如何优美，始终无法摆脱**被动的境况**：由于它自身并非容器，所以基本上不得不随JavaEE容器启动而装载，例如Tomcat、Jetty、JBoss等。然而Spring Boot的出现，改变了Spring Framework甚至整个Spring技术体系的现状。

此外，其**配置**复杂（xml方式），随着应用的复杂**依赖管理**也变得复杂。



## Spring Boot

Spring Boot这家伙简直就是对Java企业级应用开发进行了一场浩浩荡荡的革命。

以前的 Java Web 开发模式：**Tomcat + WAR包**。WEB项目基于spring framework，项目目录一定要是标准的WEB-INF + classes + lib，而且大量的xml配置。如果说，以前搭建一个SSH架构的Web项目需要1个小时，那么现在应该10分钟就可以了。

**Spring Boot** 能够让你非常容易的创建一个单机版本、生产级别的基于spring framework的应用。然后，"**just run**"即可。Spring Boot **默认集成了很多第三方包（集成嵌入式 Servlet 容器，如 Tomcat）**，以便你能以最小的代价开始一个项目。

官方对Spring Boot的**定义**：

Spring Boot is designed to get you up and running as quickly as possible, with minimal upfront configuration of Spring. Spring Boot takes an opinionated view of building production-ready applications.

即Spring Boot为**快速启动**且**最小化配置**的spring应用而设计，并且它具有用于**构建生产级别应用**的一套**固化的视图**（摘自小马哥的《SpringBoot编程思想》）。这里的固化的视图，可以理解成**Spring Boot的约定**，因为Spring Boot的设计是**约定大于实现**的。



## Spring Cloud

最后就是大名鼎鼎的Spring Cloud了，Spring Cloud 事实上是**一整套基于 Spring Boot** 的**微服务解决方案**。它为开发者提供了很多工具，用于快速构建分布式系统的一些通用模式，例如：**配置管理、注册中心、服务发现、限流、网关、链路追踪**等