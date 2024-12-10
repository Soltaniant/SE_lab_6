FROM openjdk:17-jdk-slim
WORKDIR /usr/app
COPY target/demo-0.0.1-SNAPSHOT.jar department-service.jar
ENTRYPOINT ["java", "-jar", "department-service.jar"]
