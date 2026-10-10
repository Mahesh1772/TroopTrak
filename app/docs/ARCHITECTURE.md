# TroopTrak Architecture

TroopTrak is one Flutter app with two roles: **commanders** manage a unit (dashboard, nominal roll, conducts, guard duty), and **soldiers** see their own profile, conducts and duties. Both read and write the same Firestore database.

The code is organised by feature, with clean-architecture layers inside each feature.

## Layout

```
lib/
  main.dart            bindings, no runtime font fetching, Firebase, AppDependencies, runApp(App)
  app.dart             MultiProvider, ScreenUtilInit (450x1000), MaterialApp, themes, router
  firebase_options.dart
  core/
    constants/         ranks, rank assets, status/conduct/ration/blood types, Firestore keys, pref keys
    data/              failure mapping (guard, guardStream) and Firestore helpers shared by data layers
    di/                composition root (injection.dart), Firebase/emulator bootstrap, cross-feature adapters
    error/             Failure types, exceptions, Result<T> / ResultStream<T>
    router/            route names, route table, commander and soldier shells
    services/          Clock, PreferencesService, IdGenerator, TickSource
    state/             ViewState (loading / error / data), StreamStateNotifier
    theme/             colour, spacing, radius, shadow and text tokens; light/dark themes; ThemeManager
    usecase/           UseCase / StreamUseCase base, NoParams
    utils/             date_formats.dart (every date pattern and parser)
    widgets/           shared widgets: scaffold, search field, tiles, cards, dialogs, pickers, feedback views
  features/<name>/
    domain/            entities, repository interfaces, use cases, rule services. Pure Dart
    data/              models (Firestore map <-> entity), remote data sources, repository implementations
    presentation/      pages, widgets, ChangeNotifier providers, <name>_routes.dart
test/                  mirrors lib/; helpers/ holds pumpApp, builders, fake clock, Firestore seeds
integration_test/      end-to-end role flows against the Firebase emulators
tool/                  coverage_by_layer.dart
firestore_rules_test/  security rules tests (Node)
```

## Dependency rule

Dependencies point inward: `presentation -> domain <- data`.

- `domain/` imports only Dart, `dartz`, `equatable`, `rxdart`, `recase` and the plain parts of `core/` (`error`, `usecase`, `constants`, `services`, `utils`). It never imports Flutter, Firebase, `core/data`, `core/di`, `core/router`, `core/widgets`, `core/theme`, or any `data/` or `presentation/` folder.
- `data/` implements domain repository interfaces. Firestore and Firebase Auth are used only here.
- `presentation/` calls use cases. Providers and widgets never touch Firebase.
- A feature never imports another feature's `data/` or `presentation/`. Only the shared domains `soldiers`, `statuses`, `attendance` and `enlistment` may be imported across features, and only their `domain/`.
- `core/di` (wiring) and `core/router` (navigation) are the only places that see every feature.

`test/architecture_test.dart` enforces this on every `flutter test` run by parsing the imports of every file under `lib/`. It fails when:

| Check | Rule |
|---|---|
| Cross-feature imports | a feature imports another feature's `data/` or `presentation/` |
| Shared domains | a feature imports the `domain/` of a feature other than `soldiers`, `statuses`, `attendance`, `enlistment` |
| Pure domain | a `domain/` file imports Flutter, Firebase, `core/data`, `core/di`, `core/router`, `core/widgets`, `core/theme`, or a `data/`/`presentation/` folder |
| Firebase boundary | `cloud_firestore`, `firebase_auth` or `firebase_core` is imported outside `data/` folders, `core/di/` and `firebase_options.dart`, or `FirebaseFirestore`/`FirebaseAuth` appears in a presentation file |
| Theme tokens | `Color(0x..)`, `Color.fromARGB` or `Color.fromRGBO` appears outside `core/theme/` |
| Clock | `DateTime.now()` appears outside `core/services/clock.dart` |
| Date formats | `DateFormat` appears outside `core/utils/date_formats.dart` |
| Build once | `Icons.search` outside `core/widgets/`, or `army-ranks` paths outside `core/constants/rank_assets.dart` |

## Features

| Feature | Layers | Responsibility |
|---|---|---|
| `onboarding` | domain, data, presentation | Splash page and role selection; stores the role in the `onBoard` preference |
| `auth` | domain, data, presentation | Commander email/password (sign in, register, forgot password, delete own account); soldier phone OTP, profile capture, soldier entry gate |
| `soldiers` | domain, data | `Soldier` entity and the `Users` repository (shared domain) |
| `statuses` | domain, data | `Status` entity, `EligibilityService` (active status, conduct exclusions, duty eligibility), `Statuses` repository (shared domain) |
| `attendance` | domain, data | `AttendanceRecord`, book in/out, effective in-camp per soldier, `Attendance` repository (shared domain) |
| `enlistment` | domain, data, presentation | `Men/{uid}` registration; soldier generates a QR code, commander scans it to prefill the add-soldier form (shared domain: `auth` uses `MenRepository`) |
| `soldier_profile` | presentation | Profile page with basic info, statuses and attendance tabs, status and attendance forms. One page for all three uses, switched by `ProfileCapabilities` (commander viewing a soldier, commander's own profile, soldier's own profile) |
| `nominal_roll` | domain, presentation | Soldier list with category search chips, in/out toggle, add/edit soldier form |
| `conducts` | domain, data, presentation | Conduct tracker by day with a participation chart, add/update/details, roster with automatic exclusions |
| `guard_duty` | domain, data, presentation | Points leaderboard, today/upcoming duties, add/update/delete duty with weekday points |
| `dashboard` | domain, presentation | Strength summary, status breakdown, strength chart, event calendar. Calendar events come through `CalendarEventSource`, implemented by `core/di/calendar_event_adapter.dart` over the conduct and duty repositories |
| `shell` | presentation | Bottom-navigation shells: commander (Dashboard, Nominal Roll, Conduct Tracker, Guard Duty) and soldier (My Profile, Conduct Tracker, Guard Duty) |

## Dependency injection

`core/di/injection.dart` holds `AppDependencies`, the single composition root.

1. `main.dart` calls `initFirebase()` (`core/di/firebase_bootstrap.dart`), which initialises Firebase and, when built with `--dart-define=USE_EMULATOR=true`, points Firestore and Auth at the emulators.
2. `AppDependencies.create()` loads `PreferencesService`. Data sources and repositories are created lazily from `FirebaseFirestore.instance` / `FirebaseAuth.instance`, or from instances passed to the constructor (tests pass `FakeFirebaseFirestore` and `MockFirebaseAuth`).
3. `AppDependencies.providers` returns one `Provider` per use case plus `Clock`, `TickSource`, `PreferencesService` and the `ThemeManager`. `App` puts them in a `MultiProvider` above `MaterialApp`.
4. Page-level `ChangeNotifierProvider`s are created in each feature's `<name>_routes.dart`, reading the use cases they need with `context.read`.

There is no service locator. Anything that needs the current time takes a `Clock`, so date rules are testable with a fixed clock.

## Routing

All routes are named. `core/router/app_routes.dart` lists the names; each feature exposes a `Map<String, RouteWidgetBuilder>` (or tab builders) in `presentation/<name>_routes.dart`; `core/router/app_router.dart` merges them into one `onGenerateRoute`. Unknown names show a "Page not found." view. Features navigate with `Navigator.pushNamed(AppRoutes.x)`, never by importing another feature's page.

`core/router/commander_routes.dart` (`CommanderHome`) and `core/router/soldier_routes.dart` (`SoldierHome`) build the two shells from the feature tab builders, so `shell` never imports other features.

### Startup

`/` is `SplashPage`. It reads the `onBoard` preference through `GetRole`:

| `onBoard` | Next route |
|---|---|
| unset | `/role` role selection; choosing a role writes `onBoard` |
| `1` (soldier) | `/soldier` soldier gate |
| `2` (commander) | `/commander` commander gate |

- **Commander gate:** listens to `authStateChanges`. A signed-in user gets the commander shell; otherwise the email sign-in page.
- **Soldier gate:** `ResolveSoldierEntry` sends a signed-in soldier with a `Men/{uid}` document (and the `is_signedin` preference set) to `/soldier/home`, a signed-in soldier without one to `/soldier/profile-capture`, and everyone else to `/soldier/phone`.
- **Sign out** clears all preferences, so the next start shows role selection again (kept from the original app).

## State

- `provider` with `ChangeNotifier`. Use cases are plain `Provider`s; screens own their `ChangeNotifier`s.
- Stream-backed views hold a `ViewState<T>` (`ViewLoading`, `ViewError`, `ViewData`), usually through `core/state/stream_state_notifier.dart`, and render it with the shared loading / error / empty views.
- Writes report their outcome through `AppSnackbar`.
- `ThemeManager` switches light and dark themes (dark by default).

## Errors

- Every repository method returns `Result<T>` (`Future<Either<Failure, T>>`) or `ResultStream<T>` (`Stream<Either<Failure, T>>`) from `dartz`.
- Data layers wrap Firebase calls in `guard` / `guardStream` (`core/data/failure_mapper.dart`), which turn exceptions into `Failure`s: `ServerFailure`, `NotFoundFailure`, `AuthFailure` (with readable messages per Firebase code), `ValidationFailure`, `CacheFailure`.
- Use cases return `ValidationFailure` for rule violations (for example a duplicate soldier name or an end date before the start date). Providers fold the `Either` into view state or a snackbar message.

## Firestore data model

Collection and field names, and the string date formats, are identical to the original app so both can read the same data. All mapping lives in `data/models/`; keys are in `core/constants/firestore_keys.dart`.

| Path | Fields |
|---|---|
| `Users/{name}` | `name`, `rank`, `company`, `platoon`, `section`, `appointment`, `rationType`, `bloodgroup`, `dob`, `enlistment`, `ord` (strings), `currentAttendance` (`Inside Camp` / `Outside`), `points` (number) |
| `Users/{name}/Statuses/{auto}` | `statusType` (`Excuse` / `Leave` / `Medical Appointment`), `statusName`, `startDate`, `endDate`, `start_id`, `end_id` |
| `Users/{name}/Attendance/{yyyy-MM-dd HH:mm:ss}` | `isInsideCamp` (bool), `date&time` (string) |
| `Men/{uid}` | soldier's own registration: profile fields, `points`, `QRid` (string or null) |
| `Conducts/{auto}` | `conductName`, `conductType`, `startDate`, `startTime`, `endTime`, `participants` (list of names), `soldierReason` (map name to reason) |
| `Duties/{auto}` | `dutyDate`, `startTime`, `endTime`, `dayType`, `points` (number), `participants` (map name to rank) |

Dates are strings: day `d MMM yyyy`, time `jm` (`5:30 PM`). `Users` documents are keyed by the soldier's name, and conducts and duties refer to soldiers by name. `Men/{uid}` (soldier side) and `Users/{name}` (commander side) are linked only by that name, so renaming a soldier breaks the link; the document id never changes on edit.

Statuses and attendance are also read across all soldiers with collection-group queries (dashboard, nominal roll, rosters). Every other query is a single-field equality (`Conducts.startDate`, `Men.QRid`) or a full collection read, so `firestore.indexes.json` is empty.

## Key business rules

- **Active status:** a status is active on a day when that day is on or before its end date. The start date is not checked, except on the dashboard, which counts a status only once it has started. `Medical Appointment` counts as "On MA", other types as "On Status"; each soldier is counted once.
- **Conduct exclusions:** when a conduct is created, soldiers with an active `Leave` are excluded from every type; an active `Excuse` excludes when its name is in that conduct type's list. Exclusions use statuses active today, not on the conduct's date. Excuse names must match the lists exactly (the lists are copied from the original, inconsistencies included). The reason is stored in `soldierReason`.
- **Guard duty eligibility:** excluded by an active `Ex Uniform` or `Ex Boots` excuse, or any active `Leave`. A duty has at most 10 slots.
- **Duty points:** Mon-Thu 1, Fri 1.5, Sat 2.5, Sun 2, stored on the duty. Adding a duty adds its points to each participant's `Users.points`; updating reverses the old points from the old participants and adds the new points to the new ones; deleting subtracts them (never below 0). The duty and the points change in one transaction. The leaderboard reads `Users.points` for both roles.
- **Book in/out:** writes an attendance record and sets `currentAttendance`. `Leave` and `Medical Appointment` statuses own two linked attendance records (book out at 00:30 on the start day, book in at 22:00 on the end day, ids in `start_id`/`end_id`) that move with the status and are deleted with it. Effective in-camp is the latest attendance record not in the future, falling back to `currentAttendance`.
- **Attendance list:** newest first; future records are hidden.
- **Soldiers:** adding a soldier whose name already exists is refused. Deleting a soldier deletes their statuses, attendance and `Users` document. New soldiers start `Inside Camp` with 0 points and an initial attendance record.
- **QR enlistment:** the soldier writes a v4 UUID to `Men/{uid}.QRid` for 2 minutes and clears it when the dialog closes or expires. The commander's scan looks `Men` up by `QRid` and opens a prefilled add-soldier form.
- **Validation:** status and conduct end cannot be before start; conduct date and times are required; soldier profile capture requires every date; passwords need at least 8 characters, and registration also requires 1 uppercase letter, 3 lowercase letters, 1 digit and 1 special character.

## Security rules

`firestore.rules`:

- Every collection (`Users` and its `Statuses` / `Attendance`, `Conducts`, `Duties`, and the collection-group reads) requires a signed-in user.
- `Men/{uid}` is readable by any signed-in user (QR lookup) and writable only by the user whose uid it is.

`firestore_rules_test/rules.test.mjs` checks these rules in the Firestore emulator.

**Risk:** roles are not separated. Commanders and soldiers are both just signed-in Firebase users, so a soldier account could write `Users`, `Statuses`, `Attendance`, `Conducts` and `Duties` directly. Closing this needs a role marker the rules can read, such as a custom claim or a role document. Deploying the rules to the live project is a separate, manual decision.
