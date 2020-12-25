# springboot工程http请求特殊字符

工程框架 SpringBoot + Maven

开发IDE IDEA

## 特殊字符 {}

有时候http请求中会使用json格式发送

如GET /cloud-platform/statistic/v1/upload-data-monitor?params={"startTime":"2020-06-02 00:00:00","endTime":"2020-06-02 23:59:59"}

默认情况下，会返回400错误 日志报错 

```
java.lang.IllegalArgumentException: Invalid character found in the request target. The valid characters are defined in RFC 7230 and RFC 3986
```





