# Stage 1: Build
FROM gradle:8.12-jdk21 AS builder
WORKDIR /build

COPY gradle/ gradle/
COPY gradlew gradlew.bat settings.gradle.kts ./
COPY app/build.gradle.kts app/
RUN gradle :app:dependencies --no-daemon --quiet || true

COPY app/src app/src
RUN gradle :app:bootJar --no-daemon -x test

# Stage 2: Run
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

RUN addgroup -S dealer && adduser -S dealer -G dealer
USER dealer

COPY --from=builder /build/app/build/libs/app-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
