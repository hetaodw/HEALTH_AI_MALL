FROM maven:3.9-eclipse-temurin-17 AS builder

# 取消 Docker Desktop 全局代理设置
ENV HTTP_PROXY=""
ENV HTTPS_PROXY=""
ENV http_proxy=""
ENV https_proxy=""

WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests --batch-mode

FROM eclipse-temurin:17-jre

WORKDIR /app

COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-Dspring.profiles.active=docker", "-jar", "app.jar"]
