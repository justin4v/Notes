# SQL关联查询join

## MySQL

关联查询JOIN可以在两个或多个表中关联查询数据



- **INNER JOIN（内连接,或等值连接）**：INNER 可以省略。获取两个表中字段匹配关系的记录（***只显示两个表中都存在且符合查询条件的记录***）。
- **LEFT JOIN（左连接）：**获取左表所有记录，即使右表没有对应匹配的记录（***以左边的表的为准，显示所有左边表中符合条件的记录以及左边表中存在右边不存在的记录***）。
- **RIGHT JOIN（右连接）：** 与 LEFT JOIN 相反，用于获取右表所有记录，即使左表没有对应匹配的记录（***和左连接相对***）。

## 示例

1. inner join ：``SELECT a.runoob_id, a.runoob_author, b.runoob_count FROM runoob_tbl a INNER JOIN tcount_tbl b ON a.runoob_author = b.runoob_author;``

2. left join: ``SELECT a.runoob_id, a.runoob_author, b.runoob_count FROM runoob_tbl a LEFT JOIN tcount_tbl b ON a.runoob_author = b.runoob_author;`` 其中runoob_tbl是左表
3. right join： ``SELECT a.runoob_id, a.runoob_author, b.runoob_count FROM runoob_tbl a RIGHT JOIN tcount_tbl b ON a.runoob_author = b.runoob_author;``



## MyBatis-plus

mybatis-plus 

1. 特点是灵活，可以在xml中自定义SQL语句。
2. 内置的方法基本上都是针对单表的操作。
3. 针对多表关联的查询等操作，需要使用自定义sql

