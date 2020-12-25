# REST架构

REST 是 **Representational state transfer** 的缩写，翻译过来的意思是**表述性状态转换**。REST 是一种架构风格，它包含了一个分布式超文本系统中对于组件、连接器和数据的约束。

REST 是作为互联网自身架构的抽象而出现的，其关键在于所定义的架构上的各种约束。**只有满足这些约束，才能称之为符合 REST 架构风格**。REST 的约束包括：

- **客户端-服务器结构**。通过一个统一的接口来分开客户端和服务器，使得两者可以独立开发和演化。客户端的实现可以简化，而服务器可以更容易的满足可伸缩性的要求。
- **无状态**。在不同的客户端请求之间，服务器并不保存客户端相关的上下文状态信息。任何客户端发出的每个请求都包含了服务器处理该请求所需的全部信息。
- **可缓存**。客户端可以缓存服务器返回的响应结果。服务器可以定义响应结果的缓存设置。
- **分层的系统**。在分层的系统中，可能有中间服务器来处理安全策略和缓存等相关问题，以提高系统的可伸缩性。客户端并不需要了解中间的这些层次的细节。
- **按需代码（可选）**。服务器可以通过传输可执行代码的方式来扩展或自定义客户端的行为。这是一个可选的约束。
- **统一接口**。该约束是 **REST 服务的基础**，是客户端和服务器之间的桥梁。该约束又包含下面 4 个子约束。
  - **资源标识符**。每个资源都有各自的标识符。客户端在请求时需要指定该标识符。在 REST 服务中，该**标识符通常是 URI**。客户端所获取的是**资源的表述（representation）**，通常使用 XML 或 JSON 格式。
  - **通过资源的表述来操纵资源**。客户端根据所得到的资源的表达中包含的信息来了解如何操纵资源，比如对资源进行修改或删除。
  - **自描述的消息（资源的表述）**。每条消息都包含足够的信息来描述如何处理该消息。
  - **超媒体即应用状态引擎（HATEOAS）**。客户端通过服务器提供的超媒体内容中**动态提供的动作（通常是link）**来**进行状态转换**。

在了解 REST 的这些约束之后，就可以对”表述性状态转换”的含义有更加清晰的了解。”表述性状态转换”其实是指  **根据资源的表述性，客户端自发发现并进行资源的状态转换**

详细解释如下：

”表述性”的含义是指对于资源的操纵都是**依据服务器提供的资源的表述**来进行的。

客户端在根据资源的标识符获取到资源的表达之后，从资源的表达中可以**发现可以使用的动作**。使用这些动作会发出新的请求，从而**触发状态转换**。



# HATEOAS约束

HATEOAS（Hypermedia as the engine of application state）是 REST 架构风格中最复杂的约束，也是**构建成熟 REST 服务的核心**。

它的重要性在于**打破了客户端和服务器之间严格的契约**，使得客户端**更加智能和自适应**，而 REST 服务本身的**演化和更新也更加容易**。

 Richardson 提出的 REST 成熟度模型。该模型把 REST 服务按照成熟度划分成 4 个层次：

- Level 0 ： Web 服务只是使用 HTTP 作为传输方式，实际上只是远程方法调用（RPC）的一种具体形式。SOAP 和 XML-RPC 都属于此类。
- Level 1 ： Web 服务引入了资源的概念。每个资源有对应的标识符和表达。
- **Level 2**： Web 服务使用不同的 **HTTP 方法来进行不同的操作，使用 HTTP 状态码来表示不同的结果**。如 HTTP GET 方法来获取资源，HTTP DELETE 方法来删除资源。
- **Level 3**： Web 服务使用 **HATEOAS**。在资源的表达中包含了链接信息。客户端可以根据链接来发现可以执行的动作。

从上述 REST 成熟度模型中可以看到，使用 HATEOAS 的 REST 服务是成熟度最高的，也是推荐的做法。目前很多应用处于 level2 级别。

对于不使用 HATEOAS 的 REST 服务，客户端和服务器的实现之间是**紧密耦合**的。客户端需要根据服务器提供的相关文档来了解所暴露的资源和对应的操作。当服务器发生了变化时，如修改了资源的 URI，客户端也需要进行相应的修改。而使用 HATEOAS 的 REST 服务中，客户端可以通过服务器提供的资源的表达来智能地发现可以执行的操作。当服务器发生了变化时，客户端并不需要做出修改，因为资源的 URI 和其他信息都是动态发现的。



## Spring HATEOAS

满足 HATEOAS 约束的 REST 服务最大的**特点在于服务器提供给客户端的表达中包含了动态的链接信息，客户端通过这些链接来发现可以触发状态转换的动作**。Spring HATEOAS 的主要功能在于提供了简单的机制来创建这些链接，并**与 Spring MVC 框架有很好的集成**。

### 配置

Spring MVC应用，只需要增加HATEOAS的依赖：

```java
<dependency>
 <groupId>org.springframework.hateoas</groupId>
 <artifactId>spring-hateoas</artifactId>
 <version>0.16.0.RELEASE</version>
</dependency>
```

最新版本为  Spring HATEOAS 1.0 。名称有如下变化（因为实际上这些**并不是代表资源，而是带有 Hypemedia 信息表述模型-representation model**）：

- `ResourceSupport` is now `RepresentationModel`
- `Resource` is now `EntityModel`
- `Resources` is now `CollectionModel`
- `PagedResources` is now `PagedModel`

### 资源

REST 架构中的核心**概念之一是资源**。服务器提供的是资源的表述，通常使用 JSON 或 XML 格式。

在一般的 Web 应用中，服务器端代码会对所使用的**资源建模**，提供相应的**模型层次的Java 类**，这些模型层 Java 类通常包含 JPA 相关的注解来完成持久化。

在客户端请求时，服务器端代码通过 Jackson 或 JAXB **把模型对象转换成 JSON 或 XML 格式**。

此时，服务器端返回的只是模型类对象本身的内容，并**没有提供相关的链接信息/超媒体信息（Hypemedia information）**。为了把模型对象类转换成满足 HATEOAS 要求的资源，需要添加链接信息。Spring HATEOAS 使用 org.springframework.hateoas.Link 类来表示链接。

Link 类遵循 **Atom 规范中对于链接的定义**，包含 **rel** 和 **href** 两个属性。**属性 rel 表示的是链接所表示的关系（relationship，表示连接所代表的动作），href 表示的是链接指向的资源标识符，一般是 URI**。资源通常都包含一个属性 rel 值为 self 的链接，用来指向该资源本身。

#### 创建

首先，如果是单个对象 可以使用 Resource.wrap()，为单个对象增加 link 信息。Resource 代表单个Resource，Resources 代表多个 Resource。

```java
@GetMapping("/recent")
public Resources<Resource<Taco>> recentTacos() {
PageRequest page = PageRequest.of(
0, 12, Sort.by("createdAt").descending());
List<Taco> tacos = tacoRepo.findAll(page).getContent();
Resources<Resource<Taco>> recentResources = Resources.wrap(tacos);
recentResources.add(new Link("http://localhost:8080/design/recent", "recents"));
return recentResources;
}
```



但是这里**硬编码了URL（localhost:8080）**，Spring HATEOAS 提供了 **link builder： ControllerLinkBuilder**，ControllerLinkBuilder可以自动获取当前 hostname 且提供了 fluent API。

使用用例如下：

```java
Resources<Resource<Taco>> recentResources = Resources.wrap(tacos);
recentResources.add(ControllerLinkBuilder.linkTo(DesignTacoController.class)
	.slash("recent")
	.withRel("recents"));
```

此时不需要硬编码hostname 和 路径名称，仅仅说明 link 到 DesignTacoController ，得到基础路径  “/design” 。之后， slash() 用 slash（/）连接上 “recent” 路径。最后，指明 link 表示的动作（获取recent）。

或者使用 linkTo() 指明具体的方法名来确认具体路径：

```java
Resources<Resource<Taco>> recentResources = Resources.wrap(tacos);
recentResources.add(linkTo(methodOn(DesignTacoController.class).recentTacos()).withRel("recents"));
```

其中 recentTacos 是处理 /recent 路径请求的方法名。 



#### 转换

在代码实现中经常会需要把**模型类对象转换成对应的资源对象**，如把 List 类的对象转换成 ListResource 类的对象。一般的做法是通过”new ListResource(list)”这样的方式来进行转换。可以使用 Spring HATEOAS 提供的**资源组装器（Resource Assembler）把转换的逻辑封装起来**。

上例使用 Resources.wrap() 中，返回的是 Resources（List），但是**只是为整个list 增加了link**，list 中的**元素没有增加link**。一种解决方案是 遍历 list 然后对每个 对象进行包装，但是这种方式有些繁琐。

其次，如果是collection对象，为了避免手动 iterator，可以继承自 Spring HATEOAS 提供的 org.springframework.hateoas.Resource 类, 将 Domain Object 转为 Resource。

1. 定义一个 resource

   ```java
   public class TacoResource extends ResourceSupport {
   @Getter
   private final String name;
   @Getter
   private final Date createdAt;
   @Getter
   private final List<Ingredient> ingredients;
   public TacoResource(Taco taco) {
   this.name = taco.getName();
   this.createdAt = taco.getCreatedAt();
   this.ingredients = taco.getIngredients();
   }
   }
   ```

   这里重新定义了一个 resource 对象，忽略用不到的domain属性，如 id。

   2.定义 resource assembler

   ```java
   public class TacoResourceAssembler
   extends ResourceAssemblerSupport<Taco, TacoResource> {
   public TacoResourceAssembler() {
   super(DesignTacoController.class, TacoResource.class);
   }
   @Override
   protected TacoResource instantiateResource(Taco taco) {
   return new TacoResource(taco);
   }
   @Override
   public TacoResource toResource(Taco taco) {
   return createResourceWithId(taco.getId(), taco);
   }
   }
   ```

   3.使用 resource assembler

   ```java
   @GetMapping("/recent")
   public Resources<TacoResource> recentTacos() {
   PageRequest page = PageRequest.of(0, 12, Sort.by("createdAt").descending());
   List<Taco> tacos = tacoRepo.findAll(page).getContent();
   List<TacoResource> tacoResources = new TacoResourceAssembler().toResources(tacos);
   Resources<TacoResource> recentResources = new Resources<TacoResource>(tacoResources);
   recentResources.add(linkTo(methodOn(DesignTacoController.class).recentTacos()).withRel("recents"));
   return recentResources;
   }
   ```

ListResourceAssembler 类的 **instantiateResource 方法用来根据一个模型类 List 的对象创建出 ListResource 对象**。

ResourceAssemblerSupport 类的默认实现是通过反射来创建资源对象的。**toResource 方法用来完成实际的转换（加上link信息，实际底层调用了 instantiateResource() 方法）**。此处使用了 **ResourceAssemblerSupport 类的 createResourceWithId 方法来创建一个包含 self 链接的资源对象**。

### 链接

HATEOAS 的核心是链接。**链接的存在使得客户端可以动态发现其所能执行的动作**。

在上一节中介绍过链接由 rel 和 href 两个属性组成。其中属性 rel 表明了该链接所代表的**关系含义**。应用可以根据需要为链接选择最适合的 rel 属性值。由于每个应用的情况并不相同，对于应用相关的 rel 属性值并没有统一的规范。不过对于很多常见的链接关系，IANA 定义了规范的 rel 属性值。在开发中可能使用的常见 rel 属性值如表 1 所示。

​                                              表 1. 常用的 rel 属性

| rel 属性值                  | 描述                                                         |
| :-------------------------- | :----------------------------------------------------------- |
| self                        | 指向当前资源本身的链接的 rel 属性。每个资源的表达中都应该包含此关系的链接。 |
| edit                        | 指向一个可以编辑当前资源的链接。                             |
| item                        | 如果当前资源表示的是一个集合，则用来指向该集合中的单个资源。 |
| collection                  | 如果当前资源包含在某个集合中，则用来指向包含该资源的集合。   |
| related                     | 指向一个与当前资源相关的资源。                               |
| search                      | 指向一个可以搜索当前资源及其相关资源的链接。                 |
| first、last、previous、next | 这几个 rel 属性值都有集合中的遍历相关，分别用来指向集合中的第一个、最后一个、上一个和下一个资源。 |

如果在应用中使用**自定义 rel 属性值**，一般的做法是属性值全部为小写，中间使用”-”分隔。

链接中另外一个重要属性 **href** 表示的是资源的标识符。对于 Web 应用来说，通常是一个 URL。URL 必须指向的是一个绝对的地址。

## 超媒体控制与 HAL

在添加了链接之后，服务器端提供的表达可以帮助客户端更好的发现服务器端所支持的动作。

在具体的表达中，应用虽然可以根据需要选择最适合的格式，但是在表达的基本结构上应该遵循一定的规范，这样可以保证**最大程度的适用性**。这个基本结构主要是整体的组织方式和链接的格式。**HAL（Hypertxt Application Language）是一个被广泛采用的超文本表达的规范**。应用可以考虑遵循该规范，Spring HATEOAS 提供了对 HAL 的支持。

### HAL 规范

HAL 规范本身是很简单的，下面给出了示例的 JSON 格式的表达。

```json
 {
 "_links": {
 "self": {
 "href": "http://localhost:8080/lists"
 }
 },
 "_embedded": {
 "lists": [
 {
 "id": 1,
 "name": "Default",
 "_links": {
 "todo:items": {
 "href": "http://localhost:8080/lists/1/items"
 },
 "self": {
 "href": "http://localhost:8080/lists/1"
 },
 "curies": [
 {
 "href": "http://www.midgetontoes.com/todolist/rels/{rel}",
 "name": "todo",
 "templated": true
 }
 ]
 }
 }
 ]
 }
}
```

HAL 规范围绕**资源**和**链接**这两个简单的概念展开。

**资源的表达中包含链接、嵌套的资源和状态**。资源的**状态是该资源本身所包含的数据**。**链接则包含其指向的目标**（URI）、所表示的关系和其他可选的相关属性。

对应到 JSON 格式中，资源的链接包含在_links 属性对应的哈希对象中。该_links 哈希对象中的键（key）是链接的关系，而值（value）则是另外一个包含了 href 等其他链接属性的对象或对象数组。当前资源中所包含的**嵌套资源由_embeded 属性**来表示，其值是一个包含了其他资源的哈希对象。

链接的关系不仅是区分不同链接的标识符，同样也是指向相关文档的 URL。文档用来告诉客户端如何对该链接所指向的资源进行操作。当开发人员获取到了资源的表达之后，可以通过查看链接指向的文档来了解如何操作该资源。

### Spring HATEOAS 的 HAL 支持

目前 Spring HATEOAS 仅支持 HAL 一种超媒体表达格式，只需要在**应用的配置类上添加”@EnableHypermediaSupport(type= {HypermediaType.HAL})”注解就可以启用该超媒体支持**。

在启用了超媒体支持之后，**服务器端输出的表达格式会遵循 HAL 规范**。另外，启用超媒体支持会默认启用”@EnableEntityLinks”。在启用超媒体支持之后，应用需要进行相关的定制使得生成的 HAL 表达更加友好。

内嵌资源在 _embedded 对应的哈希对象中的属性值，该属性值是由 org.springframework.hateoas.RelProvider 接口的实现来提供的。

如果需要**修改  _embedded 的属性名称**，只需要在内嵌资源对应的模型类中添加 org.springframework.hateoas.core.Relation 注解即可，如下所示。

在模型类中添加 @Relation 注解

```java
@Relation(value="taco", collectionRelation="tacos")
public class TacoResource extends ResourceSupport {
...
}
```

声明了当模型类 **TacoResource List 的对象作为内嵌资源时，名字是 tacos。单个 TacoResource 作为内嵌时，名字是taco**。



## 小结

采用 HATEOAS 所带来的好处是很大的，可以帮助**客户端和服务器更好的解耦**，可以减少很多潜在的问题。Spring HATEOAS 在 Spring MVC 框架的基础上，允许开发人员通过简单的配置来添加 HATEOAS 约束。如果应用本身已经使用了 Spring MVC，则同时启用 HATEOAS 是一个很好的选择。