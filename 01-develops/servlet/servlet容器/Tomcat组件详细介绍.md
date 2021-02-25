## Tomcat组件详细介绍

### 顶级组件Server

　　服务器(server)：表示一个正在JVM运行的Tomcat实例 (单例的)；Server代表整个catalina servlet容器；包含一个或多个service子容器。

　　![img](E:\00justin\03-Note\01-Note\Notes\01-develops\servlet\servlet容器\server.png)

 

　　Server代表完整的Tomcat实例，在Java虚拟机中是单例，主要是用来管理容器下各个Serivce组件的生命周期。

　　Server实例是通过server.xml配置文件来配置的；其根元素<Server>所代表的正是Tomcat实例，默认实现为org.apache.catalina.core.StandardServer。但是，你也可以通过<Server>标签的class属性来自定义服务器实现。

　　服务器重要的一方面就是它打开了8005端口（默认端口）来监听关闭服务命令（默认情况下命令为SHUTDOWN）。当收到shutdown命令后，服务器会优雅的关闭自己。同时出于安全考虑，发起关闭请求的连接必须来自同一台机器上的同一个运行中的Tomcat实例。

　　Server还提供了一个Java命名服务和JNDI服务，可以通过这两个服务可以使用名称来注册专用对象（如数据源配置）。在运行期，单个组件（如Servlet）**可以使用对象名称来通过服务器的JNDI绑定服务来查找需要的对象相关信息**。虽然JNDI实现并不是Servlet容器的功能，但是它属于JavaEE规范一部分，并且可以为Servlet从应用服务器或者servlet容器中获取所需要的信息提供服务。

　　虽然在一个JVM中通常只有一个服务器实例，但是完全可以在同一台物理机器中运行多个服务器实例，每个实例对应一个JVM实例（一台物理服务器上可以在启动多个JVM的情况下在每一个JVM中启动一个Tomcat实例，每个实例分属于一个独立的管理端口。）；这种做法将运行在一个JVM中的应用中的错误与其他JVM中应用的错误隔离开来互不影响，这也简化了维护使得JVM的重启与其他独立开来。这是一个共享主机环境的机制（另一种是虚拟主机机制,很快我们将会看到），这种机制下需要将运行在同一物理主机下的多个web应用隔离开来。

 

### 顶级组件Service

　 Server代表Tomcat实例本身，Service则代表Tomcat中一组处理请求,提供服务的组件。包括多个Connector和一个Container。

 　![img](E:\00justin\03-Note\01-Note\Notes\01-develops\servlet\servlet容器\service.png)

 

　　 Server可以包含一个或多个Service，但每个Service则将一组Connector组件和Engine关联了起来。

　　 客户端请求首先到达连接器(connector),连接器在再将这些请求轮流传入引擎中处理，而Engine也是Tomcat中请求处理的关键组件。上图中展示了HTTP连接器、HTTPS连接以及AJP组件。

　　一个Service集中了一些连接器，每个连接器监控一个指定的IP及端口并通过指定的协议做出响应。

　　所以，一个关于多个服务的使用示例就是当你希望通过IP地址或者端口号来区分不同服务（包括这些服务中所包含的engine、host、web应用）时。例如，当需要配置防火墙来为用户开放某一个服务而该主机上托管的其他服务仍然只是对内部用户可见，这将确保外部用户无法访问内部应用程序，因为对应访问会被防火墙拦截。因此，Service仅仅是一个分组结构，它并不包含任何其他的附加功能。

 

###  Connector

　　Connector是客户端连接到Tomcat容器的服务点，它为引擎提供协议服务来将引擎与客户端各种协议隔离开来，如HTTP、HTTPS、AJP协议。

　　Tomcat有两种可配的工作模式--独立模式或在同一web服务器中共享模式。

　　独立模式：

　　![img](E:\00justin\03-Note\01-Note\Notes\01-develops\servlet\servlet容器\connector.png) 

 　**一个Connecter将在某个指定的端口上侦听客户请求，接收浏览器的发过来的 tcp 连接请求，创建一个 Request 和 Response 对象分别用于和请求端交换数据，然后会产生一个线程来处理这个请求并把产生的 Request 和 Response 对象传给处理Engine(Container中的一部分)，从Engine出获得响应并返回客户。**

　　在独立模式下，Tomcat会配置HTTP和HTTPS连接器，这可以使Tomcat看起来更像完整的web服务器以处理静态请求内容同时还委托Catalina引擎来处理动态内容。

　　发布时，Tomcat为这种运作模式提供了3种可能实现，即HTTP、HTTP1.1以及HTTPS。

　　Tomcat中最常见的连接器为标准连接器，也就是通过java标准I／O实现的Coyote连接器。

　　你也许希望使用一些技术实现，这其中就包括使用Java1.4中引入的非阻塞特性NIO，另一方面可能是通过APR充分利用本地代码来优化特定的操作系统。

　　值得注意的是，Connector和Engine不仅运行在同一个JVM中，而且还运行在同一个Tomcat服务实例中。

 

　　共享模式：

  ![img](E:\00justin\03-Note\01-Note\Notes\01-develops\servlet\servlet容器\connector-share model.png)

　　在共享模式中，Tomcat扮演着对web服务器如Apache httpd、Nginx和微软的IIS支撑的角色。这里web服务器充当客户端通过Apache模块或者通过dll格式ISAPI模块来和Tomcat通信。当该模块判定一个请求需要传入Tomcat处理时，它将使用AJP协议来与Tomcat通信，该协议为二进制协议，在web服务器和Tomcat通信时比基于文本的Http协议更高效。

　　在Tomcat端，通过AJP连接器来接收web服务器的请求，并将请求解释为Catalina引擎可处理的格式。

　　这种模式下Tomcat作为来自web服务器的单独进程运行在自身独立的JVM中。

 

　　不论在哪种模式中，Connector的基本属性都是它所需要监听的IP地址及端口号，以及所支持的协议。还有一个关键属性就是并发处理传入请求的最大线程数。一旦所有的处理线程都忙，那么传入的请求都将被忽略，直到有线程空闲为止。

　　默认情况下，连接器会监听指定物理机器上的所有IP（address属性默认值为0.0.0.0）；但也可以配置为只监听某一个IP，这将限制它只接收指定ip的连接请求。

　　任意一个连接器接收到的请求都会被传入单一的服务引擎中，而这个引擎，就是众所周知的catalina，它负责处理请求并生成响应结果。

　　引擎将生成的结果返回给连接器，连接器再通过指定的协议将结果回传至客户端。

 

　　**注意，Connector关键的有 连接器（HTTP  HTTPS  HTTP1.1  AJP  SSL proxy）** 　

　　　　　　　　　　　　　　**运行模式（BIO NIO NIO2/AIO APR）**

　　　　　　　　　　　　　　**多线程/线程池**

 　 

　　看一下Connector的结构图（图B），如下所示：

　　![img](E:\00justin\03-Note\01-Note\Notes\01-develops\servlet\servlet容器\connector-2.png)

　　Connector就是使用ProtocolHandler来处理请求的，不同的ProtocolHandler代表不同的连接类型，比如：Http11Protocol使用的是普通Socket来连接的，Http11NioProtocol使用的是NioSocket来连接的。

　　其中ProtocolHandler由包含了三个部件：Endpoint、Processor、Adapter。

　　（1）Endpoint用来处理底层Socket的网络连接，Processor用于将Endpoint接收到的Socket封装成Request，Adapter用于将Request交给Container进行具体的处理。

　　（2）Endpoint由于是处理底层的Socket网络连接，因此Endpoint是用来实现TCP/IP协议的，而Processor用来实现HTTP协议的，Adapter将请求适配到Servlet容器进行具体的处理。

　　（3）Endpoint的抽象实现AbstractEndpoint里面定义的Acceptor和AsyncTimeout两个内部类和一个Handler接口。Acceptor用于监听请求，AsyncTimeout用于检查异步Request的超时，Handler用于处理接收到的Socket，在内部调用Processor进行处理。

### Container

　　Container用于封装和管理Servlet，以及具体处理Request请求；包含4大请求处理组件：引擎（engine）、虚拟主机、上下文（context）组件。

　　Container是容器的父接口，用于封装和管理Servlet，以及具体处理Request请求，该容器的设计用的是典型的责任链的设计模式，它由四个自容器组件构成，分别是Engine、Host、Context、Wrapper。这四个组件是负责关系，存在包含关系。只包含一个引擎。

### 容器组件Engine

　　引擎表示可运行的Catalina的servlet引擎实例，并且包含了servlet容器的核心功能。在一个服务中只能有一个引擎。同时，作为一个真正的容器，Engine元素之下可以包含一个或多个虚拟主机。

　　![img](E:\00justin\03-Note\01-Note\Notes\01-develops\servlet\servlet容器\engine.png)

　　作为请求处理的主要组件，它接收Connector传入请求的对象以及输出相应结果。**它主要功能是将传入请求委托给适当的虚拟主机处理。如果根据名称没有找到可处理的虚拟主机，那么将根据默认的Host来判断该由哪个虚拟主机处理。**

　　引擎通是指处理请求的Servlet引擎组件，即Catalina Servlet引擎，它检查每一个请求的HTTP首部信息以辨别此请求应该发往哪个host或context，并将请求处理后的结果返回的相应的客户端。严格意义上来说，容器不必非得通过引擎来实现，它也可以是只是一个容器。如果Tomcat被配置成为独立服务器，默认引擎就是已经定义好的引擎。而如果Tomcat被配置为Apache Web服务器的提供Servlet功能的后端，默认引擎将被忽略，因为Web服务器自身就能确定将用户请求发往何处。一个引擎可以包含多个host组件。

### 容器组件Host

　　虚拟主机在Tomcat中使用Host组件表示，是web应用容器或者是Tomcat中所说的上下文。

　　Host 是 Engine 的子容器，一个 Host 在 Engine 中代表一个虚拟主机，这个虚拟主机的作用就是运行多个应用，它负责安装和展开这些应用，并且标识这个应用以便能够区分它们。它的子容器通常是 Context，它除了关联子容器外，还有就是保存一个主机应该有的信息。一个虚拟主机下都可以部署一个或者多个Web App，每个Web App对应于一个Context，当Host获得一个请求时，将把该请求匹配到某个Context上，然后把该请求交给该Context来处理。

　　在虚拟主机中有两个概念非常重要--主机的域名和根目录。

　　**域名**：每个虚拟主机是由它注册的域名来标识的（例：www.host1.com）。域名是您预期的在客户端浏览器地址栏输入的值，对虚拟主机来说就是请求头部。一台虚拟主机的名称在包含它的引擎内必须是唯一的。

　　**根目录**：根目录所在的文件夹包含将被部署到此主机的上下文。根目录可以是一个绝对路径，也可以是对CATALINA_BASE 来说的一个相对路径。

 　CATALINA_HOME 是一个环境变量，它引用了tomcat 二进制文件的位置。通过CATALINA_BASE 环境变量仅仅使用一个tomcat安装信息的二进制文件，就可以根据不同的配置运行多个tomcat实例（这主要由conf文件夹的内容决定）。此外，使用一个CATALINA_BASE引用的位置（和CATALINA_HOME不同）保持标准的二进制分配独立于您的安装。这是有好处的，使tomcat升级到一个新版本变得容易，而不必担心影响已经发布的web应用程序和相关的配置文件 。

　　 虚拟主机技术，有两种常用的方法来设置虚拟主机：1. 基于独立IP地址的虚拟主机服务2. 基于名称的虚拟主机服务

### 　　1) 基于独立IP地址的虚拟主机服务

　　使用这种技术，每个FQHN(完全合格的主机名)被解析为一个单独的IP地址。然而，这些IP中的每一个被解析后都映射到同一台物理机器上。

　　![img](E:\00justin\03-Note\01-Note\Notes\01-develops\servlet\servlet容器\host.png)

　　您可以使用以下的机制来实现此技术：

　　　　多宿主服务器，也就是说它安装了多个网卡(NICs),每一个网卡都分配了IP地址

　　　　使用操作系统功能来设置虚拟网络接口，为单个物理NIC（网卡）动态分配多个IP地址

　　无论在哪一种情况下，缺点是我们要获得多个IP地址，而且这些地址(至少对于IPv4来说)是一种有限的资源。

　　Web服务器监听为这些IP地址分配的端口，当Web服务器在一个特定的IP地址检测到传入的请求时，它会生成该IP地址的响应信息。

　　例如，您有一个web服务器，它运行在一个特定的在80端口监听 11.156.33.345 和 11.156.33.346 IP地址请求的物理主机上。此web服务器用以下方式响应请求：当收到来自主机域名www.host1.com的请求时，则映射到11.156.33.345 IP地址；反之当收到来自主机域名www.host2.com的请求时则映射到后面的 IP地址 11.156.33.346 。

　　当接收到一个来自11.156.33.346 IP地址的请求时，web服务器知道它应当为ww.host2.com对应的域准备响应信息。对用户来说，这是一个完全独立的物理服务器在为他提供服务。

### 　　2) 基于名称的虚拟主机服务

　　![img](E:\00justin\03-Note\01-Note\Notes\01-develops\servlet\servlet容器\host-2.png)

　　这是一种比较新的技术，它允许您把不同的域名映射到同一个IP地址。这些都是经过注册的正常的域名，多个DNS条目将这些域名映射到同一IP地址。

　　HTTP 1.1协议要求每个请求必须包含一个主机头：带有完全合格的主机域名，以及用户希望连接的端口号(如果已指定)。主机上运行的web服务器接收到此请求，解析此请求中的主机头信息，以确定相应的虚拟主机来响应此请求。简单、而且不使用不必要的IP地址，基于名称的虚拟主机服务是我们的首选。

　　然而，当您同时使用SSL(安全套接层)和虚拟主机时，您也许不得不使用基于IP地址的虚拟主机服务。原因是，在特定的虚拟主机响应请求之前，协商协议要进行证书认证。这是因为：**SSL协议层位于HTTP协议层的下方，而且在握手消息认证完成之前，与客户端请求进行安全认证的模块无法读取HTTP请求头信息。**

　　您也许可以同时使用SSL和基于名称的虚拟主机服务，如果您的web服务器和客户机支持RFC 3546(传输层安全性扩展) 指定的服务器名称标识扩展。使用此扩展，在SSL协商期间，客户端会传输主机名称给它尝试连接的对象，从而使web服务器能够处理握手信息并为正确的主机名返回证书。

　　**虚拟主机别名**

　　当web服务器解析别名信息时，例如它在主机头里看到了域名的别名，那么web服务器会把此别名当作虚拟主机的域名来处理。 例如，您把swengsol.com设置为虚拟主机域名www.swengsol.com的别名，那么在客户端url里无论是输入域名还是别名，您都会收到来自同一个虚拟主机的响应信息。 这种方式效果不错，当一个物理主机有多个域名时，而且您不想弄乱配置文件在为每个别名创建一组条目时。

 

### 容器组件Context　

　　Context上下文代表 Servlet 的 Context，它具备了 Servlet 运行的基本环境，它表示Web应用程序本身。理论上只要有 Context 就能运行 Servlet 了。简单的 Tomcat 可以没有 Engine 和 Host。Context 最重要的功能就是管理它里面的 Servlet 实例，Servlet 实例在 Context 中是以 Wrapper 出现的，还有一点就是 Context 如何才能找到正确的 Servlet 来执行它呢？ Tomcat5 以前是通过一个 Mapper 类来管理的，Tomcat5 以后这个功能被移到了 request 中，在前面的时序图中就可以发现获取子容器都是通过 request 来分配的。一个Context对应于一个Web Application，一个Web Application由一个或者多个Servlet组成。

　　上下文或者web应用是应用自定义代码（servlet、jsp）所存活的地方。它为web应用组织资源提供了便利。

　　![img](E:\00justin\03-Note\01-Note\Notes\01-develops\servlet\servlet容器\context.png)

　　同时context容器为servlet提供了一个ServletContext实例。在许多方面,servlet规范主要是关心这个上下文组件。例如，它规定了部署上下文的格式以及部署内容的描述符。

　　以下是上下文的一些重要属性：

　　**根目录（document base）**：这个路径是指war包或者未压缩的项目文件所存放的目录，可以是相对的，也可以是绝对的。

　　**上下文路径（context path）**：它是指在一个host下url中唯一标识一个web应用的部分。它帮助host容器来判断该由哪一个已部署的上下文来处理传入的请求。

　　也许你可能配置了默认context，它可以在找不到匹配的context的情况下来处理传入请求。该默认context可以通过将其上下文路径配置为空来标记的，因此，可以通过只有主机名的路径来访问它（译注：如http://localhost:8080/来访问）。并且该context已被tomcat默认定义为根目录下的ROOT目录。

·　　**自动重加载（automic reload）**：上下文中的资源会被tomcat监控，一旦资源发生改变Tomcat就会自动重新加载资源文件。虽然该功能在开发过程中非常有用，但是在生产环境这个操作代价非常高，通常需要重启产品应用。

　　Context配置

　　Context是唯一的，这主要是因为它的配置包含多个选项。而我们之前已经注意到的conf/server.xml是用来配置Tomcat实例中一些全局性的参数。虽然在这个文件中可以配置context相关的东西，但是不推荐这样做。相反，Tomcat推荐大家将context相关的配置从server.xml中提取出来，配置到上下文段文件中，该文件会被Tomcat监控并且可以在运行过程中重新加载。请再次注意，server.xml只有在启动时被加载一次。同时需要确保在context中配置一个独立明确的host和engine，因为Tomcat会在CATALINA_HOME/conf///目录下查找context相关配置。而该目录下为特定主机配置的上下文段文件则是以名称.xml命名。默认情况下，会有一个引擎Catalina和一个名称为localhost的主机，对应的工作目录为CATALINA_HOME/conf/Catalina/localhost。但是该目录也可以是有效域名，如www.swengsol.com，那么对应目录就是CATALINA_HOME/conf/Catalina/www.swengsol.com。另外，context片段也可以在war或部署目录中被包含在META-INF目录下。这种情况下，context文件名称必须为context.xml。此外，Context还可以被配置在web应用描述符文件web.xml中。虽然这个片段文件是Tomcat专用的，但是由于该描述符是通过Servlet规范来描述的，因此它也适用与JavaEE下的其他轻量级servlet容器。

　

### 容器组件Wrapper

　　包装器wrapper对象是context容器的子容器，表示一个单独的servlet（或者由jsp文件转换而来的servlet）。它之所以称为包装器是因为它包装了java.servlet.Servlet实例。　　

 　Wrapper : 代表一个 Servlet，它负责管理一个 Servlet，包括的 Servlet 的装载、初始化、执行以及资源回收。Wrapper 是最底层的容器，它没有子容器了，所以调用它的 addChild 将会报错。

　　![img](E:\00justin\03-Note\01-Note\Notes\01-develops\servlet\servlet容器\wrapper.png)

　　这是容器层次结构的最底层，添加任何子类都会导致异常。

　　同时包装器还对它所包装的servlet负责，包括加载、实例化servlet以及调用控制servlet生命周期相关的函数，如init()、service()和destroy()方法。

　　此外包装器还通过它基本的Valve来调用和其包装的servlet相关的过滤器。

 

###  嵌套组件Valve

　　valve是处理元素，它可以被包含在每个Tomcat容器的处理路径中--如engine、host、context以及servelt包装器。若要增加Valve到Tomcat容器则需要在server.xml中使用<Valve>标签。在server.xml中这些标签的执行顺序与其物理顺序相同。

　　而在Tomcat中也分布这大量预先编译好的valve。包括：

• 在请求日志元素中将请求（如远程客户端ip地址）写入日志文件或数据库时

• 根据远程客户端ip或主机名来控制某一特定web应用的访问权限时

• 记录每个请求和响应头信息日志时

• 在同一个虚拟主机下为多个应用配置单点登录时

　　如果以上这些都不能满足你的要求，那么你可以通过继承org.apache.catalina.Valve来实现自定义的Valve并将其配置到对应服务中。

　　![img](E:\00justin\03-Note\01-Note\Notes\01-develops\servlet\servlet容器\valve.png)

　　但是对于一个容器来说，它并不会持有某个单独valve的引用；相反，它会持有一个称作管道（Pipeline）的单一实体的引用，并用这个管道来表示与该容器所关联的一系列valve。当一个容器被调用来处理一个请求时，它会委托与其关联的管道来处理对应请求。在管道中，这些valve则是基于他们在server.xml中的定义作顺序排列。其中排在队列中排在最后的valve被称为管道的基本valve，该valve用来完成去执行容器的核心功能的任务。与单个valve不同，管道在server . xml不是一个明确的元素，而是含蓄的按照valve在给定容器中所定义的顺序组成。并且在管道中，每个valve都知道其下一个valve；在它执行完前置处理以后，接下来它会调用链中的下一个valve，当该调用返回以后，它会在return之前执行他自身的处理任务。这种方式和servlet规范中的过滤器链所做的事情非常相似。

　　在这幅图中，**当接收到传入请求时引擎所配置的valve首先被触发。其中引擎中基本的valve负责确定目标主机委托该主机来处理；接下来目标主机(www.host1.com)的valve被按顺序触发。而该主机的基本valve则又决定了目标context(在这里是Context1)并且委托该context来处理该请求。最后Context1中所配置的valve被触发，然后通过context中配置的基本valve委托给适当的包装器来处理；而包装器的基本valve又将处理转交至被包装的servlet来处理。处理完成以后，响应结果会按照以上的路径反方向返回。**

　　由于Valve就成了Tomcat服务器实现中的一部分，并且可以为开发者提供一种方式将自定义的代码注入到处理请求的servlet容器中。因此，自定的valve类文件需要发布到CATALINA_HOME/lib目录下而不是应用的发布目录WEB-INF/classes。由于它们并不是servlet规范中的部分，所以valve在企业级一用中属于不可移植元素。因此，如果已经依赖了一个特定的valve时，你必须在不同的应用服务器上找到对等的选择方案。

　　还有很重要的一点就是，为了不影响请求处理的效率必须要保证valve的代码高效执行。 

### 嵌套组件Realm

　　容器管理安全方面的工作通过容器处理应用程序的身份验证和授权方面来解决。身份验证存在的主要任务就是确保用户所说的就是她自己，而授权的主要任务是决定一个用户是否可以在某个应用下执行特定操作。由容器来管理安全的优势是可以通过应用的发布者直接来配置安全措施。也就是说，为用户分配密码以及为用户分配角色都可以用户配置来完成，而这些配置也可以在修改任何代码的情况下来供多个web应用共用。

　　应用管理安全，还有一种可选方案就是通过应用来管理安全问题。这种情况下，我的web应用程序代码就是唯一的仲裁者来决定用户在我们的应用下是否有访问特定功能或资源的权限。

　　想要使容器来管理安全问题起作用，我们需要组装一下组件：

• 安全约束：在我们的web应用部署描述器web.xml中，我们必须确定限制资源访问的url表达式以及可以访问这些资源的用户角色。

• 凭证输入机制：在web.xml部署文件中，我们需要指定容器应该如何提示用户通过凭证来验证。这通常是通过弹出一个对话框提示用户输入用户名和密码来完成，但也可以配置使用其他机制,如一个定制的登录表单等。

• Realm：这是一个数据存储机制来保存用户名、密码以及角色来对用户所提供的凭证信息进行检查。它可以是一个简单的xml文件，一个通过JDBC API来访问的关系型数据库中的一张表或者是可以通过JNDI API访问的轻量级目录访问协议服务器（LDAP）。正是Realm为Tomcat提供了一致的访问机制来访问这些不同的数据源。

　　以上这三种组件在技术上是相互独立的。基于容器安全的威力就在于我们可以根据我们自身的安全情况从这几种方式中选出适合的一种或几种方式来混合使用。至此，当一个用户请求一个资源时，Tomcat将检查对所请求的资源是否已经存在了安全限制。对于存在限制的资源，Tomcat将自动要求用户提供身份凭证并通过所配置的Realm来检查用户所提供凭证是否符合。只有在用户所提供的凭证信息通过了验证或者用户的角色在可访问资源的配置之列才能访问对应资源。

###  嵌套组件Excutor

　　这是从tomcat 6.0.11版本开始，新增的一个组件。执行器组件允许您配置一个共享的线程池，以供您的连接器使用。您的连接器可能使并发线程的数量达到上限。请注意，此限制同样适用于：即使一个特定的连接器没有用完为它配置的所有线程。

### 嵌套组件Listener

　　每个主要的tomcat组件都实现了org.apache.catalina.Lifecycle接口。实现了该接口的组件注册到监听器，然后该组件的生命周期事件被触发，比如该组件的启动和停止都会被监听。一个监听器实现了org.apache.catalina.LifecycleListener接口，也实现了该接口的lifecycleEvent()方法，监听器捕捉到一个LifecycleEvent 表示事件已经发生。这就给您提供了一个机会：把您自定义的进程注入到tomcat的生命周期。

###  嵌套组件Session Manager

　　会话让使用无状态HTTP协议的应用程序完成通信。会话表示客户端和服务器之间的通信，会话功能是由javax.servlet.http.HttpSession 的实例实现的，该实例存储在服务器上而且与一个唯一的标识符相关联，客户端在与服务器的每次交互中根据请求中的标识符找到它的会话。一个新的会话在客户端请求后被创建，会话一直有效直到一段时间后客户端连接超时，或者会话直接失效例如客户退出访问服务器。

　　![img](E:\00justin\03-Note\01-Note\Notes\01-develops\servlet\servlet容器\session manager.png)

 　　上图显示了一个非常简单的 tomcat 会话机制视图。Catalina 引擎(engine)使用了组件org.apache.catalina.Manager 去创建、查找、注销会话。该组件负责管理为上下文创建的会话以及会话的生命周期。会话管理器(Manager)把会话存放在内存中，但是它支持在服务器重启时恢复会话。当服务器停止时，会话管理器把所有活动的会话写入磁盘，当服务器重新启动时把会话重新加载到内存。

　　一个<Manager>必须是 <Context>的子节点，而且<Manager>负责管理与web应用程序上下文相关的会话。

　　会话管理器管理这样的属性：例如用来生成会话标识符的算法，每秒钟检查过期会话的频率，支持的活动会话的最大数目，以及持久化会话的文件。

　　会话管理器实现了这样的功能：为会话提供持久化存储，例如一个文件或一个JDBC数据库。

###  嵌套组件Loader

　　这个组件是一个给定的web应用程序的类加载器。简而言之，类加载器负责加载、解释Java类编译后的字节码。

　　一个Java类的字节码可能存放在各种不同的位置，最常见的是在本地文件系统或网络中。类加载器的主要任务是：抽象字节如何被获取以及如何重组到内存中的类的过程。

 