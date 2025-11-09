# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SQLBot is an intelligent data query system built on LLM and RAG technologies that enables users to query databases using natural language. It's a full-stack application with Vue 3 frontend and FastAPI backend.

## Architecture

- **Frontend**: Vue 3 + TypeScript + Element Plus (location: `/frontend/`)
- **Backend**: Python FastAPI + SQLModel + PostgreSQL (location: `/backend/`)
- **AI Integration**: LangChain + multiple LLM providers (OpenAI, Azure, VLLM, Tongyi)
- **Database**: PostgreSQL with pgvector for vector operations
- **Deployment**: Docker-based containerized deployment

## Development Commands

### Backend Development
```bash
cd backend
# Install dependencies (Python 3.11 required)
pip install -e .

# Start development server
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Code formatting and linting
./scripts/format.sh  # or: ruff format .
./scripts/lint.sh    # or: ruff check .
./scripts/test.sh    # or: pytest

# Database migrations
alembic upgrade head                    # Apply migrations
alembic revision --autogenerate -m "description"  # Create new migration
```

### Frontend Development
```bash
cd frontend
npm install
npm run dev        # Start dev server on port 5173
npm run build      # Production build
npm run lint       # ESLint checking
```

### Production Deployment
```bash
# Using pre-built image
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

# Custom build
docker build -t sqlbot .
```

## Key Backend Modules

- `apps/ai_model/`: LLM integration and model management
- `apps/chat/`: Core chat functionality and SQL generation
- `apps/datasource/`: Multi-database connection management
- `apps/system/`: User, workspace, and authentication
- `apps/dashboard/`: Visualization and dashboard features
- `apps/terminology/`: Domain-specific terminology
- `apps/data_training/`: Training data management
- `common/`: Shared utilities and core functionality

## Database Configuration

- **Primary DB**: PostgreSQL with vector extensions
- **Migrations**: Alembic (47 migration files in `/backend/alembic/`)
- **ORM**: SQLModel (SQLAlchemy + Pydantic)
- **Supported Sources**: MySQL, Oracle, SQL Server, PostgreSQL, ClickHouse, Redshift, Elasticsearch, Excel/CSV

## API Structure

RESTful API with prefix `/api/v1`:
- Authentication: `/login`, `/user`
- Workspace: `/workspace`, `/assistant`
- AI Models: `/aimodel`, `/terminology`
- Data Sources: `/datasource`
- Features: `/chat`, `/dashboard`
- MCP Service: `/mcp` (Model Context Protocol)

## Development Tools

- **Backend**: Ruff (linting/formatting), MyPy (type checking), pytest (testing)
- **Frontend**: ESLint, Prettier, TypeScript, Vite
- **Quality**: Pre-commit hooks available in dev dependencies

## Environment Setup

- Python 3.11 required (specified in pyproject.toml)
- Node.js for frontend development
- PostgreSQL for database
- Docker for deployment (recommended)

## Configuration Files

- `backend/pyproject.toml`: Python dependencies and tooling
- `frontend/package.json`: Node.js dependencies and scripts
- `backend/alembic.ini`: Database migration config
- `common/core/config.py`: Environment variables and settings

## Security Features

- JWT authentication with configurable expiration
- Workspace-based resource isolation
- Fine-grained data permissions (row/column level)
- Encrypted API keys and credentials
- CORS middleware configured