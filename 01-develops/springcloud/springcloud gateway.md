# Spring Cloud Gateway(SCG)

## 概述

网关作为一个系统的流量的入口，有着举足轻重的作用，通常的作用如下：

- **协议转换，路由转发**
- **流量聚合，对流量进行监控，日志输出**
- **作为整个系统的前端工程，对流量进行控制，有限流的作用**
- **作为系统的前端边界，外部流量只能通过网关才能访问系统**
- **可以在网关层做权限的判断**
- **可以在网关层做缓存**

## 架构

处于**系统流量入口** ，具体见springcloud 架构图



## 流程

![img](.\springcloudgateway-flow.png)

SCG自带GlobalFilter的执行顺序:

![img](.\SCG-filters-execution-order.png)



处理流程如下：

- 客户端向Spring Cloud Gateway发出请求
- Gateway Handler Mapping确定请求与路由是否匹配（**predicate** 判断）
- 如果匹配，将其发送到Gateway web handler处理（ Gateway web handler处理请求时会经过一系列的过滤器链。 过滤器链被虚线划分的原因是过滤器链可以在发送代理请求之前或之后执行过滤逻辑）
- 先执行所有“pre”过滤器，然后进行代理请求
- 收到代理服务的响应之后执行“post”过滤器。

在执行所有**“pre”**过滤器逻辑时，往往进行了**鉴权、限流、日志输出**等功能，以及**请求头的更改、协议的转换**；

收到响应之后，会执行所有“**post**”过滤器的逻辑，在这里可以响应数据进行了修改，比如**响应头、协议的转换**等。



## 设计模式

主要是采用了 

- **责任链 （response chain）** 模式 -- **过滤器**的设计

- **建造者（builder） 模式**  -- **RouteLocatorBuilder**
- **工厂（factory）** **模式**



## 注意

"pre" filter "post" filter 是在实际代码中区分的。**实际就是业务代码 和 提交过滤器链继续执行过滤的顺序**决定了过滤器是 pre 还是 post，这也是符合逻辑的。

如下：

### PreFilter

```java
public class PreGatewayFilterFactory extends AbstractGatewayFilterFactory {
	@Override
	public GatewayFilter apply(Config config) {
		return (exchange, chain) -> {
            // business logic
            return chain.filter();
		};
	}
}
```

### postFilter

```java
public class PostGatewayFilterFactory extends AbstractGatewayFilterFactory {
	@Override
	public GatewayFilter apply(Config config) {
		return (exchange, chain) -> {
			return chain.filter(exchange).then(/* business logic */);
		};
	}
}
```

可以看到，二者**其实只有业务代码位置的不同**





## Predicate

### 简介

Predicate来自于java8的接口。

**Predicate 接受一个输入参数，返回一个布尔值结果。**

该接口包含多种默认方法来将Predicate组合成其他复杂的逻辑（比如：add–与、or–或、negate–非）。可以用于接口请求参数校验、判断新老数据是否有变化需要进行更新操作。



### 类型

Spring Cloud Gateway内置了许多Predict（org.springframework.cloud.gateway.handler.predicate），如下图：

![img](.\Predicate.png)



1. 时间类型的Predicated（AfterRoutePredicateFactory BeforeRoutePredicateFactory BetweenRoutePredicateFactory），当只有满足特定时间要求的请求会进入到此predicate中，并交由router处理；

2. cookie类型的CookieRoutePredicateFactory，指定的cookie满足正则匹配，才会进入此router;

3. 及host、method、path、querparam、remoteaddr类型的predicate，每一种predicate都会对当前的客户端请求进行判断，是否满足当前的要求，如果满足则交给当前请求处理。

   **如果一个请求满足多个Predicate，则按照配置的顺序第一个生效。**





### 示例

SCG配置：

```
spring:
  cloud:
    gateway:
      routes:
      - id: after_route
        uri: http://httpbin.org:80/get
        predicates:
        - After=2017-01-20T17:42:47.789-07:00[America/Denver]
```

#### Predicates 配置的含义



Predicate中参数和值之间**使用 ‘，’ 分隔**



#### After Route Predicate Factory

After=2017-01-20T17:42:47.789-07:00[America/Denver] 会被解析成 **PredicateDefinition** 对象 （name =After ，args= 2017-01-20T17:42:47.789-07:00[America/Denver]）。

 predicates 的 After 这个配置，遵循的 **约定大于配置** 的思想（**只有SCG内继承  AbstractRoutePredicateFactory 的 Predicate 工厂支持**），它实际被 **AfterRoutePredicateFactory** 这个类所处理

 **After** 就是指定了它的 **Gateway web handler** 类为 AfterRoutePredicateFactory ，同理，其他类型的predicate也遵循这个规则。



#### Header Route Predicate Factory

Header Route Predicate Factory需要2个参数，一个是**header名**，另外一个**header值**（**逗号分隔**），该值可以是一个正则表达式。当此断言匹配了请求的header名和值时，断言通过，进入到router的规则中去。

```
predicates:
        - Header=X-Request-Id, \d+
```

当请求的Header中有X-Request-Id的header名，且header值为数字时，请求会被路由到配置的 uri

如果在请求中没有带上X-Request-Id的header名，或者值不为数字时，请求就会报**404**，路由没有被正确转发

#### Cookie Route Predicate Factory

Cookie Route Predicate Factory需要2个参数，一个时**cookie名字**，另一个是**值**，可以为正则表达式



#### Host Route Predicate Factory

Host Route Predicate Factory需要**一个参数hostname**，它可以使用. * 等去匹配host。

这个参数会匹配请求头中的host的值，一致，则请求正确转发



#### Method Route Predicate Factory

Method Route Predicate Factory 需要**一个参数请求的类型**。比如GET类型的请求都转发到此路由



#### Path Route Predicate Factory

Path Route Predicate Factory 需要**一个参数: spel表达式**，应用匹配路径



#### Query Route Predicate Factory

Query Route Predicate Factory 需要2个参数:一个**参数名**和一个**参数值的正则表达式**





## Filter

filter从作用范围可分为另外两种

一种是针对于单个路由的gateway filter，它在配置文件中的写法同predict类似；

另外一种是针对于所有路由的global gateway filer



## Gateway filter

GatewayFilter 工厂同 Predicate 工厂类似，都是在配置文件application.yml中配置，遵循**约定大于配置** （继承 AbstractGatewayFilterFactory   **filter factory**） 的思想

只需要在配置文件配置GatewayFilter Factory的名称，而不需要写全部的类名，比如AddRequestHeaderGatewayFilterFactory只需要在配置文件中写AddRequestHeader，而不是全部类名。

Spring Cloud Gateway 内置的过滤器工厂一览表如下

![image-20200929145810747](.\Filter.png)



![filter1](.\filter1.png)



### 示例



### AddRequestHeader GatewayFilter Factory

```
spring:
  cloud:
    gateway:
      routes:
      - id: add_request_header_route
        uri: http://httpbin.org:80/get
        filters:
        - AddRequestHeader=X-Request-Foo, Bar
        predicates:
        - After=2017-01-20T17:42:47.789-07:00[America/Denver]
  profiles: add_request_header_route
```

配置了 roter 的 id 为 add_request_header_route，路由地址为 http://httpbin.org:80/get，

该 router 有 AfterPredictFactory，有一个 **filter 为 AddRequestHeaderGatewayFilterFactory** ( **约定写成AddRequestHeader** )，AddRequestHeader过滤器工厂会**在请求头加上一对请求头，名称为X-Request-Foo，值为Bar**



### RewritePath GatewayFilter Factory

```
spring:
  cloud:
    gateway:
      routes:
      - id: rewritepath_route
        uri: https://blog.csdn.net
        predicates:
        - Path=/foo/**
        filters:
        - RewritePath=/foo/(?<segment>.*), /$\{segment}
  profiles: rewritepath_route
```

所有的 /foo/** 开始的路径都会命中配置的 router，并执行过滤器的逻辑。

在本案例中配置了RewritePath过滤器工厂，此工厂将  /foo/(?.*) 重写为 {segment} ，然后转发到 https://blog.csdn.net。比如在网页上请求 localhost:8081/foo/forezp，此时会将请求转发到 https://blog.csdn.net/forezp 的页面，比如在网页上请求localhost:8081/foo/forezp/1，页面显示404，就是因为不存在 https://blog.csdn.net/forezp/1 这个页面。



### 自定义 GatewayFilter

实现自定义的`Gateway Filter`我们需要`GatewayFilter、Ordered`两个接口

```java
public class RequestTimeFilter implements GatewayFilter, Ordered {

    private static final Log log = LogFactory.getLog(GatewayFilter.class);
    private static final String REQUEST_TIME_BEGIN = "requestTimeBegin";

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {

        exchange.getAttributes().put(REQUEST_TIME_BEGIN, System.currentTimeMillis());
        return chain.filter(exchange).then(
                Mono.fromRunnable(() -> {
                    Long startTime = exchange.getAttribute(REQUEST_TIME_BEGIN);
                    if (startTime != null) {
                        log.info(exchange.getRequest().getURI().getRawPath() + ": " + (System.currentTimeMillis() - startTime) + "ms");
                    }
                })
        );
    }

    @Override
    public int getOrder() {
        return 0;
    }
}
```

Ordered中的 int getOrder() 方法是来给过滤器设定优先级别的，值越大则优先级越低。

还有有一个**filter(exchange,chain)**方法，在该方法中，先记录了请求的开始时间，并保存在 ServerWebExchange 中，此处是在 **chain.filter().then** 中 执行业务代码，相当于"**post**"过滤器。

**自定义  gateway filter 以后，其需要跟`Route`绑定使用，不能在`application.yml`文件中直接配置使用**

```java
@Bean
    public RouteLocator routeLocator(RouteLocatorBuilder builder) {
        return builder.routes().route(r ->
                r.path("/aa")
                        //转发路由
                        .uri("http://localhost:8003/provider/test")
                        //注册自定义过滤器
                        .filters(new RequestTimeFilter())
                        //给定id
                        .id("user-service"))
                .build();
    }
```

**测试结果**：可以在控制台看到输出



#### 自定义Gateway Filter Factory

很多时候我们更希望在配置文件中配置 `Gateway Filter` ,所以我们可以自定义过滤器工厂实现。 
自定义过滤器工厂需要继承`AbstractGatewayFilterFactory`



```java
@Component
public class AuthorizeGatewayFilterFactory extends AbstractGatewayFilterFactory<AuthorizeGatewayFilterFactory.Config> {

    private static final Log logger = LogFactory.getLog(AuthorizeGatewayFilterFactory.class);

    private static final String AUTHORIZE_TOKEN = "token";
    private static final String AUTHORIZE_UID = "uid";

    @Autowired
    private StringRedisTemplate stringRedisTemplate;

    public AuthorizeGatewayFilterFactory() {
        super(Config.class);
        logger.info("Loaded GatewayFilterFactory [Authorize]");
    }

    @Override
    public List<String> shortcutFieldOrder() {
        return Arrays.asList("enabled");
    }

    @Override
    public GatewayFilter apply(AuthorizeGatewayFilterFactory.Config config) {
        return (exchange, chain) -> {
            if (!config.isEnabled()) {
                return chain.filter(exchange);
            }

            ServerHttpRequest request = exchange.getRequest();
            HttpHeaders headers = request.getHeaders();
            String token = headers.getFirst(AUTHORIZE_TOKEN);
            String uid = headers.getFirst(AUTHORIZE_UID);
            if (token == null) {
                token = request.getQueryParams().getFirst(AUTHORIZE_TOKEN);
            }
            if (uid == null) {
                uid = request.getQueryParams().getFirst(AUTHORIZE_UID);
            }

            ServerHttpResponse response = exchange.getResponse();
            if (StringUtils.isEmpty(token) || StringUtils.isEmpty(uid)) {
                response.setStatusCode(HttpStatus.UNAUTHORIZED);
                return response.setComplete();
            }
            String authToken = stringRedisTemplate.opsForValue().get(uid);
            if (authToken == null || !authToken.equals(token)) {
                response.setStatusCode(HttpStatus.UNAUTHORIZED);
                return response.setComplete();
            }
            return chain.filter(exchange);
        };
    }

    public static class Config {
        // 控制是否开启认证
        private boolean enabled;

        public Config() {}

        public boolean isEnabled() {
            return enabled;
        }

        public void setEnabled(boolean enabled) {
            this.enabled = enabled;
        }
    }
}
```

静态内部类类 **Config** 就是为了接收那个 **boolean 类型的参数**服务的，里边的变量名可以随意写，但是要重写 List shortcutFieldOrder() 这个方法。

需要**注意**的是，在类的构造器中一定要调用下父类的构造器把Config类型传过去，否则会报ClassCastException



在`application.yml`配置使用

```yaml
# 网关路由配置
spring:
  cloud:
    gateway:
      routes:
      - id: user-service
        uri: http://localhost:8077/api/user/list
        predicates:
        - Path=/user/list
        filters:
        # 默认绑定到 AuthorizeGatewayFilterFactory
        # 值为true则开启认证，false则不开启
        # 这种配置方式和spring cloud gateway内置的GatewayFilterFactory一致
        - Authorize=true
```





### Global Filter

Spring Cloud Gateway根据作用范围划分为GatewayFilter和GlobalFilter，二者区别如下：

- GatewayFilter : 需要通过 spring.cloud.routes.filters 配置在具体路由下，只作用在当前路由上或通过 **spring.cloud.default-filters** 配置在全局，作用在所有路由上
- GlobalFilter : **全局过滤器，不需要在配置文件中配置**，作用在所有的路由上，最终通过 GatewayFilterAdapter 包装成 GatewayFilterChain 可识别的过滤器，它为请求业务以及路由的URI转换为真实业务服务的请求地址的核心过滤器，**不需要配置，系统初始化时加载，并作用在每个路由上**。

![img](.\globalFilter.png)



### 自定义 GlobalFilter

实现自定义全局过滤器需要继承`GlobalFilter`和`Ordered`

```java
public class TokenFilter implements GlobalFilter, Ordered {

    Logger logger=LoggerFactory.getLogger( TokenFilter.class );
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String token = exchange.getRequest().getQueryParams().getFirst("token");
        if (token == null || token.isEmpty()) {
            logger.info( "token is empty..." );
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }
        return chain.filter(exchange);
    }

    @Override
    public int getOrder() {
        return -100;
    }
}
```

GlobalFilter **会校验请求中是否包含了请求参数 “token”**，如何不包含请求参数 “token” 则不转发路由，否则执行正常的逻辑

然后需要将TokenFilter在工程的启动类中注入到Spring Ioc容器中.



## Filter Order

自定义 **gateway Filter**，分两种情况  可以看 **RouteDefinitionRouteLocator.java** 的源代码：

- 如果RouteFilter实现了`Ordered`接口或者写了`@Order`注解，那么它的order就是它自己设定的值。
- 否则，它的order则是从1开始，按照Route中定义的顺序依次排序。

自定义 **Global Filter**， order 可以看 **FilteringWebHandler.java** 的源代码 ：

- 如果你的自定义Global Filter实现了`Ordered`接口或者写了`@Order`注解，那么它的order就是它自己设定的值
- 否则，它就没有order

最后SCG把它们两个结合起来，做一个排序，对于没有order的Filter，它的order则默认为`Ordered.LOWEST_PRECEDENCE`。关于这点可以看 **FilteringWebHandler.java** 的源代码。



### 注意

**GatewayFilterFactory 默认没有设置 Order ，是在获取 Routes 的时候，装配 filter ，并设置 GatewayFilterFactory 的顺序** 

一个路由如果配置了**多个 filter**， 实际顺序就是 **配置的先后顺序**

```java
@SuppressWarnings("unchecked")
List<GatewayFilter> loadGatewayFilters(String id,List<FilterDefinition> filterDefinitions) {
	ArrayList<GatewayFilter> ordered = new ArrayList<>(filterDefinitions.size());
		for (int i = 0; i < filterDefinitions.size(); i++) {
			FilterDefinition definition = filterDefinitions.get(i);
			GatewayFilterFactory factory = this.gatewayFilterFactories
					.get(definition.getName());
			if (factory == null) {
				throw new IllegalArgumentException(
						"Unable to find GatewayFilterFactory with name "
								+ definition.getName());
			}
			if (logger.isDebugEnabled()) {
				logger.debug("RouteDefinition " + id + " applying filter "
						+ definition.getArgs() + " to " + definition.getName());
			}

			// @formatter:off
			Object configuration = this.configurationService.with(factory)
					.name(definition.getName())
					.properties(definition.getArgs())
					.eventFunction((bound, properties) -> new FilterArgsEvent(
							// TODO: why explicit cast needed or java compile fails
							RouteDefinitionRouteLocator.this, id, (Map<String, Object>) properties))
					.bind();
			// @formatter:on

			// some filters require routeId
			// TODO: is there a better place to apply this?
			if (configuration instanceof HasRouteId) {
				HasRouteId hasRouteId = (HasRouteId) configuration;
				hasRouteId.setRouteId(id);
			}
			GatewayFilter gatewayFilter = factory.apply(configuration);
			if (gatewayFilter instanceof Ordered) {
				ordered.add(gatewayFilter);
			}
			else {
				ordered.add(new OrderedGatewayFilter(gatewayFilter, i + 1));
			}
		}
		return ordered;
	}
```



- **RouteLocator 实际就是一个 获取 routes 的接口** ，接口名实际可以理解为 Routes
- **Route** 中存放 Route 基本信息；**RouteDefinition** 是GatewayProperties 中的属性。主要是用于存放 从网关配置文件读取的**配置信息**。 **FilterDefinition** **PredicateDefinition** 类似。



## 源码流程

流程中的 Gateway Handler Mapping 对应一个关键类 ： RoutePredicateHandlerMapping

```java
public class RoutePredicateHandlerMapping extends AbstractHandlerMapping {
      
      // ....省略部分代码
    @Override
   protected Mono<?> getHandlerInternal(ServerWebExchange exchange) {
    		// don't handle requests on management port if set and different than server port
    		if (this.managementPortType == DIFFERENT && this.managementPort != null
    				&& exchange.getRequest().getURI().getPort() == this.managementPort) {
    			return Mono.empty();
    		}
    		exchange.getAttributes().put(GATEWAY_HANDLER_MAPPER_ATTR, getSimpleName());
    
    		return lookupRoute(exchange)
    		// .log("route-predicate-handler-mapping", Level.FINER) //name this
    				.flatMap((Function<Route, Mono<?>>) r -> {
    					exchange.getAttributes().remove(GATEWAY_PREDICATE_ROUTE_ATTR);
    					if (logger.isDebugEnabled()) {
    					logger.debug("Mapping [" + getExchangeDesc(exchange) + "] to " + r);
    					}
    
    					exchange.getAttributes().put(GATEWAY_ROUTE_ATTR, r);
    					return Mono.just(webHandler);
    				}).switchIfEmpty(Mono.empty().then(Mono.fromRunnable(() -> {
    					exchange.getAttributes().remove(GATEWAY_PREDICATE_ROUTE_ATTR);
    					if (logger.isTraceEnabled()) {
    						logger.trace("No RouteDefinition found for ["
    								+ getExchangeDesc(exchange) + "]");
    					}
    				})));
    	}
      
      //...省略部分代码
   
    }
```

- 此类继承了 **AbstractHandlerMapping**，注意这里的是 reactive 包下的，也就是 webflux 提供的 handlermapping，其作用等同于 webmvc 的 handlermapping，其作用是**将请求映射找到对应的handler来处理**。
- 在这里处理的关键就是先寻找合适的route，关键的方法为lookupRoute()：



```java
protected Mono<Route> lookupRoute(ServerWebExchange exchange) {
      		return this.routeLocator.getRoutes()
      // individually filter routes so that filterWhen error delaying is not a
      				// problem
      				.concatMap(route -> Mono.just(route).filterWhen(r -> {
      					// add the current route we are testing 
      					exchange.getAttributes().put(GATEWAY_PREDICATE_ROUTE_ATTR, r.getId());
      					return r.getPredicate().apply(exchange);
      				})
      			// instead of immediately stopping main flux due to error, log and
      			// swallow it
      						.doOnError(e -> logger.error("Error applying predicate for route: " + route.getId(),e)).onErrorResume(e -> Mono.empty()))
      				// .defaultIfEmpty() put a static Route not found
      				// or .switchIfEmpty()
      				// .switchIfEmpty(Mono.<Route>empty().log("noroute"))
      				.next()
      				// TODO: error handling
      				.map(route -> {
      					if (logger.isDebugEnabled()) {
      						logger.debug("Route matched: " + route.getId());
      					}
      					validateRoute(route, exchange);
      					return route;
      				});
      
      		/*
      		 * TODO: trace logging if (logger.isTraceEnabled()) {
      		 * logger.trace("RouteDefinition did not match: " + routeDefinition.getId()); }
      		 */
      	}
```

- 其中 RouteLocator 的接口作用是**获取 Route 定义**，那么在 GatewayAutoConfiguaration 里有相关的配置

- 然后在注释add the current route we are testing处(**第8行**)可以得到一个结论，其是根据Predicate的声明条件过滤出合适的Route
- 最终拿到 **FilteringWebHandler** 作为它的返回值，这个类是**真正意义上处理请求的类**，它实现了 webflux 提供的WebHandler 接口:

```java
      public class FilteringWebHandler implements WebHandler {
        
        //.....省略其它代码
        
        @Override
      	public Mono<Void> handle(ServerWebExchange exchange) {
          //拿到当前的route
      		Route route = exchange.getRequiredAttribute(GATEWAY_ROUTE_ATTR);
          //获取所有的gatewayFilter
      		List<GatewayFilter> gatewayFilters = route.getFilters();
      		//获取全局过滤器
      		List<GatewayFilter> combined = new ArrayList<>(this.globalFilters);
      		combined.addAll(gatewayFilters);
      		// TODO: needed or cached?
      		AnnotationAwareOrderComparator.sort(combined);
      
      		if (logger.isDebugEnabled()) {
      			logger.debug("Sorted gatewayFilterFactories: " + combined);
      		}
      		//交给默认的过滤器链执行所有的过滤操作
      		return new DefaultGatewayFilterChain(combined).filter(exchange);
      	}
      
        //....省略其它代码
      }
```

在这里可以看到它的实际处理方式是**委派给过滤器链**进行后续处理



猜想：

- 实际处理以后  chain中的 index 加1 进行下一个 filter 处理