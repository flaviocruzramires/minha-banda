FROM dart:3.8-sdk AS runner
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN dart pub get --no-example
COPY . .
EXPOSE 8080
CMD ["dart", "run", "bin/server.dart"]
