# Spring Web Flux

## 简介

传统的Web框架，比如说：struts2，springmvc等都是基于 Servlet API 与 Servlet 容器基础之上运行的，在Servlet3.1之后才有了异步非阻塞的支持。

WebFlux是一个典型**非阻塞异步**的框架，它的核心是基于 Reactor 的相关API实现的。相对于传统的 web 框架来说，它可以运行在诸如Netty，Undertow及支持Servlet3.1的容器上，因此它的运行环境的可选择性要比传统web框架多的多。

与传统的 MVC 最大的特点是**异步**的、**事件驱动**的、**非阻塞**的。

WebFlux 模块的名称是 spring-webflux，名称中的 Flux 来源于 Reactor 中的类 Flux。该模块中包含了对反应式 HTTP、服务器推送事件和 WebSocket 的客户端和服务器端的支持。

## Spring MVC 和 Spring WebFlux

![img](.\MVC和Webflux.png)

它们都可以用注解式编程模型，都可以运行在tomcat，jetty，undertow等servlet容器当中。但是SpringMVC采用**命令式编程方式**，代码一句一句的执行，这样更有利于理解与调试，而 WebFlux 则是基于**异步响应式编程**。

包名为： **org.springframework.boot:spring-boot-starter-webflux**



## 使用

在服务器端，WebFlux 支持两种不同的编程模型：

- 第一种是 Spring MVC 中使用的**基于 Java 注解**（**@GetMapping**）的方式；

- 第二种是基于 Java 8 的 lambda 表达式的**函数式编程模型**（编写 **handler**）。

  这两种编程模型只是在**代码编写方式上存在不同**。它们运行在同样的反应式底层架构之上，因此在运行时是相同的。



### 启动流程图



![webflux启动](.\webflux启动.png)



## 设计

### 接口抽象

1. org.springframework.boot.web.reactive.server.ReactiveWebServerFactory
2. org.springframework.boot.web.server.WebServer
3. org.springframework.http.server.reactive.HttpHandler
4. org.springframework.web.reactive.HandlerMapping
5. org.springframework.web.server.WebHandler



