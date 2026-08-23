# Build AOT del server e immagine finale minima (pattern ufficiale Dart).
FROM dart:stable AS build

WORKDIR /app
COPY pubspec.* ./
RUN dart pub get
COPY . .
RUN dart pub get --offline
RUN dart compile exe bin/server.dart -o bin/server

# Immagine finale: solo il runtime Dart + l'eseguibile compilato.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/server

ENV ITINERA_DATA_DIR=/data
EXPOSE 8080
CMD ["/app/bin/server"]
