# Road Mobile

Flutter application for mobile EV transactions.

## Adding a White Labeled version

Also known as _flavors_ these are spin off white labeled apps in Google Play Store, Apple App Store, and corresponding Firebase Apps. Each app corresponds to a Provider in the road platform.

Note: Each app will need its own onboarding with the customer on the app stores. See Confluence for this.

### Step 1: Configure a new app in Apple and Google Play accounts

Create the app in the Apple and Google play accounts. Try to stick to a reverse DNS format for the app id. i.e. com.elexon.ios
and com.elexon.android

### Step 2: Create a new Firebase project for both apps.

This is used for internal app distribution, crashlytics and analytics. Download the config files - they will be needed in the
next step.

### Step 3: Base config

Add a flavor directory (such as eFlux or Elexon), add a directory under flavors with the following contents:

- android_splash_screen_logo.png - Transparent backed Android launch screen logo png @ 1152x1152 with logo not exceeding 720px circle.
- google-services.json - Firebase config for Android
- GoogleService-Info.plist - Firebase config for iOS
- icon_1024.png - App Icon
- splash_screen_background.png - Scalable background for iOS launch screen
- splash_screen_logo.png - Transparent backed iOS launch screen logo

Add an entry in flavorizr.yaml for the new flavor, matching the existing format for other flavors., then run the flavorizr generator:

```
dart run flutter_flavorizr -p assets:download,assets:extract,android:androidManifest,android:buildGradle,android:icons,ios:xcconfig,ios:buildTargets,ios:schema,ios:icons,ios:plist,google:firebase,assets:clean,ide:config
```

### Step 4: Generate native splash screens

Create and configure a flutter_native_splash-flavorname.yaml file, then generate the splash screens:

```
dart run flutter_native_splash:create --flavors <flavor name>
```

Drag the generated splash screen storyboard file into the XCode project alongside the other storyboards. NB - The Splash Storyboard will be in the same location as the other Storyboard's, it just won't have been added to XCode. Make sure it is added to the build. Configure the new flavor's LAUNCH_SCREEN_STORYBOARD in build settings to reference the new storyboard file.

### Step 5: Configure runtime flavors

Add a new flavor to the Flavor enum in flavors.dart. All the runtime flavor switch statements will now generate an error, as the
runtime flavor information will be missing. Fill in the missing values (color information, app name etc) in these enums.

### Step 6: Generate an Android keypair

Modify the flavor names below to the new flavor:

```
keytool -genkey -v -keystore opcharge-ev.keystore -alias opchargeKeyAlias -keyalg RSA -keysize 2048 -validity 30000
```

You can extract the SHA fingerprints from the keystore with:

```
keytool -list -v -alias opchargeKeyAlias -keystore fastlane/opcharge-ev.keystore
```

### Step 7: Configure Google API Credentials

Note: This is done by Dominiek at the moment.

Open the "Credentials" section in Google Cloud's "APIs & Services": https://console.cloud.google.com/apis/credentials?project=eflux-production

Add the Android app ID and the SHA1 to the `Road App - Android` API Key.
Add the iOS app ID to the `Road App - iOS` API Key.

Note: If Google Play re-signs the app after if is uploaded (as is now a requirement) then the Google controlled SHA-1 key will also need to be whitelisted in the portal. You may not be able to see this until after the app is first uploaded to Google Play for distribution.

The map will be blank, and Google Places will not work until the new app ID's are whitelisted in the Google Services account.

### Step 8: Add Fastlane build configuration entries

Modify ios/fastlane/Fastfile and android/fastlane/Fastfile to include a build entry for the new flavor. Copy/paste an existing
entry. Do not forget to add an entry to the "build all" and "build all whitelabel" sections.

### Step 9: Temporary step - additional XCode settings

Turn on "Allow Non-modular includes in Framework Modules" for the new project. This is an issue related to current versions of CocoaPods.

Add the new format XCode light/dark/tinted icons to the project. Once Flavorizer is updated to handle these icons, this should no longer be necessary.

### Step 10: Add the Firebase push notifications token to the Firebase project

In the Apple Store console, create a push notifications key. Download the key.

In the Firebase project, go to Project Settings -> Cloud Messaging. Select the iOS app. Add the APNs Authentication Key.

### Step 11: Configure Apple Pay certificate

Create the merchant.io.road (customise this to match the app ID, stripping off the .ios). Upload the certificate to Checkout.

### Step 12: Configure CarPlay and Android Auto Support

CarPlay and Android Auto allow users to view nearby charging stations and navigate to them from their car's infotainment display. Follow these steps to enable these features for a new white-label app.

#### iOS CarPlay Setup

1. **Request CarPlay Entitlement from Apple** (Required - this is a restricted entitlement)
   - Log in to the Apple Developer Portal
   - Navigate to "Certificates, Identifiers & Profiles" → "Identifiers"
   - Select the app's App ID
   - Under "Additional Capabilities", enable "CarPlay (EV Charging)"
   - Apple must approve this request before the entitlement will work

2. **Add CarPlay Entitlement to the Flavor's Entitlements File**

   Edit `ios/Runner/Runner-<flavor>.entitlements` and add the following key inside the `<dict>` element:

   ```xml
   <key>com.apple.developer.carplay-charging</key>
   <true/>
   ```

   For example, see `ios/Runner/Runner-eflux.entitlements` as a reference.

3. **Regenerate Provisioning Profiles**

   After Apple approves the CarPlay entitlement, regenerate the provisioning profiles in the Apple Developer Portal and download the updated profiles.

#### Android Auto Setup

1. **Create Automotive App Descriptor**

   Create the directory and file:
   ```
   android/app/src/<flavor>/res/xml/automotive_app_desc.xml
   ```

   With the following content:
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <automotiveApp>
       <uses name="template"/>
   </automotiveApp>
   ```

2. **Verify Android Manifest** (Usually no action needed)

   The main `AndroidManifest.xml` already contains the Android Auto service registration. This is shared across all flavors, so no flavor-specific changes are needed.

#### Testing CarPlay and Android Auto

- **iOS Simulator**: Use the CarPlay Simulator in Xcode (I/O → External Displays → CarPlay). Note: This only works with the app running in the iOS Simulator, not with a physical device.
- **iOS Physical Device**: Use the standalone CarPlay Simulator app (available in Additional Tools for Xcode from Apple Developer downloads). Connect your physical iPhone via USB and the simulator will mirror CarPlay.
- **Android Emulator**: Use Android Automotive OS emulator or DHU (Desktop Head Unit)
- **Physical Devices**: Connect to a vehicle with CarPlay/Android Auto support

### Step 13: Add App Links / Universal Link support to the apps.

For Android apps, create a android/app/src/<flavor name>/AndroidManifest.xml. Copy and modify the existing e-flux one, changing:

android:pathPrefix="/e-flux"

to 

android:pathPrefix="<provider slug>"

Setup universal link support in the iOS project in a similar way to the E-Flux app.

Note: When we want to support app links, we also need to update the following files:

https://app.road.io/.well-known/apple-app-site-association
https://app.road.io/.well-known/assetlinks.json

### Step 14: Build the new flavor

Make sure to clean everything prior to building, with

```
flutter clean
flutter pub get
dart run phrase
```

Failure to do so will result in Podfile installation errors.

### Step 15: Configure device attestation (Firebase App Check)

The app attests itself on login and signup (Play Integrity on Android, App Attest on
iOS, via Firebase App Check) and sends the resulting token as `X-Firebase-AppCheck`.
The backend verifies it per provider. Attestation fails open in the app: a flavor that
skips this step still works, but its traffic is unattested and cannot be bot-protected.

In the flavor's Firebase project:

1. Firebase console -> App Check -> Apps: register both apps. Select Play Integrity as
   the Android provider and App Attest as the iOS provider.
2. Firebase console -> Project Settings -> General -> the Android app: add the SHA-256
   certificate fingerprints of the Play App Signing key (Play Console -> Test and
   release -> Setup -> App signing) and of the upload keystore from Step 6.
3. Play Console -> App integrity needs no setup: Firebase requests Play Integrity
   verdicts on the app's behalf, so the "Play Integrity API" services listed there can
   all stay off. That page only matters if a backend ever integrates the Play Integrity
   API directly to consume raw verdicts (e.g. sampling device-integrity levels across
   real traffic before raising the App Check enforcement bar).
4. Register debug tokens (App Check -> app -> Manage debug tokens) for development
   devices and CI. Debug and profile builds use the App Check debug provider; release
   builds attest for real.

Ensure the iOS flavor entitlements file (`ios/Runner/Runner-<flavor>.entitlements`)
contains the App Attest entitlement present in the existing flavors:

```
<key>com.apple.developer.devicecheck.appattest-environment</key>
<string>production</string>
```

Finally, send the platform team the provider slug, the Firebase project number, and
both Firebase app IDs (from google-services.json / GoogleService-Info.plist) so the
API's `ATTESTATION_PROVIDERS` config can include the new app. Until that config entry
exists the backend skips attestation for the provider entirely.

Note: Android attestation only succeeds for builds installed through Google Play
(internal testing counts; sideloaded release builds always fail with a 403). Use debug
builds with a registered debug token for local development.

# Other useful commands

## Rebuilding strings files

Modify the lib/l10n/app\_??.arb files, then rebuild strings code:

```
flutter gen-l10n
```

## Convert translations files to/from CSV

Use the arb2csv.py in the lib/l10n directory to create a CSV

Make sure you have the Flutter arb_tooling package available:

```
dart pub global activate arb_tooling
```

Use the arb_tooling package to create an ARB

```
arb_tooling from_csv -i en_to_ger2.csv -o . -p app_
```

For iOS - make sure all languages are declared in the Info.plist file.

## Regenerate dart-gen code

```
flutter pub run build_runner build --delete-conflicting-outputs
```

## Generate phrase symbols

```
dart run phrase
```

## Building and pushing to Firebase / App Stores

Switch to either ios or android subdirectory, then run fastlane:

```
bundle exec fastlane
```

## Environment Configuration

The app uses environment variables for sensitive configuration. To set up your development environment:

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Configure the following environment variables in `.env`:
   - `GOOGLE_SERVICES_API_KEY_IOS`: Google Places and Maps iOS API key from Google Cloud Console
   - `GOOGLE_SERVICES_API_KEY_ANDROID`: Google Places and Maps Android API key from Google Cloud Console
   - `INTERCOM_APP_ID`: Intercom application ID
   - `INTERCOM_IOS_API_KEY`: Intercom iOS API key
   - `INTERCOM_ANDROID_API_KEY`: Intercom Android API key
   - `INTERCOM_IOS_IDENTITY_VERIFICATION_SECRET`: Intercom iOS identity verification secret
   - `INTERCOM_ANDROID_IDENTITY_VERIFICATION_SECRET`: Intercom Android identity verification secret
   - `PHRASE_DISTRIBUTION_ID`: Phrase distribution ID for translations
   - `PHRASE_DEVELOPMENT_SECRET`: Phrase development secret
   - `PHRASE_PRODUCTION_SECRET`: Phrase production secret
   - `CHECKOUT_SANDBOX_PUBLIC_KEY`: Checkout.com sandbox public key
   - `CHECKOUT_PRODUCTION_PUBLIC_KEY`: Checkout.com production public key

### Google Service Account Setup

1. Go to the Google Cloud Console
2. Create a new project or select an existing one
3. Enable the required APIs
4. Create a service account and download the JSON key
5. Encode the JSON file as base64:
   ```bash
   base64 -i path/to/service-account.json
   ```

Note: Never commit the `.env` file or any files containing actual secrets to version control.
