# 代理设置

Go 1.13 将 `GOPROXY` 默认成了中国大陆无法访问的 [https://proxy.golang.org](https://proxy.golang.org/) 所以国内一般需要重新设置代理

## 代理设置

 `go env -w GOPROXY=https://goproxy.cn,direct`



## 解释

之所以在后面拼接一个 `,direct`，是因为通过这样做我们可以在一定程度上解决私有库的问题（当然， [goproxy.cn](https://goproxy.cn/) 无法访问你的私有库）。

这个 `GOPROXY` 设定的工作原理是：当 `go` 在抓取目标模块时，若遇见了 404 错误，那么就回退到 `direct` 也就是直接去目标模块的源头（比如 GitHub） 去抓取。而恰好，GitHub 等类似的代码托管网站的原则基本都是“你无权访问的你来说就是不存在的”，所以我才说通过这样设定可以在一定程度上解决私有库无法通过模块代理访问的问题