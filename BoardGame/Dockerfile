################################
# Stage 1: Build the application
################################
FROM maven:3.9.6-eclipse-temurin-11 AS build

WORKDIR /usr/src/app

COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests

################################
# Stage 2: Go Online
################################
FROM adoptopenjdk/openjdk11

EXPOSE 8080

ENV APP_HOME /usr/src/app

WORKDIR $APP_HOME

COPY --from=build /usr/src/app/target/*.jar $APP_HOME/app.jar

CMD ["java", "-jar", "app.jar"]
