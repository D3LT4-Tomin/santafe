# Santafe

Santafe is the repo for Tomin, our Flutter finance app built for the Talentland Genius Arena challenge. It uses Firebase for authentication and data storage and it integrates with Tomy for chat-based financial guidance.

## Features

- Firebase authentication
- Firestore-backed user accounts, transactions, and learning progress
- Real-time data sync through Firestore listeners
- Tomy AI chat integration
- Responsive Flutter UI for mobile, desktop, and web

## Run Locally

### Prerequisites

- Flutter SDK installed
- A configured Firebase project
- A connected device or Chrome for web

### Flutter

```bash
flutter pub get
flutter run
```

If Flutter asks for a target device, choose the one you want to run on.

## Configuration

The app expects Firebase to be configured through `lib/firebase_options.dart`. It also depends on the Tomy service being available at runtime.

## Run with Docker

The project can also be built in web release mode and served with Nginx.

### Docker Compose

```bash
docker compose up --build
```

Open: http://localhost:8080

### Docker CLI

```bash
docker build -t santafe-app .
docker run --rm -p 8080:80 santafe-app
```

Open: http://localhost:8080

## Notes

- Docker runs the web build only; it does not launch Android or iOS emulators.
- The app needs internet access for Firebase and Tomy.
- Some UI state is kept locally in memory or via client-side persistence where implemented.
