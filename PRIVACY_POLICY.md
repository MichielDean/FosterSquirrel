# Privacy Policy

**Last updated: November 9, 2025**

## Introduction

FosterSquirrel is built as a free, open-source app for wildlife rehabilitators. This app is provided at no cost and is intended for use as is.

This privacy policy explains what information FosterSquirrel collects, how it's used, and your choices regarding your data. By using FosterSquirrel, you agree to the terms described in this policy.

## Our Commitment to Your Privacy

**FosterSquirrel does not collect, transmit, or share any of your personal data.** All data you enter into the app (squirrel records, feeding schedules, care notes, weights, photos, etc.) is stored locally on your device and never leaves your device.

## Information Storage and Use

### Local Data Storage

FosterSquirrel stores all application data locally on your device using:
- **SQLite database** (via Drift library) for structured data (squirrel records, feeding logs, care notes)
- **Local file storage** (via path_provider) for photos and images
- **SharedPreferences** for app settings and preferences

**This data is never transmitted to any remote server, cloud service, or third party.** The data remains entirely under your control on your device.

### What Data is Stored Locally

The app stores the following types of data on your device:
- Squirrel information (names, species, intake dates, release dates)
- Weight measurements and tracking history
- Feeding schedules and feeding records
- Care notes and observations
- Photos you capture or select from your device
- App settings and preferences

### Data Access

Only you have access to the data stored by FosterSquirrel. The app does not:
- Send data to remote servers
- Share data with third parties
- Transmit data over the internet
- Use analytics or tracking services
- Collect crash reports or usage statistics

## Third-Party Libraries

FosterSquirrel uses the following open-source libraries to provide functionality. These libraries operate locally on your device and do not collect or transmit personal information:

### Core Flutter Framework
- **Flutter SDK** - UI framework by Google
- **Dart SDK** - Programming language runtime

### Data Storage Libraries
- **Drift** - Type-safe SQLite database wrapper (local database management)
- **sqlite3_flutter_libs** - SQLite native libraries (local database engine)
- **path_provider** - Access to device storage directories (local file access)
- **path** - File path manipulation utilities
- **shared_preferences** - Local key-value storage for settings

### User Interface Libraries
- **provider** - State management (app-side only, no network communication)
- **fl_chart** - Chart and graph rendering (visual display only)
- **animated_splash_screen** - Startup animation (visual only)
- **intl** - Internationalization and date formatting (local processing)

### Device Access Libraries
- **image_picker** - Access to device camera and photo gallery (with your permission)

### Utility Libraries
- **uuid** - Generate unique identifiers (local generation only)

**Important:** While these libraries are integrated into the app, none of them are configured to collect, transmit, or share your data with external services.

## Device Permissions

FosterSquirrel may request the following device permissions:

- **Camera** - To take photos of squirrels (photos are stored locally only)
- **Photo Gallery/Storage** - To select existing photos or save photos (local access only)
- **Storage** - To save and retrieve app data on your device (local access only)

These permissions are used solely for local functionality. No data accessed through these permissions is transmitted off your device.

## No User Accounts or Authentication

FosterSquirrel does not require user accounts, registration, email addresses, or any form of authentication. You can use the app completely anonymously.

## No Internet Connection Required

FosterSquirrel functions entirely offline and does not require an internet connection to operate. All features are available without network access.

## Data Backup and Transfer

Because all data is stored locally on your device:
- **Device uninstall** - Uninstalling the app will delete all locally stored data
- **Device loss** - If you lose your device or it's damaged, your data cannot be recovered unless you've manually backed it up using Android's backup features
- **Device transfer** - Data is not automatically transferred to new devices

We recommend using your device's built-in backup features (such as Android's backup service) if you want to preserve your data.

## Children's Privacy

FosterSquirrel does not collect any information from anyone, including children under the age of 13. Since no data is transmitted or collected by us, COPPA (Children's Online Privacy Protection Act) compliance concerns do not apply to our data practices.

However, parents and guardians should supervise children's use of the app as appropriate, particularly when using camera or photo gallery features.

## Data Security

While we do not collect or transmit your data, we take the security of your local data seriously:
- All data is stored locally on your device in an SQLite database (unencrypted by default)
- The app follows Flutter and Android security best practices
- Your data is protected by your device's security features (lock screen, device-level encryption, etc.)

**You are responsible for securing your device** using passwords, biometric authentication, and device encryption to protect the data stored by FosterSquirrel.

## No Cookies or Tracking

FosterSquirrel does not use:
- Cookies
- Web beacons
- Analytics services
- Advertising networks
- Tracking pixels
- Session recording
- Crash reporting services

## Your Data Rights

Since all your data is stored locally on your device:
- **Access** - You have complete access to all your data through the app interface
- **Modification** - You can edit or update any data at any time
- **Deletion** - You can delete individual records or all data through the app settings
- **Export** - You can take screenshots or manually transcribe your data (automated export features may be added in future versions)
- **Portability** - Your data remains on your device; you control if and how to move it

## Changes to This Privacy Policy

We may update this privacy policy from time to time to reflect changes in the app or legal requirements. Any changes will be posted in this document with an updated "Last updated" date.

We encourage you to review this policy periodically. Continued use of FosterSquirrel after changes constitutes acceptance of the updated policy.

## Open Source Transparency

FosterSquirrel is open-source software. You can review the complete source code to verify our privacy claims at:

**GitHub Repository:** https://github.com/MichielDean/FosterSquirrel

We encourage technical users to audit the code to confirm that no data collection or transmission occurs.

## Contact Us

If you have questions, concerns, or suggestions about this privacy policy or FosterSquirrel's privacy practices, please contact us:

**GitHub Issues:** https://github.com/MichielDean/FosterSquirrel/issues

---

## Summary

**In Plain English:**
- ✅ All your data stays on your device
- ✅ No data is sent to servers or the internet
- ✅ No tracking, analytics, or advertising
- ✅ No user accounts or personal information required
- ✅ Open source - you can verify these claims
- ✅ You have complete control over your data
