---
layout: default
title: TroopTrak Documentation
description: Comprehensive documentation for the TroopTrak military troop management application
---

# 🎖️ TroopTrak Documentation

<div align="center">

<img src="assets/TroopTrakAppIcon.png" alt="TroopTrak Logo" width="200" style="border-radius: 20px; margin-bottom: 20px;">

<p>
<strong>Comprehensive documentation for the TroopTrak military troop management application</strong>
</p>

<p>
<strong>Built with Flutter • Powered by Firebase • Made for Military Personnel</strong>
</p>

---

### 📚 Quick Links

[User Guide](USER_GUIDE.md) • [Developer Guide](DEVELOPER_GUIDE.md) • [Architecture](ARCHITECTURE.md)

---

</div>

## 🌟 About TroopTrak

TroopTrak is a modern, cross-platform mobile application designed to streamline military troop management operations. Built with Flutter and powered by Firebase, it provides real-time tracking of personnel, conducts, guard duties, and attendance with an intuitive user interface.

### Key Features

- 🔐 **Secure Authentication** - Phone-based OTP authentication
- 👥 **Role-Based Access** - Separate interfaces for Men and Commanders
- 📊 **Real-Time Tracking** - Live updates on all operations
- 📱 **QR Code System** - Quick identification and verification
- 🎨 **Modern UI/UX** - Beautiful dark theme with smooth animations
- ☁️ **Cloud-Based** - Reliable Firebase backend

---

## 📖 Documentation Overview

### 1. [User Guide](USER_GUIDE.html)

**For End Users**

Learn how to use TroopTrak effectively as a soldier or commander.

**Contents:**
- Getting started with the app
- Authentication and profile setup
- Navigating the main features
- Tracking conducts and guard duties
- Managing attendance and statuses
- Troubleshooting common issues
- Frequently asked questions

**Target Audience:** All TroopTrak users (Men and Commanders)

---

### 2. [Developer Guide](DEVELOPER_GUIDE.html)

**For Developers & Technical Staff**

Complete technical documentation for developing, maintaining, and deploying TroopTrak.

**Contents:**
- Project architecture and structure
- Technology stack details
- Development environment setup
- Firebase configuration
- Database schema and models
- API reference
- Code conventions and best practices
- Testing strategies
- Deployment procedures
- Security considerations
- Performance optimization

**Target Audience:** Developers, DevOps engineers, System administrators

---

### 3. [Architecture Documentation](ARCHITECTURE.html)

**For System Architects & Technical Leads**

Detailed system architecture, design patterns, and technical diagrams.

**Contents:**
- High-level system architecture
- Component diagrams
- Data flow diagrams
- Class relationships (UML)
- Sequence diagrams
- Deployment architecture
- Scalability design
- Security architecture
- Performance considerations

**Target Audience:** Architects, Technical leads, Senior developers

---

## 🚀 Quick Start

### For Users

1. **Download** the TroopTrak app from your organization's distribution channel
2. **Install** on your Android or iOS device
3. **Open** the app and select your role (Men or Commander)
4. **Authenticate** using your phone number
5. **Complete** your profile setup
6. **Start** managing your troop operations!

👉 [Read the full User Guide](USER_GUIDE.html)

### For Developers

```bash
# Clone the repository
git clone <repository-url>
cd firebase_project_2

# Install dependencies
flutter pub get

# Configure Firebase
flutterfire configure

# Run the app
flutter run
```

👉 [Read the full Developer Guide](DEVELOPER_GUIDE.html)

---

## 📱 Application Overview

### Main Modules

<div style="display: flex; flex-wrap: wrap; gap: 20px;">

<div style="flex: 1; min-width: 250px; border: 2px solid #8147e6; border-radius: 10px; padding: 20px;">

#### 👤 My Profile
- View personal information
- Track attendance history
- Manage medical statuses
- Generate QR code
- Update profile details

</div>

<div style="flex: 1; min-width: 250px; border: 2px solid #8147e6; border-radius: 10px; padding: 20px;">

#### 📊 Conduct Tracker
- View scheduled conducts
- Check participation status
- See participation statistics
- Filter by date
- Access conduct details

</div>

<div style="flex: 1; min-width: 250px; border: 2px solid #8147e6; border-radius: 10px; padding: 20px;">

#### 🛡️ Guard Duty Tracker
- View duty assignments
- Check points leaderboard
- See upcoming duties
- Track duty history
- Manage duty roster (Commanders)

</div>

</div>

---

## 🏗️ Technology Stack

<div align="center">

| Category | Technologies |
|----------|-------------|
| **Frontend Framework** | Flutter 2.19.6+ |
| **Programming Language** | Dart |
| **Backend Services** | Firebase (Auth, Firestore, Storage) |
| **State Management** | Provider Pattern |
| **Authentication** | Firebase Phone Authentication |
| **Database** | Cloud Firestore (NoSQL) |
| **UI/UX** | Material Design, Google Fonts |
| **Charts & Graphs** | FL Chart |
| **QR Code** | qr_flutter, mobile_scanner |

</div>

---

## 📊 System Architecture

```
┌─────────────────────────────────────────┐
│         Mobile Applications             │
│     (Android, iOS, Web, Desktop)        │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│         Flutter Framework               │
│  • Material Widgets                     │
│  • Provider State Management            │
│  • Navigation & Routing                 │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│         Application Layer               │
│  • Authentication                       │
│  • Conduct Management                   │
│  • Guard Duty Management                │
│  • Profile Management                   │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│         Firebase Services               │
│  • Authentication                       │
│  • Cloud Firestore                      │
│  • Cloud Storage                        │
│  • Firebase Hosting                     │
└─────────────────────────────────────────┘
```

👉 [View detailed architecture](ARCHITECTURE.html)

---

## 🔒 Security Features

- **🔐 Multi-Factor Authentication** - Phone number + OTP verification
- **🛡️ Role-Based Access Control** - Separate permissions for Men and Commanders
- **🔒 Encrypted Communications** - TLS 1.2+ for all data transmission
- **📝 Audit Logging** - All critical operations tracked
- **⚡ Real-Time Security Rules** - Firestore security rules enforce access control
- **🔑 Session Management** - Automatic token refresh and secure logout

---

## 📈 Features by Role

### For Men (CFC and Below)

- ✅ View own profile and details
- ✅ Track personal attendance (book in/out)
- ✅ View assigned conducts and participation status
- ✅ Check guard duty schedule
- ✅ View guard duty points ranking
- ✅ Generate and display QR code
- ✅ View medical statuses and leaves

### For Commanders (3SG and Above)

- ✅ All Men features, plus:
- ✅ View entire troop roster
- ✅ Create and manage conducts
- ✅ Assign guard duty personnel
- ✅ View all personnel statuses
- ✅ Edit troop information
- ✅ Access analytics and reports
- ✅ Scan QR codes for verification
- ✅ Auto-filter excused personnel

---

## 🎨 User Interface

### Design Principles

- **🌙 Dark Theme First** - Modern dark theme with purple accents
- **📱 Mobile-Optimized** - Responsive design for all screen sizes
- **⚡ Smooth Animations** - Fluid transitions and micro-interactions
- **🎯 Intuitive Navigation** - Bottom navigation with clear labels
- **📊 Visual Data** - Charts and graphs for quick insights
- **♿ Accessibility** - High contrast and readable fonts

### Color Palette

- **Primary:** `#8147E6` (Purple)
- **Dark Background:** `#151922`
- **Card Background:** `#212836`
- **Accent:** `#481EE5` (Dark Purple)
- **Success:** Green
- **Error:** Red

---

## 📱 Supported Platforms

| Platform | Minimum Version | Status |
|----------|----------------|--------|
| **Android** | 6.0 (API 23) | ✅ Supported |
| **iOS** | 11.0 | ✅ Supported |
| **Web** | Modern Browsers | ⚠️ Beta |
| **Windows** | Windows 10+ | 🚧 In Development |
| **macOS** | 10.14+ | 🚧 In Development |
| **Linux** | Ubuntu 18.04+ | 🚧 In Development |

---

## 📚 Database Schema

### Firestore Collections

```
firestore/
├── Men/                    # User profiles
│   └── {uid}/             
│       ├── name
│       ├── rank
│       └── ...
│
├── Users/                  # Main user data
│   └── {name}/            
│       ├── Attendance/     # Subcollection
│       └── Statuses/       # Subcollection
│
├── Conducts/              # Training events
│   └── {conductId}/
│
└── Duties/                # Guard duty assignments
    └── {dutyId}/
```

👉 [View complete database schema](DEVELOPER_GUIDE.html#database-schema)

---

## 🧪 Testing

The project includes comprehensive testing:

- **Unit Tests** - Model and business logic testing
- **Widget Tests** - UI component testing
- **Integration Tests** - End-to-end flow testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

---

## 🚀 Deployment

### Production Build

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ipa --release
```

### Version Management

Current Version: **1.0.0+1**

Versioning format: `MAJOR.MINOR.PATCH+BUILD_NUMBER`

---

## 📞 Support & Resources

### Documentation

- 📖 [User Guide](USER_GUIDE.md) - For end users
- 💻 [Developer Guide](DEVELOPER_GUIDE.md) - For developers
- 🏛️ [Architecture](ARCHITECTURE.md) - For architects

### External Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Dart Language](https://dart.dev/)
- [Provider Package](https://pub.dev/packages/provider)

### Community

- [Flutter Community](https://flutter.dev/community)
- [Firebase Discord](https://discord.gg/firebase)
- [Stack Overflow - Flutter](https://stackoverflow.com/questions/tagged/flutter)

---

## 📝 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024 | Initial release with core features |

---

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write/update tests
5. Update documentation
6. Submit a pull request

👉 [Read Contributing Guidelines](DEVELOPER_GUIDE.md#-contributing-guidelines)

---

## 📄 License

This project is proprietary software for military use. All rights reserved.

---

## 🙏 Acknowledgments

Built with:
- [Flutter](https://flutter.dev/) - Google's UI toolkit
- [Firebase](https://firebase.google.com/) - Google's backend platform
- [Provider](https://pub.dev/packages/provider) - State management
- And many other amazing open-source packages!

---

<div align="center">

## 📚 Documentation Index

<table>
<tr>
<th>Document</th>
<th>Description</th>
<th>Target Audience</th>
</tr>
<tr>
<td><a href="USER_GUIDE.html">User Guide</a></td>
<td>Complete guide for using TroopTrak</td>
<td>All Users</td>
</tr>
<tr>
<td><a href="DEVELOPER_GUIDE.html">Developer Guide</a></td>
<td>Technical documentation for development</td>
<td>Developers</td>
</tr>
<tr>
<td><a href="ARCHITECTURE.html">Architecture</a></td>
<td>System design and architecture diagrams</td>
<td>Architects</td>
</tr>
</table>

---

<p>
<strong>TroopTrak Documentation</strong>
</p>

<img src="assets/BladesOfOlympusLogo.png" alt="Blades of Olympus" width="150" style="margin: 20px 0;">

Made with ❤️ for military personnel

<p>
<strong>Built with Flutter • Powered by Firebase</strong>
<strong>Version 1.0.0 | Last Updated: 2024</strong>
</p>

</div>

