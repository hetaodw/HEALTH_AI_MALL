FROM maven:3.9-eclipse-temurin-17 AS builder

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG http_proxy
ARG https_proxy

ENV HTTP_PROXY=${HTTP_PROXY}
ENV HTTPS_PROXY=${HTTPS_PROXY}
ENV http_proxy=${http_proxy}
ENV https_proxy=${https_proxy}

WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mkdir -p /root/.m2 && \
    echo '<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">\n\
<proxies>\n\
<proxy>\n\
<id>http-proxy</id>\n\
<active>true</active>\n\
<protocol>http</protocol>\n\
<host>host.docker.internal</host>\n\
<port>7897</port>\n\
</proxy>\n\
<proxy>\n\
<id>https-proxy</id>\n\
<active>true</active>\n\
<protocol>https</protocol>\n\
<host>host.docker.internal</host>\n\
<port>7897</port>\n\
</proxy>\n\
</proxies>\n\
</settings>' > /root/.m2/settings.xml && \
    mvn clean package -DskipTests

FROM eclipse-temurin:17-jre

WORKDIR /app

COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
