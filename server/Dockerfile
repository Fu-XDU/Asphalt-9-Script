FROM maven:3.8.3-openjdk-11 AS MAVEN_BUILD
COPY settings.xml /usr/share/maven/conf/settings.xml
COPY pom.xml /build/
COPY src /build/src/
WORKDIR /build/
RUN mvn package

FROM maslick/minimalka:jdk11
COPY --from=MAVEN_BUILD /build/target/a9script-0.0.1-SNAPSHOT.jar /app/
RUN mkdir -p "/app/A9log"
# 支持中文
ENV LANG C.UTF-8
# 修改时区
ENV TZ Asia/Shanghai
EXPOSE 8081
ENTRYPOINT ["java","-jar","/app/a9script-0.0.1-SNAPSHOT.jar"]
