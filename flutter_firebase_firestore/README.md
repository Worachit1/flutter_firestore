# flutter_firebase_firestore

A new Flutter project.

dependencies:
flutter:
sdk: flutter
firebase_core: ^last_version

ให้กด flutter pub outdated จะได้
dependencies:
flutter:
sdk: flutter
firebase_core: ^2.24.2
cloud_firestore: ^4.14.0 # Firestore package

^2.24.2 ไปเปลี่ยนแทน

to add firebase to project

```
 flutter pub add cloud_firestore
 flutter pub add firebase_core
```

## Connect to Firebase project

```
dart pub global activate flutterfire_cli
flutterfire configure --project=[FIREBASE_PROJECT_CONSOLE_NAME]
```
