# URI和URL

## 背景知识

### URI / URL / URN

**URL URI URN 关系图片**

- A Uniform Resource Identifier (URI) 是一个紧凑的字符串用来**标示抽象或物理资源** 像是一本书、一篇文章等

- A URI 可以进一步被分为**定位符**、**名字**或两者都是. 

- Uniform Resource Locator (URL) 是URI的子集, 除了确定一个资源,还提供一种定位该资源的主要**访问机制**(如其网络“位置”)

- **URI可以分为URL,URN（Uniform Resource Names）**或同时具备locators 和names特性。

- URN作用就好像一个人的名字，URL就像一个人的地址。换句话说：**URN确定了身份**，**URL提供了找到它的方式(路径)**

- URI能**成为URL**的当然就是那个**“访问机制(协议)**”，“网络位置”。e.g. `http://` or `ftp://`.

  ![URI&URL&URN](.\URI&URL&URN.png)
  
  

### URI和URL结构

**URI结构**

```
scheme:[//authority][/path][?query][#fragment]
```

**解释：**

- ***scheme*** − for URLs, is the name of the protocol used to access the resource, for other URIs, is a name that refers to a specification for assigning identifiers within that scheme
- ***authority\*** − an optional part comprised of user authentication information, a host and an optional port
- ***path*** − it serves to identify a resource within the scope of its *scheme* and *authority*
- ***query*** − additional data that, along with the *path,* serves to identify a resource. For URLs, this is the query string
- ***fragment*** − an optional identifier to a specific part of the resource

**区分：**

**To easily identify if a particular URI is also a URL, we can check its scheme**. 

Every URL has to start with any of these schemes: ***ftp*, *http*, *https,* *gopher*, *mailto*, *news*, *nntp*, *telnet*, *wais*, *file*, or *prospero***. If it doesn't start with it, then it's not a URL.



### URL编码

RFC 3986, characters found in a URL must be present in the defined set of reserved and unreserved ASCII characters. 

RFC 3986 标准规定，**url中除了ASCII码和一些保留字符外的其他字符在传输时需要进行编码**。

[Reference](https://www.techopedia.com/definition/10346/url-encoding)



### url 自动编码解码



- 浏览器在发送url的时候 会**自动对url进行编码**。

- tomcat 接收到请求后，getParameter() 也会**自动对url进行解码**

- Spring 框架接收请求 进行参数映射时 也会**自动完成url解码**
- 跟踪源码可知，**restTemplate** 在发送http请求之前也会**默认对url进行编码** [参考][https://blog.csdn.net/Joryun/article/details/96133878]

## 问题

### 场景 

在 中山项目 网关配置管理中，机构location信息的查询，是通过 RESTful  HTTP API 的接口调用 pigx里面的 upms-biz 微服务查询结果。

### 异常

http url路径中的调用参数如果全是 ASCII 字符时一切正常

当路径参数中如果有中文时 会出现调用结果不正常。

查看日志发现是因为**被调用方**接收到的参数**没有经过 URLEncoder**。

在发送方调用的请求方法是 **RestTemplate** 的 

```java
exchange(String url, HttpMethod method, @Nullable HttpEntity<?> requestEntity, Class<T> responseType, Map<String, ?> uriVariables)
```



url构建方法是 

```java
private String orgContext = "http://%s:%s/admin/org";
UriComponentsBuilder.fromHttpUrl(String.format(orgContext, ip, port)).queryParams(param).toUriString();
```



### 尝试

#### 不另外编码

1  **直接使用原始中文参数不进行 urlencoder**

使用 guava 的 Joiner 方法拼接路径

```java
Joiner.on("&").withKeyValueSeparator("=").join(paramMap)
```

请求拼接

```java
String.format(orgContextAppend, config.getIp(), config.getPort(), context)+"?"+Joiner.on("&").withKeyValueSeparator("=").join(param);
```

如 请求参数 level=三甲

**请求正确 能正常解析参数**



2 带双引号的参数

如 level = “三甲” 

被调用方能够**正确接收到参数** "三甲" 但是由于不是正确的查询参数，所以结果仍然不正确。



#### 编码

使用 UriComponentsBuilder 构建 url 

```java
UriComponentsBuilder.fromHttpUrl(String.format(orgContext, config.getIp(), config.getPort())).queryParams(param).toUriString()
```

debug 发现经过上述语句 url 将会被url encoder 但是被调用方发现参数仍然是 编码过的。



### 原因

经过分析发现 UriComponentsBuilder 的 **toUriString会自动对url编码后返回**，结果**在 RestTemplate 中又对 String url 进行了一次编码**。

UriComponentsBuilder .toUriString 源码

```java
public String toUriString() {
   return this.uriVariables.isEmpty() ?
         build().encode().toUriString() :
         buildInternal(EncodingHint.ENCODE_TEMPLATE).toUriString();
}
```

结果 **被调用方只会自动进行一次解码**，结果就是请求参数**仍然是未解码**的，所以请求出错。

结果是 **url 进行了二次编码，但是只进过了一次解码，造成请求参数出错**



### 解决

**使用URI 避免 RestTemplate 进行二次编码**

```java
URI uri = UriComponentsBuilder.fromHttpUrl(String.format(orgContextAppend, config.getIp(), config.getPort(),context)).queryParams(param).build(Collections.emptyMap());
```

