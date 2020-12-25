# pigx-register



## nacos - namespace初始化

**entry：namespaceController --  RestResult<List<Namespace>> getNamespaces**

**name： public**

注意：

1. 配置数据库--使用 ExternalStoragePersistServiceImpl （interface ：PersistService）
2. 数据库名(查询语句) 写死在 jar 代码中（jar : com.pig4cloud.nacos:nacos-config:1.3.2）



## nacos - 配置管理



在 com.alibaba.nacos.config consoleConfig中加载了：

```
com.alibaba.nacos.naming.controllers;
com.alibaba.nacos.controller;
com.alibaba.nacos.config.server.controller;
```

**三个包中 controller的 请求方法** 

**实际将 三个包中 带有 @RequestMapping 注解的 方法 加载到 ConsoleConfig bean中**



### nacos 编辑 配置文件

前端请求路径：v1/cs/configs

后端api ：**com.pig4cloud.nacos:nacos-config**

Controller :  **com.alibaba.nacos.config.server.controller**.ConfigController  

Method： publishConfig()



该包中为 nacos配置相关接口



### com.alibaba.nacos.naming.controllers

com.pig4cloud.nacos:nacos-naming

该包为名称空间 相关操作



### com.alibaba.nacos.controller

pigx-register 微服务

名称空间入口 权限管理



# Spring Cloud

## 架构

![img](.\springcloud框架.png)



## Spring cloud alibaba

### 架构

![springcloud-alibaba架构](.\springcloud-alibaba架构.png)



### 说明

#### Nacos 服务注册

Spring Cloud Alibaba 基于 Nacos 提供 **spring-cloud-alibaba-starter-nacos-discovery & spring-cloud-alibaba-starter-nacos-config 实现了服务注册 & 配置管理**功能。依靠 @EnableDiscoveryClient 进行服务的注册，兼容 RestTemplate & OpenFeign （**声明式客户端调用**）的客户端进行服务调用。

适配 Spring Cloud 服务注册与发现标准，默认集成了 Ribbon 的支持。



#### Sentinel 服务限流降级

作为稳定性的核心要素之一，服务限流和降级是微服务领域特别重要的一环，Spring Cloud Alibaba 基于 Sentinel，对 Spring 体系内基本所有的客户端，网关进行了适配，

默认支持 WebServlet、WebFlux, OpenFeign、RestTemplate、Spring Cloud Gateway, Zuul, Dubbo 和 RocketMQ 限流降级功能的接入。



#### API 网关 Spring Cloud Gateway

Spring Cloud Gateway 作为 Spring Cloud 生态系统中的网关，目标是替代 Netflix Zuul，其不仅提供统一的路由方式，并且基于 Filter 链的方式提供了网关基本的功能，例如：安全，监控/指标，和限流。

底层基于 Netty （异步的、基于事件驱动的网络应用框架）实现



#### RabbitMQ 消息队列

支持为微服务应用构建消息驱动能力，基于 Spring Cloud Stream 提供 Binder 的新实现: Spring Cloud Stream RocketMQ Binder，

也新增了 Spring Cloud Bus 消息总线的新实现 Spring Cloud Bus RocketMQ。



#### Seata 分布式事务

使用 Seata 解决微服务场景下面临的分布式事务问题。

使用 @GlobalTransactional 注解，在微服务中传递事务上下文，可以对业务零侵入地解决分布式事务问题。



#### Feign

Feign是Netflix开发的声明式，模板化的HTTP客户端。主要为了方便微服务之间API接口的调用。只需创建一个接口并使用注解的方式来配置它(以前是Dao接口上面标注Mapper注解,现在是一个微服务接口上面标注一个Feign注解即可)，即可完成对服务提供方（注解中name指定的服务）的接口绑定，其后调用其中的接口方法，即可发起http请求（实际具体调用时通过代理生成 RequestTemplate.）。

```
@FeignClient(name = "github-client", url = "https://api.github.com")
```



#### Ribbon

Ribbon是Netflix发布的云中间层服务开源项目，其主要功能是提供客户端实现负载均衡算法。

Ribbon客户端组件提供一系列完善的配置项如连接超时，重试等。简单的说，Ribbon是一个客户端负载均衡器，我们可以在配置文件中Load Balancer后面的所有机器，Ribbon会自动的帮助你基于某种规则（如简单轮询，随机连接等）去连接这些机器，也可用Ribbon实现自定义的负载均衡算法。





## 认证

首先记过过滤器 PigxRequestGlobalFilter