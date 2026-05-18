# E-Commerce Mobile App

A modern cross-platform eCommerce application built with Flutter and Firebase, providing a seamless shopping experience across Android and iOS devices.

## Features

### Authentication
- Email & Password Authentication
- User Registration
- Password Recovery
- Persistent Login Sessions

### Product Management
- Browse Product Catalog
- Product Search
- Product Categories
- Product Details
- Product Images

### Shopping Cart
- Add to Cart
- Update Quantity
- Remove Items
- Cart Summary

### User Profile
- User Information Management
- Order History
- Address Management

### Firebase Integration
- Firebase Authentication
- Cloud Firestore Database
- Firebase Storage
- Cloud Functions

## Tech Stack

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Functions
- Provider / Riverpod (depending on implementation)

## Project Structure

```
lib/
├── models/
├── screens/
├── widgets/
├── services/
├── providers/
├── utils/
└── main.dart

android/
ios/
web/
functions/
```

## Prerequisites

Before running the project, ensure you have installed:

- Flutter SDK (3.x or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase CLI
- Android SDK
- Xcode (for iOS development)

## Installation

### Clone Repository

```bash
git clone https://github.com/your-username/ecommerce-app.git
cd ecommerce-app
```

### Install Dependencies

```bash
flutter pub get
```

### Firebase Configuration

Configure Firebase for your project:

```bash
flutterfire configure
```

### Run Application

#### Android

```bash
flutter run
```

#### iOS

```bash
flutter run -d ios
```

#### Web

```bash
flutter run -d chrome
```

## Build

### Android APK

```bash
flutter build apk --release
```

### Android App Bundle

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web
```

## Environment Setup

Create Firebase project and update configuration files:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

## Firebase Services Used

- Authentication
- Firestore Database
- Storage
- Cloud Functions

## Deployment

### Firebase Hosting

```bash
flutter build web
firebase deploy
```

## Screens

- Login
- Register
- Home
- Product List
- Product Detail
- Shopping Cart
- Profile
- Order History

## License

This project is for educational and demonstration purposes.

## Author

Developed using Flutter and Firebase.