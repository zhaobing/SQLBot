# SQLBot 项目指南

## 项目概述

SQLBot 是一款基于大模型和 RAG（检索增强生成）技术的智能问数系统。该项目采用前后端分离架构，后端使用 Python FastAPI 框架，前端使用 Vue 3 + TypeScript，支持与多种数据源连接，通过自然语言查询生成 SQL 并进行数据分析和可视化。

### 核心功能
- **智能问数**: 通过大模型和 RAG 技术实现高质量的文本到 SQL 转换
- **多数据源支持**: 支持多种数据库作为数据源
- **嵌入式集成**: 可快速嵌入到第三方业务系统
- **工作空间隔离**: 基于工作空间的资源隔离机制
- **细粒度权限控制**: 提供数据权限控制
- **图表可视化**: 查询结果支持多种图表展示
- **AI 助手集成**: 支持 AI 助手功能

### 技术栈
- **后端**: Python 3.11, FastAPI, SQLModel, PostgreSQL, Alembic
- **前端**: Vue 3, TypeScript, Element Plus, Vite
- **数据库**: PostgreSQL (主要), 支持 MySQL, Oracle, SQL Server 等数据源
- **AI/ML**: LangChain, PyTorch, sentence-transformers, 向量嵌入
- **部署**: Docker, Docker Compose

## 项目结构

```
SQLBot/
├── backend/              # 后端代码 (Python/FastAPI)
│   ├── alembic/          # 数据库迁移脚本
│   ├── apps/             # 主要业务模块
│   │   ├── ai_model/     # AI 模型管理
│   │   ├── chat/         # 聊天和问答功能
│   │   ├── dashboard/    # 仪表板功能
│   │   ├── datasource/   # 数据源管理
│   │   ├── system/       # 系统管理 (用户、工作空间等)
│   │   └── ...
│   ├── common/           # 通用工具和核心功能
│   ├── main.py           # 应用入口点
│   └── pyproject.toml    # Python 依赖管理
├── frontend/             # 前端代码 (Vue 3/TypeScript)
│   ├── src/
│   │   ├── components/   # Vue 组件
│   │   ├── views/        # 页面视图
│   │   ├── api/          # API 调用
│   │   ├── router/       # 路由配置
│   │   └── stores/       # Pinia 状态管理
│   ├── package.json      # 前端依赖管理
│   └── vite.config.ts    # Vite 构建配置
├── g2-ssr/               # 图表服务端渲染
├── docker-compose.yaml   # Docker Compose 部署配置
├── Dockerfile            # Docker 构建文件
└── start.sh              # 应用启动脚本
```

## 构建和运行

### 开发环境运行

#### 后端 (开发模式)
```bash
cd backend
# 创建虚拟环境
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
# .venv\Scripts\activate  # Windows

# 安装依赖
pip install -e .

# 运行应用
python main.py
# 或使用 uvicorn
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

#### 前端 (开发模式)
```bash
cd frontend
npm install
npm run dev
```

### 生产环境部署

#### Docker 部署 (推荐)
```bash
# 使用预构建镜像
docker run -d \
  --name sqlbot \
  --restart unless-stopped \
  -p 8000:8000 \
  -p 8001:8001 \
  -v ./data/sqlbot/excel:/opt/sqlbot/data/excel \
  -v ./data/sqlbot/file:/opt/sqlbot/data/file \
  -v ./data/sqlbot/images:/opt/sqlbot/images \
  -v ./data/sqlbot/logs:/opt/sqlbot/app/logs \
  -v ./data/postgresql:/var/lib/postgresql/data \
  --privileged=true \
  dataease/sqlbot

# 或使用 docker-compose
docker-compose up -d
```

#### 构建 Docker 镜像
```bash
docker build -t sqlbot .
```

## 核心模块分析

### 1. AI 模型管理 (apps/ai_model/)
- 支持多种 AI 模型 (OpenAI, 自定义等)
- 模型配置和管理 API
- 嵌入模型用于语义搜索

### 2. 聊天问答系统 (apps/chat/)
- 自然语言到 SQL 的转换
- 支持流式响应
- 历史记录管理
- 图表和数据可视化
- 推荐问题生成

### 3. 数据源管理 (apps/datasource/)
- 支持多种数据库连接
- 数据表关系配置
- 连接验证和管理

### 4. 用户和权限系统 (apps/system/)
- 用户管理
- 工作空间管理
- AI 模型配置
- 嵌入式应用管理
- 助手功能

### 5. 术语和训练数据 (apps/terminology/, apps/data_training/)
- 专业术语定义
- 数据训练功能
- RAG 增强

### 6. 仪表板 (apps/dashboard/)
- 可视化图表展示
- 仪表板编辑和预览

## 配置管理

### 环境变量 (backend/common/core/config.py)
```python
# 数据库配置
POSTGRES_SERVER: str = 'localhost'
POSTGRES_PORT: int = 5432
POSTGRES_USER: str = 'root'
POSTGRES_PASSWORD: str
POSTGRES_DB: str = "sqlbot"

# 应用配置
PROJECT_NAME: str = "SQLBot"
API_V1_STR: str = "/api/v1"
SECRET_KEY: str  # 用于 JWT
ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 8  # 8天

# AI/ML 配置
LOCAL_MODEL_PATH: str = '/opt/sqlbot/models'
DEFAULT_EMBEDDING_MODEL: str = 'shibing624/text2vec-base-chinese'
EMBEDDING_ENABLED: bool = True
EMBEDDING_DEFAULT_SIMILARITY: float = 0.4
```

### CORS 设置
- 默认允许的来源: `http://localhost,http://localhost:5173,https://localhost,https://localhost:5173`
- 可通过 `BACKEND_CORS_ORIGINS` 环境变量配置

## API 路由结构

API 路由在 `backend/apps/api.py` 中定义，包含以下主要模块:

- `/api/v1/login` - 用户登录
- `/api/v1/user` - 用户管理
- `/api/v1/workspace` - 工作空间管理
- `/api/v1/assistant` - AI 助手功能
- `/api/v1/aimodel` - AI 模型管理
- `/api/v1/terminology` - 专业术语管理
- `/api/v1/data_training` - 数据训练
- `/api/v1/datasource` - 数据源管理
- `/api/v1/chat` - 聊天问答功能
- `/api/v1/dashboard` - 仪表板功能
- `/api/v1/mcp` - MCP (Model Context Protocol) 服务

## 数据库设计

项目使用 SQLModel (SQLAlchemy + Pydantic) 进行数据库操作，支持 PostgreSQL 并通过 Alembic 进行数据库迁移。主要数据表包括:

- 用户和权限相关表
- AI 模型配置表
- 数据源配置表
- 聊天记录表
- 仪表板配置表
- 术语和训练数据表

## 开发约定

### 后端开发
- 使用 FastAPI 的依赖注入系统
- 使用 SQLModel 进行数据库建模
- 遵循 RESTful API 设计原则
- 使用 Pydantic 进行数据验证
- 实现异步操作以提高性能

### 前端开发
- 使用 Vue 3 Composition API
- 使用 TypeScript 进行类型检查
- 使用 Element Plus 组件库
- 使用 Pinia 进行状态管理
- 使用 Vue Router 进行路由管理

### 代码规范
- 后端: 使用 Ruff 进行代码格式化和检查
- 前端: 使用 ESLint 和 Prettier
- 提交前运行预提交钩子检查

## 扩展和定制

SQLBot 支持通过 `sqlbot-xpack` 进行扩展功能开发，允许在不修改核心代码的情况下添加额外功能。

## 部署注意事项

1. **数据持久化**: 确保 PostgreSQL 数据、Excel 文件、日志等数据目录正确挂载
2. **环境变量**: 正确配置数据库连接、安全密钥等环境变量
3. **资源需求**: AI 模型需要大量内存和计算资源
4. **网络配置**: 如果使用外部 AI 服务，确保网络连通性
5. **安全考虑**: 生产环境中应使用安全的密码和密钥，配置适当的 CORS 策略

## 许可证

SQLBot 遵循 FIT2CLOUD Open Source License (基于 GPLv3)。二次开发需保持开源并保留版权信息。