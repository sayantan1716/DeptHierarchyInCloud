FROM openjdk-8-jdk:latest

COPY *-application/target/*.jar application.jar

ENV JAVA_OPTS=""
CMD [ "sh", "-c", "java $JAVA_OPTS -XX:+UseParallelGC -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=20 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -jar /home/app.jar" ]
USER 1001
EXPOSE 8081
