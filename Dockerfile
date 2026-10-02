# Base image pinned by digest (Phase 4 B.1); bump deliberately when Trivy reports fixes.
FROM python:3.11-alpine@sha256:9a725b14f2ae4e1b92ae4c7a8f575c7bf0f451276b5d38c9ec20bb005d0063a8

ARG APP_VERSION=v1.2.0
ARG BUILD_COMMIT=local
ARG BUILD_TIME=unknown

ENV APP_VERSION=${APP_VERSION} \
    BUILD_COMMIT=${BUILD_COMMIT} \
    BUILD_TIME=${BUILD_TIME}

# Create non-root user & group (UID/GID 10001)
RUN addgroup -g 10001 appgroup && \
    adduser -u 10001 -G appgroup -s /sbin/nologin -D appuser

WORKDIR /app

# Copy source code and assign ownership
COPY --chown=appuser:appgroup src/ /app/src/

USER appuser

EXPOSE 8080

CMD ["python3", "-u", "src/main.py"]
