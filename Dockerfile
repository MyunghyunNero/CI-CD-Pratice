# Build stage
FROM openjdk:11 AS builder
WORKDIR /gradle
COPY gradlew build.gradle settings.gradle ./
COPY gradle/ gradle/
# 의존성 패키지만 빌드해서 캐싱 적용
RUN ./gradlew build || return 0

#모든 파일 도커로 옮김
COPY . .

# gradlew build 실행해서 모든 파일 빌드 -> 여기서 의존성 패키지는 캐싱되므로 바뀐 부분만 빌드
RUN ["./gradlew", "clean", "build", "--no-daemon"]


# Run stage
FROM openjdk:11
EXPOSE 8080
WORKDIR /app
COPY --from=builder /gradle/build/libs/*.jar ./app.jar   #gradle밑에 있는 실행파일 롬ㄱ미

# 이미지 실행하면 기본으로 실행되는 명령어
CMD ["java", "-jar", "app.jar"]