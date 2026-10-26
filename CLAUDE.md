# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter mobile application for EV (Electric Vehicle) charging, specifically the "Road Mobile" app that supports multiple white-labeled versions across different charging providers (E-Flux, Elexon, Opcharge, Friwigo, EZdrive, NXT 50five, and EZdrive+).

## Linked Projects

This mobile app is part of the E-Flux ecosystem. Related codebases are located at:

- **Backend API**: `../e-flux/services/api` - Main Node.js/TypeScript API service that the mobile app communicates with
- **Web Application**: `../e-flux/services/web` - React web application with similar functionality (useful for feature parity)
- **E-Flux Mono Repo**: `../e-flux` - The complete backend mono repository containing all services
- **Driver Experience**: `../driver-experience` - Go monorepo for driver-facing services (live-activity-notifier, push-notifier, email-notifier, notification-fabricator, phrase-pull, tokens-etl)

These linked projects allow for cross-referencing implementations, ensuring feature parity, and understanding the full system architecture.

## Standard Workflow

1. First, think through the problem, read the codebase for relevant files, and write a plan to tasks/todo-<some sensible filename postfix>.md.
2. The plan should have a list of ToDo items that you can check off as you complete them.
3. Before you begin working, check in with me and I will verify the plan.
4. Then, begin working on the ToDo items, marking them as complete as you go.
5. Finally, add a review section to the todo.md file with a summary of the changes you made and any other relevant information.


## Key Development Commands

### Basic Flutter Commands
- `flutter clean` - Clean build artifacts
- `flutter pub get` - Install dependencies  
- `flutter analyze` - Run static analysis
- `flutter test` - Run unit tests
- `flutter gen-l10n` - Generate localization files

### Code Generation
- `dart run build_runner build --delete-conflicting-outputs` - Generate code (models, serialization, dependency injection)
- `dart run phrase && flutter gen-l10n` - Generate translation symbols from Phrase and produce translation files.

### Environment Setup
- `.env.example` is an example file in the repo. This is configured to `.env` locally, which users must do manually to setup the required environment variables
- Environment variables include API keys for Google Services, Intercom, Phrase, and Checkout.com

### Flavor/Build Commands
- `flutter build ipa --flavor=eflux` - Build iOS for specific flavor
- `flutter build apk --flavor=eflux --release` - Build Android for specific flavor
- Available flavors: eflux, elexon, opcharge, friwigo, ezdrive, nxt50five, ezdriveplus

### Fastlane Deployment
From `android/` or `ios/` directories:
- `bundle exec fastlane` - See available deployment lanes
- Firebase and App Store deployment configured per flavor

### Flavor Configuration
- `dart run flutter_flavorizr -p assets:download,assets:extract,android:androidManifest,android:buildGradle,android:icons,ios:xcconfig,ios:buildTargets,ios:schema,ios:icons,ios:plist,google:firebase,assets:clean,ide:config` - Generate flavor configurations
- `dart run flutter_native_splash:create --flavors <flavor name>` - Generate splash screens

## Architecture Overview

### State Management
- **BLoC Pattern**: Uses `flutter_bloc` for state management throughout the app
- **Cubit**: Most business logic implemented as Cubits extending BlocBase
- **Repository Pattern**: Data layer abstracted through repository classes

### Dependency Injection
- **GetIt + Injectable**: Service locator pattern with code generation
- Configuration in `lib/services/di/injection.dart`
- Auto-generated setup in `injection.config.dart`

### Flavor System
- **Multi-brand Support**: Single codebase supporting 7+ white-label apps
- **Flavor Configuration**: `lib/flavors.dart` contains brand-specific logic
- **Build Variants**: Each flavor has dedicated Firebase projects, API keys, and branding

### Key Services
- **API Service**: HTTP client with interceptors in `lib/services/network/`
- **Authentication**: JWT-based auth with secure storage
- **Location Services**: GPS and map integration using Google Maps
- **Analytics**: Firebase Analytics and Crashlytics
- **Notifications**: Firebase Cloud Messaging with local notifications
- **Internationalization**: Phrase.com integration with ARB files

### UI Structure
- **Main App**: Navigation between Home, Explore (Map), Wallet, and Account tabs
- **Onboarding**: Login/signup flows with multi-factor authentication support
- **Map Integration**: Google Maps with custom markers for charging stations
- **Charging Flow**: Remote charging initiation and session management
- **Payment**: Credit card management with Apple Pay/Google Pay support

### Data Layer
- **Models**: JSON serializable with Freezed and json_annotation
- **API Integration**: RESTful API communication with dio HTTP client
- **Local Storage**: Secure storage for sensitive data, SharedPreferences for settings
- **Caching**: In-memory caching for map data and user sessions

### Testing
- **Unit Tests**: Located in `test/` directory
- **Widget Tests**: Flutter widget testing framework
- **Mocking**: Uses mockito for dependency mocking
- **BLoC Testing**: Dedicated testing for state management components

## Important Notes

### Security
- Never commit `.env` files or actual API keys
- Keystore files and certificates are gitignored
- Authentication tokens stored in secure storage

### Map Integration
- Google Maps requires API keys for both iOS and Android
- Different API keys needed for each flavor/brand
- Latest Android renderer used for optimal performance

### Multi-language Support
- Translations managed through Phrase.com
- ARB files in `lib/l10n/` for each supported language
- CSV conversion tools available for bulk translation management

### Firebase Configuration
- Each flavor has separate Firebase project
- Crashlytics and Analytics configured per brand
- Push notifications require APNs certificates for iOS

### Development Workflow
- Clean build artifacts before switching flavors
- Run code generation after model changes
- Test with multiple flavors to ensure brand-specific logic works
- Update translations before releases
