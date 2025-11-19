---
layout: default
title: User Guide - TroopTrak Documentation
permalink: /USER_GUIDE/
---

# 🎖️ TroopTrak User Guide

<div align="center">

<img src="{{ site.baseurl }}/assets/TroopTrakAppIcon.png" alt="TroopTrak Logo" width="150" style="border-radius: 20px; margin-bottom: 20px;">

<p>
<strong>A comprehensive mobile application for military troop management and tracking</strong>
</p>

<p>
<strong>Version 1.0.0 • Flutter Platform • Military Management</strong>
</p>

<p>
<a href="{{ site.baseurl }}/">🏠 Home</a> • <a href="#-features">Features</a> • <a href="#-getting-started">Getting Started</a> • <a href="#-user-roles">User Roles</a> • <a href="#-main-modules">Main Modules</a> • <a href="#-faq">FAQ</a>
</p>

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [User Roles](#-user-roles)
- [Getting Started](#-getting-started)
  - [Installation](#installation)
  - [First-Time Setup](#first-time-setup)
  - [Phone Authentication](#phone-authentication)
- [Main Modules](#-main-modules)
  - [My Profile](#1-my-profile)
  - [Conduct Tracker](#2-conduct-tracker)
  - [Guard Duty Tracker](#3-guard-duty-tracker)
- [Common Tasks](#-common-tasks)
- [Troubleshooting](#-troubleshooting)
- [FAQ](#-faq)

---

## 🌟 Overview

**TroopTrak** is a modern mobile application designed to streamline military troop management operations. Built with Flutter and Firebase, it provides real-time tracking of personnel, conducts, guard duties, and attendance in an intuitive and user-friendly interface.

### Key Highlights

- 🔐 **Secure Phone Authentication** - OTP-based login system
- 👥 **Dual Role System** - Separate interfaces for Men and Commanders
- 📊 **Real-time Tracking** - Live updates on conducts and duties
- 📱 **QR Code Integration** - Quick identification and check-in
- 🎨 **Modern UI/UX** - Dark theme with purple accent colors
- ☁️ **Cloud-Based** - Firebase backend for reliability

---

## ✨ Features

### For All Users

| Feature | Description |
|---------|-------------|
| 📱 **User Profile Management** | View and manage personal information including rank, appointment, company details |
| 📊 **Attendance Tracking** | Monitor book-in/book-out status with timestamp history |
| 🏥 **Status Management** | Track medical statuses, leaves, and excuses |
| 📅 **Conduct Participation** | View assigned conducts and participation status |
| 🛡️ **Guard Duty Schedule** | Check upcoming guard duty assignments |
| 🔢 **Points System** | Track guard duty points on leaderboard |
| 📲 **QR Code Generation** | Generate personal QR code for quick identification |

### Commander-Specific Features

- 👨‍✈️ **Troop Management** - Full roster access and management
- 📝 **Conduct Creation** - Schedule and manage military conducts
- 🎯 **Duty Assignment** - Assign and track guard duty personnel
- 📈 **Analytics Dashboard** - View participation statistics and charts
- ✅ **Attendance Management** - Track and verify troop attendance

---

## 👤 User Roles

TroopTrak supports two distinct user roles:

### 1. **Men** (Rank: CFC and Below)

> **Access Level:** Standard User
> 
> **Available Features:**
> - View own profile and details
> - Track personal attendance
> - View assigned conducts
> - Check guard duty schedule
> - Generate personal QR code
> - View guard duty points

### 2. **Commanders** (Rank: 3SG and Above)

> **Access Level:** Administrative User
> 
> **Available Features:**
> - All Men features plus:
> - Manage entire troop roster
> - Create and edit conducts
> - Assign guard duties
> - View all personnel statuses
> - Access analytics and reports
> - Scan QR codes for verification

---

## 🚀 Getting Started

### Installation

#### Prerequisites
- Android device (Android 6.0 or higher) or iOS device (iOS 11.0 or higher)
- Active internet connection
- Valid phone number for authentication

#### Download & Install

1. **Android:**
   - Download the APK file
   - Enable "Install from Unknown Sources" in Settings
   - Install the application
   - Grant required permissions (Camera, Storage)

2. **iOS:**
   - Install from TestFlight or App Store
   - Grant required permissions when prompted

### First-Time Setup

#### Step 1: Role Selection

Upon first launch, you'll be presented with a role selection screen.

```
┌─────────────────────────────────────┐
│       Please pick your role         │
├─────────────────────────────────────┤
│                                     │
│  ┌──────────┐    ┌──────────┐       │
│  │   Men    │    │Commanders│       │
│  │ CFC and  │    │ 3SG or   │       │
│  │  below   │    │  higher  │       │
│  └──────────┘    └──────────┘       │
│                                     │
└─────────────────────────────────────┘
```

**Choose your role:**
- Select **"Men"** if your rank is REC, PTE, LCP, CPL, CFC, or SCT
- Select **"Commanders"** if your rank is 3SG or higher

#### Step 2: Phone Authentication

1. **Enter Phone Number**
   - Select your country code (default: +65 for Singapore)
   - Enter your mobile number
   - Tap "GET STARTED" or "Send OTP"

2. **Verify OTP**
   - A 6-digit OTP will be sent to your phone
   - Enter the OTP code
   - Wait for automatic verification

3. **Complete Profile**
   
   Fill in the following mandatory information:

   | Field | Description | Example |
   |-------|-------------|---------|
   | **Name** | Full name as per NRIC | John Tan Wei Ming |
   | **Rank** | Current military rank | CPL |
   | **Company** | Unit company | Alpha |
   | **Platoon** | Platoon number | 1 |
   | **Section** | Section number | 3 |
   | **Appointment** | Current role/appointment | Rifleman |
   | **Date of Birth** | DOB in DD/MM/YYYY | 15/03/1999 |
   | **Enlistment Date** | Date joined NS | 10/01/2018 |
   | **ORD Date** | Operationally Ready Date | 09/01/2020 |
   | **Blood Group** | Blood type | B+ |
   | **Ration Type** | Dietary requirements | No Pork |

4. **Submit & Access**
   - Tap "REGISTER" to complete setup
   - You'll be redirected to the main application

---

## 📱 Main Modules

### 1. My Profile

The **My Profile** module displays your personal information and provides quick access to essential features.

#### Profile Header

- **Display Name & Rank Badge**
- **Appointment** - Current role/position
- **Company, Platoon & Section** - Unit details
- **QR Code Button** - Tap to generate/display your QR code

#### Three Information Tabs

##### 📋 Tab 1: Basic Info

Displays your core personal information:

```
╔═══════════════════════════════════╗
║         BASIC INFORMATION         ║
╠═══════════════════════════════════╣
║ Date of Birth:    15 Mar 1999     ║
║ Enlistment Date:  10 Jan 2018     ║
║ ORD Date:         09 Jan 2020     ║
║ Blood Group:      B+              ║
║ Ration Type:      No Pork         ║
╚═══════════════════════════════════╝
```

**Features:**
- View all personal details
- Information is read-only for Men
- Commanders can edit troop details

##### ⚠️ Tab 2: Statuses

Track medical conditions, leaves, and excuses:

```
┌─────────────────────────────────────┐
│  Current & Upcoming Statuses        │
├─────────────────────────────────────┤
│  🏥 Medical Leave                   │
│  Start: 01 Jan 2024                 │
│  End:   03 Jan 2024                 │
│  Status: Active                     │
├─────────────────────────────────────┤
│  🩹 Excuse Boots                    │
│  Start: 05 Jan 2024                 │
│  End:   15 Jan 2024                 │
│  Status: Active                     │
└─────────────────────────────────────┘
```

**Status Types:**
- **Excuse** - Medical excuses (Ex Boots, Ex Uniform, etc.)
- **Leave** - Various leave types (Annual, Medical, etc.)
- **Other** - Special statuses

**Information Displayed:**
- Status name and type
- Start and end dates
- Current status (Active/Expired)
- Remarks (if any)

##### 📅 Tab 3: Attendance

View your book-in and book-out history:

```
╔═══════════════════════════════════╗
║      ATTENDANCE HISTORY           ║
╠═══════════════════════════════════╣
║ 📍 BOOKED IN                      ║
║    10 Jan 2024, 08:30             ║
║    Status: In Camp                ║
╟───────────────────────────────────╢
║ 📍 BOOKED OUT                     ║
║    09 Jan 2024, 18:00             ║
║    Status: Left Camp              ║
╟───────────────────────────────────╢
║ 📍 BOOKED IN                      ║
║    08 Jan 2024, 08:15             ║
║    Status: In Camp                ║
╚═══════════════════════════════════╝
```

**Features:**
- Chronological attendance log
- Book-in and book-out timestamps
- Current camp status indicator
- Complete history available

#### 📲 QR Code Feature

Tap the "SHOW QR CODE" button in the profile header to display your personal QR code.

**Uses:**
- Quick identification
- Attendance verification
- Conduct participation tracking
- Guard duty check-in

---

### 2. Conduct Tracker

The **Conduct Tracker** module helps you monitor military conducts (training activities, exercises, events).

#### Main Screen Layout

```
┌─────────────────────────────────────────┐
│        Conduct Tracker                  │
├─────────────────────────────────────────┤
│  📅  Date Selector                      │
│  [< 09 Jan    10 Jan    11 Jan >]       │
├─────────────────────────────────────────┤
│  📊 Participation Strength              │
│  [Bar Chart showing participation]      │
├─────────────────────────────────────────┤
│  📋 Conducts Completed / Ongoing        │
│                                         │
│  ┌───────────────────────────────┐     │
│  │ 🎯 Field Training Exercise    │     │
│  │    Type: Training             │     │
│  │    ✓ You are participating    │     │
│  └───────────────────────────────┘     │
│                                         │
│  ┌───────────────────────────────┐     │
│  │ 🏃 Physical Training          │     │
│  │    Type: PT                   │     │
│  │    ✓ You are participating    │      │
│  └───────────────────────────────┘      │
└─────────────────────────────────────────┘
```

#### Features Explained

##### 📅 Date Navigation

- **Horizontal Date Picker** - Swipe left/right to browse dates
- **Calendar Icon** - Tap to jump to specific date
- **Today Indicator** - Highlighted current date

##### 📊 Participation Chart

Visual bar graph showing:
- Number of participants per conduct
- Total troop strength comparison
- Participation rates

##### 📋 Conduct Cards

Each conduct displays:
- **Conduct Name** - Activity title
- **Conduct Type** - Category (Training, Exercise, Admin, etc.)
- **Participation Status** - Whether you're assigned
- **Time Details** - Start and end times (in detail view)

##### Conduct Details View

Tap any conduct card to view full details:

```
╔════════════════════════════════════╗
║   FIELD TRAINING EXERCISE          ║
╠════════════════════════════════════╣
║ Type:       Training               ║
║ Date:       10 Jan 2024            ║
║ Start Time: 08:00                  ║
║ End Time:   17:00                  ║
╟────────────────────────────────────╢
║ PARTICIPANTS (25/30)               ║
╟────────────────────────────────────╢
║ ✓ CPL John Tan                    ║
║ ✓ PTE Sarah Lee                   ║
║ ✓ LCP Mike Wong                   ║
║ ...                                ║
╟────────────────────────────────────╢
║ NON-PARTICIPANTS (5)               ║
╟────────────────────────────────────╢
║ ❌ PTE David Lim (Medical Leave)   ║
║ ❌ CPL Alex Koh (Excuse Boots)     ║
║ ...                                ║
╚════════════════════════════════════╝
```

**Commander Features:**
- Add/remove participants
- Edit conduct details
- Delete conduct
- Mark participation status

---

### 3. Guard Duty Tracker

The **Guard Duty Tracker** manages duty assignments and points tracking.

#### Two Main Tabs

##### 📊 Tab 1: Points Leaderboard

View the guard duty points ranking:

```
╔════════════════════════════════════╗
║     GUARD DUTY LEADERBOARD         ║
╠════════════════════════════════════╣
║ #1  🥇 CPL Sarah Lee      25 pts   ║
║ #2  🥈 LCP Mike Wong      23 pts   ║
║ #3  🥉 CPL John Tan       20 pts   ║
║ #4     PTE Alex Koh       18 pts   ║
║ #5     PTE David Lim      15 pts   ║
║ ...                                ║
╚════════════════════════════════════╝
```

**Features:**
- Real-time points ranking
- Medal indicators for top 3
- Your position highlighted
- Sortable by points

**Points System:**
- Points awarded per duty completed
- Automatic calculation
- Fair distribution algorithm

##### 📅 Tab 2: Upcoming Duties

View scheduled guard duties:

```
┌─────────────────────────────────────────┐
│         Today's Duties                  │
├─────────────────────────────────────────┤
│  📅  Date: 10 Jan 2024                 │
├─────────────────────────────────────────┤
│  ┌───────────────────────────────┐     │
│  │ 🛡️ Guard Duty Alpha            │     │
│  │                                │     │
│  │ Time: 00:00 - 08:00            │     │
│  │ Location: Main Gate            │     │
│  │                                │     │
│  │ 👤 CPL John Tan (Commander)    │     │
│  │ 👤 PTE Mike Lee                │     │
│  │ 👤 PTE Sarah Ng                │     │
│  └───────────────────────────────┘     │
│                                         │
│  ┌───────────────────────────────┐     │
│  │ 🛡️ Guard Duty Bravo            │     │
│  │                                │     │
│  │ Time: 08:00 - 16:00            │     │
│  │ Location: Armory               │     │
│  │                                │     │
│  │ 👤 CPL Alex Koh (Commander)    │     │
│  │ 👤 LCP David Tan               │     │
│  └───────────────────────────────┘     │
└─────────────────────────────────────────┘
```

**Information Displayed:**
- Duty date and time slots
- Duty location/post
- Assigned personnel with roles
- Duty commander designation

**Features:**
- Date selector (same as Conduct Tracker)
- Filter by date range
- View past and future duties
- Your assignments highlighted

**Commander Features:**
- Create new duty assignments
- Edit existing duties
- Assign personnel
- Auto-filter excused personnel (Ex Uniform, Ex Boots)

---

## 💡 Common Tasks

### How to View My Profile

1. Launch TroopTrak app
2. You'll land on **My Profile** tab by default
3. Scroll to view all information
4. Tap tabs to switch between Basic Info, Statuses, and Attendance

### How to Check My Guard Duty Schedule

1. Navigate to **Guard Duty** tab (bottom navigation)
2. Tap **Upcoming Duties** tab
3. Select date to view duties
4. Look for your name in the duty roster
5. Note the time slot and location

### How to Display My QR Code

1. Go to **My Profile** tab
2. Tap the **"SHOW QR CODE"** button (center of profile header)
3. QR code will display in a popup
4. Present to scanner for verification
5. Tap outside to close

### How to View Conduct Details

1. Navigate to **Conduct Tracker** tab
2. Select the date (if not today)
3. Tap on any conduct card
4. View full details, participants, and timings
5. Tap back button to return

### How to Check Participation Status

1. Go to **Conduct Tracker**
2. Look for the indicator on conduct cards:
   - ✓ **Green checkmark** = You are participating
   - ❌ **No indicator** = You are not participating
3. For detailed list, tap the conduct card

### How to Track My Attendance History

1. Go to **My Profile** → **Attendance** tab
2. Scroll through chronological list
3. View book-in/out times and dates
4. Current status shown at top

### How to Sign Out

1. Go to **My Profile** tab
2. Tap the **Exit Icon** (↗️) at top-right corner
3. Confirm sign out
4. You'll return to welcome screen

---

## 🔧 Troubleshooting

### Authentication Issues

#### Problem: Not receiving OTP

**Solutions:**
-  Check phone number is correct (including country code)
-  Ensure stable internet connection
-  Check SMS inbox and spam folder
-  Wait 60 seconds before requesting new OTP
-  Verify phone number can receive SMS

#### Problem: OTP verification fails

**Solutions:**
-  Enter OTP exactly as received (6 digits)
-  OTP expires after 60 seconds - request new one
-  Check for typos in OTP entry
-  Restart app if persistent issue

### Loading Issues

#### Problem: Data not loading / infinite loading

**Solutions:**
-  Check internet connection (WiFi/Mobile data)
-  Pull down to refresh screen
-  Force close and restart app
-  Clear app cache (Settings → Apps → TroopTrak → Clear Cache)
-  Reinstall app if issue persists

#### Problem: Profile information not displaying

**Solutions:**
-  Ensure profile setup was completed
-  Check Firebase connection
-  Sign out and sign in again
-  Contact commander/administrator

### Display Issues

#### Problem: QR code not generating

**Solutions:**
-  Ensure profile information is complete
-  Check internet connection
-  Refresh profile page
-  Sign out and sign back in

#### Problem: Charts/graphs not displaying

**Solutions:**
-  Ensure conducts exist for selected date
-  Refresh page by pulling down
-  Check internet connection
-  Restart app

### Navigation Issues

#### Problem: Can't switch between tabs

**Solutions:**
-  Tap directly on tab text/icon
-  Restart app if unresponsive
-  Check for app updates

#### Problem: Back button not working

**Solutions:**
-  Use device back button (Android)
-  Use in-app back arrow
-  Restart app if stuck

---

## ❓ FAQ

### General Questions

**Q: Who can use TroopTrak?**  
A: TroopTrak is designed for military personnel. Both enlisted men (CFC and below) and commanders (3SG and above) can use the app with different access levels.

**Q: Is internet connection required?**  
A: Yes, TroopTrak requires an active internet connection as it uses Firebase cloud database for real-time synchronization.

**Q: Is my data secure?**  
A: Yes, TroopTrak uses Firebase Authentication and Firestore with security rules. All data is encrypted in transit and at rest.

**Q: Can I use TroopTrak on multiple devices?**  
A: Yes, you can sign in on multiple devices using the same phone number. Your data will sync across devices.

### Account & Authentication

**Q: Can I change my phone number?**  
A: Currently, phone numbers cannot be changed in-app. Contact your administrator for account modifications.

**Q: What if I lose my phone?**  
A: You can sign in on a new device using your registered phone number. Your data is stored in the cloud.

**Q: How do I update my profile information?**  
A: For Men, profile information is managed by Commanders. If you need updates, contact your unit commander.

**Q: Can I delete my account?**  
A: Contact your unit administrator or commander for account deletion requests.

### Features & Functionality

**Q: How are guard duty points calculated?**  
A: Points are automatically assigned based on duty completion. The system uses a fair distribution algorithm.

**Q: Can I see other soldiers' profiles?**  
A: Men can only view their own profiles. Commanders have access to all troop profiles.

**Q: What types of conducts are tracked?**  
A: All conducts including training exercises, physical training, administrative tasks, and special events.

**Q: How do I know if I'm assigned to a conduct?**  
A: Check the Conduct Tracker - assigned conducts will show "✓ You are participating".

**Q: What if I'm excused from guard duty?**  
A: If you have valid medical excuses (Ex Boots/Ex Uniform), you'll be automatically excluded from guard duty assignments.

**Q: Can I request leave through TroopTrak?**  
A: Currently, TroopTrak displays statuses but leave requests must be done through official channels. Commanders update status information.

### Technical Questions

**Q: What devices are supported?**  
A: TroopTrak supports:
- Android 6.0 (API 23) and above
- iOS 11.0 and above

**Q: How much storage does the app require?**  
A: Approximately 50-100 MB depending on cached data.

**Q: Why is the app slow?**  
A: Slow performance can be due to:
- Poor internet connection
- Device memory constraints
- Outdated app version
- Solution: Check connection, clear cache, or update app

**Q: What permissions does TroopTrak need?**  
A: Required permissions:
- 📱 **Phone** - For SMS OTP verification
- 📷 **Camera** - For QR code scanning (Commanders only)
- 💾 **Storage** - For caching data

### Support & Contact

**Q: Who do I contact for issues?**  
A: 
1. Technical issues: Contact your unit IT support
2. Profile/data issues: Contact your unit commander
3. App bugs: Report through official channels

**Q: How do I report a bug?**  
A: Contact your unit administrator with:
- Description of issue
- Steps to reproduce
- Screenshots if possible
- Device model and OS version

**Q: Is there a user manual?**  
A: Yes, this document serves as the complete user guide. Keep it handy for reference.

---

## 📞 Support

For additional support:

- 📧 **Email**: trooptrak@gmail.com
- 📱 **Contact**: Unit IT Support
- 📖 **Documentation**: [Developer Guide]({{ site.baseurl }}/DEVELOPER_GUIDE/)

---

## 📄 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024 | Initial release with core features |

---

<div align="center">

<p>
<strong>TroopTrak</strong> - Streamlining Military Troop Management
</p>

<p>
Made with ❤️ for military personnel
</p>

<p>
<a href="https://firebase.google.com/"><img src="https://img.shields.io/badge/Firebase-FFCA28?style=flat&logo=firebase&logoColor=black" alt="Firebase"></a>
<a href="https://flutter.dev/"><img src="https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white" alt="Flutter"></a>
</p>

</div>

