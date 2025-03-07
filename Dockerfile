FROM openjdk:17-jdk-slim AS BUILD_IMAGE
RUN apt update -y
RUN apt install git -y
RUN apt install maven -y
RUN git clone https://github.com/Azharpasha1996/DevOps.git
RUN cd DevOps && mvn install

FROM tomcat:jre17

RUN rm -rf /usr/local/tomcat/webapps/*

COPY --from=BUILD_IMAGE DevOps/target/DevOps-0.0.1-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
