# Spring 框架

## 定义

**Spring是一个Java平台的（企业级）*应用开发框架*（application framework）和*控制反转容器*（IOC）**。



keys： 

- application framework -- 提供**一整套java平台应用开发解决方案** ，可扩展
- IOC -- 提供了一种 **java  instance/object 管理方案**，使得 Java instance 之间不再显式 **强依赖**





## features

1. IoC -- Inversion of Control  容器：容器通过**反射（reflection）**配置以及管理beans。

2. AOP -- Aspect-oriented programming ：（运行时）代理机制。解决横切面业务（扩展）需求。利用容器管理。

3. Data Access Framework -- 不提供统一数据操作API（保留原始API），只提供数据库管理环境。需要配置数据源、sessionFactory、properties、transactionManager等
4. Transaction management-- 提供统一的抽象机制。和data access配合使用。
5. Model–view–controller framework -- 网页应用框架

## design philosophy

- **Provide choice at every level ** 可配置. Spring lets you defer design decisions as late as possible. For example, you can switch persistence providers through configuration without changing your code. The same is true for many other infrastructure concerns and integration with third-party APIs.
- **Accommodate diverse perspectives **灵活. Spring embraces flexibility and is not opinionated about how things should be done. It supports a wide range of application needs with different perspectives.
- **Maintain strong backward compatibility** 向后兼容. Spring’s evolution has been carefully managed to force few breaking changes between versions. Spring supports a carefully chosen range of JDK versions and third-party libraries to facilitate maintenance of applications and libraries that depend on Spring.
- **Care about API design.** The Spring team puts a lot of thought and time into making APIs that are intuitive and that hold up across many versions and many years.
- **Set high standards for code quality**. The Spring Framework puts a strong emphasis on meaningful, current, and accurate javadoc. It is one of very few projects that can claim clean code structure with no circular dependencies between packages.