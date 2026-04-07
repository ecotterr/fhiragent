# syntax=docker/dockerfile:1

FROM python:3.11-slim-bookworm

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

# Pin interpreter for `uv sync` (same major as `.python-version`).
ENV UV_PYTHON=/usr/local/bin/python3 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    PYTHONUNBUFFERED=1

# Uncomment if your config uses MCP servers that spawn `npx` (see .ai-agent/config.toml).
# RUN apt-get update && apt-get install -y --no-install-recommends nodejs npm \
#     && rm -rf /var/lib/apt/lists/*

COPY pyproject.toml uv.lock ./

RUN uv sync --frozen --no-cache

COPY . .

# Use the synced venv directly so startup does not re-run `uv` (matches `uv run main.py` environment).
ENTRYPOINT ["/app/.venv/bin/python", "main.py"]
