# 🔧 TapTrade Environment Setup

## Quick Start

### 1. Create Your `.env` File

Copy the example file:

```bash
cp env.example .env
```

### 2. Fill in Your Values

Open `.env` and replace the placeholder values with your actual credentials:

```env
# Backend API
API_BASE_URL=https://taptradebackend.pythonanywhere.com/
IMAGE_BASE_URL=https://taptradebackend.pythonanywhere.com
PAYMENT_API_URL=https://mbjalaly.pythonanywhere.com/api/payment/

# Firebase (from Firebase Console)
FIREBASE_API_KEY=your_actual_api_key_here
FIREBASE_AUTH_DOMAIN=taptrade-d4ca5.firebaseapp.com
FIREBASE_PROJECT_ID=taptrade-d4ca5
FIREBASE_STORAGE_BUCKET=taptrade-d4ca5.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=502704204773
FIREBASE_APP_ID=1:502704204773:android:131e0e6943908364781d0c

# Google Maps (from Google Cloud Console)
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here

# App Config
APP_NAME=TapTrade
APP_VERSION=1.0.0
ENVIRONMENT=production
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the App

```bash
flutter run
```

---

## 🔑 Where to Get API Keys

### **Firebase Configuration**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `taptrade-d4ca5`
3. Click the gear icon → **Project Settings**
4. Scroll to "Your apps" section
5. Select your Android/iOS/Web app
6. Copy the values from the config object

### **Google Maps API Key**

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Navigate to **APIs & Services** → **Credentials**
4. Click **Create Credentials** → **API Key**
5. Enable these APIs:
   - Maps JavaScript API
   - Geocoding API
   - Geolocation API
   - Places API

---

## 🌍 Multiple Environments

### Development

Create `.env.development`:

```env
API_BASE_URL=http://localhost:8000/
ENVIRONMENT=development
```

### Production

Use `.env` (default):

```env
API_BASE_URL=https://taptradebackend.pythonanywhere.com/
ENVIRONMENT=production
```

### Switching Environments

```bash
# Use development
mv .env .env.backup
mv .env.development .env
flutter run

# Switch back to production
mv .env .env.development
mv .env.backup .env
```

---

## ⚠️ Important Notes

1. **Never commit `.env` files** - They contain secrets!
2. **Keep `env.example` updated** - Template for other developers
3. **Use different keys** for dev/prod environments
4. **Restart app** after changing `.env` values

---

## 🔒 Security Checklist

- [ ] `.env` is in `.gitignore`
- [ ] Using different Firebase projects for dev/prod
- [ ] Google Maps API key has restrictions enabled
- [ ] Backend API uses HTTPS
- [ ] Environment variables are not hardcoded anywhere

---

## 🆘 Troubleshooting

**Problem:** "Unable to load asset: .env"

**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

**Problem:** Environment variables are empty

**Solution:**
- Check `.env` file exists in project root
- Verify `.env` is listed in `pubspec.yaml` assets
- Rebuild the app completely

**Problem:** Firebase not initializing

**Solution:**
- Verify all Firebase values in `.env`
- Check `google-services.json` (Android) exists
- Check `GoogleService-Info.plist` (iOS) exists

---

## 📚 Documentation

- [Flutter Dotenv Package](https://pub.dev/packages/flutter_dotenv)
- [Firebase Setup](https://firebase.google.com/docs/flutter/setup)
- [Google Maps Setup](https://developers.google.com/maps/documentation/android-sdk/start)
- [Railway Deployment](./RAILWAY_DEPLOYMENT.md)
- [Migration Guide](./MIGRATION_GUIDE.md)

---

## ✅ Verification

To verify your setup is correct:

1. Run the app
2. Check console for "TapTrade Configuration" output
3. Test login functionality
4. Test map features
5. Test image uploads

If everything works, you're all set! 🎉

