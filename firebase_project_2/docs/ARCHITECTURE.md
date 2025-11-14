---
layout: default
title: Architecture - TroopTrak Documentation
permalink: /ARCHITECTURE/
---

# 🏛️ TroopTrak Architecture Documentation

<div align="center">

![Architecture](https://img.shields.io/badge/Architecture-System_Design-8147e6?style=for-the-badge)

**Detailed system architecture, design patterns, and technical diagrams**

</div>

---

## 📋 Table of Contents

- [System Overview](#system-overview)
- [Architecture Patterns](#architecture-patterns)
- [Component Diagrams](#component-diagrams)
- [Data Flow](#data-flow)
- [Class Relationships](#class-relationships)
- [Sequence Diagrams](#sequence-diagrams)
- [Deployment Architecture](#deployment-architecture)

---

## System Overview

### High-Level System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                                 │
│                                                                      │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐   │
│  │  Android   │  │    iOS     │  │    Web     │  │  Desktop   │   │
│  │   App      │  │    App     │  │    App     │  │    App     │   │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘   │
│        └─────────────────┴───────────────┴───────────────┘          │
│                              │                                       │
└──────────────────────────────┼───────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    FLUTTER FRAMEWORK LAYER                          │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    Material Design Widgets                    │  │
│  └──────────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    State Management (Provider)                │  │
│  └──────────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    Navigation & Routing                       │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                      │
└──────────────────────────────────┬───────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER                                │
│                                                                      │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐       │
│  │ Authentication │  │    Conduct     │  │   Guard Duty   │       │
│  │     Module     │  │    Module      │  │     Module     │       │
│  └────────────────┘  └────────────────┘  └────────────────┘       │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐       │
│  │  User Profile  │  │   Attendance   │  │     Status     │       │
│  │     Module     │  │     Module     │  │     Module     │       │
│  └────────────────┘  └────────────────┘  └────────────────┘       │
│                                                                      │
└──────────────────────────────┬───────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     FIREBASE SERVICES LAYER                         │
│                                                                      │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐       │
│  │   Firebase     │  │   Cloud        │  │   Cloud        │       │
│  │   Auth         │  │   Firestore    │  │   Storage      │       │
│  └────────────────┘  └────────────────┘  └────────────────┘       │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐       │
│  │   Firebase     │  │   Cloud        │  │   Firebase     │       │
│  │   Analytics    │  │   Messaging    │  │   Hosting      │       │
│  └────────────────┘  └────────────────┘  └────────────────┘       │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Architecture Patterns

### 1. Clean Architecture Layers

```
┌─────────────────────────────────────────┐
│         PRESENTATION LAYER              │
│  • Screens & Widgets                    │
│  • UI Components                        │
│  • View Models (Providers)              │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│         BUSINESS LOGIC LAYER            │
│  • Use Cases                            │
│  • Business Rules                       │
│  • Data Transformation                  │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│            DATA LAYER                   │
│  • Repositories                         │
│  • Data Sources (Firestore)             │
│  • Models                               │
└─────────────────────────────────────────┘
```

### 2. Provider Pattern (State Management)

```
┌─────────────────────────────────────────────────┐
│              MultiProvider (Root)               │
│                                                 │
│  ┌───────────────────────────────────────┐     │
│  │        ChangeNotifier Providers        │     │
│  │                                        │     │
│  │  ┌──────────────────────────────┐     │     │
│  │  │      AuthProvider            │     │     │
│  │  │  - Manages auth state        │     │     │
│  │  │  - Phone authentication      │     │     │
│  │  │  - User session              │     │     │
│  │  └──────────────┬───────────────┘     │     │
│  │                 │                     │     │
│  │  ┌──────────────▼───────────────┐     │     │
│  │  │      MenUserData             │     │     │
│  │  │  - User data streams         │     │     │
│  │  │  - Conduct queries           │     │     │
│  │  │  - Duty management           │     │     │
│  │  └──────────────┬───────────────┘     │     │
│  │                 │                     │     │
│  │  ┌──────────────▼───────────────┐     │     │
│  │  │      ThemeManager            │     │     │
│  │  │  - Theme switching           │     │     │
│  │  │  - Preference persistence    │     │     │
│  │  └──────────────────────────────┘     │     │
│  └───────────────────────────────────────┘     │
│                                                 │
│  ┌───────────────────────────────────────┐     │
│  │       Consumer Widgets                 │     │
│  │  - Listen to provider changes          │     │
│  │  - Rebuild on state update             │     │
│  └───────────────────────────────────────┘     │
└─────────────────────────────────────────────────┘
```

### 3. Repository Pattern

```
┌─────────────────────────────────────────┐
│          Presentation Layer             │
│         (UI & Providers)                │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│       Repository Interface              │
│  + getUserData(id)                      │
│  + saveConductData(conduct)             │
│  + getDutyList()                        │
└─────────────────┬───────────────────────┘
                  │
          ┌───────┴────────┐
          │                │
          ▼                ▼
┌──────────────┐   ┌──────────────┐
│  Firestore   │   │    Local     │
│  Repository  │   │  Repository  │
│              │   │ (SharedPrefs)│
└──────────────┘   └──────────────┘
```

---

## Component Diagrams

### Authentication Module

```
┌─────────────────────────────────────────────────────────┐
│               Authentication Module                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌────────────────────────────────────────────┐         │
│  │     CommanderOrManSelectScreen             │         │
│  │  - Role selection (Men/Commander)          │         │
│  └─────────────────┬──────────────────────────┘         │
│                    │                                     │
│                    ▼                                     │
│  ┌────────────────────────────────────────────┐         │
│  │           WrapperScreen                    │         │
│  │  - Checks authentication status            │         │
│  └─────────────────┬──────────────────────────┘         │
│                    │                                     │
│        ┌───────────┴─────────────┐                      │
│        │                         │                      │
│        ▼                         ▼                      │
│  ┌──────────┐           ┌────────────────┐             │
│  │  Main    │           │   Register     │             │
│  │  App     │           │   Screen       │             │
│  └──────────┘           └────────┬───────┘             │
│                                  │                      │
│                                  ▼                      │
│                         ┌────────────────┐             │
│                         │  Phone Number  │             │
│                         │  Entry Screen  │             │
│                         └────────┬───────┘             │
│                                  │                      │
│                                  ▼                      │
│                         ┌────────────────┐             │
│                         │   OTP Screen   │             │
│                         └────────┬───────┘             │
│                                  │                      │
│                                  ▼                      │
│                         ┌────────────────┐             │
│                         │   Get User     │             │
│                         │   Info Screen  │             │
│                         └────────┬───────┘             │
│                                  │                      │
│                                  ▼                      │
│                            ┌──────────┐                │
│                            │  Success │                │
│                            └──────────┘                │
│                                                          │
│  ┌────────────────────────────────────────────┐         │
│  │         AuthProvider (State)               │         │
│  │  - isSignedIn                              │         │
│  │  - userid                                  │         │
│  │  - signInWithPhone()                       │         │
│  │  - verifyOTP()                             │         │
│  │  - saveUserData()                          │         │
│  └────────────────────────────────────────────┘         │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Main Application Module

```
┌─────────────────────────────────────────────────────────┐
│               Main Application                           │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌────────────────────────────────────────────┐         │
│  │          GNavMainScreen                    │         │
│  │       (Bottom Navigation Host)             │         │
│  └─────────────────┬──────────────────────────┘         │
│                    │                                     │
│         ┌──────────┼──────────┐                         │
│         │          │          │                         │
│         ▼          ▼          ▼                         │
│  ┌──────────┐ ┌────────┐ ┌─────────┐                   │
│  │ Profile  │ │Conduct │ │  Guard  │                   │
│  │  Screen  │ │Tracker │ │  Duty   │                   │
│  └────┬─────┘ └───┬────┘ └────┬────┘                   │
│       │           │           │                         │
│       ▼           ▼           ▼                         │
│  ┌─────────────────────────────────┐                    │
│  │  Tab 1  │  Tab 2  │  Tab 3     │                    │
│  ├─────────┼─────────┼────────────┤                    │
│  │ Basic   │ Status  │ Attendance │  (Profile)         │
│  │ Info    │         │            │                    │
│  └─────────┴─────────┴────────────┘                    │
│  ┌─────────────────────────────────┐                    │
│  │ Participation  │  Conduct List  │  (Conduct)        │
│  │    Chart       │                │                    │
│  └────────────────┴────────────────┘                    │
│  ┌─────────────────────────────────┐                    │
│  │  Leaderboard  │  Upcoming       │  (Guard Duty)     │
│  │               │   Duties        │                    │
│  └───────────────┴─────────────────┘                    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Conduct Tracker Module

```
┌─────────────────────────────────────────────────────────┐
│            Conduct Tracker Module                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌────────────────────────────────────────────┐         │
│  │      ConductTrackerScreen                  │         │
│  │                                            │         │
│  │  ┌──────────────────────────────────┐     │         │
│  │  │   Date Selector Widget           │     │         │
│  │  │  - Horizontal date picker        │     │         │
│  │  │  - Calendar popup                │     │         │
│  │  └──────────────────────────────────┘     │         │
│  │                                            │         │
│  │  ┌──────────────────────────────────┐     │         │
│  │  │   Participation Chart            │     │         │
│  │  │  - Bar graph (fl_chart)          │     │         │
│  │  │  - Shows participation strength  │     │         │
│  │  └──────────────────────────────────┘     │         │
│  │                                            │         │
│  │  ┌──────────────────────────────────┐     │         │
│  │  │   Conduct List                   │     │         │
│  │  │  - ListView.builder              │     │         │
│  │  │  - ConductTile widgets           │     │         │
│  │  └──────────────────────────────────┘     │         │
│  │                                            │         │
│  └─────────────────┬──────────────────────────┘         │
│                    │                                     │
│                    │ Tap conduct                         │
│                    ▼                                     │
│  ┌────────────────────────────────────────────┐         │
│  │      ConductDetailsScreen                  │         │
│  │                                            │         │
│  │  - Conduct information                     │         │
│  │  - Participant list                        │         │
│  │  - Non-participant list                    │         │
│  │  - Edit/Delete (Commander only)            │         │
│  └────────────────────────────────────────────┘         │
│                                                          │
│  ┌────────────────────────────────────────────┐         │
│  │         Data Source                        │         │
│  │  - MenUserData.conducts_data               │         │
│  │  - Stream<QuerySnapshot>                   │         │
│  │  - Real-time Firestore updates             │         │
│  └────────────────────────────────────────────┘         │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Data Flow

### Authentication Data Flow

```
┌──────────────┐
│    User      │
│  (Mobile)    │
└──────┬───────┘
       │ 1. Enter phone number
       ▼
┌──────────────┐
│ AuthProvider │
│ signInWith   │
│   Phone()    │
└──────┬───────┘
       │ 2. Request OTP
       ▼
┌──────────────┐
│  Firebase    │
│    Auth      │
└──────┬───────┘
       │ 3. Send SMS OTP
       ▼
┌──────────────┐
│   User       │
│  (Receives   │
│    SMS)      │
└──────┬───────┘
       │ 4. Enter OTP
       ▼
┌──────────────┐
│ AuthProvider │
│  verifyOTP() │
└──────┬───────┘
       │ 5. Verify with Firebase
       ▼
┌──────────────┐
│  Firebase    │
│    Auth      │
└──────┬───────┘
       │ 6. Return User object
       ▼
┌──────────────┐
│ AuthProvider │
│ checkExisting│
│   User()     │
└──────┬───────┘
       │ 7. Query Firestore
       ▼
┌──────────────┐
│  Firestore   │
│ 'Men' doc?   │
└──────┬───────┘
       │
   ┌───┴────┐
   │        │
 Exists   New User
   │        │
   │        ▼
   │   ┌─────────┐
   │   │  User   │
   │   │  Info   │
   │   │  Form   │
   │   └────┬────┘
   │        │ 8. Submit data
   │        ▼
   │   ┌─────────┐
   │   │  Save   │
   │   │   to    │
   │   │Firestore│
   │   └────┬────┘
   │        │
   └────┬───┘
        │ 9. Save session
        ▼
   ┌─────────┐
   │ Shared  │
   │  Prefs  │
   └────┬────┘
        │ 10. Navigate to app
        ▼
   ┌─────────┐
   │  Main   │
   │  App    │
   └─────────┘
```

### Conduct Data Flow

```
User Action: View Conducts
        │
        ▼
┌────────────────┐
│ Conduct Screen │
│   (initState)  │
└────────┬───────┘
         │ 1. Request stream
         ▼
┌────────────────┐
│  MenUserData   │
│ conducts_data  │
└────────┬───────┘
         │ 2. Create stream
         ▼
┌────────────────┐
│   Firestore    │
│   .collection  │
│  ('Conducts')  │
│  .snapshots()  │
└────────┬───────┘
         │ 3. Listen for changes
         ▼
┌────────────────┐
│ StreamBuilder  │
│  (rebuilds on  │
│    updates)    │
└────────┬───────┘
         │ 4. Process data
         ▼
┌────────────────┐
│  Filter by     │
│   Selected     │
│     Date       │
└────────┬───────┘
         │ 5. Build UI
         ▼
┌────────────────┐
│  Display       │
│  Conduct List  │
└────────────────┘

User Action: Tap Conduct
        │
        ▼
┌────────────────┐
│   Navigate to  │
│    Details     │
│     Screen     │
└────────┬───────┘
         │
         ▼
┌────────────────┐
│  Show Full     │
│  Conduct Info  │
└────────────────┘
```

### Guard Duty Data Flow

```
Commander Action: Assign Duty
        │
        ▼
┌────────────────┐
│  Duty Screen   │
│  Create Form   │
└────────┬───────┘
         │ 1. Fill duty details
         ▼
┌────────────────┐
│  Auto-filter   │
│   excused      │
│   personnel    │
└────────┬───────┘
         │ 2. Query user statuses
         ▼
┌────────────────┐
│   Firestore    │
│  Get active    │
│   statuses     │
└────────┬───────┘
         │ 3. Filter list
         ▼
┌────────────────┐
│  Show eligible │
│   personnel    │
└────────┬───────┘
         │ 4. Select & assign
         ▼
┌────────────────┐
│   Save duty    │
│   document     │
└────────┬───────┘
         │ 5. Write to Firestore
         ▼
┌────────────────┐
│   Firestore    │
│  'Duties'      │
│  collection    │
└────────┬───────┘
         │ 6. Real-time update
         ▼
┌────────────────┐
│  All users see │
│   new duty     │
└────────────────┘
```

---

## Class Relationships

### Core Classes UML

```
┌──────────────────────────────────────┐
│         ChangeNotifier               │
│          (Flutter SDK)               │
└─────────────┬───────────────────────┘
              │
              │ extends
              │
    ┌─────────┼─────────┐
    │                   │
    ▼                   ▼
┌─────────────┐   ┌─────────────┐
│AuthProvider │   │ MenUserData │
├─────────────┤   ├─────────────┤
│ - isSignedIn│   │ - docIDs    │
│ - userid    │   │ - userList  │
│ - data      │   │ - statusList│
├─────────────┤   ├─────────────┤
│ + signIn()  │   │ + getData() │
│ + verifyOTP │   │ + conducts()│
│ + signOut() │   │ + duties()  │
└─────────────┘   └─────────────┘
      │                 │
      │                 │ uses
      │                 ▼
      │           ┌─────────────┐
      │           │  Firestore  │
      │           │  Queries    │
      │           └─────────────┘
      │
      │ uses
      ▼
┌─────────────┐
│  Firebase   │
│    Auth     │
└─────────────┘


┌──────────────────────────────────────┐
│         StatefulWidget               │
│          (Flutter SDK)               │
└─────────────┬───────────────────────┘
              │
              │ extends
              │
    ┌─────────┼─────────┬──────────┐
    │         │         │          │
    ▼         ▼         ▼          ▼
┌─────┐   ┌─────┐  ┌────────┐  ┌──────┐
│User │   │Cond.│  │ Guard  │  │ Auth │
│Prof.│   │Track│  │ Duty   │  │Screen│
└─────┘   └─────┘  └────────┘  └──────┘
   │         │         │          │
   │         │         │          │ uses
   │         │         │          ▼
   │         │         │      ┌──────────┐
   │         │         │      │  Auth    │
   │         │         │      │ Provider │
   │         │         │      └──────────┘
   │         │         │
   │         │         │ uses
   │         └─────────┴──────────┐
   │                              │
   │ uses                         ▼
   └───────────────────────► ┌──────────┐
                             │ MenUser  │
                             │  Data    │
                             └──────────┘
```

### Data Model Relationships

```
┌───────────────────────────────────────────────┐
│                  UserModel                    │
├───────────────────────────────────────────────┤
│ + uid: String                                 │
│ + name: String                                │
│ + rank: String                                │
│ + company: String                             │
│ + ...                                         │
├───────────────────────────────────────────────┤
│ + toMap(): Map                                │
│ + fromMap(Map): UserModel                     │
└───────────────┬───────────────────────────────┘
                │
                │ has many
                ▼
┌───────────────────────────────────────────────┐
│              AttendanceModel                  │
├───────────────────────────────────────────────┤
│ + timestamp: DateTime                         │
│ + isInsideCamp: bool                          │
│ + action: String                              │
├───────────────────────────────────────────────┤
│ + toMap(): Map                                │
│ + fromMap(Map): AttendanceModel               │
└───────────────────────────────────────────────┘

┌───────────────────────────────────────────────┐
│                StatusModel                    │
├───────────────────────────────────────────────┤
│ + statusType: String                          │
│ + statusName: String                          │
│ + startDate: String                           │
│ + endDate: String                             │
├───────────────────────────────────────────────┤
│ + isActive(): bool                            │
│ + toMap(): Map                                │
│ + fromMap(Map): StatusModel                   │
└───────────────────────────────────────────────┘


┌───────────────────────────────────────────────┐
│               ConductModel                    │
├───────────────────────────────────────────────┤
│ + conductName: String                         │
│ + conductType: String                         │
│ + startDate: String                           │
│ + participants: List<String>                  │
├───────────────────────────────────────────────┤
│ + addParticipant(name): void                  │
│ + isParticipant(name): bool                   │
│ + toMap(): Map                                │
└───────────────┬───────────────────────────────┘
                │
                │ references
                ▼
┌───────────────────────────────────────────────┐
│                UserModel                      │
│         (via name/reference)                  │
└───────────────────────────────────────────────┘


┌───────────────────────────────────────────────┐
│                 DutyModel                     │
├───────────────────────────────────────────────┤
│ + dutyDate: String                            │
│ + personnel: List<String>                     │
│ + commander: String                           │
│ + points: int                                 │
├───────────────────────────────────────────────┤
│ + assignPersonnel(name): void                 │
│ + toMap(): Map                                │
└───────────────┬───────────────────────────────┘
                │
                │ references
                ▼
┌───────────────────────────────────────────────┐
│                UserModel                      │
│         (via name/reference)                  │
└───────────────────────────────────────────────┘
```

---

## Sequence Diagrams

### Phone Authentication Sequence

```
User        RegisterScreen   AuthProvider    FirebaseAuth    Firestore    OTPScreen    MainApp
 │                │                │               │             │            │          │
 │ Enter phone    │                │               │             │            │          │
 ├───────────────>│                │               │             │            │          │
 │                │ signInWithPhone│               │             │            │          │
 │                ├───────────────>│               │             │            │          │
 │                │                │ verifyPhone() │             │            │          │
 │                │                ├──────────────>│             │            │          │
 │                │                │               │ Send SMS    │            │          │
 │                │                │               ├─────────────┤            │          │
 │                │                │ codeSent      │             │            │          │
 │                │                │<──────────────┤             │            │          │
 │                │                │ Navigate      │             │            │          │
 │                │                ├───────────────┼─────────────┼───────────>│          │
 │ Receive SMS    │                │               │             │            │          │
 ├────────────────┤                │               │             │            │          │
 │ Enter OTP      │                │               │             │            │          │
 ├────────────────┼────────────────┼───────────────┼─────────────┼───────────>│          │
 │                │                │               │             │            │          │
 │                │                │ verifyOTP()   │             │            │          │
 │                │                │<──────────────┼─────────────┼────────────┤          │
 │                │                │ signInWith    │             │            │          │
 │                │                │  Credential() │             │            │          │
 │                │                ├──────────────>│             │            │          │
 │                │                │ UserCredential│             │            │          │
 │                │                │<──────────────┤             │            │          │
 │                │                │               │             │            │          │
 │                │                │ checkExisting │             │            │          │
 │                │                │     User()    │             │            │          │
 │                │                ├───────────────┼─────────────>            │          │
 │                │                │               │ Query 'Men' │            │          │
 │                │                │               │<────────────┤            │          │
 │                │                │               │  Exists?    │            │          │
 │                │                │<──────────────┼─────────────┤            │          │
 │                │                │               │             │            │          │
 │                │  (if new user) │               │             │            │          │
 │ Fill user info │                │               │             │            │          │
 ├───────────────>│                │               │             │            │          │
 │                │ saveUserData() │               │             │            │          │
 │                ├───────────────>│               │             │            │          │
 │                │                │ saveUser()    │             │            │          │
 │                │                ├───────────────┼─────────────>            │          │
 │                │                │               │ Write doc   │            │          │
 │                │                │<──────────────┼─────────────┤            │          │
 │                │                │               │             │            │          │
 │                │                │ setSignIn()   │             │            │          │
 │                │                ├───────────────┤             │            │          │
 │                │                │ SharedPrefs   │             │            │          │
 │                │                │               │             │            │          │
 │                │                │ Navigate to Main           │            │          │
 │                │                ├───────────────┼─────────────┼────────────┼─────────>│
 │                │                │               │             │            │          │
```

### Conduct Creation Sequence (Commander)

```
Commander  ConductForm  MenUserData  Firestore  AllUsers
   │            │            │           │         │
   │ Fill form  │            │           │         │
   ├───────────>│            │           │         │
   │            │ Create     │           │         │
   │            │ Conduct    │           │         │
   │            ├───────────>│           │         │
   │            │            │ Add doc   │         │
   │            │            ├──────────>│         │
   │            │            │  Success  │         │
   │            │            │<──────────┤         │
   │            │            │           │         │
   │            │            │ Real-time │         │
   │            │            │  update   │         │
   │            │            ├───────────┼────────>│
   │            │            │           │ Stream  │
   │            │            │           │ receives│
   │            │            │           │  update │
   │            │            │           │<────────┤
   │            │  Success   │           │         │
   │            │<───────────┤           │         │
   │            │            │           │         │
   │ Navigate   │            │           │         │
   │   back     │            │           │         │
   │<───────────┤            │           │         │
   │            │            │           │         │
```

---

## Deployment Architecture

### Cloud Infrastructure

```
┌──────────────────────────────────────────────────────────┐
│                   Firebase Project                        │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  ┌────────────────────────────────────────────┐          │
│  │         Firebase Authentication            │          │
│  │  • Phone number authentication             │          │
│  │  • User session management                 │          │
│  │  • Token refresh automation                │          │
│  └────────────────────────────────────────────┘          │
│                                                           │
│  ┌────────────────────────────────────────────┐          │
│  │         Cloud Firestore                    │          │
│  │  Collections:                              │          │
│  │  ├─ Men/                                   │          │
│  │  ├─ Users/                                 │          │
│  │  │   ├─ Attendance/ (subcollection)        │          │
│  │  │   └─ Statuses/ (subcollection)          │          │
│  │  ├─ Conducts/                              │          │
│  │  └─ Duties/                                │          │
│  │                                            │          │
│  │  Security Rules:                           │          │
│  │  • Role-based access control               │          │
│  │  • Field-level permissions                 │          │
│  └────────────────────────────────────────────┘          │
│                                                           │
│  ┌────────────────────────────────────────────┐          │
│  │         Cloud Storage                      │          │
│  │  • User profile images                     │          │
│  │  • Document attachments                    │          │
│  │  • Asset caching                           │          │
│  └────────────────────────────────────────────┘          │
│                                                           │
│  ┌────────────────────────────────────────────┐          │
│  │         Firebase Hosting                   │          │
│  │  • Documentation website                   │          │
│  │  • Admin dashboard (future)                │          │
│  └────────────────────────────────────────────┘          │
│                                                           │
└──────────────────────────────────────────────────────────┘

                         ▲
                         │ HTTPS/WSS
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
   ┌─────────┐     ┌─────────┐     ┌─────────┐
   │ Android │     │   iOS   │     │   Web   │
   │   App   │     │   App   │     │   App   │
   └─────────┘     └─────────┘     └─────────┘
```

### Network Architecture

```
┌─────────────────────────────────────────────────────┐
│              Mobile Devices (Clients)               │
├─────────────────────────────────────────────────────┤
│  • WiFi / Mobile Data                               │
│  • TLS 1.2+ encryption                              │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│           Content Delivery Network (CDN)            │
│              (Firebase CDN)                         │
├─────────────────────────────────────────────────────┤
│  • Global edge locations                            │
│  • Low latency                                      │
│  • DDoS protection                                  │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│            Firebase Backend Services                │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌───────────────┐  ┌───────────────┐            │
│  │ Load Balancer │  │ API Gateway   │            │
│  └───────┬───────┘  └───────┬───────┘            │
│          │                  │                     │
│          ▼                  ▼                     │
│  ┌──────────────────────────────────┐            │
│  │    Firebase Services             │            │
│  │  • Auth                           │            │
│  │  • Firestore                      │            │
│  │  • Storage                        │            │
│  └──────────────────────────────────┘            │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Scalability Design

```
Single User Request
        │
        ▼
┌───────────────┐
│   Firebase    │
│  Load Balance │
└───────┬───────┘
        │
        ▼
┌───────────────┐
│  Firestore    │
│  Auto-scales  │
│  to demand    │
└───────┬───────┘
        │
        ▼
┌───────────────┐
│  Distributed  │
│   Database    │
│   Replicas    │
└───────────────┘

Benefits:
• Automatic horizontal scaling
• Multi-region replication
• Real-time synchronization
• 99.99% uptime SLA
```

---

## Performance Considerations

### Optimization Strategies

1. **Query Optimization**
   - Use indexes for frequently queried fields
   - Limit result sets with `.limit()`
   - Implement pagination for large datasets

2. **Caching Strategy**
   - Firestore automatic caching
   - SharedPreferences for user settings
   - Stream caching to prevent duplicate subscriptions

3. **Data Loading**
   - Lazy loading with StreamBuilder
   - Efficient list rendering with ListView.builder
   - Pagination for large collections

4. **Network Efficiency**
   - Batch writes when possible
   - Minimize document reads
   - Use subcollections for hierarchical data

---

## Security Architecture

### Authentication Flow Security

```
┌─────────────────────────────────────────┐
│      Multi-layer Security               │
├─────────────────────────────────────────┤
│                                         │
│  Layer 1: Firebase Phone Auth          │
│  • OTP verification                     │
│  • Rate limiting                        │
│  • Fraud detection                      │
│                                         │
│  Layer 2: Session Management            │
│  • JWT tokens                           │
│  • Auto-refresh                         │
│  • Secure storage                       │
│                                         │
│  Layer 3: Firestore Rules               │
│  • User-level access control            │
│  • Field-level permissions              │
│  • Role-based authorization             │
│                                         │
│  Layer 4: Network Security              │
│  • TLS 1.2+ encryption                  │
│  • HTTPS only                           │
│  • Certificate pinning                  │
│                                         │
└─────────────────────────────────────────┘
```

---

<div align="center">

**TroopTrak Architecture Documentation**

For more information, see [Developer Guide](DEVELOPER_GUIDE.md) and [User Guide](USER_GUIDE.md)

Version 1.0.0 | 2024

</div>

