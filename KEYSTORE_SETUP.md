# Android Keystore Setup Guide

This document describes how to generate and configure the release signing credentials for the **elct** Flutter application.

> [!WARNING]
> **NEVER** commit `release.jks` or `local.properties` to version control (Git). They contain sensitive keys and passwords that could compromise your app's security.

---

## Step 1: Generate the Release Keystore File

Run the following command in your terminal to generate a new Java keystore (`release.jks`). Make sure you are in the project root directory when running this:

```bash
keytool -genkey -v -keystore android/keystore/release.jks -keyalias electronic -keyalg RSA -keysize 2048 -validity 10000
```

### Prompt Details:
- **Keystore destination:** `android/keystore/release.jks`
- **Key alias:** `electronic`
- **Key algorithm:** `RSA`
- **Keysize:** `2048` bits
- **Validity:** `10000` days

During the prompt, you will be asked to:
1. Choose and confirm a keystore password. (Keep this safe!)
2. Provide your name, organizational unit, organization, city, state, and country code.
3. Confirm details by typing `yes`.
4. Choose and confirm a key password (or press Enter to make it the same as the keystore password).

---

## Step 2: Configure `local.properties`

Open the `android/local.properties` file in your editor. Ensure it contains the following values (replace placeholders with the actual passwords chosen in Step 1):

```properties
storeFile=../keystore/release.jks
storePassword=YOUR_STORE_PASSWORD
keyAlias=electronic
keyPassword=YOUR_KEY_PASSWORD
```

*Note: The `storeFile` path is relative to the `android/app` directory where the Gradle build script runs.*

---

## Step 3: Validate the Configuration

Once configured, verify that you can build the release build locally:

```bash
flutter build apk --release
# OR
flutter build appbundle --release
```

Gradle will automatically load the credentials from `local.properties` and sign the generated APK/AAB with your release keystore.
