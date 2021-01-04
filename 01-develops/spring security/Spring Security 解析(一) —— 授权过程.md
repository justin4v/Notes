##  Spring Security 解析(一) —— 授权过程 

>  &emsp;&emsp;在学习Spring Cloud 时，遇到了授权服务oauth 相关内容时，总是一知半解，因此决定先把Spring Security 、Spring Security Oauth2 等权限、认证相关的内容、原理及设计学习并整理一遍


> 项目环境:
> - JDK1.8
> - Spring boot 2.x
> - Spring Security 5.x

### Security Demo

#### 1、 自定义的UserDetailsService实现 

自定义MyUserDetailsUserService类，实现 UserDetailsService 接口的 loadUserByUsername()方法，这里就简单的返回一个Spring Security 提供的 User 对象。

为了后面方便演示Spring Security 的权限控制，这里使用**AuthorityUtils.commaSeparatedStringToAuthorityList("admin")** 设置了user账号有一个admin的角色权限信息。实际项目中可以在这里通过**访问数据库获取到用户及其角色、权限信息**。

```java
@Component
public class MyUserDetailsUserService implements UserDetailsService {
    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // 不能直接使用 创建 BCryptPasswordEncoder 对象来加密， 这种加密方式没有 {bcrypt}  前缀，
        // 会导致在 matches 时导致获取不到加密的算法出现
        // java.lang.IllegalArgumentException: There is no PasswordEncoder mapped for the id "null"  问题
        // 问题原因是 Spring Security5 使用 DelegatingPasswordEncoder(委托)  替代不安全的 NoOpPasswordEncoder，
        // 并且 默认使用  BCryptPasswordEncoder 加密（注意 DelegatingPasswordEncoder 委托加密方法BCryptPasswordEncoder 加密前添加了加密类型的前缀）  https://blog.csdn.net/alinyua/article/details/80219500
        return new User("user",  PasswordEncoderFactories.createDelegatingPasswordEncoder().encode("123456"), AuthorityUtils.commaSeparatedStringToAuthorityList("admin"));
    }
}
```
&emsp;

注意Spring Security 5 开始，不再使用 **NoOpPasswordEncoder**作为其默认的密码编码器，而是默认使用 **DelegatingPasswordEncoder** 作为其密码编码器，其 encode 方法是通过 **密码编码器的名称作为前缀 + 委托各类密码编码器 **来实现encode的。

```java
public String encode(CharSequence rawPassword) {
        return "{" + this.idForEncode + "}" + this.passwordEncoderForEncode.encode(rawPassword);
    }
```



注意代码中 **idForEncode** 就是密码编码器的简略名称，可以通过 **PasswordEncoderFactories.createDelegatingPasswordEncoder()** 内部实现看到默认是使用的前缀是 bcrypt 也就是**密码编码器默认实现为 BCryptPasswordEncoder**

```java
public class PasswordEncoderFactories {
    public static PasswordEncoder createDelegatingPasswordEncoder() {
        String encodingId = "bcrypt";
        Map<String, PasswordEncoder> encoders = new HashMap();
        encoders.put(encodingId, new BCryptPasswordEncoder());
        encoders.put("ldap", new LdapShaPasswordEncoder());
        encoders.put("MD4", new Md4PasswordEncoder());
        encoders.put("MD5", new MessageDigestPasswordEncoder("MD5"));
        encoders.put("noop", NoOpPasswordEncoder.getInstance());
        encoders.put("pbkdf2", new Pbkdf2PasswordEncoder());
        encoders.put("scrypt", new SCryptPasswordEncoder());
        encoders.put("SHA-1", new MessageDigestPasswordEncoder("SHA-1"));
        encoders.put("SHA-256", new MessageDigestPasswordEncoder("SHA-256"));
        encoders.put("sha256", new StandardPasswordEncoder());
        return new DelegatingPasswordEncoder(encodingId, encoders);
    }
}
```



#### 2、 设置Spring Security配置

&emsp;&emsp;定义SpringSecurityConfig 配置类，并继承**WebSecurityConfigurerAdapter**覆盖其configure(HttpSecurity http) 方法。

```java
@Configuration
@EnableWebSecurity //1
public class SpringSecurityConfig extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.formLogin()  //2
            .loginPage("/login")
            .and()
            .authorizeRequests() //3
            .antMatchers("/index","/").permitAll() //4
            .anyRequest().authenticated(); //6
    }
}
```



配置解析：

-  @EnableWebSecurity  查看其注解源码，主要是**引用 WebSecurityConfiguration.class** 和 **加入了@EnableGlobalAuthentication 注解** ，这里就不介绍了，我们只要明白添加 @EnableWebSecurity 注解将开启 Security 功能。

-  ```java
   @Retention(value = java.lang.annotation.RetentionPolicy.RUNTIME)
   @Target(value = { java.lang.annotation.ElementType.TYPE })
   @Documented
   @Import({ WebSecurityConfiguration.class,
   		SpringWebMvcImportSelector.class,
   		OAuth2ImportSelector.class })
   @EnableGlobalAuthentication
   @Configuration
   public @interface EnableWebSecurity {
   
   	/**
   	 * Controls debugging support for Spring Security. Default is false.
   	 * @return if true, enables debug support with Spring Security
   	 */
   	boolean debug() default false;
   }
   ```

-  **formLogin()  使用表单登录（默认请求地址为 /login）**,在Spring Security 5 里其实已经将旧版本默认的  httpBasic() 更换成 formLogin() 了，这里为了表明表单登录还是配置了一次。

-  **loginPage("/login") 指定登录页面**

-  **authorizeRequests() 开始请求权限配置**

-  **antMatchers() 使用Ant风格的路径匹配**，这里配置匹配 / 和 /index

-  **permitAll() 用户可任意访问**

-  **anyRequest() 匹配所有路径**

-  **authenticated() 用户登录后可访问**

**解释：**

1. 允许所有用户访问 "/index","/" ；
2. 任何路径需要认证（登录）后访问；
3. 指定“/login”该路径为登录页面，当未认证的用户尝试访问任何受保护的资源时，都会跳转到“/login”；
4. **第一条先生效，第二条再生效。所以最后结果是：除了  "/index","/"  路径外，其他的所有请求需要登录后访问**



---


#### 3、 配置html 和测试接口

&emsp;&emsp; 在 resources/static 目录下新建 index.html ， 其内部定义一个访问测试接口的按钮


```
<!DOCTYPE html>
<html lang="en" >
<head>
    <meta charset="UTF-8">
    <title>欢迎</title>
</head>
<body>
        Spring Security 欢迎你！
        <p> <a href="/get_user/test">测试验证Security 权限控制</a></p>
</body>
</html>
```
&emsp;&emsp;创建 rest 风格的获取用户信息接口

```java
@RestController
public class TestController {

    @GetMapping("/get_user/{username}")
    public String getUser(@PathVariable  String username){
        return username;
    }
}
```

#### 4、 启动项目测试

1、访问 localhost:8080 无任何阻拦直接成功

2、点击测试验证权限控制按钮 被重定向到了 Security默认的登录页面 

3、使用 MyUserDetailsUserService定义的默认账户 user : 123456 进行登录后成功跳转到 /get_user 接口




---

###  @EnableWebSecurity 解析

 还记得之前讲过 @EnableWebSecurity 引用了 WebSecurityConfiguration 配置类 和 @EnableGlobalAuthentication 注解吗？  其中 WebSecurityConfiguration 就是与授权相关的配置，@EnableGlobalAuthentication 配置了 认证相关的我们下节再细讨。



#### WebSecurityConfiguration

java doc

> **Uses a WebSecurity to create the FilterChainProxy that performs the web based security for Spring Security**. It then exports the necessary beans. 
>
> **Customizations can be made to WebSecurity by extending WebSecurityConfigurerAdapter and exposing it as a Configuration or implementing WebSecurityConfigurer and exposing it as a Configuration.** This configuration is imported when using EnableWebSecurity.

 首先我们查看 **WebSecurityConfiguration** 源码，可以看到 **springSecurityFilterChain()** 方法，**用来生成 Spring Security Filter Chain**。
```java
    /**
	 * Creates the Spring Security Filter Chain
	 * @return the Filter that represents the security filter chain
	 * @throws Exception
	 */
    @Bean(name = AbstractSecurityWebApplicationInitializer.DEFAULT_FILTER_NAME)
	public Filter springSecurityFilterChain() throws Exception {
		boolean hasConfigurers = webSecurityConfigurers != null
				&& !webSecurityConfigurers.isEmpty();
		if (!hasConfigurers) {
			WebSecurityConfigurerAdapter adapter = objectObjectPostProcessor
					.postProcess(new WebSecurityConfigurerAdapter() {
					});
			webSecurity.apply(adapter);
		}
		return webSecurity.build(); //1
	}
```
这个方法首先会判断 webSecurityConfigurers 是否为空，为空加载一个默认的 WebSecurityConfigurerAdapter对象，由于**自定义的 SpringSecurityConfig 本身是继承 WebSecurityConfigurerAdapter对象的，所以我们自定义的 Security 配置肯定会被加载进来的**（如果想要了解如何加载进来可以看下**WebSecurityConfiguration.setFilterChainProxySecurityConfigurer()** 方法）。

 我们看下 webSecurity.build() 方法实现 实际调用的是 **AbstractConfiguredSecurityBuilder.doBuild()** 方法，其方法内部实现如下：

```java
@Override
	protected final O doBuild() throws Exception {
		synchronized (configurers) {
			buildState = BuildState.INITIALIZING;

			beforeInit();
			init();

			buildState = BuildState.CONFIGURING;

			beforeConfigure();
			configure();

			buildState = BuildState.BUILDING;

			O result = performBuild(); // 1 实际调用 HttpSecurity 类中的实现： 创建 DefaultSecurityFilterChain （Security Filter 责任链 ）

			buildState = BuildState.BUILT;

			return result;
		}
	}
```



#### DefaultSecurityFilterChain

**实际 build 过程是 performBuild() 实现**

我们把关注点放到 **performBuild()** 方法，看其实现子类  **HttpSecurity.performBuild() 方法**，其内部排序 filters 并创建了  **DefaultSecurityFilterChain** 对象。


```java
    @Override
	protected DefaultSecurityFilterChain performBuild() throws Exception {
		Collections.sort(filters, comparator);
		return new DefaultSecurityFilterChain(requestMatcher, filters);
	}
```

查看 **DefaultSecurityFilterChain** 的构造方法，我们可以看到有记录日志。
```java
public DefaultSecurityFilterChain(RequestMatcher requestMatcher, List<Filter> filters) {
		logger.info("Creating filter chain: " + requestMatcher + ", " + filters); // 按照正常情况，我们可以看到控制台输出 这条日志 
		this.requestMatcher = requestMatcher;
		this.filters = new ArrayList<>(filters);
	}
```


观察下图项目启动日志。可以看到下图明显打印了 这条日志，并且把所有 Filter名都打印出来了。==**（请注意这里打印的 filter 链，接下来我们的所有授权过程都是依靠这条filter 链展开 ）**==

![Security filter chain日志](.\Security filter chain日志.png)



那么还有个疑问： **HttpSecurity.performBuild() 方法中的 filters 是怎么加载的呢？** 

这个时候需要查看 **WebSecurityConfigurerAdapter.init()** 方法，这个方法内部 调用 **getHttp()** 方法返回 HttpSecurity 对象（**实际调用 addFilter() 方法**），具体如何加载的也就不介绍了。

```java
public void init(final WebSecurity web) throws Exception {
		final HttpSecurity http = getHttp(); // 1 
		web.addSecurityFilterChainBuilder(http).postBuildAction(new Runnable() {
			public void run() {
				FilterSecurityInterceptor securityInterceptor = http
						.getSharedObject(FilterSecurityInterceptor.class);
				web.securityInterceptor(securityInterceptor);
			}
		});
	}
```


 用了这么长时间解析 @EnableWebSecurity ，**其实最关键的一点就是创建了  DefaultSecurityFilterChain** 也就是 **security  filter 责任链**，整个**授权过程**由 DefaultSecurityFilterChain 中的 filters 完成。




### 授权过程解析
> **Security 的授权过程可以理解成各种 filter 处理最终完成一个授权**。那么我们再看下之前 打印的filter 链，这里为了方便，再次贴出图片
![Security filter chain日志](.\Security filter chain日志.png)



这里我们只关注以下几个重要的 filter ：

> - **SecurityContextPersistenceFilter** 
> - **UsernamePasswordAuthenticationFilter (AbstractAuthenticationProcessingFilter)**
> - **BasicAuthenticationFilter**
> - **AnonymousAuthenticationFilter**
> - **ExceptionTranslationFilter**
> - **FilterSecurityInterceptor**



#### 1、SecurityContextPersistenceFilter

SecurityContextPersistenceFilter 用途：

**用于在请求 request之前，从配置的 SecurityContextRepository  中获取信息并填充到  SecurityContextHolder 中。并且在请求完成之后存回 SecurityContextRepository  并且清理 SecurityContextHolder 。**

java doc：

>**Populates the SecurityContextHolder with information obtained from the configured SecurityContextRepository prior to the request and stores it back in the repository once the request has completed and clearing the context holder**. **By default it uses an HttpSessionSecurityContextRepository. See this class for information HttpSession related configuration options.**
>	This filter will only execute once per request, to resolve servlet container (specifically Weblogic) incompatibilities.
>    This filter MUST be executed BEFORE any authentication processing mechanisms. Authentication processing mechanisms (e.g. BASIC, CAS processing filters etc) expect the SecurityContextHolder to contain a valid SecurityContext by the time they execute.
>	This is essentially a refactoring of the old HttpSessionContextIntegrationFilter to delegate the storage issues to a separate strategy, allowing for more customization in the way the security context is maintained between requests.
>	The forceEagerSessionCreation property can be used to ensure that a session is always available before the filter chain executes (the default is false, as this is resource intensive and not recommended).



SecurityContextPersistenceFilter 这个 filter 在执行时（**doFilter**() 方法）的主要做了以下几件事：

> - 首先通过 **(SecurityContextRepository)repo.loadContext()** 方法从请求Session中获取 **SecurityContext（Security 上下文 ，类似 ApplicaitonContext** ） 对象，如果请求Session中没有SecurityContext 调用 generateNewContext() 创建一个 authentication(认证的关键对象) 属性为 null 的 SecurityContext 对象;
> - 接着 SecurityContextHolder.setContext() 将 SecurityContext 对象放入 SecurityContextHolder 进行管理（SecurityContextHolder **默认使用 ThreadLocal 策略来存储认证信息**，这里**使用 ThreadLocal 是为了当前线程数据共享**）
> - 之后调用 chain.doFilter() 开始在 security filter 责任链上处理； 
> - 最后在 finally 里通过 SecurityContextHolder.clearContext() 将 SecurityContext 对象 从 SecurityContextHolder 中清除。最后通过 repo.saveContext() 将 SecurityContext 对象 放入Session中；
>
> 
>
> **SecurityContextPersistenceFilter  doFilter 源码如下**

```java
HttpRequestResponseHolder holder = new HttpRequestResponseHolder(request,
				response);
		//从Session中获取SecurityContxt 对象，如果Session中没有则创建一个 authtication 属性为 null 的SecurityContext对象
		SecurityContext contextBeforeChainExecution = repo.loadContext(holder); 

		try {
		    // 将 SecurityContext 对象放入 SecurityContextHolder进行管理 （SecurityContextHolder默认使用ThreadLocal 策略来存储认证信息）
			 SecurityContextHolder.setContext(contextBeforeChainExecution);

			 chain.doFilter(holder.getRequest(), holder.getResponse());

		}
		finally {
			SecurityContext contextAfterChainExecution = SecurityContextHolder
					.getContext();
			
			// 将 SecurityContext 对象 从 SecurityContextHolder中清除
			SecurityContextHolder.clearContext();
			// 将 SecurityContext 对象 放入Session中
			repo.saveContext(contextAfterChainExecution, holder.getRequest(),
					holder.getResponse());
			request.removeAttribute(FILTER_APPLIED);

			if (debug) {
				logger.debug("SecurityContextHolder now cleared, as request processing completed");
			}
		}
```



我们在 SecurityContextPersistenceFilter 中打上断点，启动项目，访问 localhost:8080 , 来debug看下实现：

![image-20201224152413129](.\Security Context 链.png)

![image-20201224152557567](.\Security Context 链-debug-2.png)



我们可以清楚的看到创建了一个authtication 为null 的 SecurityContext对象，并且可以看到请求调用的filter链具体有哪些。接下来看下 finally 内部处理

![image-20201224152745746](.\Security Context 链-debug-3.png)

&emsp;&emsp; 你会发现这里的 SecurityContxt 中的 authtication 是一个名为 **anonymousUser （匿名用户）**的认证信息，这是因为 请求调用到了 AnonymousAuthenticationFilter , Security默认创建了一个匿名用户访问。



#### 2、UsernamePasswordAuthenticationFilter (AbstractAuthenticationProcessingFilter)

**UsernamePasswordAuthenticationFilter 继承自 AbstractAuthenticationProcessingFilter。增加了部分方法，核心方法是 AbstractAuthenticationProcessingFilter 中的 doFilter()**。

doc 如下：

>**Processes an authentication form submission**. Called AuthenticationProcessingFilter prior to Spring Security 3.0.
>	Login forms must present two parameters to this filter: a username and password. The default parameter names to use are contained in the static fields SPRING_SECURITY_FORM_USERNAME_KEY and SPRING_SECURITY_FORM_PASSWORD_KEY. The parameter names can also be changed by setting the usernameParameter and passwordParameter properties.

这是一个**通过获取请求中的账户密码来进行授权的 filter**，下面是该 filter  （AbstractAuthenticationProcessingFilter）在 **doFilter()** 中处理的过程：

> - 通过 requiresAuthentication（）判断 是否以POST 方式请求 /login
> - 调用 attemptAuthentication() 方法进行认证，内部创建了 authenticated 属性为 false（即未授权）的UsernamePasswordAuthenticationToken 对象， 并传递给 AuthenticationManager().authenticate() 方法进行认证，认证成功后 返回一个 authenticated = true （即授权成功的)UsernamePasswordAuthenticationToken 对象 
> - 通过 sessionStrategy.onAuthentication() 将 Authentication  放入Session中
> - 通过 successfulAuthentication() 调用 AuthenticationSuccessHandler 的 onAuthenticationSuccess 接口 进行成功处理（ 可以 通过 继承 AuthenticationSuccessHandler 自行编写成功处理逻辑 ）successfulAuthentication(request, response, chain, authResult);
> - 通过 unsuccessfulAuthentication() 调用AuthenticationFailureHandler 的 onAuthenticationFailure 接口 进行失败处理（可以通过继承AuthenticationFailureHandler 自行编写失败处理逻辑 ）

&emsp;&emsp;我们再看下官方源码的处理逻辑：

```java
// 1 AbstractAuthenticationProcessingFilter 的 doFilter 方法
public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
			throws IOException, ServletException {

		HttpServletRequest request = (HttpServletRequest) req;
		HttpServletResponse response = (HttpServletResponse) res;

        // 2 默认判断请求地址是否是  /login 和 请求方式为 POST  （UsernamePasswordAuthenticationFilter 构造方法中初始化 super(new AntPathRequestMatcher("/login", "POST")); 确定的）
		if (!requiresAuthentication(request, response)) {
			chain.doFilter(request, response);
			return;
		}
		Authentication authResult;
		try {
		    
		    // 3 调用 子类  UsernamePasswordAuthenticationFilter 的 attemptAuthentication 方法
		    // attemptAuthentication 方法内部创建了 authenticated 属性为 false （即未授权）的 UsernamePasswordAuthenticationToken 对象， 并传递给 AuthenticationManager().authenticate() 方法进行认证，
		    //认证成功后 返回一个 authenticated = true （即授权成功的） UsernamePasswordAuthenticationToken 对象 
			authResult = attemptAuthentication(request, response);
			if (authResult == null) {
				return;
			}
			// 4 将认证成功的 Authentication 存入Session中
			sessionStrategy.onAuthentication(authResult, request, response);
		}
		catch (InternalAuthenticationServiceException failed) {
		     // 5 认证失败后 调用 AuthenticationFailureHandler 的 onAuthenticationFailure 接口 进行失败处理（ 可以 通过 继承 AuthenticationFailureHandler 自行编写失败处理逻辑 ）
			unsuccessfulAuthentication(request, response, failed);
			return;
		}
		catch (AuthenticationException failed) {
		    // 5 认证失败后 调用 AuthenticationFailureHandler 的 onAuthenticationFailure 接口 进行失败处理（ 可以 通过 继承 AuthenticationFailureHandler 自行编写失败处理逻辑 ）
			unsuccessfulAuthentication(request, response, failed);
			return;
		}
		
        ......
         // 6 认证成功后 调用 AuthenticationSuccessHandler 的 onAuthenticationSuccess 接口 进行失败处理（ 可以 通过 继承 AuthenticationSuccessHandler 自行编写成功处理逻辑 ）
		successfulAuthentication(request, response, chain, authResult);
	}
```
从源码上看，**整个流程**其实是很清晰的：

1. **判断是否处理**
2. **认证**
3. **最后判断认证结果分别作出认证成功和认证失败的处理。**

debug 调试下看 结果，这次我们请求 localhast:8080/get_user/test  , 由于没权限会直接跳转到登录界面，我们先输入错误的账号密码，看下认证失败是否与我们总结的一致。

这次输入正确的密码, 可以看到这次成功返回一个 authticated = ture 。放开断点，由于Security默认的成功处理器是SimpleUrlAuthenticationSuccessHandler ，这个处理器会重定向到之前访问的地址，也就是 localhast:8080/get_user/test。 至此整个流程结束。

不，我们还差一个，**Session**，我们从浏览器中看到 Session：

![image-20201228142332396](.\浏览器显示登录写入的session.png)
        

#### 3、BasicAuthenticationFilter

BasicAuthenticationFilter 处理 BASIC 认证请求，并且将结果保存在 SecurityContextHolder 中。

java doc

>**Processes a HTTP request's BASIC authorization headers, putting the result into the SecurityContextHolder.**
>	For a detailed background on what this filter is designed to process, refer to RFC 1945, Section 11.1 . Any realm name presented in the HTTP request is ignored.
>	In summary, this filter is responsible for processing any request that has a HTTP request header of Authorization with an authentication scheme of Basic and a Base64-encoded username:password token. For example, to authenticate user "Aladdin" with password "open sesame" the following header would be presented:
>
>Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==
>
>This filter can be used to provide BASIC authentication services to both remoting protocol clients (such as Hessian and SOAP) as well as standard user agents (such as Internet Explorer and Netscape).
>	If authentication is successful, the resulting Authentication object will be placed into the SecurityContextHolder.
>
>If authentication fails and ignoreFailure is false (the default), an AuthenticationEntryPoint implementation is called (unless the ignoreFailure property is set to true). Usually this should be BasicAuthenticationEntryPoint, which will prompt the user to authenticate again via BASIC authentication.
>	Basic authentication is an attractive protocol because it is simple and widely deployed. **However, it still transmits a password in clear text and as such is undesirable in many situations**. Digest authentication is also provided by Spring Security and should be used instead of Basic authentication wherever possible. See DigestAuthenticationFilter.
>Note that if a RememberMeServices is set, this filter will automatically send back remember-me details to the client. Therefore, subsequent requests will not need to present a BASIC authentication header as they will be authenticated using the remember-me mechanism.

BasicAuthenticationFilter  是一个 OncePerRequestFilter ，特点是**每个请求线程中只会执行一次**，filter 主方法是 **doFilterInternal()**。

BasicAuthenticationFilter 与 UsernameAuthticationFilter 类似，不过区别还是很明显，**BasicAuthenticationFilter 主要是从Header 中获取 Authorization 参数信息，然后调用认证，认证成功后最后直接访问接口。 **BasicAuthenticationFilter 的 onSuccessfulAuthentication() 和 onUnsuccessfulAuthentication() 处理方法是一个空方法。

**UsernameAuthticationFilter 通过 AuthenticationSuccessHandler 进行跳转。**

为了试验BasicAuthenticationFilter, 我们需要将 SpringSecurityConfig 中的formLogin()更换成httpBasic()以支持BasicAuthenticationFilter，重启项目，同样访问
localhast:8080/get_user/test，这时由于没权限访问这个接口地址，页面上会弹出一个登陆框，输入账户密码后，看下debug数据：

![image-20201231132123220](.\httpBasic认证.png)

我们就能够获取到 Authorization 参数，进而解析获取到其中的账户和密码信息，进行认证。

我们查看认证成功后返回的**Authtication对象信息其实是和 UsernamePasswordAuthticationFilter 中的一致**，最后再次调用下一个 filter，由于已经认证成功了会直接进入 FilterSecurityInterceptor 进行权限验证。



#### 4、AnonymousAuthenticationFilter
&emsp;&emsp;这里为什么要提下 AnonymousAuthenticationFilter呢，主要是因为**在Security中不存在没有账户，所有没有经过注册的账户都会被当成 匿名用户 – anonymousUser，Security官方专门指定了 AnonymousAuthenticationFilter** 。

**当前面所有filter都认证失败的情况下，自动创建一个默认的匿名用户，拥有匿名访问权限**。还记得 在讲解 SecurityContextPersistenceFilter 时我们看到得匿名 autication信息么？如果不记得还得回头看下哦，这里就不再叙述了。



#### 5、ExceptionTranslationFilter

java doc

> **Handles any AccessDeniedException and AuthenticationException thrown within the filter chain.**
> **This filter is necessary because it provides the bridge between Java exceptions and HTTP responses.** **It is solely concerned with maintaining the user interface. This filter does not do any actual security enforcement.**
> 	If an AuthenticationException is detected, the filter will launch the authenticationEntryPoint. This allows common handling of authentication failures originating from any subclass of org.springframework.security.access.intercept.AbstractSecurityInterceptor.
> 	If an AccessDeniedException is detected, the filter will determine whether or not the user is an anonymous user. If they are an anonymous user, the authenticationEntryPoint will be launched. If they are not an anonymous user, the filter will delegate to the AccessDeniedHandler. By default the filter will use AccessDeniedHandlerImpl.

**ExceptionTranslationFilter 其实没有做任何过滤处理，它的用处就在于它捕获AuthenticationException 和 AccessDeniedException，如果发生2 个异常会调用 handleSpringSecurityException() 方法进行处理**。 我们模拟下 AccessDeniedException(无权限，禁止访问异常)情况，首先我们需要修改下 /get_user 接口：

- 在Controller 上添加 
@EnableGlobalMethodSecurity(prePostEnabled =true) 启用Security 方法级别得权限控制
- 在 接口上添加 @PreAuthorize("hasRole('user')")  只允许有user角色得账户访问（还记得我们默认得user 账户时admin角色么？）


```java
@RestController
@EnableGlobalMethodSecurity(prePostEnabled =true)  // 开启方法级别的权限控制
public class TestController {

    @PreAuthorize("hasRole('user')") //只允许user角色访问
    @GetMapping("/get_user/{username}")
    public String getUser(@PathVariable  String username){
        return username;
    }
}
```

重启项目,重新访问 /get_user 接口，输入正确的账户密码，发现返回一个 403 状态的错误页面，这与我们之前将的流程时一致的。debug，看下处理：

![image-20201231134835408](.\AccessDeniedException.png)



可以明显的看到异常对象是 AccessDeniedException ，异常信息是不允许访问，我们再看下 AccessDeniedException 异常后的**处理方法 accessDeniedHandler.handle()** , 进入到了 **AccessDeniedHandlerImpl 的handle()方法**，这个方法会先判断系统是否配置了 errorPage (错误页面)，没有的话直接往 response 中设置403 状态码。

![image-20201231134954178](.\accessDeniedHandle.png)



#### 6、FilterSecurityInterceptor
**FilterSecurityInterceptor 是整个Security filter链中的最后一个，也是最重要的一个，它的主要功能就是判断认证成功的用户是否有权限访问接口**。其最主要的处理方法就是调用父类（AbstractSecurityInterceptor）的 **super.beforeInvocation(fi)**，我们来梳理下这个方法的处理流程：

> - 通过 obtainSecurityMetadataSource().getAttributes() 获取 当前访问地址所需权限信息
> - 通过 authenticateIfRequired() 获取当前访问用户的权限信息
> - 通过 accessDecisionManager.decide() **使用投票机制判权，判权失败直接抛出 AccessDeniedException 异常**




```java
protected InterceptorStatusToken beforeInvocation(Object object) {
	    ......
	    
	    // 1 获取访问地址的权限信息 
		Collection<ConfigAttribute> attributes = this.obtainSecurityMetadataSource()
				.getAttributes(object);

		if (attributes == null || attributes.isEmpty()) {
		
		    ......
		    
			return null;
		}

        ......

        // 2 获取当前访问用户权限信息
		Authentication authenticated = authenticateIfRequired();

		try {
		    // 3  默认调用AffirmativeBased.decide() 方法, 其内部 使用 AccessDecisionVoter 对象 进行投票机制判权，判权失败直接抛出 AccessDeniedException 异常 
			this.accessDecisionManager.decide(authenticated, object, attributes);
		}
		catch (AccessDeniedException accessDeniedException) {
			publishEvent(new AuthorizationFailureEvent(object, attributes, authenticated,
					accessDeniedException));

			throw accessDeniedException;
		}

        ......
        return new InterceptorStatusToken(SecurityContextHolder.getContext(), false,
					attributes, object);
	}
```

整个流程其实看起来不复杂，主要就分3个部分:

- **首选获取访问地址的权限信息**
- **其次获取当前访问用户的权限信息**
- **最后通过投票机制判断出是否有权。**




###  个人总结

      整个授权流程核心的就在于这几次核心filter的处理，这里我用序列图来概况下这个授权流程

![授权过程序列图](.\授权过程序列图.png)


