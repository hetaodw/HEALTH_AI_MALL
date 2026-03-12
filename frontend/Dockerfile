# syntax=docker/dockerfile:1
FROM node:18-alpine AS builder

ARG HTTP_PROXY
ARG HTTPS_PROXY

ENV HTTP_PROXY=${HTTP_PROXY}
ENV HTTPS_PROXY=${HTTPS_PROXY}
ENV http_proxy=${HTTP_PROXY}
ENV https_proxy=${HTTPS_PROXY}

WORKDIR /app

COPY frontend/package*.json ./

RUN npm config set registry https://registry.npmjs.org/ && \
    npm install --no-audit --progress=false

COPY frontend/ ./

COPY tools ./tools

RUN npm run build

FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html

COPY frontend/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
