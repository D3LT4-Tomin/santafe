FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Install dependencies first to maximize Docker layer caching.
COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get

# Copy the rest of the project and build web assets.
COPY . .
RUN flutter config --enable-web && flutter build web --release

FROM nginx:1.27-alpine AS runtime

COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
