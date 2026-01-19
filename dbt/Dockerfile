FROM python:3.11-slim

# Prevent Python from writing .pyc files and enable unbuffered output
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DBT_PROFILES_DIR=/root/.dbt

# Install system dependencies commonly required by dbt adapters
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install dbt and the Snowflake adapter (extend here for other adapters)
RUN pip install --upgrade pip && \
    pip install "dbt-core" "dbt-snowflake"

# Create application directory
WORKDIR /app

# Copy dbt project files into the image
COPY reviews_pipeline_orchestration/ ./reviews_pipeline_orchestration

# Copy dbt profiles
COPY profiles.yml /root/.dbt/profiles.yml

# Ensure profiles directory exists
RUN mkdir -p /root/.dbt && chmod 600 /root/.dbt/profiles.yml

# Default command drops into a shell; override with `dbt run`, etc.
CMD ["/bin/bash"]
