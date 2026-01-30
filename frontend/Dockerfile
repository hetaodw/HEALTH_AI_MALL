# syntax=docker/dockerfile:1
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./

# 强制清除环境变量和 npm 配置
RUN unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy && \
    npm config set registry https://registry.npmjs.org/ && \
    npm install --no-audit --progress=false

COPY . .

RUN npm run build

FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
