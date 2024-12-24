# trooptrak_final_application

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

```
C:.
│   firebase_options.dart
│   main.dart
│
├───assets
│   │   icons8-doctors-folder-64.png
│   │   icons8-error-64.png
│   │   icons8-medals-64.png
│   │   icons8-soldier-man-64.png
│   │   icons8-soldiers-64.png
│   │   icons8-user-96.png
│   │   noConductspng.png
│   │   Troop Trak Poster.png
│   │   TroopTrakSplashscreen.png
│   │   TroopTrak_logo.jpg
│   │   TroopTrak_logo_unmasked.jpg
│   │   TroopTrak_Splash_Screen.jpg
│   │   user.png
│   │
│   ├───army-ranks
│   │       1sg.png
│   │       1wo.png
│   │       2lt.png
│   │       2sg.png
│   │       2wo.png
│   │       3sg.png
│   │       3wo.png
│   │       bg.png
│   │       cfc.png
│   │       col.png
│   │       cpl.png
│   │       cpt.png
│   │       cwo.png
│   │       lcp.png
│   │       lg.png
│   │       lta.png
│   │       ltc.png
│   │       maj.png
│   │       men.png
│   │       mg.png
│   │       msg.png
│   │       mwo.png
│   │       oct.png
│   │       pte.png
│   │       rec.png
│   │       sct.png
│   │       sltc.png
│   │       soldier.png
│   │       ssg.png
│   │       swo.png
│   │
│   ├───calendar-images
│   │       April.png
│   │       August.png
│   │       December.png
│   │       February.png
│   │       January.png
│   │       July.png
│   │       June.png
│   │       March.png
│   │       May.png
│   │       November.png
│   │       October.png
│   │       September.png
│   │
│   └───phone_auth
│           troopTrak_logo.png
│           troopTrak_mascot.png
│
├───core
│   └───theme
│           theme.dart
│
├───default_app
│       counter_model.dart
│       home_page.dart
│
└───features
    ├───auth
    │   ├───data
    │   ├───domain
    │   └───presentation
    │
    ├───conduct_tracker
    │   ├───data
    │   ├───domain
    │   └───presentation
    │
    ├───dashboard
    │   ├───data
    │   ├───domain
    │   └───presentation
    │
    ├───detailed_view
    │   ├───data
    │   │   ├───models
    │   │   │       attendance_model.dart
    │   │   │       status_model.dart
    │   │   │
    │   │   └───repositories
    │   │           attendance_repository_impl.dart
    │   │           status_repository_impl.dart
    │   │
    │   ├───domain
    │   │   ├───entities
    │   │   │       attendance_record.dart
    │   │   │       status.dart
    │   │   │
    │   │   ├───repositories
    │   │   │       attendance_repository.dart
    │   │   │       status_repository.dart
    │   │   │
    │   │   └───usecases
    │   │           add_status_usecase.dart
    │   │           delete_attendance.dart
    │   │           delete_status_usecase.dart
    │   │           get_statuses_usecase.dart
    │   │           get_user_attendance.dart
    │   │           update_attendance.dart
    │   │           update_status_usecase.dart
    │   │           update_user_attendance.dart
    │   │
    │   └───presentation
    │       ├───pages
    │       │       add_update_status_page.dart
    │       │       attendance_tab.dart
    │       │       edit_attendance_page.dart
    │       │       soldier_detailed_screen.dart
    │       │
    │       ├───providers
    │       │       attendance_provider.dart
    │       │       status_provider.dart
    │       │
    │       └───widgets
    │               attendance_tile.dart
    │               basic_info_tab.dart
    │               custom_rect_tween.dart
    │               hero_dialog_route.dart
    │               past_status_tile.dart
    │               statuses_tab.dart
    │               status_tile.dart
    │
    ├───guard_duty
    │   ├───data
    │   ├───domain
    │   └───presentation
    │
    └───nominal_roll
        ├───data
        │   ├───models
        │   │       user_model.dart
        │   │
        │   └───repositories
        │           qr_scanner_repository_impl.dart
        │           user_repository_impl.dart
        │
        ├───domain
        │   ├───entities
        │   │       attendance_record.dart
        │   │       scanned_soldier.dart
        │   │       user.dart
        │   │
        │   ├───repositories
        │   │       qr_scanner_repository.dart
        │   │       user_repository.dart
        │   │
        │   └───usecases
        │           add_user_usecase.dart
        │           delete_user_usecase.dart
        │           get_users_usecase.dart
        │           get_user_attendance_usecase.dart
        │           get_user_by_id_usecase.dart
        │           scan_qr_code_usecase.dart
        │           update_user_attendance_usecase.dart
        │           update_user_usecase.dart
        │
        └───presentation
            ├───pages
            │       edit_soldier_screen.dart
            │       nominal_roll_screen.dart
            │       qr_scanner_page.dart
            │
            ├───providers
            │       qr_scanner_provider.dart
            │       user_detail_provider.dart
            │       user_provider.dart
            │
            └───widgets
                    action_button.dart
                    qr_scanner_error_widget.dart
                    qr_scanner_overlay.dart
                    user_tile.dart

```