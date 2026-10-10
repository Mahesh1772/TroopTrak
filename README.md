# TroopTrak

<div align="center">

![5493](https://github.com/Mahesh1772/Orbital/assets/110832731/a83e397e-ad8e-4fe5-9935-d295c71580db)

<p>
<strong>A mobile app for military troop management and tracking</strong>
</p>

<p>
<a href="https://flutter.dev/"><img src="https://img.shields.io/badge/Made%20with-Flutter-02569B?style=flat&logo=flutter" alt="Made with Flutter"></a>
<a href="https://firebase.google.com/"><img src="https://img.shields.io/badge/Powered%20by-Firebase-FFCA28?style=flat&logo=firebase&logoColor=black" alt="Firebase"></a>
<img src="https://img.shields.io/badge/Platform-Android-lightgrey" alt="Platform">
</p>

</div>

---

One Flutter app, two roles chosen on first launch:

- **Commander:** dashboard of unit strength, nominal roll with book in/out, soldier profiles with statuses and attendance, adding soldiers by QR scan, conduct tracker with automatic exclusions, and a guard duty roster with points.
- **Soldier:** phone sign-in, own profile, a QR code for the commander to scan, the conducts they are on, and the guard duty leaderboard.

## Install

Download the latest `trooptrak-<version>.apk` from [Releases](https://github.com/Mahesh1772/TroopTrak/releases) on an Android phone and open it. Allow installs from unknown sources when asked.

## Repository layout

| Folder | What it is |
|---|---|
| [`app/`](app/) | The app: a feature-first Flutter project with clean-architecture layers and tests at every layer. Start with [`app/README.md`](app/README.md). |
| [`app/docs/`](app/docs/) | [Architecture](app/docs/ARCHITECTURE.md) and [developer guide](app/docs/DEVELOPER_GUIDE.md): setup, Firebase emulators, test commands, building an APK. |
| [`legacy/`](legacy/) | The original NUS Orbital prototypes (`firebase_project_2` is the feature reference for the rebuild), early demos, the old documentation site and design notes. Kept for reference; not built or maintained. |
| `.github/workflows/` | CI (analyze, unit and widget tests, Firestore rules tests) and the tag-triggered APK release. |

## License

This project is proprietary software designed for military use.

## Authors

<div align="center">

**Aakash Ramaswamy** • **Sivagnanam Maheshwaran**

<p>
<sub>Part of the NUS Orbital Program</sub>
</p>

![BladesOfOlympusLogo](https://github.com/Mahesh1772/Orbital/assets/110832731/6aa388e9-f47e-4bb1-8449-288a1e63a478)

</div>
