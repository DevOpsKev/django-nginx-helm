# Dockerfile
FROM python:3.6.7-alpine3.7

RUN mkdir -p /code

WORKDIR /code

# Annotate Port
EXPOSE 8000

RUN apk add --no-cache --upgrade bash
# System Deps
RUN apk update && \
    apk add --no-cache \
        gcc \
        musl-dev \
        libc-dev \
        linux-headers \
        postgresql-dev \
        curl
# Python Application Deps
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Application Setup
COPY webapp/ ./webapp/

WORKDIR /code/webapp