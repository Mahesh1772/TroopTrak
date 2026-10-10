# TroopTrak Developer Guide

How to set up, run and test the app, and how to add to it. Read [ARCHITECTURE.md](ARCHITECTURE.md) first for the layers and rules.

Every command below runs from `trooptrak_final_application/`.

## Prerequisites

| Tool | Version | Used for |
|---|---|---|
| Flutter SDK | 3.47 or newer (Dart 3.13 or newer; see `pubspec.lock`) | building, `flutter test`, `flutter analyze` |
| Java (JDK) | 17 | Android build (Gradle 8.14, AGP 8.11, Kotlin 2.2) and the Firebase emulators |
| Node.js + npm | 18 or newer | Firebase CLI and the rules tests |
| Firebase CLI | `npm install -g firebase-tools` (built with 13.x) | Auth and Firestore emulators. Newer CLI releases may need a newer JDK for the emulators |
| Android SDK + AVD | an Android emulator image | running the app and the integration tests |

The Firebase project is `trooptrak-54337` (`.firebaserc`, `lib/firebase_options.dart`, `android/app/google-services.json`). Use the emulators for development so real data is never touched.

## Setup

```sh
flutter pub get
npm ci --prefix firestore_rules_test   # once, for the rules tests
```

## Running against the emulators

1. Start the Auth and Firestore emulators (ports from `firebase.json`: Auth 9099, Firestore 8080, Emulator UI 4000):

   ```sh
   firebase emulators:start --only auth,firestore
   ```

   They load `firestore.rules`, so the app runs under the same rules as production.

2. Start an Android emulator, then run the app pointed at the emulators:

   ```sh
   flutter run --dart-define=USE_EMULATOR=true
   ```

How it connects (`lib/core/di/firebase_bootstrap.dart`):

- `USE_EMULATOR=true` makes `initFirebase()` call `useFirestoreEmulator` and `useAuthEmulator`. Without it the app talks to the live project.
- The host is `10.0.2.2` on Android (the emulator's alias for the host machine) and `localhost` elsewhere. Override it with `--dart-define=EMULATOR_HOST=<ip>`, for example for a physical device on the same network.
- Android blocks cleartext HTTP by default. Debug builds allow it only for `10.0.2.2`, `localhost` and `127.0.0.1` through `android/app/src/debug/res/xml/network_security_config.xml`, referenced from `android/app/src/debug/AndroidManifest.xml`. Release builds are unaffected.

**Phone sign-in on the emulator:** the Auth emulator never sends an SMS. Enter any number, then read the code from the emulator log or fetch it over REST:

```sh
curl http://localhost:9099/emulator/v1/projects/trooptrak-54337/verificationCodes
```

## Tests

| What | Command |
|---|---|
| Static analysis | `flutter analyze` |
| Unit, widget and architecture tests | `flutter test` |
| Coverage per layer | `flutter test --coverage`, then `dart run tool/coverage_by_layer.dart` |
| Firestore rules | `firebase emulators:exec --only firestore "npm --prefix firestore_rules_test test"` |
| Integration (Android emulator) | `firebase emulators:exec --only auth,firestore "flutter test integration_test -d emulator-5554 --dart-define=USE_EMULATOR=true"` |

### Unit and widget tests

`flutter test` runs everything under `test/`, which mirrors `lib/`:

- **Domain:** entities, rule services and use cases, with `mocktail` repositories and `FixedClock` (`test/helpers/fake_clock.dart`).
- **Data:** models and repositories against `fake_cloud_firestore` and `firebase_auth_mocks`, using the exact Firestore field names. `test/helpers/firestore_seed.dart` and `test/helpers/builders.dart` build documents and entities.
- **Presentation:** providers with mocked use cases; pages and widgets through `tester.pumpApp` / `pumpThemed` (`test/helpers/pump_app.dart`), which sets the 450x1000 design size, the theme and the providers. Pages are pumped in both light and dark themes (`themeModes`).
- **Architecture:** `test/architecture_test.dart` fails the run if a layering or build-once rule is broken (see ARCHITECTURE.md).

`test/flutter_test_config.dart` turns off runtime font fetching; fonts are bundled under `lib/assets/google_fonts/`.

### Coverage

```sh
flutter test --coverage
dart run tool/coverage_by_layer.dart           # per layer, against targets
dart run tool/coverage_by_layer.dart --files   # also lists every file below 100%, lowest first
```

Targets: domain 95%, data 85%, presentation 70%. `core/data/` counts as data; the rest of `core/` is reported without a target. The tool exits with 1 if a layer is below its target. `coverage/` is gitignored.

### Firestore rules

```sh
firebase emulators:exec --only firestore "npm --prefix firestore_rules_test test"
```

Runs `firestore_rules_test/rules.test.mjs` (`node:test` and `@firebase/rules-unit-testing`) against `firestore.rules` in a throwaway Firestore emulator.

### Integration tests

`integration_test/commander_flow_test.dart` (register, add soldier, status, conduct with exclusion, duty with points, dashboard counts) and `integration_test/soldier_flow_test.dart` (phone OTP, profile capture, QR) run on a real Android emulator against the Firebase emulators.

1. Start an Android emulator and note its id from `flutter devices` (usually `emulator-5554`).
2. Run:

   ```sh
   firebase emulators:exec --only auth,firestore "flutter test integration_test -d emulator-5554 --dart-define=USE_EMULATOR=true"
   ```

- The tests refuse to run without `USE_EMULATOR=true`, so they never touch the live project.
- Before each test, `integration_test/support/emulator.dart` empties Firestore and Auth through the emulator REST API, signs out and clears preferences.
- The soldier flow reads its OTP from the Auth emulator's `verificationCodes` endpoint.
- A run takes a few minutes. It occasionally fails at launch with "Connecting to the VM Service timed out"; re-run it.

## Adding a feature

1. **Domain** (`lib/features/<name>/domain/`): entities (`equatable`), a repository interface returning `Result<T>` / `ResultStream<T>`, and one use case per action implementing `UseCase` or `StreamUseCase` from `core/usecase/usecase.dart`. Put rules (filtering, calculations, status logic) here, not in widgets. Take a `Clock` for anything date-based. Need soldiers, statuses, attendance or registrations? Import those shared domains; nothing else from other features.
2. **Data** (`data/`): a model that maps the Firestore map to the entity (keys in `core/constants/firestore_keys.dart`, dates through `core/utils/date_formats.dart`), a remote data source that owns the Firestore or Auth calls, and a repository implementation that wraps them in `guard` / `guardStream` (`core/data/failure_mapper.dart`).
3. **Presentation** (`presentation/`): `ChangeNotifier` providers that call use cases and expose `ViewState`; pages and widgets built from `core/widgets` and `core/theme` tokens.
4. **DI:** create the repository in `AppDependencies` (`lib/core/di/injection.dart`) and add a `Provider` for each use case to `providers`.
5. **Routes:** add names to `lib/core/router/app_routes.dart`, expose a `Map<String, RouteWidgetBuilder>` (or a tab builder) from `presentation/<name>_routes.dart` that creates the page's providers, and spread it into `AppRouter.routes`. Shell tabs are wired in `core/router/commander_routes.dart` or `core/router/soldier_routes.dart`.
6. **Tests:** mirror the files under `test/features/<name>/{domain,data,presentation}/`, then run `flutter analyze`, `flutter test` and the coverage tool.

## Conventions

- No Firebase in widgets or providers; only `data/` folders and `core/di` import Firebase.
- No business logic in widgets; it belongs in use cases, entities or domain services.
- Build it once: anything used by two features goes in `core/` (widgets, constants, date formats, rank assets) or a shared domain.
- Colours, text styles, spacing, radii and shadows come from `core/theme` tokens; no hardcoded colours outside it.
- Never call `DateTime.now()`; inject `Clock`.
- Every repository call returns `Either<Failure, T>`.
- Firestore names and string date formats stay identical to the original app (see the data model in ARCHITECTURE.md).
- Keep comments to the ones that are needed.
- Lints are set in `analysis_options.yaml` (`flutter_lints` plus stricter rules such as `prefer_final_locals`, `unawaited_futures`, `directives_ordering`); `flutter analyze` must report no issues.
