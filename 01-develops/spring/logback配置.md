# logback配置

注意看考官网说明 [logback手册](http://logback.qos.ch/manual/index.html)



## EvaluatorFilter

抽象类 有多种实现

默认实现是 

```
ch.qos.logback.classic.boolex.JaninoEventEvaluator
```



### JaninoEventEvaluator

可以用任意返回 boolean 的 java 代码块作为过滤标准

需要 Janino library支持。

官方文档有如下说明

[Conditional processing](http://logback.qos.ch/manual/configuration.html#conditional) in configuration files requires the [**Janino library**](http://docs.codehaus.org/display/JANINO/Home). Moreover, the evaluator examples based on `JaninoEventEvaluator` require Janino as well

