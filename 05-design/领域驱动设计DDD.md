## DDD

《Domain-Driven Design Tackling Complexity in the Heart of Software》 Eric Evans 

有很多因素使得软件开发复杂化，最根本的原因是**问题领域本身的错综复杂**。软件复杂性无法回避，只能够控制。

本书描述并建立了领域建模艺术的词汇库，它提供了一个参考框架，可以用其来解释相关活动。

领域驱动设计的**实质是消化吸收大量的知识，最后产生一个反映深层次领域知识并聚焦于关键概念的模型**。

## 书籍结构

本书假定项目必须遵守两个开发实践：

1. **迭代开发。**
2. **开发人员与领域专家有密切关系。**

第一部分  **Putting the Domain Model to Work** presents the basic goals of domain-driven development。

- Crunching Knowledge
- Communication and the Use of Language
- Binding Model and Implementation

第二部分 **The Building Blocks of a Model-Driven Design**。This section focuses on bridging the gap between models and practical, running software. Using standard patterns also contributes terminology to a common language, which all team members can use to discuss model and design decisions.

But the main point of this section is to focus on the kinds of decisions that keep the model and implementation aligned with each other, each reinforcing the other’s effectiveness.

- Isolating the Domain
- A Model Expressed in Software
- The Life Cycle of a Domain Object
- Using the Language: An Extended Example

第三部分 **Refactoring Toward Deeper Insight**  goes beyond the building blocks to the challenge of assembling them into practical models that provide the payoff。 Rather than jumping directly into esoteric design principles, this section emphasizes the discovery process. That understanding comes from diving in,implementing an initial design based on a probably naive model, and then transforming it again and again。

- Breakthrough
- Making Implicit Concepts Explicit
- Supple Design
- Applying Analysis Patterns
- Relating Design Patterns to the Model
- Relating Design Patterns to the Model

第四部分 **Strategic Design** deals with situations that arise in complex systems, larger organizations, and interactions with external systems and legacy systems.This section explores a triad of principles that apply to the system as a whole: context, distillation, and large-scale structure.

- Maintaining Model Integrity
- Distillation
- Large-Scale Structure
- Bringing the Strategy Together



## Crunching Knowledge

和领域专家沟通，由简单的原型开始，在整个开发流程中反复沟通、迭代改进。在这个过程中双方都在消化理解对方的领域知识，开发人员学习重要的业务原理，而不是机械式的进行功能开发；领域专家提炼知识，同时也理解软件项目的概念严谨性。

传统的瀑布开发中，业务专家与分析员讨论，分析员消化理解后将结果传递给程序员，再由程序员编写代码，这种方式没有反馈，很容易失败。分析员负责基于业务专家的意见创建模型，没有向程序员学习，也没有早期软件版本的经验。知识知识朝着一个方向流动，没有反馈与累积。

### Ingredients of Effective Modeling

- Binding the model and the implementation.
- Cultivating a language based on the model.  
- Developing a knowledge-rich model.
- Distilling the model. 
- Brainstorming and experimenting. 



### Continuous Learning

**When we set out to write software, we never know enough**

- Knowledge on the project is **fragmented**,scattered among many people and documents, and it’s mixed with other information so that we don’t even know which bits of knowledge we really need。
- Domains that seem less technically daunting can be deceiving: we don’t realize **how much we don’t know**. This ignorance leads us to make false assumptions.
- All projects **leak knowledge**。

我们应该通过 continuous learning 积累知识。对开发人员而言，这意味着完善专业技术知识和培养一般的建模技能，这也包括认真学习他们正在从事的特定领域知识。