# Ant-style Pattern

Spring默认的策略实现了 org.springframework.util.AntPathMatcher，即**Apache Ant项目类似的样式路径规则**，Apache Ant样式的路径有三种通配符匹配方法（在下面的表格中列出)。

其匹配比 regex 正则**更加灵活**

## 通配符表

Table Ant Wildcard Characters

| Wildcard | Description             |      |
| -------- | ----------------------- | ---- |
| ?        | 匹配任何单字符          |      |
| *        | 匹配0或者任意数量的字符 |      |
| **       | 匹配0或者更多的目录     |      |

## 例子

Table Example Ant-Style Path Patterns

| Path                    | Description                                                  |      |
| ----------------------- | ------------------------------------------------------------ | ---- |
| ```/app/*.x```          | 匹配(Matches)所有在app路径下的.x文件                         |      |
| ```/app/p?ttern```      | 匹配(Matches) /app/pattern 和 /app/pXttern,但是不包括/app/pttern |      |
| ```/**/example```       | 匹配(Matches) /app/example, /app/foo/example, 和 /example    |      |
| ```/app/**/dir/file.``` | 匹配(Matches) /app/dir/file.jsp, /app/foo/dir/file.html,/app/foo/bar/dir/file.pdf, 和 /app/dir/file.java |      |
| ```/**/*.jsp```         | 匹配(Matches)任何的根路径下的.jsp 文件                       |      |

## 注意

**最长匹配原则(has more characters)**  优先匹配 **含有更多匹配字符的路径**

URL请求 /project/dir/file.jsp，现在存在两个路径匹配模式  

```/**/*.jsp```

```/project/dir/*.jsp```

将会匹配 ```/project/dir/*.jsp```



