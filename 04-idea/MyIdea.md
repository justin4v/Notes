# 冷热数据分离

## 问题

冷热数据分开存储有利于**提升性能**或者**节省扩容成本** （冷数据存储在低速介质中）

典型的冷热数据**分开存储的依据是时间**



但是在查询的时候 往往又**不会传递时间参数**，所以**无法**根据传入参数判定该数据在冷库还是热库



## 解决

### 建索引

建立 查询 字段和库 的索引。每次先查询索引得到需要查询的库，之后到指定的库中查询数据。

优点：简单直接 易于理解

缺点：每次都需要做两次查询；索引增长可能很快

### 先查询热库

每次先查询热库，查询不到再查询 冷库



优点：不需要另外建立索引；一定程度上减少了网络访问

缺点：第一个查询对象是固定的，仍然可能有很多多余的查询

### 算法

建立一个学习算法（神经网络，有监督，每次的查询都有反馈）

输入: id 或者 时间 等查询参数 

输出: 数据存在于各个库的概率

则根据概率顺序 到对应库中查找数据。