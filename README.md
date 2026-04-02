# santafe

Aplicacion Hackaton 2026

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

##  Docker

builds app in web mode (release) and serves it with Nginx.

### Option 1: Docker Compose

```bash
docker compose up --build
```

then open: http://localhost:8080

### Option 2: Docker CLI

```bash
docker build -t santafe-app .
docker run --rm -p 8080:80 santafe-app
```

then open: http://localhost:8080

## Note 

Docker does not run mobile targets  (Android/iOS) as emulator. 
