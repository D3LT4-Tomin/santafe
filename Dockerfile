FROM ghcr.io/cirruslabs/flutter:stable AS base

WORKDIR /app

# Install dependencies first to maximize Docker layer caching.
COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get

# Copy the rest of the project.
COPY . .

FROM base AS build-web

# Build web assets.
RUN flutter config --enable-web && flutter build web --release --pwa-strategy=none

FROM base AS build-linux

# Native deps required by Flutter Linux desktop builds.
RUN apt-get update && apt-get install -y --no-install-recommends \
	clang \
	cmake \
	ninja-build \
	pkg-config \
	libgtk-3-dev \
	liblzma-dev \
	&& rm -rf /var/lib/apt/lists/*

RUN flutter config --enable-linux-desktop && flutter build linux --release

FROM nginx:1.27-alpine AS runtime

COPY --from=build-web /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
