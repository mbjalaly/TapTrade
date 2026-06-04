# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Essential Commands

### Frontend Development (Flutter Mobile)

```bash
# Install dependencies
flutter pub get

# Run mobile app (development)
flutter run

# Run with specific device
flutter run -d chrome          # Web browser
flutter run -d android         # Android device/emulator
flutter run -d ios            # iOS device/simulator

# Build for production
flutter build appbundle       # Android App Bundle for Play Store
flutter build ipa             # iOS IPA for App Store
flutter build web             # Web build for deployment

# Testing
flutter test                  # Run all tests
flutter test test/widget_test.dart  # Run specific test file

# Clean build artifacts
flutter clean
```

### Backend Development (Node.js/TypeScript)

```bash
cd backend

# Install dependencies
npm ci                        # Clean install (preferred)
npm install                   # Regular install

# Development (auto-reload on changes)
npm run dev

# Build TypeScript to JavaScript
npm run build

# Run production build
npm start

# Note: Backend runs on port 3001 by default
```

### Admin Panel Development (Flutter Web)

```bash
cd admin_panel

# Install dependencies
flutter pub get

# Run admin panel in browser
flutter run -d chrome

# Build for production
flutter build web
```

## High-Level Architecture

### Multi-Tier Application Structure

This is a full-stack application with three main components:

1. **Flutter Mobile App** (`lib/`) - iOS/Android app with GetX state management
2. **TypeScript Backend** (`backend/src/`) - Express.js REST API with Supabase
3. **Admin Panel** (`admin_panel/`) - Flutter Web dashboard

### State Management Flow (GetX Pattern)

```
User Action (Widget)
    ↓
GetX Controller (productController, userController)
    ↓
Service Layer (apiServices, productService, authService, etc.)
    ↓
HTTP Request (apiServices.dart with Bearer token)
    ↓
Backend API (Express routes in backend/src/routes/taptrade.ts)
    ↓
Supabase Database (PostgreSQL)
```

**Key Controllers:**
- `lib/Controller/productController.dart` - Global product state (matched products, trade requests, etc.)
- `lib/Controller/userController.dart` - User profile and authentication state
- `lib/Controller/settingsController.dart` - App settings, preferences, and UI state
- `lib/Controller/languageController.dart` - Localization and language switching

### Environment-Based Configuration System

**Critical Pattern:** All configuration is centralized through `lib/Const/appConfig.dart`

```dart
// AppConfig loads from .env and provides app-wide config
API_BASE_URL → apiEndPoint.dart → Services → API calls
```

**How it works:**
1. `.env` file contains all environment variables (API URLs, Firebase config, etc.)
2. `lib/Const/appConfig.dart` loads `.env` using `flutter_dotenv`
3. `lib/Const/apiEndPoint.dart` dynamically generates all API endpoints from AppConfig
4. Services use apiEndPoint for all HTTP requests

**To switch environments:**
- Update `API_BASE_URL` in `.env`
- All API endpoints automatically update
- Supports PythonAnywhere, Railway, or local backend seamlessly

### Backend API Architecture

**Single Route File:** All 49 API endpoints are in `backend/src/routes/taptrade.ts` (~4,100 lines)

**Key Endpoint Categories:**
- Authentication: `/api/user/register/`, `/api/user/login/`, `/api/user/api/social_login_or_register/`, `/api/user/account/activation/`, `/api/user/check-user/`
- OTP Verification: `/api/email/send-otp/`, `/api/email/verify-otp/`, `/api/sms/send-otp/`, `/api/sms/verify-otp/`
- Password Reset: `/api/user/forgot-password/`, `/api/user/verify-reset-otp/`, `/api/user/reset-password/`, `/api/user/forgotpassword/`
- User Management: `/api/user/me/`, `/api/user/updateProfile/`, `/api/user/profile/`, `/api/user/delete/`
- Products: `/add_products/`, `/add_user_products/`, `/getallproducts/`, `/update_products/`, `/delete_products/:id/`, `/activate_product/:id/`
- Categories & Interests: `/getallcategories/`, `/getallinterests/`, `/add-interests/`, `/getuserinterests/`
- Trading: `/api/trade/preferences/`, `/api/trade/getuserpreferences/`, `/api/trade/api/nearby-users/`, `/api/trade/create-matchfeedback/`, `/api/trade/matchfeedback/user/`
- Trade Requests: `/api/trade/trade-requests/:userId/`, `/api/trade/trade-requests/create/`, `/api/trade/accept-requests/`, `/api/trade/mark-complete/`, `/api/trade/confirm-complete/`, `/api/trade/cancel/`, `/api/trade/trade_payment_status/`
- Disliked Products: `/api/trade/disliked-products/`, `/api/trade/disliked-products/:feedbackId/`
- Chat/Matches: `/api/matches/create/`, `/api/matches/`, `/api/matches/:matchId`, `/api/matches/:matchId/messages/` (GET & POST), `/api/matches/:matchId/read/`
- Testing: `/test-logging/`, `/api/test/notification`

**Authentication Flow:**
1. Frontend: Firebase authentication (email/phone/Google/Apple)
2. Backend: JWT tokens generated via `src/utils/jwt.ts`
3. Protected routes use `requireAuth` middleware
4. Token stored in SharedPreferences, auto-injected in all API calls

**File Upload Handling:**
- Multer middleware with 10MB per file limit, 50MB total
- Images uploaded to **Supabase Storage** (S3-compatible CDN) via `backend/src/utils/imageUpload.ts`
- Public CDN URLs returned for display (replaced old base64-in-database approach)
- Supported formats: JPEG, PNG, WebP
- Frontend image compression & cropping via `lib/Services/ImageFileService/imageFileService.dart`

**Backend Services:**
- `backend/src/services/supabaseClient.ts` - Supabase database client (service role key)
- `backend/src/services/pushNotificationService.ts` - Firebase Cloud Messaging push notifications
- `backend/src/services/unoSendService.ts` - SMS OTP provider for phone verification
- `backend/src/services/inactivityCron.ts` - Scheduled cron job for user inactivity handling
- `backend/src/utils/imageUpload.ts` - Supabase Storage image upload utility
- `backend/src/utils/jwt.ts` - JWT token generation and verification
- `backend/src/utils/logger.ts` - Application logging
- `backend/src/utils/respond.ts` - Standardized API response helper

**SQL Migrations** (`backend/` root): Schema change files including `ADD_COUNTRY_CODE_COLUMN.sql`, `ADD_PHONE_VERIFICATION_COLUMNS.sql`, `TRADE_REQUESTS_SCHEMA.sql`, `add_social_login_columns.sql`, and others.

### Service Layer Organization

The Flutter app uses a service-oriented architecture in `lib/Services/`:

**API Communication:**
- `ApiServices/apiServices.dart` - Central HTTP client with token injection, timeout handling, error handling

**Integration Services** (`IntegrationServices/`):
- `authService.dart` - Main auth coordinator
- `firebaseEmailAuthService.dart` - Firebase email auth
- `firebasePhoneAuthService.dart` - Firebase phone auth
- `googleSignIn.dart` - Google Sign-In integration
- `appleAuthService.dart` - Apple Sign-In integration
- `productService.dart` - Product CRUD operations
- `profileService.dart` - User profile management
- `chatService.dart` - Chat/messaging API calls
- `unoSendSmsService.dart` - SMS OTP via UnoSend provider
- `generalService.dart` - Utility services

**Domain Services:**
- `LocationService/` - GPS, geolocation, nearby user detection
- `NotificationService/` - Firebase Cloud Messaging setup
- `CooldownService/` - Enforces 2-day cooldown between product swipes
- `SearchFilterService/` - Product filtering logic
- `SharedPreferenceService/` - Local persistent storage
- `LocalizationService/` - Multi-language support (English, Arabic with RTL)
- `TutorialService/` - Onboarding tutorial flow
- `ImageFileService/` - Image compression, cropping, and format conversion
- `SupabaseService/` - Optional direct Supabase SDK access from mobile app
- `ApiResponse/` - Standardized API response parsing
- `AppException/` - Custom exception handling
- `logService.dart` - Application logging

**Helpers & Models:**
- `lib/Helpers/matchGroupingHelper.dart` - Groups matched products for the chat/matches UI
- `lib/Models/ChatModels/` - Chat data models (`matchModel.dart`, `messageModel.dart`, `myProductMatchGroup.dart`)

**Why this matters:** When modifying features, changes often span:
1. Widget (UI) → 2. Controller (state) → 3. Service (logic) → 4. Backend API

### Database Architecture (Supabase)

Backend uses Supabase PostgreSQL with the following key tables:
- `users` - User profiles and authentication
- `products` - Product listings
- `categories` - Product categories
- `interests` - User interests
- `trade_requests` - Trade negotiations
- `match_feedback` - Like/dislike history
- `trade_preferences` - User trading preferences
- `matches` - Chat matches between users (see `MATCH_CHAT_SCHEMA.sql`)
- `messages` - Chat messages within matches
- `logs` - Application logs (see `CREATE_LOGS_TABLE.sql`)

**Access patterns:**
- Backend: Supabase client in `backend/src/services/supabaseClient.ts` (service role key)
- Admin Panel: Direct Supabase SDK access (`admin_panel/lib/config/supabase_config.dart`)
- Mobile App: Primarily uses REST API, optional direct Supabase access

### Tinder-Like Swipe System

**Components:**
1. **UI:** `lib/Widgets/customMatchCard.dart` with `swipe_cards` package
2. **Cooldown Logic:** `lib/Services/CooldownService/` enforces 2-day cooldown per product
3. **Nearby Products:** `/api/trade/api/nearby-users/` returns location-sorted products
4. **Match Feedback:** `/api/trade/create-matchfeedback/` records likes/dislikes
5. **State Management:** `productController.matchedProduct` stores current swipe stack

**Flow:**
- User swipes on product
- CooldownService checks if product is on cooldown locally
- If allowed, sends like/dislike to backend
- Backend records feedback in `match_feedback` table
- Frontend refreshes product stack from nearby users API

## Critical Configuration

### Environment Variables (.env)

**Required for development:**
```env
# Backend API (change based on environment)
API_BASE_URL=http://localhost:3001/        # Local dev
# API_BASE_URL=https://taptrade-backend-production.up.railway.app/  # Production
IMAGE_BASE_URL=http://localhost:3001

# Firebase Authentication
FIREBASE_API_KEY=your_key
FIREBASE_PROJECT_ID=your_project
FIREBASE_AUTH_DOMAIN=your_domain
FIREBASE_STORAGE_BUCKET=your_bucket
FIREBASE_MESSAGING_SENDER_ID=your_id
FIREBASE_APP_ID=your_app_id

# Google Maps
GOOGLE_MAPS_API_KEY=your_google_maps_key

# App Metadata
APP_NAME=TapTrade
APP_VERSION=1.0.0
ENVIRONMENT=development
```

**Never commit `.env` file** - it's in `.gitignore`. Use `env.example` as template. A `.env.development` file also exists for development-specific overrides.

### Multi-Environment Support

**Development:**
```bash
# Use .env with local backend
API_BASE_URL=http://localhost:3001/
# Run backend locally: cd backend && npm run dev
```

**Production:**
```bash
# Update .env with Railway backend
API_BASE_URL=https://taptrade-backend-production.up.railway.app/
```

**No code changes needed** - all endpoints update automatically via AppConfig.

### Firebase Platform Configuration

Firebase configuration differs by platform:
- **Android:** `android/app/google-services.json`
- **iOS:** `ios/Runner/GoogleService-Info.plist`
- **Web:** Configured in `web/index.html`

All platforms use same credentials from `.env` via AppConfig.

## Development Workflow

### Starting Local Development

1. **Backend First:**
   ```bash
   cd backend
   npm ci
   # Create .env in backend/ with Supabase credentials
   npm run dev
   # Backend runs on http://localhost:3001
   ```

2. **Frontend:**
   ```bash
   # Update .env with API_BASE_URL=http://localhost:3001/
   flutter pub get
   flutter run
   ```

### Making API Changes

**Backend route changes** (`backend/src/routes/taptrade.ts`):
1. Add/modify endpoint in route file
2. Update Supabase queries if needed
3. Test with `npm run dev` (auto-reloads)

**Frontend service changes** (`lib/Services/IntegrationServices/`):
1. Update service method (e.g., `productService.dart`)
2. Ensure endpoint URL matches `apiEndPoint.dart`
3. Update controller if state changes needed
4. Hot reload Flutter app to test

### Authentication Token Flow

**How tokens work:**
1. User authenticates via Firebase (frontend)
2. Backend receives Firebase token or credentials
3. Backend generates JWT via `src/utils/jwt.ts`
4. Frontend stores JWT in SharedPreferences (`lib/Services/SharedPreferenceService/`)
5. All API calls auto-inject token in `apiServices.dart` as `Bearer {token}`
6. Backend `requireAuth` middleware validates token on protected routes

**Token storage keys:**
- `userToken` - JWT access token
- `userId` - User ID
- `userData` - Serialized user profile

### Common Pain Points

**1. Image Upload Failures**
- Check file size < 10MB per file
- Verify base64 encoding in `imageFileService.dart`
- Check multer configuration in `backend/src/routes/taptrade.ts`

**2. Location Services Not Working**
- Verify `GOOGLE_MAPS_API_KEY` in `.env`
- Check platform-specific permissions (AndroidManifest.xml, Info.plist)
- Ensure LocationService is initialized in `main.dart`

**3. API 401 Errors**
- Token expired or missing in SharedPreferences
- Check `apiServices.dart` token injection
- Verify `requireAuth` middleware on backend routes
- User redirected to login on 401 automatically

**4. Cooldown Not Working**
- Check `CooldownService` local storage
- Backend also enforces cooldown in `/api/trade/api/nearby-users/`
- Clear app data to reset cooldowns during testing

**5. Environment Variables Not Loading**
- Ensure `flutter pub get` run after `.env` changes
- Check `flutter_dotenv` package imported in `main.dart`
- Verify `.env` file in project root (not in subdirectories)

### Key Files to Understand

**For authentication work:**
- `lib/Services/IntegrationServices/authService.dart` - Auth coordinator
- `lib/Services/IntegrationServices/unoSendSmsService.dart` - SMS OTP via UnoSend
- `backend/src/routes/taptrade.ts` - Auth & OTP endpoints (first ~1,500 lines)
- `backend/src/utils/jwt.ts` - Token generation/verification
- `backend/src/services/unoSendService.ts` - SMS OTP backend service

**For product features:**
- `lib/Services/IntegrationServices/productService.dart` - Product API calls
- `lib/Controller/productController.dart` - Product state
- `lib/Services/ImageFileService/imageFileService.dart` - Image processing
- `backend/src/routes/taptrade.ts` - Product endpoints (~lines 1,500-2,500)
- `backend/src/utils/imageUpload.ts` - Supabase Storage upload utility

**For trading/matching:**
- `lib/Services/CooldownService/` - Swipe cooldown logic
- `lib/Widgets/customMatchCard.dart` - Swipe UI
- `backend/src/routes/taptrade.ts` - Trading endpoints (~lines 2,500-4,100)

**For chat/messaging:**
- `lib/Services/IntegrationServices/chatService.dart` - Chat API calls
- `lib/Models/ChatModels/` - Match, message, and product group models
- `lib/Helpers/matchGroupingHelper.dart` - Groups products by match for chat list
- `lib/Screens/Dashboard/Chat/` - Chat screens (chatScreen, matchesListScreen, users_screen)
- `backend/src/routes/taptrade.ts` - Chat/match endpoints (`/api/matches/*`)
- `backend/src/services/pushNotificationService.ts` - Push notification delivery

## Deployment

### Backend Deployment (Railway)

```bash
cd backend
# Ensure Dockerfile and railway.json configured
# Push to GitHub, Railway auto-deploys
# Set environment variables in Railway dashboard
```

### Mobile App Deployment

```bash
# Update .env with production API_BASE_URL
# Android
flutter build appbundle --release
# Upload to Google Play Console

# iOS
flutter build ipa --release
# Upload to App Store Connect
```

### Web Deployment (Railway)

```bash
# Update .env with production backend URL
flutter build web
# Deploy web/ directory to Railway with server.js
```

## Project Context

**Project Type:** Production-ready peer-to-peer trading marketplace
**Status:** Active development, deployed on Railway
**Version:** 1.0.0+8
**Flutter SDK:** >=3.2.0 <4.0.0
**Primary Language:** Dart (134 files frontend) + TypeScript (~4.1K lines backend)
**Supported Languages:** English, Arabic (with full RTL support via `lib/l10n/`)

**Major Features:**
- Tinder-like swipe interface with 2-day cooldown
- Location-based product matching
- Firebase multi-provider authentication (Email, Phone, Google, Apple)
- Real-time chat and notifications with match-based messaging
- Payment integration with trade payment status tracking
- Admin dashboard for management (Flutter Web)
- Onboarding tutorial system (`lib/Screens/Tutorial/`)
- Bilingual UI with Arabic RTL support
- Product activation/deactivation
- Inactivity cron job for user engagement

**Note:** The project has two utility directories due to a naming inconsistency: `lib/Utills/` (main utilities) and `lib/Utils/` (cooldown test helper). Keep this in mind when adding new utilities.
