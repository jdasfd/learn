# Bioinformatic concepts

In the markdown, I recorded some concepts or definitions related in simplified Chinese.

## RESTful

### What is REST

REST全称是**RE**presentational **S**tate **T**ransfer，中文意思是表述性（通常译为表征）状态转移。它首次出现在2000年Roy Fielding（HTTP规范的主要编写者之一）的博士论文中。REST是一种软件架构风格（a software architectural style)。

像其他架构风格一样（architectural styles)。REST有其对应的指导原则和约束。如果需要将一个服务器接口（a service interface)称为**RESTful**，则必须满足这些原则。

符合REST架构风格的Web API（或者Web Service）就是REST API。

`REST!=HTTP`

RESTful背后的理念是使用Web的现有特征和能力，更好地使用现有Web标准中的一些准则和约束。虽然REST本身受Web技术的影响很深，但是理论上REST架构风格并不是绑定在HTTP上，只不过目前HTTP是唯一与REST相关的实例。

**总结**：简而言之，在REST架构风格中，数据（data）和功能（functionality）都被视为一种资源（resources）并使用统一资源标识（Uniform Resource Identifiers, URIs)进行访问。

### Basic concepts

1. 资源与URI

REST全称为表述性状态转移，那究竟何为表述？其实指的就是资源，任何事务只要有被引用的必要性，就是一个资源。资源可以是数据实体（如手机号码，个人信息），也可以是抽象概念（如某些价值）。

而要让一个资源可以被识别，需要一个唯一标识，在Web中这个唯一标识是URI。

URI既可以看成资源的地址，也可以看成资源的名称。如果某些信息没有用URI标识，那么就不能算作一个资源，只能算是资源的一些信息。以GitHub为例：

- https://github.com/git
- https://github.com/git/git
- https://github.com/git/git/blob/master/block-sha1/sha1.h
- https://github.com/git/git/pulls
- https://github.com/git/git/pulls?state=closed

越来越多的URI采用了如下的方式进行编辑，使其可读性更高：

- 可以使用`_`或`-`来让URI可读性变得更好。
- 使用`/`来表示资源的层级关系。
- 使用`?`来过滤资源。`/git/git/pulls`表示所有推入请求，`/pulls?state=closed`表示git项目中已经关闭的推入请求，这种URL通常对应的是一些特定条件的查询结果或算法运算结果。
- 使用`,`或`;`来表示同级资源的关系。

2. 统一资源接口

RESTful结构遵循统一接口原则，统一接口包含了一组首先的预定义的操作，不论什么样的资源，都是通过使用相同的接口进行资源的访问。接口应该使用标准的HTTP方法如GET，PUT和POST，并遵循这些方法的语义。

3. 资源的表述

客户端可以通过HTTP方法获取资源，但更确切的说，客户端获取的是资源的表述。而资源在外界可通过多种表述形式具体呈现，在客户端和服务端之间传送的即资源的表述，而非资源本身。例如文本资源可以采用html、xml、json等格式，图片可以采用PNG或JPG。

资源的表述包括：数据和描述数据的元数据，如HTTP头`"Content-Type"`就是这样一个元数据属性。

客户端可以通过HTTP内容协商，通过Accept头请求一种特定格式的表述，服务端通过Content-Type告诉客户端资源的表述形式

```bash
# Request
GET https://api.github.com/orgs/github

# response
{"login":"github","id":9919,"node_id":"MDEyOk9yZ2FuaXphdGlvbjk5MTk=","url":"https://api.github.com/orgs/github","repos_url":"https://api.github.com/orgs/github/repos","events_url":"https://api.github.com/orgs/github/events","hooks_url":"https://api.github.com/orgs/github/hooks","issues_url":"https://api.github.com/orgs/github/issues","members_url":"https://api.github.com/orgs/github/members{/member}","public_members_url":"https://api.github.com/orgs/github/public_members{/member}","avatar_url":"https://avatars.githubusercontent.com/u/9919?v=4","description":"How people build software.","name":"GitHub","company":null,"blog":"https://github.com/about","location":"San Francisco, CA","email":null,"twitter_username":null,"is_verified":true,"has_organization_projects":true,"has_repository_projects":true,"public_repos":420,"public_gists":0,"followers":0,"following":0,"html_url":"https://github.com/github","created_at":"2008-05-11T04:37:31Z","updated_at":"2022-04-08T10:02:08Z","type":"Organization"}
```

In [Pseudomonas.md](https://github.com/jdasfd/withncbi_note/blob/main/note/Pseudomonas.md):

```bash
curl -fsSL "https://www.ncbi.nlm.nih.gov/biosample/?term={}&report=full&format=text" -o biosample/{}.txt
```

### Reference

[REST API Tutorial](https://restfulapi.net/).
[RESTful 架构详解](https://www.runoob.com/w3cnote/restful-architecture.html)

## What is HTTP

## `node.js`

`Node.js`，简单来说就是运行在服务端的JavaScript，是一个事件驱动I/O服务端JavaScript环境，基于Google的V8引擎。