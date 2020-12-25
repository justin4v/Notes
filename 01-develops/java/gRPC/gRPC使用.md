# gRPC使用文档

## 1 RPC基础

### 1.1 定义

RPC（Remote Procedure Call）**远程过程调用****-****一种技术概念/****思想**。相对于本地过程或者函数方法调用而言，**RPC****实现允许调用另外一个地址空间的（如网络上的另一台主机）过程后者函数方法**。而且调用的方式和本地调用并无区别，具体远程调用中的底层实现细节由RPC服务完成。



### 1.2 应用

RPC可用于**分布式服务、分布式计算、远程调用**等应用中。



## 2 区别

### 2.1 其他远程调用方式

**RPC****、HTTP****、RMI****、Web Service** **都能完成远程调用**，但是实现方式和侧重点各有不同。



### 2.2 HTTP

HTTP（HyperText Transfer Protocol）是**应用层通信协议**，使用**标准语义访问指定资源**（图片、接口等）。HTTP 协议是一种**资源访问协议**，通过 HTTP 协议可以完成远程请求并返回请求结果。

相对而言，HTTP可以看做是RPC技术思想的一种应用与实现。

HTTP简单直接，但是在**安全、网络开销**等方面优势不大。



### 2.3 RMI

**RMI****（Remote Method Invocation****）远程方法调用-**是指 Java 语言中的远程方法调用，RMI 中的每个方法都具有方法签名，**RMI** **客户端和服务器端通过方法签名进行远程方法调用**。

**RMI** **只能在 Java** **语言中使用**， 可以把 RMI 看作面向对象的 Java RPC 。



### 2.4 Web Service

Web Service 是一种**基于** **Web** **进行服务发布、查询、调用的架构方式**，重点在于**服务的管理与使用**。Web Service 一般通过 WSDL 描述服务，使用 SOAP（简单对象访问协议）通过 **HTTP** **调用服务**。

**当 RPC** **框架提供了服务的发现与管理，并使用 HTTP** **作为传输协议时，其实就是 Web Service**。

相对 Web Service，RPC 框架可以对服务进行更细粒度的治理，包括流量控制、SLA 管理等，在微服务化、分布式计算方面有更大的优势



### 2.5 RPC 

RPC 只规定了 Client 与 Server 之间的**点对点调用流程**，包括 stub、通信协议、RPC 消息解析等部分. 在实际应用中，还需要考虑服务的**高可用、负载均衡**等问题。

RPC 框架一般指的是能够完成 RPC 调用的解决方案。除了点对点的 **RPC** **协议的具体实现**外，还可以包括**服务的发现与注销、多台** **Server** **的负载均衡、服务的高可用等**更多的功能。



### 2.6 总结

 目前的 RPC 框架大致有**两种不同的侧重方向**，**一种偏重于服务治理，另一种偏重于跨语言调用** **。**



#### 2.6.1 服务治理型 RPC 框架

　**服务治理型的** **RPC** **框架有 Dubbo****、DubboX** **等**。Dubbo 是阿里开源的**分布式服务框架**，能够实现高性能 RPC 调用，并且提供了**丰富的管理功能**，是十分优秀的 RPC 框架。DubboX 是基于 Dubbo 框架开发的 RPC 框架，支持 **REST** **风格远程调用**，并增加了一些新的 feature。

这类的 RPC 框架的特点是功能丰富，提供**高性能的远程调用以及服务发现及治理功能**， 适用于**大型服务的微服务化拆分以及管理**，对于特定语言（Java）的项目可以十分友好的透明化接入。但缺点是**语言耦合度较高**，跨语言支持难度较大。



#### 2.6.2 跨语言调用型RPC框架

跨语言调用型的 RPC 框架有 Thrift、gRPC、Hessian、Hprose 等，这一类的 RPC 框架重点关注于**服务的跨语言调用**，能够支持大部分的语言进行语言无关的调用，非常适合于**为不同语言提供通用远程服务的场景**。 但这类框架没有服务发现相关机制 ，实际使用时一般**需要代理层进行请求转发和负载均衡**策略控制。



## 3 RPC架构

### 3.1 组成

RPC程序包含如下5个部分：

- User

- User-stub

- RPCRuntime

- Server-stub

- Server



### 3.2 结构图

![https://images2015.cnblogs.com/blog/285763/201603/285763-20160328150931051-310572538.png](.\gRPC结构.png)

这里 user 就是 client 端，当 user 想发起一个远程调用时，它实际是通过**本地调用** **user-stub**。

user-stub 负责将调用的接口、方法和参数通过**约定的协议规范进行编码**并通过本地的 **RPCRuntime** **实例传输到远端的实例**。

远端 RPCRuntime 实例收到请求后交给 **server-stub** **进行解码**后发起本地端调用，调用结果再返回给 user 端。



### 3.3 接口定义

较早的RPC架构CORBAR 采用了IDL（Interface Definition Language）来定义远程接口，并将其映射到特定的平台语言中，后来大部分的跨语言平台 RPC 基本都采用了此类方式。

通过 **IDL** **定义接口**，提供工具来**映射生成不同语言平台的** **user-stub** **和 server-stub**，并通过框架库来提供 RPCRuntime 的支持。

## 4 gRPC

### 4.1 定义

gRPC是谷歌开发的一种PRC开源框架，主要聚焦于**高性能、跨语言调用**等方面。

gRPC使用Protocol Buffers 序列化协议作为接口定义语言（IDL，Interface Definition Language）。

### 4.2 使用

最基本的开发步骤是：

- 定义 proto 文件；

- 定义请求 Request 和 响应 Response Message；

- 定义一个服务 Service 接口。传入Request Message返回Response Message；

- 利用插件工具生成gRPC客户端和服务端接口代码。包括Request、Response Message类、服务接口类。服务接口类中含有：1.用于被继承的service基类，其中包含service中定义的所有方法；2.服务类和客户端连接的各种stub类。

- 服务端实现服务接口-上文提到的service基类，比如GetFileServiceGrpc.GetFileServiceImplBase。

- 实现客户端。组建Request Message；注入stub，调用服务接口。

 

### 4.3 Java Example

#### 4.3.1 说明

通过远程调用，调用getdata方法查询Files表，获取记录。



#### 4.3.2 Proto

```java
syntax = "proto3";
//是否将message拆分为类文件
option java_multiple_files = true;
//生成的文件所在包
option java_package = "com.uih.uplus.imagecloud.common.grpc.files";
 // 输出类主文件
option java_outer_classname = "FilesTable";
//import "google/protobuf/empty.proto";
 
package sql;
// 数据库 files 表服务 
// gRPC 方式调用 
service FilesTableService {
  rpc getRecord(GRpcFilesTableRequest) 
      returns (GRpcFilesTableResponse){};
 }
 
// request message
message GRpcFilesTableRequest{
  string locationCode = 1;
  string resourceId = 2;
  string idType = 3;
 }
 
// response message
message GRpcFilesTableResponse{
  map<string, string> filesInfo = 1;
 }
```



#### 4.3.3 Service

```java
@GrpcService
@UIHLog
public class GRpcFilesTableServiceMysqlImpl extends FilesTableServiceGrpc.FilesTableServiceImplBase {

    @Qualifier(ServiceBeanIdCst.FILES_SERVICE_MYSQL_IMPL)
    @Autowired
    private FilesService filesService;

    @Override
    public void getRecord(GRpcFilesTableRequest request, StreamObserver<GRpcFilesTableResponse> responseObserver) {
        ……
    }
}
```

 

#### 4.3.4 Client

1. 在application中添加gRPC服务端口：

```
grpc:
  client:
    getdata-server:
      address: "static://10.3.13.157:9093" # 服务端口
      enableKeepAlive: true
      keepAliveWithoutCalls: true
      negotiationType: PLAINTEXT   # 此部分的意义为不进行TSL认证
```

 

2. 在client中导入stub，并通过stub调用服务接口  

```java
@GrpcClient("getdata-server")//配置相应gRPC服务器的客户端
private FilesTableServiceGrpc.FilesTableServiceBlockingStub filesTableServiceBlockingStub;

……

GRpcFilesTableResponse response = filesTableServiceBlockingStub.getRecord(filesParams);
```



### 4.4 更多

请参考：

https://github.com/smallnest/grpc-examples

 