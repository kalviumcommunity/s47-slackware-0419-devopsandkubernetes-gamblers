# Multi-stage Dockerfile demonstrating production best practices
# Stage 1: Builder stage
# This stage installs dependencies. By separating this into its own stage,
# we can leverage Docker layer caching to avoid reinstalling packages
# when only application code changes.
FROM python:3.11-slim AS builder

# Set working directory inside the container
WORKDIR /app

# Set environment variables to prevent Python from writing pyc files
# and to buffer stdout/stderr for real-time logs in container
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install system dependencies required for Python packages
# Using --no-install-recommends reduces image size by excluding unnecessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy only requirements.txt first
# This layer is cached independently of application code changes.
# If requirements.txt doesn't change, this layer is reused from cache,
# significantly speeding up builds.
COPY requirements.txt .

# Install Python dependencies into a virtual environment
# This isolates project dependencies and keeps the final image clean
RUN python -m pip install --upgrade pip && \
    python -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

# Stage 2: Runtime stage
# This is the final image that will be deployed. By copying only
# necessary artifacts from the builder stage, we minimize image size.
FROM python:3.11-slim

# Set metadata labels for image identification and documentation
LABEL maintainer="DevOps Learning Project" \
      description="Flask application demonstrating Docker best practices" \
      version="1.0.0"

# Set working directory
WORKDIR /app

# Set environment variables for the runtime
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH" \
    APP_ENV=production \
    APP_VERSION=1.0.0 \
    PORT=5000

# Create a non-root user for enhanced security
# Running as root in containers is a security risk.
# This user will run the application with minimal privileges.
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy virtual environment from builder stage
# This includes all compiled dependencies without the build tools,
# keeping the image size significantly smaller than installing in the final stage
COPY --from=builder --chown=appuser:appuser /opt/venv /opt/venv

# Copy application code from builder stage
# By placing this COPY after requirements.txt operations in the builder,
# we ensure application code changes don't invalidate the dependency layer cache
COPY --chown=appuser:appuser app.py .
COPY --chown=appuser:appuser requirements.txt .

# Switch to non-root user for security
# The application now runs with minimal privileges
USER appuser

# Expose port 5000 for the Flask application
# This documents which port the application uses (doesn't actually open the port)
EXPOSE 5000

# Health check instruction for container orchestration platforms
# This helps Docker and Kubernetes determine if the container is running properly
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

# Set the entry point to run the Flask application
# Using exec form (JSON array) ensures signals are properly forwarded
CMD ["python", "app.py"]
