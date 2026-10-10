# TroopTrak

A Flutter and Firebase app for running a unit day to day. One app, two roles, chosen on first launch:

- **Commander:** signs in with email and password. Dashboard of unit strength and a calendar of conducts and duties; nominal roll with search, book in/out and soldier profiles (statuses, attendance); adding soldiers manually or by scanning a soldier's QR code; conduct tracker with automatic exclusions by status; guard duty roster with weekday points and a leaderboard.
- **Soldier:** signs in by phone OTP and fills in a profile once. Own profile with statuses and attendance, a QR code for the commander to scan, a conduct tracker that marks the conducts they are on, and the guard duty leaderboard and upcoming duties.

Light and dark themes; data lives in Cloud Firestore.

## Quick start

Needs Flutter 3.47+, JDK 17, Node.js and the Firebase CLI, and an Android emulator. Details in the developer guide.

```sh
flutter pub get
firebase emulators:start --only auth,firestore     # in one terminal
flutter run --dart-define=USE_EMULATOR=true        # in another, with the Android emulator running
```

Checks:

```sh
flutter analyze
flutter test
```

## Project layout

`lib/core/` holds shared code (theme, DI, routing, errors, widgets); `lib/features/<name>/` holds one feature each, split into `domain/`, `data/` and `presentation/`. Tests mirror `lib/` under `test/`; end-to-end flows are in `integration_test/`; Firestore rules are in `firestore.rules` with tests in `firestore_rules_test/`.

## Docs

- [Architecture](docs/ARCHITECTURE.md): layers and the rules that enforce them, features, DI, routing, state, errors, Firestore data model, business rules, security rules.
- [Developer guide](docs/DEVELOPER_GUIDE.md): setup, running against the emulators, every test command, adding a feature, conventions.
