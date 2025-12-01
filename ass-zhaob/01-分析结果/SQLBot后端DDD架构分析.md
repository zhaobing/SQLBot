# SQLBot后端架构DDD分析

## 1. 领域划分（Bounded Contexts）

基于对SQLBot后端代码的分析，系统划分为以下9个核心子域（Bounded Contexts）：

```
┌─────────────────────────────────────────────────────────────────┐
│                    SQLBot 领域架构                                │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │    System   │  │    Chat     │  │ DataSource  │             │
│  │  系统管理子域  │  │   聊天子域   │  │  数据源子域   │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   AI Model  │  │ Terminology │  │DataTraining │             │
│  │  AI模型子域   │  │  术语管理子域│  │  数据训练子域│             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │  Dashboard  │  │     MCP     │  │  Template   │             │
│  │  仪表盘子域   │  │  上下文协议  │  │   模板子域   │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└─────────────────────────────────────────────────────────────────┘
```

## 2. DDD概念分类

### 2.1 系统管理子域（System）

#### 聚合根（Aggregate Roots）
- **UserModel** - 用户聚合根
  - 职责：管理用户身份、认证和基本信息
  - 不变条件：用户账户唯一性、密码安全性
  - 领域服务：用户认证服务、权限校验服务

- **WorkspaceModel** - 工作空间聚合根
  - 职责：管理多租户工作空间
  - 不变条件：工作空间名称唯一性、权限边界
  - 领域服务：租户隔离服务

- **AssistantModel** - 助手聚合根
  - 职责：管理AI助手配置和行为
  - 不变条件：助手配置一致性、API密钥安全性
  - 领域服务：助手生命周期管理服务

- **AiModelDetail** - AI模型聚合根
  - 职责：管理AI模型配置和供应商信息
  - 不变条件：模型配置有效性、API访问安全性

#### 聚合（Aggregates）
- **用户-工作空间聚合**：UserWsModel + WorkspaceModel
- **助手-模型聚合**：AssistantModel + AiModelDetail

#### 实体（Entities）
- **UserWsModel** - 用户工作空间关系实体
- **AiModelDetail** - AI模型详情实体

#### 值对象（Value Objects）
- **BaseCreatorDTO** - 创建者信息值对象
- **AiModelBase** - AI模型基础配置值对象
- **WorkspaceBase** - 工作空间基础信息值对象
- **AssistantBaseModel** - 助手基础配置值对象

### 2.2 数据源子域（DataSource）

#### 聚合根（Aggregate Roots）
- **CoreDatasource** - 数据源聚合根
  - 职责：管理数据库连接配置和元数据
  - 不变条件：连接配置有效性、数据完整性
  - 领域服务：连接测试服务、元数据同步服务

#### 聚合（Aggregates）
- **数据源聚合**：CoreDatasource + CoreTable + CoreField

#### 实体（Entities）
- **CoreTable** - 数据表实体
  - 职责：存储表结构和元数据信息
  - 生命周期：依赖于数据源聚合根
- **CoreField** - 数据字段实体
  - 职责：存储字段详细信息和类型定义
  - 生命周期：依赖于数据表实体

#### 值对象（Value Objects）
- **TableSchema** - 表结构信息值对象
- **ColumnSchema** - 列结构信息值对象
- **TableAndFields** - 表字段组合值对象
- **DatasourceConf** - 数据源配置值对象
- **CreateDatasource** - 创建数据源DTO值对象

### 2.3 聊天子域（Chat）

#### 聚合根（Aggregate Roots）
- **Chat** - 聊天会话聚合根
  - 职责：管理聊天会话生命周期和数据源绑定
  - 不变条件：会话完整性、数据源一致性
  - 领域服务：会话管理服务、消息流服务

- **ChatRecord** - 聊天记录聚合根
  - 职责：管理单次问答的完整执行过程
  - 不变条件：执行状态一致性、结果完整性
  - 领域服务：问答执行服务、结果缓存服务

#### 聚合（Aggregates）
- **聊天会话聚合**：Chat + ChatRecord + ChatLog

#### 实体（Entities）
- **ChatLog** - 聊天日志实体
  - 职责：记录详细的操作日志和token使用情况
  - 生命周期：依赖于聊天记录聚合根

#### 值对象（Value Objects）
- **AiModelQuestion** - AI问题模板值对象
- **ChatQuestion** - 聊天问题值对象
- **ChatRecordResult** - 聊天记录结果值对象
- **CreateChat** - 创建聊天DTO值对象
- **RenameChat** - 重命名聊天DTO值对象
- **ChatInfo** - 聊天信息值对象
- **McpQuestion** - MCP问题值对象

#### 领域服务（Domain Services）
- **LLMService** - 核心领域服务
  - 职责：协调整个AI问答流程
  - 复杂业务逻辑：SQL生成、图表生成、数据分析
  - 跨聚合协调：Chat、DataSource、AI Model

### 2.4 术语管理子域（Terminology）

#### 聚合根（Aggregate Roots）
- **Terminology** - 术语聚合根
  - 职责：管理业务术语定义和向量嵌入
  - 不变条件：术语唯一性、向量一致性
  - 领域服务：术语搜索服务、向量计算服务

#### 值对象（Value Objects）
- **TerminologyInfo** - 术语信息值对象

### 2.5 数据训练子域（DataTraining）

#### 聚合根（Aggregate Roots）
- **DataTraining** - 训练数据聚合根
  - 职责：管理训练样本和向量嵌入
  - 不变条件：数据质量、向量一致性
  - 领域服务：训练数据服务、相似度计算服务

#### 值对象（Value Objects）
- **DataTrainingInfo** - 训练数据信息值对象

### 2.6 仪表盘子域（Dashboard）

#### 聚合根（Aggregate Roots）
- **CoreDashboard** - 仪表板聚合根
  - 职责：管理仪表板配置和布局
  - 不变条件：配置一致性、布局有效性
  - 领域服务：仪表板渲染服务、组件管理服务

#### 值对象（Value Objects）
- **DashboardBaseResponse** - 仪表板基础响应值对象
- **DashboardResponse** - 仪表板响应值对象
- **BaseDashboard** - 基础仪表板值对象
- **QueryDashboard** - 查询仪表板值对象
- **CreateDashboard** - 创建仪表板值对象

### 2.7 跨领域共享组件

#### 共享实体基类
- **SnowflakeBase** - 雪花ID基类实体
  - 职责：提供统一的主键生成策略
  - 不变条件：ID唯一性、可排序性

## 3. 架构设计原理

### 3.1 聚合设计原则

#### 单一职责原则
每个聚合都有明确的单一职责边界：

- **用户聚合**：仅负责用户身份和权限管理
- **数据源聚合**：仅负责数据库连接和元数据管理
- **聊天聚合**：仅负责问答流程和结果管理
- **仪表板聚合**：仅负责可视化配置管理

#### 一致性边界
每个聚合维护自己的数据一致性：

```python
# 聚合根示例：CoreDatasource
class CoreDatasource(SQLModel, table=True):
    id: int = Field(primary_key=True)  # 聚合根标识
    name: str = Field(max_length=128)  # 不变条件：名称唯一性
    configuration: str = Field()        # 不变条件：配置有效性

    # 聚合内部实体访问控制
    @property
    def tables(self) -> List[CoreTable]:
        """通过聚合根访问内部实体"""
        return self._tables
```

### 3.2 限界上下文（Bounded Context）

#### 上下文映射
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   System Core   │◄──►│    Chat Core    │◄──►│ DataSource Core │
│   系统核心上下文   │    │   聊天核心上下文  │    │  数据源核心上下文 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         ▲                       ▲                       ▲
         │                       │                       │
         │              ┌─────────────────┐              │
         └──────────────►│   Shared Kernel │◄─────────────┘
                        │    共享内核     │
                        └─────────────────┘
```

#### 上下文关系
- **共享内核（Shared Kernel）**：SnowflakeBase、基础DTO类
- **客户-供应商（Customer-Supplier）**：Chat → DataSource
- **开放主机服务（Open Host Service）**：AI Model → Chat
- **发布者-订阅者（Publisher-Subscriber）**：Data Training → Chat

### 3.3 值对象设计

#### 不变性（Immutability）
```python
@dataclass(frozen=True)
class TableSchema:
    """表结构值对象 - 不可变"""
    tableName: str
    tableComment: str

    def __post_init__(self):
        if not self.tableName:
            raise ValueError("表名不能为空")
```

#### 值语义（Value Semantics）
```python
class AiModelBase(SQLModel):
    """AI模型基础配置 - 值对象"""
    name: str
    model_type: int
    base_model: str
    default_model: bool = False

    def __eq__(self, other):
        if not isinstance(other, AiModelBase):
            return False
        return (self.name == other.name and
                self.model_type == other.model_type)
```

### 3.4 领域服务设计

#### 复杂业务逻辑封装
```python
class LLMService:
    """LLM领域服务 - 处理跨聚合的复杂业务逻辑"""

    def __init__(self,
                 chat_aggregate: ChatRecord,
                 datasource_aggregate: CoreDatasource,
                 ai_model_aggregate: AiModelDetail):
        self.chat = chat_aggregate
        self.datasource = datasource_aggregate
        self.ai_model = ai_model_aggregate

    async def generate_sql_and_execute(self, question: str) -> QueryResult:
        """跨聚合协调：生成SQL并执行"""
        # 1. 获取数据源schema
        schema = await self.datasource.get_schema()

        # 2. 使用AI模型生成SQL
        sql = await self.ai_model.generate_sql(question, schema)

        # 3. 执行SQL并记录结果
        result = await self.datasource.execute_sql(sql)
        self.chat.record_execution(sql, result)

        return result
```

## 4. 划分原因和设计决策

### 4.1 为什么这样划分？

#### 业务驱动设计
1. **用户业务边界**：System子域管理用户、权限、租户等基础能力
2. **数据访问边界**：DataSource子域负责所有数据源相关能力
3. **问答业务边界**：Chat子域专注于自然语言问答流程
4. **知识管理边界**：Terminology和DataTraining管理领域知识
5. **可视化边界**：Dashboard子域专注于数据可视化

#### 技术驱动设计
1. **数据一致性**：每个聚合内部维护强一致性
2. **可扩展性**：子域独立演进，支持水平扩展
3. **团队协作**：不同子域可以并行开发
4. **技术栈选择**：不同子域可以采用不同技术方案

### 4.2 领域边界设计原则

#### 高内聚（High Cohesion）
- 每个聚合内部元素紧密相关，有明确的业务目的
- 聚合之间的依赖关系最小化
- 通用功能抽象到领域服务

#### 低耦合（Low Coupling）
- 聚合之间通过聚合根ID进行引用
- 避免跨聚合的直接对象引用
- 使用领域事件处理跨聚合的协调

#### 单一数据源（Single Source of Truth）
- 每个聚合只负责自己的数据持久化
- 避免数据冗余和同步问题
- 通过聚合根ID建立关联关系

### 4.3 企业级架构考量

#### 多租户支持
```python
class SnowflakeBase(SQLModel):
    """支持多租户的基础实体"""
    id: int = Field(default_factory=snowflake.generate_id)
    # tenant_id通过 oid 字段在每个具体实体中定义
```

#### 权限控制
```python
class CoreDatasource(SQLModel, table=True):
    """数据源实体 - 支持租户级权限隔离"""
    oid: int = Field(sa_column=Column(BigInteger()))  # 租户ID
    # 通过Repository层实现权限过滤
```

#### 审计追踪
```python
class BaseModel(SQLModel):
    """支持审计追踪的基类"""
    create_time: int = Field(sa_column=Column(BigInteger()))
    create_by: int = Field(sa_column=Column(BigInteger()))
    update_time: int = Field(sa_column=Column(BigInteger()))
    update_by: int = Field(sa_column=Column(BigInteger()))
```

## 5. 架构优势

### 5.1 业务优势
- **领域专家友好**：模型结构贴近业务语言
- **业务规则封装**：复杂的业务逻辑集中在领域层
- **业务变更隔离**：单个子域的变更不影响其他子域

### 5.2 技术优势
- **可测试性**：每个聚合和领域服务都可以独立测试
- **可维护性**：代码结构清晰，职责明确
- **可扩展性**：支持水平和垂直方向的扩展

### 5.3 团队协作优势
- **并行开发**：不同团队可以并行开发不同子域
- **技术栈灵活**：不同子域可以选择不同的技术栈
- **知识隔离**：团队成员只需要理解自己负责的子域

这种DDD架构设计使得SQLBot能够作为一个企业级AI数据查询平台，在保持代码质量的同时，支持复杂的业务需求和团队协作。