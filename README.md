# ISB26603-Project_Kururin_Exhibition

A Flutter application for managing exhibition booth reservations, user and admin profiles, and event bookings.

## Features

- User registration and login
- Admin registration and login
- Exhibition booth listing and booking
- User profile management and update
- Admin dashboard for managing users and bookings
- Modular navigation for both user and admin roles
- SQLite database integration for persistent storage

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Android Studio or VS Code
- Android device or emulator

### Installation

1. Clone this repository:
    ```sh
    git clone <repo-url>
    cd ISB26603-Project_Kururin_Exhibition
    ```

2. Get dependencies:
    ```sh
    flutter pub get
    ```

3. Run the app:
    ```sh
    flutter run
    ```

## Project Structure

```
lib/
  models/           # Data models (User, Admin, Booth, Booking)
  pages/
    admin/          # Admin pages (dashboard, profile, booking, navigation)
    user/           # User pages (home, booking, profile, navigation)
    demo.dart       # Demo and test pages
    login.dart      # Login and registration
  databaseServices/ # SQLite database helper
  widgets/          # Reusable UI components
assets/
  images/           # Booth images and other assets
```

## Notes

- The app uses SQLite for local data storage.
- Navigation is modular and consistent for both user and admin roles.
- Make sure your Android `minSdkVersion` is at least 23 in `android/app/build.gradle.kts`.
- For Firebase features, ensure you have the correct configuration files.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

