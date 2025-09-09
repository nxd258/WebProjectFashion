# Jenkins đã build JAR -> chỉ cần JRE để chạy
FROM eclipse-temurin:17-jre
WORKDIR /app

# copy JAR đã build (đừng đổi vị trí build mặc định của Maven)
ARG JAR=target/male-fashion-*.jar
COPY ${JAR} app.jar

EXPOSE 8080
# Bật profile prod nếu bạn có
# ENV SPRING_PROFILES_ACTIVE=prod
ENTRYPOINT ["java","-jar","/app/app.jar"]
