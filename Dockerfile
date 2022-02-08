FROM adoptopenjdk/openjdk11:alpine-jre
#FROM openjdk:8-jdk-alpine

MAINTAINER muhammed eren demir mhmmderen3@gmail.com

ADD target/SpringBootWeatherApi-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java","-jar","app.jar"]
