#### 轻量级J2EE作业执行策略

---

**截止日期 及 间隔时间：**

- e1    2018.12.05 23:00 (10)
- e2-e4 2018.12.26 23:00 (21)
- e5-e6 2018.01.09 23:00 (13)
- e7    2018.01.16 23:00 (7)

**自己估算的时间安排：**
- e1 4天  2018.11.28 23:00 4天  (缓6天)
- e2 8天  2018.12.05 23:00 7天
- e3 8天  2018.12.13 23:00 8天
- e4 10天 2018.12.23 23:00 10天 (缓3天)
- e5 5天  2018.12.29 23:00 6天
- e6 8天  2018.01.06 23:00 8天  (缓3天)
- e7 10天 2018.01.14 23:00 8天  (缓2天)

---

注意：实验报告中可能会需要截图（过程图）

**实验报告要求：**

**1. 主题概述**
- 简要介绍主题的核心内容，如MVC，及MVC中Controller的作用与实现

**2. 假设**
- 主题内容所参照的假设条件，或假定的某故事场景，如调试工具或软硬件环境

**3. 实现或证明**
- 对主题内容进行实验实现，或例举证明，需描述实现过程及数据。如对MVC中Controller功能的实现及例证（图示、数据、代码等）

**4. 结论**
- 对主题的总结，结果评论，发现的问题，或你的建议和看法。如MVC中Controller优点与缺点，个人看法（文字、图标、代码辅助等）

**5. 参考文献**
- 以上内容的理论知识点或技术点如果参考了网上或印刷制品，请在这里罗列出来

---

**主要任务 及 预估时间：**

- **e1 4天**
    + SimpleController
        * doGet()
        * doPost()
    + JavaWeb UseSC
        * web.xml配置
        * welcome.html
    + war包部署到tomcat
    + Http request 在 Web Container 中的处理流程
    + 比较 JSP Model 1 与 Model 2 架构，说明各自的优缺点及适用场景 

- **e2 8天**
    + UseSC 拦截器（Login, Register）配置
        * POJO
            - LoginAction
            - RegisterAction
        * html / jsp
        * controller.xml
    + SimpleController添加对拦截器的支持
        * doPost()处理action请求
        * 解析controller.xml文件
        * 根据解析到的action,type,value等信息进行相应处理（反射机制、动态代理）
    + war包部署到tomcat
    + 描述你对 Struts 2 控制器的理解，并参考资料，比较基于配置的控制器和注解的控制器各自优缺点

- **e3 8天**
    + UseSc 拦截器（Log）
        * LogInterceptor
            - preAction
            - afterAction
        * 将日志追加到log.xml（根据相应的格式）
        * controller.xml 添加拦截器结点
    + SimpleController中添加对 LogInterceptor的支持
        * 检测http请求的action
        * 根据规则执行predo()，afterdo()
        * 使用Java动态代理机制实现
    + 请分析在 MVC pattern 中，Controller 可以具备哪些功能，并描述是否合理？ 

- **e4 10天**
    + UseSC 添加 success_view.xml
    + 基于E3，将 success_view.xml作为 LoginAction 的success结果视图
    + SimpleController中添加对 `*_view.xml` 的支持
        * 根据view.xml中定义的规则，动态生成视图推送至客户端
        * 生成游览器可执行的html页面，可参考(XSLT)
    + 请描述 Struts 框架中视图组件的工作方式，如`<s:form>/<s:submit>`

- **e5 5天**
    + SimpleController中添加 dao层
        * BaseDAO（抽象）（包括字段：driver, url, userName, userPassword）
        * BaseDAO 中实现方法
            - openDBConnection(): Connection
            - closeDBConnection(): boolean
        * BaseDAO 中抽象方法
            - query(String sql): Object
            - insert(String sql): boolean
            - update(String sql): boolean
            - delete(String sql): boolean
    + UseSC 中添加 UserBean 支持
        * 修改LoginAction代码，将请求转发给UserBean中的类来处理
    + UseSC 添加 UserDAO 继承 SimpleController中的BaseDAO
        * 初始化各种字段
        * signIn()方法实现
    + UserBean中的sigIn()方法接收 UserDAO query()返回的对象，并进行相应逻辑处理
    + 打包测试代码
    + 将UseSC中的DBMS改为另一种DBMS，要求：仅修改UserDAO的代码，如：将mysql换成postgresql, sqlite

- **e6 8天**
    + UseSC 中添加 ORM 的支持
        * or_mapping.xml
        * xml中配置jdbc连接属性，table-userbean的映射关系
    + SimpleController中添加对 ORM 的支持
        * Configuration类：解析xml
        * Conversation类：将对象操作转换为数据库表操作
        * 通过JDBC完成数据持久化
    + 修改 E5 中UserDAO的代码，使用Conversation类将sql改为对对象的CRUD操作
    + war包部署到tomcat测试
    + 将测试的数据库修改为另一个 DBMS，仅修改 Conversation 代码，重新进行打包 和部署，并测试结果。如将 mysql 修改为 sqlite
    + 实现对象属性 lazy-loading（可通过代理模式 Proxy Pattern 实现）

- **e7 10天**（初次看，没概念）
    + UseSC 中添加 DI（依赖注入）的支持
        * di.xml
    + SimpleController中添加对 DI 的支持
        * 扫描controller.xml
        * 扫描di.xml
        * 反射生成`<bean>`实例
    + 使用DI，修改UseSC中的LoginAction代码，将UserBean对象属性初始化语句移除，重新打包测试
    + 基于以上内容，修改 E6 中关于对象依赖的代码，将对象依赖关系通过 di.xml 进行管理
        * DAO的依赖代码
        * Model的依赖代码
        * 其他
