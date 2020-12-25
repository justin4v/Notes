# OAuth 2.0 简介

## 定义

OAuth2.0（**Open Authorization 开放授权**）是一个关于**授权**的开放的网络协议。

　　--->允许资源所有者（用户）让第三方应用访问该资源所有者（用户）在某一网站上存储的的资源（如：照片，视频，联系人列表）。

　　--->OAuth是一个关于授权（Authorization）的开放网络标准，目前的版本是2.0版。注意**是Authorization(授权)，而不是Authentication(认证)**。用来做Authentication(认证)的标准叫openid connect。

OAuth 2.0授权框架支持第三方应用有限访问HTTP服务器：通过在资源所有者和HTTP服务之间进行一个批准交互来代表资源所有者去访问这些资源，或者允许第三方应用程序以自己的名义获取访问资源权限。



## 原理

可以认为OAuth2.0就是在**用户资源和第三方应用之间的一个中间层**，它把资源和第三方应用隔开，使得第三方应用无法直接访问资源，从而起到保护资源的作用。

为了访问这种受保护的资源，第三方应用（客户端）在访问的时候需要提供凭证。即，需要告诉OAuth2.0你是谁你要做什么。你可以将用户名和密码告诉第三方应用，让第三方应用直接以你的名义去访问，也可以授权第三方应用去访问。



## 常见场景

- 用OAuth来实现第三方应用对我们API的访问控制；
- 登录第三方应用（APP或网页）。比如经常会允许采用其他的登录方式，比如QQ，微博，微信的授权登录（QQ用户登录）。

可以联想一下微信公众平台开发，在微信公众平台开发过程中当我们访问某个页面，页面可能弹出一个提示框应用需要获取我们的个人信息问是否允许，点确认其实就是授权第三方应用获取我们在微信公众平台的个人信息。这里微信网页授权就是使用的OAuth2.0。



##  Roles

OAuth定义了**四种角色**：

- resource owner（资源所有者）
- resource server（资源服务器）: 验证访问令牌并返回响应
- client（客户端）：**代表资源所有者并且经过所有者授权**去访问受保护的资源的应用程序
- authorization server（授权服务器）：成功**验证资源所有者以及所有者的授权**后向客户端**发出访问令牌**



###  Protocol Flow

![img](.\OAuth2.0协议流程.png)

抽象的OAuth2.0流程如图所示：

1. (A)  客户端向资源所有者请求其授权
2. (B)  客户端收到资源所有者的授权许可，这个授权许可是一个代表资源所有者授权的凭据
3. (C)  客户端向授权服务器请求访问令牌，并出示授权许可
4. (D)  授权服务器对客户端身份进行认证，并校验授权许可，如果都是有效的，则发放访问令牌
5. (E)  客户端向资源服务器请求受保护的资源，并出示访问令牌
6. (F)  资源服务器校验访问令牌，如果令牌有效，则提供服务



### Authorization Grant

一个**授权许可**是一个凭据，它**代表资源所有者对受保护资源的访问授权**，是**客户端用授权许可获取访问令牌**的。

授权类型有四种：

- authorization code 授权码
- implicit 隐式授权（简化模式）
- resource owner password credentials 密码
- client credentials 客户端模式



#### Authorization Code

**授权码**是**授权服务器**用来获取并作为客户端和资源所有者之间的中介。功能最完整、流程最严密的授权模式。

代替直接向资源所有者请求授权，客户端定向资源所有者到一个授权服务器。授权服务器反过来指导资源所有者将授权码返回给客户端。

在将授权码返回给客户端之前，授权服务器对资源所有者进行身份验证并获得授权。因为资源所有者只对授权服务器进行身份验证，所以**资源所有者的凭据永远不会与客户端共享**。



####  Implicit

隐式授权是为了**兼顾到在浏览器中用诸如JavaScript的脚本语言实现的客户端而优化**的简化授权代码流程。

在隐式授权流程中，**不是发给客户端一个授权码，而是直接发给客户端一个访问令牌**，而且不会对客户端进行认证。隐式授权**提高了一些客户端（比如基于浏览器实现的客户端）的响应能力和效率**，因为它减少了获得访问令牌所需的往返次数。



####  Resource Owner Password Credentials

**资源所有者的密码凭据（比如，用户名和密码）可以直接作为授权许可来获取访问令牌**。

这个凭据只应该用在高度信任的资源所有者和客户端之间（比如，客户端是系统的一部分，或者特许的应用），并且其它授权模式不可用的时候。



#### Client Credentials

客户端凭据通常用作授权许可



#### Access Token

访问令牌是用来访问受保护的资源的凭据。

一个访问令牌是一个字符串，它代表发给客户端的授权。令牌代表资源所有者授予的对特定范围和访问的时间（PS：令牌是有范围和有效期的），并由资源服务器和授权服务器强制执行。访问令牌可以有不同的格式、结构和使用方法。



#### Refresh Token

Refresh Token是用于获取Access Token的凭据。

**刷新令牌是授权服务器发给客户端**的，用于在当前访问令牌已经失效或者过期的时候获取新的访问令牌。刷新令牌只用于授权服务器，并且**从来不会发给资源所有者**。

![img](.\OAuth token 刷新流程.png)

刷新的流程如图所示：

1. (A)  客户端请求获取访问令牌，并向授权服务器提供授权许可
2. (B)  授权服务器对客户端身份进行认证，并校验授权许可，如果校验通过，则发放访问令牌和刷新令牌
3. (C)  客户端访问受保护的资源，并向资源服务器提供访问令牌
4. (D)  资源服务器校验访问令牌，如果校验通过，则提供服务
5. (E)  重复(C)和(D)直到访问令牌过期。如果客户端直到访问令牌已经过期，则跳至(G)，否则不能继续访问受保护的资源
6. (F)  自从访问令牌失效以后，资源服务器返回一个无效的令牌错误
7. (G)  客户端请求获取一个新的访问令牌，并提供刷新令牌
8. (H)  授权服务器对客户端进行身份认证并校验刷新令牌，如果校验通过，则发放新的访问令牌（并且，可选的发放新的刷新令牌）



#  Client Registration

在使用该协议之前，**客户端向授权服务器注册**。



##  Client Types

OAuth定义了**两种客户端类型**：

- **confidential**：能够维护其凭证的机密性的客户端
- **public**：不能维护其凭证的机密性的客户端



## Client Password

拥有**客户端密码**的客户端可以使用HTTP Basic向服务器进行认证，当然前提是授权服务器支持HTTP Basic认证。

例如：Authorization: Basic czZCaGRSa3F0Mzo3RmpmcDBaQnIxS3REUmJuZlZkbUl3

授权服务器可能支持在请求体中用下列参数包含客户端凭据：

- client_id：必须的，在授权服务器中注册过的客户端标识符。
- client_secret：必须的，客户端秘钥。如果秘钥是空字符串的话可以省略该参数。

**不推荐**用这两个参数将客户端凭据包含在请求体中，并且应该限制客户端**不能直接用HTTP Basic认证方案**。



# Protocol Endpoints

两个**授权服务器端点**进行授权处理：

- Authorization endpoint：用于客户端从资源所有者那里**获取授权**
- Token endpoint：用于客户端**用授权许可交换访问令牌**

还有一个端点

- Redirection endpoint：用于资源服务器通过资源所有者的用户代理将包含**授权凭据的响应返回给客户端**



##   Authorization Endpoint

用于和资源所有者交互并**获取一个授权许可**。授权服务器必须首先校验资源所有者的身份。



### Response Type

客户端用以下参数通知授权服务器自己渴望的授权类型：

- response_type：必须的。为了请求一个授权码这个值必须是"code"，为了请求一个访问令牌这个值必须是"token"



###  Redirection Endpoint

在完成和资源所有者的交互以后，授权服务器直接将资源所有者的 user-agent 返回给客户端。授权服务器重定向到这个user-agent



## Access Token Scope

授权和令牌端点允许客户端使用**“scope”参数指定访问请求的范围**。反过来，授权服务器使用“scope”响应参数通知客户机它所发放的访问令牌的范围。



#  Obtaining Authorization

 为了获得一个访问令牌，客户端需要先从资源所有者那里获得授权。授权是以授权许可的形式来表示的。

OAuth定义了四种授权类型：

- authorization code
- implicit
- resource owner password credentials
- client credentials

##  Authorization Code Grant

![img](.\Authorization Code Grant.png)

**授权码流程**如图所示：

1. (A)  **客户端通过将资源所有者的用户代理指向授权端点来启动这个流程**。客户端包含它的客户端标识符，请求范围，本地状态，和重定向URI，在访问被允许（或者拒绝）后授权服务器立即将用户代理返回给重定向URI。
2. (B)  授权服务器验证资源所有者（通过用户代理），并确定资源所有者是否授予或拒绝客户端的访问请求。
3. (C)  假设资源所有者授权访问，那么授权服务器用之前提供的重定向URI（在请求中或在客户端时提供的）将用户代理重定向回客户端。重定向URI包括授权码和前面客户端提供的任意本地状态。
4. (D)  客户端用上一步接收到的授权码从授权服务器的令牌端点那里请求获取一个访问令牌。
5. (E)  授权服务器对客户端进行认证，校验授权码，并确保这个重定向URI和第三步(C)中那个URI匹配。如果校验通过，则发放访问令牌，以及可选的刷新令牌。



###  Authorization Request

客户端通过使用“application/x-www-form- urlencoding”格式向**授权端点**URI的查询组件添加以下参数来构造请求URI

- response_type：必须的。值必须是"code"。
- client_id：必须的。客户端标识符。
- redirect_uri：可选的。
- scope：可选的。请求访问的范围。
- state：推荐的。一个不透明的值用于维护请求和回调之间的状态。授权服务器在将用户代理重定向会客户端的时候会带上该参数。

**例如：**

　　GET /authorize?response_type=code&client_id=s6BhdRkqt3&state=xyz&redirect_uri=https%3A%2F%2Fclient%2Eexample%2Ecom%2Fcb HTTP/1.1
　　Host: server.example.com



### Authorization Response

如果资源所有者授权访问请求，授权服务器发出授权代码并通过使用“application/x-www-form- urlencoding”格式向**重定向URI**的查询组件添加以下参数，将其给客户端。

- code：必须的。授权服务器生成的授权码。授权代码必须在发布后不久过期，以减少泄漏的风险。建议最大授权代码生命期为10分钟。客户端不得多次使用授权代码。如果授权代码不止一次使用，授权服务器必须拒绝请求，并在可能的情况下撤销先前基于该授权代码发布的所有令牌。授权代码是绑定到客户端标识符和重定向URI上的。
- state：如果之前客户端授权请求中带的有"state"参数，则响应的时候也会带上该参数。

**例如：**

　　HTTP/1.1 302 Found
　　Location: https://client.example.com/cb?code=SplxlOBeZQQYbYS6WxSbIA&state=xyz



#### Error Response

- error：取值如下error_description：可选的
  - invalid_request　　
  - unauthorized_client
  - access_denied
  - unsupported_response_type
  - invalid_scope
  - server_error
  - temporarily_unavailable
- error_description
- error_uri：可选的



###  Access Token Request

客户端通过使用“application/ www-form-urlencoding”格式发送以下参数向令牌端点发出请求

- grant_type：必须的。值必须是"authorization_code"。
- code：必须的。值是从授权服务器那里接收的授权码。
- redirect_uri：如果在授权请求的时候包含"redirect_uri"参数，那么这里也需要包含"redirect_uri"参数。而且，这两处的"redirect_uri"必须完全相同。
- client_id：如果客户端不需要认证，那么必须带的该参数。

**例如：**

　　POST /token HTTP/1.1
　　Host: server.example.com
　　Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW
　　Content-Type: application/x-www-form-urlencoded

　　grant_type=authorization_code&code=SplxlOBeZQQYbYS6WxSbIA&redirect_uri=https%3A%2F%2Fclient%2Eexample%2Ecom%2Fcb



###  Access Token Response

**例如：**

　　HTTP/1.1 200 OK
　　Content-Type: application/json;charset=UTF-8
　　Cache-Control: no-store
　　Pragma: no-cache

　　{
　　　　"access_token":"2YotnFZFEjr1zCsicMWpAA",
　　　　"token_type":"example",
　　　　"expires_in":3600,
　　　　"refresh_token":"tGzv3JOkF0XG5Qx2TlKWIA",
　　　　"example_parameter":"example_value"
　　}



## Implicit Grant

**隐式授权用于获取访问令牌**（它不支持刷新令牌），它**针对已知的操作特定重定向URI的公共客户端进行了优化**。这些客户端通常在浏览器中使用脚本语言(如JavaScript)实现。

因为它是基于重定向的流程，所以客户端必须有能力和资源所有者的用户代理（典型地，是一个Web浏览器）进行交互，同时必须有能力接收来自授权服务器的重定向请求。

**隐式授权类型不包含客户端身份验证**，它依赖于资源所有者的存在和重定向URI的注册。由于访问令牌被编码到重定向URI中，所以它可能暴露给资源所有者以及同一台设备上的其它应用。

![img](.\implicit Grant.png)

隐式授权流程如图所示：

1. (A)  客户端引导资源所有者的user-agent到授权端点。客户端携带它的客户端标识，请求scope，本地state和一个重定向URI。
2. (B)  授权服务器对资源所有者（通过user-agent）进行身份认证，并建立连接是否资源所有者允许或拒绝客户端的访问请求。
3. (C)  假设资源所有者允许访问，那么授权服务器通过重定向URI将user-agent返回客户端。
4. (D)  user-agent遵从重定向指令
5. (E)  web-hosted客户端资源返回一个web页面（典型的，内嵌脚本的HTML文档），并从片段中提取访问令牌。
6. (F)  user-agent执行web-hosted客户端提供的脚本，提取访问令牌
7. (G)  user-agent将访问令牌传给客户端



###  Authorization Request

- response_type：必须的。值必须是"token"。
- client_id：必须的。
- redirect_uri：可选的。
- scope：可选的。



##  Resource Owner Password Credentials Grant

**资源所有者密码凭证授予类型**适用于**资源所有者与客户端(如设备操作系统或高度特权应用程序)存在信任关系的情况**。授权服务器在启用这种授予类型时应该特别小心，并且只在其他授权流程不可行的时候才允许使用。

这种授权类型适合于有能力维护资源所有者凭证（用户名和密码，典型地，用一个交互式的表单）的客户端。

![img](https://images2018.cnblogs.com/blog/874963/201806/874963-20180613123757202-1093486879.png)

资源所有者密码凭证流程如图：

1. (A)  资源所有者提供他的用户名和密码给客户端
2. (B)  客户端携带从资源所有者那里收到的凭证去授权服务器的令牌端点那里请求获取访问令牌
3. (C)  授权服务器对客户端进行身份认证，并校验资源所有者的凭证，如果都校验通过，则发放访问令牌



###  Access Token Request

客户端通过在HTTP请求体中添加"application/x-www-form-urlencoded"格式的参数来向令牌端点请求。

- grant_type ：必须的。而且值必须是"password"。
- username ：必须的。资源所有者的用户名。
- password ：必须的。资源所有者的密码。
- scope：可选的。

**例如：**

　　POST /token HTTP/1.1
　　Host: server.example.com
　　Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW
　　Content-Type: application/x-www-form-urlencoded

　　grant_type=password&username=johndoe&password=A3ddj3w



###  Access Token Response

**例如：**

　　HTTP/1.1 200 OK
　　Content-Type: application/json;charset=UTF-8
　　Cache-Control: no-store
　　Pragma: no-cache

　　{
　　　　"access_token":"2YotnFZFEjr1zCsicMWpAA",
　　　　"token_type":"example",
　　　　"expires_in":3600,
　　　　"refresh_token":"tGzv3JOkF0XG5Qx2TlKWIA",
　　　　"example_parameter":"example_value"
　　}



## Client Credentials Grant

客户端用它自己的客户单凭证去请求获取访问令牌

![img](https://images2018.cnblogs.com/blog/874963/201806/874963-20180613132731411-243294503.png)

客户端凭证授权流程如图所示：

1. (A)  客户端用授权服务器的认证，并请求获取访问令牌
2. (B)  授权服务器验证客户端身份，如果严重通过，则发放令牌

###   Access Token Request

- grant_type：必须的。值必须是"client_credentials"。
- scope：可选的。

**例如：**

　　POST /token HTTP/1.1
　　Host: server.example.com
　　Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW
　　Content-Type: application/x-www-form-urlencoded

　　grant_type=client_credentials

###  Access Token Response

**例如：**

　　HTTP/1.1 200 OK
　　Content-Type: application/json;charset=UTF-8
　　Cache-Control: no-store
　　Pragma: no-cache

　　{
　　　　"access_token":"2YotnFZFEjr1zCsicMWpAA",
　　　　"token_type":"example",
　　　　"expires_in":3600,
　　　　"example_parameter":"example_value"
　　}



#  Issuing an Access Token

## Successful Response

授权服务器发放令牌

- access_token：必须的。
- token_type：必须的。比如："bearer"，"mac"等等
- expires_in：推荐的。
- refresh_token：可选的。
- scope：可选的。

media type是application/json，参数被序列化成JSON对象。

授权服务器必须包含"Cache-Control"HTTP头，并且值必须是"no-store"。

**例如：**

　　HTTP/1.1 200 OK
　　Content-Type: application/json;charset=UTF-8
　　Cache-Control: no-store
　　Pragma: no-cache

　　{
　　　　"access_token":"2YotnFZFEjr1zCsicMWpAA",
　　　　"token_type":"example",
　　　　"expires_in":3600,
　　　　"refresh_token":"tGzv3JOkF0XG5Qx2TlKWIA",
　　　　"example_parameter":"example_value"
　　}

#  Refreshing an Access Token

请求参数

- grant_type：必须的。值必须是"refresh_token"。
- refresh_token：必须的。
- scope：可选的。

**例如：**

```
   POST /token HTTP/1.1
　　Host: server.example.com
　　Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW
　　Content-Type: application/x-www-form-urlencoded
　　
　　grant_type=refresh_token&refresh_token=tGzv3JOkF0XG5Qx2TlKWIA
```