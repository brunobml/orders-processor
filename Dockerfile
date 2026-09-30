FROM python:3.11-alpine

ARG APP_VERSION=v1.1.0
ARG BUILD_COMMIT=local
ARG BUILD_TIME=unknown

ENV APP_VERSION=${APP_VERSION} \
    BUILD_COMMIT=${BUILD_COMMIT} \
    BUILD_TIME=${BUILD_TIME}

WORKDIR /app

# Copy source code
COPY src/ /app/src/

EXPOSE 8080

CMD ["python3", "-u", "src/main.py"]
