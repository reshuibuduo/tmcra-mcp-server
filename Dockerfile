FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY pyproject.toml README.md LICENSE NOTICE ./
COPY src ./src

RUN python -m pip install --no-cache-dir .

# Directory inspectors need to initialize the stdio server and enumerate tools.
# This public placeholder is never used for a production API request.
ENV TMCRA_API_KEY=directory-inspection-placeholder \
    TMCRA_DEFAULT_SCOPE=directory-inspection

ENTRYPOINT ["tmcra-mcp"]
