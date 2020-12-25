# 区别

SpringBootApplication注解中包含ComponentScan注解

相同注解会相互覆盖

**所以，如果相同时使用这两个注解，需要将ComponentScan注解放在下面，否者其会被SpringBootApplication注解覆盖，不会生效**