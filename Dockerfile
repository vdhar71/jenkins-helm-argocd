FROM openjdk:22

ENV APP_HOME=/usr/app/
WORKDIR $APP_HOME
COPY . .

EXPOSE 8080

ENTRYPOINT ["java","-jar","build/libs/spring-petclinic-3.1.0.jar"]
