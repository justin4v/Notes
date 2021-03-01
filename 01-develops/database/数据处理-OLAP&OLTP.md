# OLAP与OLTP

## 简介

数据处理大致可以分成**两大类**

**联机事务处理OLTP（on-line transaction processing）**、**联机分析处理OLAP（On-Line Analytical Processing）**。OLTP是传统的关系型数据库的主要应用，主要是基本的、日常的事务处理，例如银行交易。OLAP是数据仓库系统的主要应用，支持复杂的分析操作，侧重决策支持，并且提供直观易懂的查询结果。

- OLTP：**高并发，低时延，大量简单事务**操作的业务场景。系统强调数据库内存效率，强调内存各种指标的命令率，强调绑定变量，强调并发操作；
- OLAP：**海量数据，复杂sql，实时性要求不高**的数据分析、挖掘的业务场景。系统则强调数据分析，强调SQL执行市场，强调磁盘I/O，强调分区等。

## 对比

| **Parameters**         | **OLTP**                                                     | **OLAP**                                                     |
| ---------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **Process**            | It is an online transactional system. **It manages database modification**. | OLAP is an online **analysis and data retrieving process**.  |
| **Characteristic**     | It is characterized by large numbers of short online transactions. | It is characterized by a large volume of data.               |
| **Functionality**      | OLTP is an online database modifying system.                 | OLAP is an online database query management system.          |
| **Method**             | OLTP uses traditional DBMS.                                  | OLAP uses the data warehouse.                                |
| **Query**              | Insert, Update, and Delete information from the database.    | Mostly select operations                                     |
| **Table**              | Tables in OLTP database are normalized.                      | Tables in OLAP database are **not**normalized.               |
| **Source**             | OLTP and its transactions are the sources of data.           | Different OLTP databases become the source of data for OLAP. |
| **Data Integrity**     | OLTP database must maintain data integrity constraint.       | OLAP database does not get frequently modified. Hence, data integrity is not an issue. |
| **Response time**      | It's response time is in millisecond.                        | Response time in seconds to minutes.                         |
| **Data quality**       | The data in the OLTP database is always detailed and organized. | The data in OLAP process might not be organized.             |
| **Usefulness**         | It helps to control and run fundamental business tasks.      | It helps with planning, problem-solving, and decision support. |
| **Operation**          | Allow read/write operations.                                 | Only read and rarely write.                                  |
| **Audience**           | It is a market orientated process.                           | It is a customer orientated process.                         |
| **Query Type**         | Queries in this process are standardized and simple.         | Complex queries involving aggregations.                      |
| **Back-up**            | Complete backup of the data combined with incremental backups. | OLAP only need a backup from time to time. Backup is not important compared to OLTP |
| **Design**             | DB design is application oriented. Example: Database design changes with industry like Retail, Airline, Banking, etc. | DB design is subject oriented. Example: Database design changes with subjects like sales, marketing, purchasing, etc. |
| **User type**          | It is used by Data critical users like clerk, DBA & Data Base professionals. | Used by Data knowledge users like workers, managers, and CEO. |
| **Purpose**            | Designed for real time business operations.                  | Designed for analysis of business measures by category and attributes. |
| **Performance metric** | Transaction throughput is the performance metric             | Query throughput is the performance metric.                  |
| **Number of users**    | This kind of Database users allows thousands of users.       | This kind of Database allows only hundreds of users.         |
| **Productivity**       | It helps to Increase user's self-service and productivity    | Help to Increase productivity of the business analysts.      |
| **Challenge**          | Data Warehouses historically have been a development project which may prove costly to build. | An OLAP cube is not an open SQL server data warehouse. Therefore, technical knowledge and experience is essential to manage the OLAP server. |
| **Process**            | It provides fast result for daily used data.                 | It ensures that response to the query is quicker consistently. |
| **Characteristic**     | It is easy to create and maintain.                           | It lets the user create a view with the help of a spreadsheet. |
| **Style**              | OLTP is designed to have fast response time, low data redundancy and is normalized. | A data warehouse is created uniquely so that it can integrate different data sources for building a consolidated database |



## 关键不同

- Online Analytical Processing (OLAP) is a category of software tools that **analyze data stored in a database** whereas Online transaction processing (OLTP) supports **transaction-oriented applications** in a 3-tier architecture.
- OLAP creates a single platform for **all type of business analysis needs** which includes planning, budgeting, forecasting, and analysis while OLTP is useful to administer **day to day transactions** of an organization.
- OLAP is characterized by a large volume of data while OLTP is characterized by large numbers of short online transactions.
- In OLAP, data warehouse is created uniquely so that it can integrate different data sources for building a consolidated database whereas OLTP uses traditional DBMS.