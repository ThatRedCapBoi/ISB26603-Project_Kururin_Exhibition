# ISB26603-Project_Kururin_Exhibition

A Flutter application for managing exhibition booth reservations, user and admin profiles, and event bookings.

## Features

- User registration and login (with Firebase Authentication)
- Admin registration and login
- Exhibition booth listing and booking (data from Firebase Firestore)
- User profile management and update (Firestore integration)
- Admin dashboard for managing users, booths, and bookings
- Modular navigation for both user and admin roles
- SQLite database integration for local persistent storage (demo/offline)
- Firebase integration for real-time data and cloud sync
- Responsive UI for mobile devices

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Android Studio or VS Code
- Android device or emulator
- Firebase project (for cloud features)

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

3. Configure Firebase:
    - Download your `google-services.json` (Android) and/or `GoogleService-Info.plist` (iOS) from the Firebase Console.
    - Place them in the appropriate platform folders.
    - (Optional) Run `flutterfire configure` to generate `firebase_options.dart`.

4. Run the app:
    ```sh
    flutter run
    ```

## Project Structure

```
lib/
  models/             # Data models (User, Admin, Booth, Booking)
  pages/
    admin/            # Admin pages (dashboard, profile, booking, navigation)
    user/             # User pages (home, booking, profile, navigation)
    demo.dart         # Demo and test pages
    login.dart        # Login and registration
  databaseServices/   # SQLite and Firestore database helpers
  widgets/            # Reusable UI components
  firebase_options.dart # Firebase config (should be gitignored)
assets/
  images/             # Booth images and other assets
```

## Notes

- The app uses **Firebase Firestore** for cloud data and **SQLite** for local storage.
- Navigation is modular and consistent for both user and admin roles.
- Make sure your Android `minSdkVersion` is at least 23 in `android/app/build.gradle`.
- For Firebase features, ensure you have the correct configuration files and Firestore collections:
  - `users`
  - `administrators`
  - `boothPackages`
  - `bookings`
- **Security:** Do not commit your `firebase_options.dart` or any secret keys to public repositories. Add `lib/firebase_options.dart` to your `.gitignore`.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

