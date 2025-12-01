# SQLBot LLMService 核心类图分析

## 1. 核心类图

```mermaid
classDiagram
    %% LLMService 核心类
    class LLMService {
        -ds: CoreDatasource
        -chat_question: ChatQuestion
        -record: ChatRecord
        -config: LLMConfig
        -llm: BaseChatModel
        -sql_message: List[BaseMessage]
        -chart_message: List[BaseMessage]
        -current_user: CurrentUser
        -current_assistant: CurrentAssistant
        -generate_sql_logs: List[ChatLog]
        -generate_chart_logs: List[ChatLog]
        -current_logs: Dict[OperationEnum, ChatLog]
        -chunk_list: List[str]
        -future: Future

        +__init__(session, current_user, chat_question, current_assistant?, no_reasoning?, embedding?, config?)
        +create() LLMService
        +is_running(timeout?) bool
        +init_messages()
        +init_record(session) ChatRecord
        +generate_analysis(session) Iterator[Dict]
        +generate_predict(session) Iterator[Dict]
        +generate_recommend_questions_task(session) Iterator[Dict]
        +select_datasource(session) Iterator[Dict]
        +generate_sql(session) Iterator[Dict]
        +generate_with_sub_sql(session, sql, sub_mappings) str
        +generate_assistant_dynamic_sql(session, sql, tables) Dict
        +build_table_filter(session, sql, filters) str
        +generate_filter(session, sql, tables) str
        +generate_assistant_filter(session, sql, tables) str
        +generate_chart(session, chart_type?) Iterator[Dict]
        +run_task(in_chat?, stream?, finish_step?) Iterator[Dict]
        +execute_sql(sql) Dict
    }

    %% 配置类
    class LLMConfig {
        +model_id: Optional[int]
        +model_type: str
        +model_name: str
        +api_key: Optional[str]
        +api_base_url: Optional[str]
        +additional_params: Dict[str, Any]
        +__hash__()
    }

    %% 问题模型类
    class AiModelQuestion {
        +question: str
        +ai_modal_id: int
        +ai_modal_name: str
        +engine: str
        +db_schema: str
        +sql: str
        +rule: str
        +fields: str
        +data: str
        +lang: str
        +filter: list
        +sub_query: Optional[list[dict]]
        +terminologies: str
        +data_training: str
        +custom_prompt: str
        +error_msg: str

        +sql_sys_question(db_type, enable_query_limit?) str
        +sql_user_question(current_time) str
        +chart_sys_question() str
        +chart_user_question(chart_type?) str
        +analysis_sys_question() str
        +analysis_user_question() str
        +predict_sys_question() str
        +predict_user_question() str
        +datasource_sys_question() str
        +datasource_user_question(datasource_list) str
        +guess_sys_question() str
        +guess_user_question(old_questions) str
        +filter_sys_question() str
        +filter_user_question() str
        +dynamic_sys_question() str
        +dynamic_user_question() str
    }

    %% 聊天问题类
    class ChatQuestion {
        +chat_id: int
    }

    %% 聊天记录类
    class ChatRecord {
        +id: int
        +chat_id: int
        +ai_modal_id: int
        +first_chat: bool
        +create_time: datetime
        +finish_time: datetime
        +create_by: int
        +datasource: int
        +engine_type: str
        +question: str
        +sql_answer: str
        +sql: str
        +sql_exec_result: str
        +data: str
        +chart_answer: str
        +chart: str
        +analysis: str
        +predict: str
        +predict_data: str
        +recommended_question_answer: str
        +recommended_question: str
        +datasource_select_answer: str
        +finish: bool
        +error: str
        +analysis_record_id: int
        +predict_record_id: int
    }

    %% 聊天日志类
    class ChatLog {
        +id: int
        +type: TypeEnum
        +operate: OperationEnum
        +pid: int
        +ai_modal_id: int
        +base_modal: str
        +messages: list[dict]
        +reasoning_content: str
        +start_time: datetime
        +finish_time: datetime
        +token_usage: dict
    }

    %% 数据源类
    class CoreDatasource {
        +id: int
        +oid: int
        +name: str
        +description: str
        +type: str
        +connection: dict
        +host: str
        +port: int
        +username: str
        +password: str
        +database: str
        +schema: str
        +table: str
        +status: int
        +create_time: datetime
        +update_time: datetime
        +create_by: int
        +update_by: int
    }

    %% LLM 基类和实现
    class BaseLLM {
        <<abstract>>
        #config: LLMConfig
        #_llm: BaseChatModel

        +__init__(config: LLMConfig)
        +_init_llm()* BaseChatModel
        +llm: BaseChatModel
    }

    class OpenAILLM {
        +_init_llm() BaseChatModel
    }

    class OpenAIAzureLLM {
        +_init_llm() BaseChatModel
    }

    class OpenAIvLLM {
        +_init_llm() VLLMOpenAI
    }

    %% 辅助类
    class CurrentUser {
        +oid: int
        +username: str
        +language: str
        +role: str
    }

    class CurrentAssistant {
        +id: int
        +name: str
        +type: int
        +certificate: str
        +online: bool
    }

    %% 枚举类
    class OperationEnum {
        <<enumeration>>
        GENERATE_SQL
        GENERATE_CHART
        ANALYSIS
        PREDICT_DATA
        GENERATE_RECOMMENDED_QUESTIONS
        GENERATE_SQL_WITH_PERMISSIONS
        CHOOSE_DATASOURCE
        GENERATE_DYNAMIC_SQL
    }

    class ChatFinishStep {
        <<enumeration>>
        GENERATE_SQL
        QUERY_DATA
        GENERATE_CHART
    }

    class TypeEnum {
        <<enumeration>>
        CHAT
    }

    %% 工厂类
    class LLMFactory {
        +create_llm(config: LLMConfig) BaseLLM
    }

    %% 关系定义
    LLMService --> LLMConfig : uses
    LLMService --> ChatQuestion : contains
    LLMService --> ChatRecord : manages
    LLMService --> CoreDatasource : uses
    LLMService --> BaseChatModel : uses
    LLMService --> CurrentUser : depends on
    LLMService --> CurrentAssistant : depends on
    LLMService --> ChatLog : manages
    LLMService --> OperationEnum : uses
    LLMService --> ChatFinishStep : uses

    ChatQuestion --|> AiModelQuestion : extends

    LLMFactory --> BaseLLM : creates
    BaseLLM <|-- OpenAILLM : implements
    BaseLLM <|-- OpenAIAzureLLM : implements
    BaseLLM <|-- OpenAIvLLM : implements
    BaseLLM --> LLMConfig : uses

    AiModelQuestion --> LLMConfig : references

    ChatRecord --> ChatLog : has many
    ChatLog --> OperationEnum : uses
    ChatLog --> TypeEnum : uses
```

## 2. 类职责分析

### 2.1 LLMService 类
**核心职责：** SQLBot 的核心服务类，负责协调整个AI问答流程

**主要功能：**
- **生命周期管理：** 初始化配置、消息管理、记录跟踪
- **SQL生成：** 根据用户问题生成SQL查询语句
- **图表生成：** 基于SQL结果生成可视化图表配置
- **数据分析：** 对查询结果进行智能分析和预测
- **数据源管理：** 动态选择和管理数据源连接
- **权限控制：** 实现行级和列级数据权限过滤
- **异步处理：** 支持流式输出和后台任务执行

### 2.2 配置管理类

#### LLMConfig
**职责：** 大语言模型配置管理
- 支持多种LLM类型（OpenAI、Azure、VLLM等）
- 管理API密钥和基础URL
- 支持额外的模型参数配置
- 实现哈希方法，便于缓存和比较

#### AiModelQuestion/ChatQuestion
**职责：** 问题模板管理
- 提供各种系统提示词模板生成方法
- 管理多语言支持
- 集成术语库和训练数据
- 支持自定义提示词

### 2.3 数据模型类

#### ChatRecord
**职责：** 聊天记录数据模型
- 记录完整的问答流程状态
- 存储SQL、图表、分析结果
- 支持异步任务状态跟踪
- 维护错误信息和执行时间

#### ChatLog
**职责：** 操作日志记录
- 记录所有AI模型交互
- 跟踪token使用情况
- 存储推理过程内容
- 支持操作类型分类

### 2.4 LLM集成类

#### BaseLLM及其实现类
**职责：** 大语言模型抽象和具体实现
- 提供统一的LLM接口
- 支持多种模型后端（OpenAI、Azure、VLLM）
- 实现模型配置和参数管理
- 提供流式输出支持

## 3. 核心工作流程

### 3.1 主要交互流程
1. **初始化阶段：** LLMService创建并配置所有依赖对象
2. **数据源选择：** 根据问题内容智能选择合适的数据源
3. **SQL生成：** 基于问题和数据源schema生成SQL查询
4. **权限过滤：** 根据用户权限对SQL进行行级过滤
5. **SQL执行：** 执行查询并获取结果数据
6. **图表生成：** 根据数据特性选择合适的可视化方式
7. **智能分析：** 对查询结果进行深度分析和预测
8. **结果输出：** 流式返回完整的问答结果

### 3.2 异步处理机制
- 使用ThreadPoolExecutor实现后台任务执行
- 支持流式输出，提供实时反馈
- 缓存机制优化重复请求性能
- 错误处理和异常恢复机制

## 4. 设计模式和架构特点

### 4.1 设计模式
- **工厂模式：** LLMFactory创建不同类型的LLM实例
- **策略模式：** 不同的数据源和LLM类型采用不同处理策略
- **建造者模式：** 复杂的问题模板构建过程
- **观察者模式：** 流式输出的数据推送机制

### 4.2 架构特点
- **模块化设计：** 清晰的职责分离和接口定义
- **可扩展性：** 支持新的LLM类型和数据源类型
- **多租户支持：** 基于oid的数据隔离
- **高可用性：** 完善的错误处理和恢复机制
- **性能优化：** 缓存、异步处理和资源池化

这个LLMService类图展现了SQLBot系统在AI问答功能上的核心架构，体现了现代AI应用在服务化、模块化和可扩展性方面的最佳实践。