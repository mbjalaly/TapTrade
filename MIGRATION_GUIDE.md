# 🔄 Railway Deployment Guide

This guide explains how to deploy your TapTrade app and backend to Railway.

---

## 📊 New Setup - Railway

**New Backend:** Railway (modern, scalable platform)
**Flutter Web:** Railway
**Mobile Apps:** App Stores (unchanged)

Your app is now configured to use Railway as the primary deployment platform. Railway offers better performance, automatic deployments, and modern infrastructure.

---

## ✅ What We've Changed

### 1. **Environment-Based Configuration**

We've implemented a flexible configuration system using `.env` files:

- **Added `flutter_dotenv`** package for environment variable management
- **Created `AppConfig` class** to centralize all configuration
- **Updated all API endpoints** to use dynamic URLs from `.env`
- **Modified `main.dart`** to load environment on startup

### 2. **Files Modified**

```
✓ pubspec.yaml              - Added flutter_dotenv dependency
✓ lib/Const/appConfig.dart  - NEW: Central configuration class
✓ lib/Const/apiEndPoint.dart - Now uses AppConfig for URLs
✓ lib/Const/globleKey.dart  - Now uses AppConfig for image URLs
✓ lib/main.dart             - Loads .env on startup
✓ .env                      - NEW: Production environment variables
✓ .env.development          - NEW: Development environment variables
✓ env.example               - Template for environment variables
```

---

## 🚀 How to Switch to Railway

### **Deploy Backend to Railway**

#### Step 1: Deploy Your Backend to Railway

1. **Prepare your backend code** (Python/Django)
2. **Create a Railway project**:
   - Go to [railway.app](https://railway.app)
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Choose your backend repository

3. **Configure environment variables** in Railway:
   - Database credentials
   - Secret keys
   - Firebase credentials
   - Any other backend config

4. **Get your Railway URL** (e.g., `https://taptrade-backend-production.up.railway.app`)

#### Step 2: Your Flutter App is Already Configured

The `.env` file is already set up for Railway:

```env
# Already configured for Railway!
API_BASE_URL=https://taptrade-backend-production.up.railway.app/
IMAGE_BASE_URL=https://taptrade-backend-production.up.railway.app
```

Just replace the URL with your actual Railway deployment URL.

#### Step 3: Test and Deploy

1. **Test locally**:
   ```bash
   flutter run
   ```

2. **Build for production**:
   ```bash
   # Android
   flutter build appbundle
   
   # iOS
   flutter build ipa
   
   # Web
   flutter build web
   ```

3. **Deploy to stores** or Railway (for web version)

---

## 🔧 Environment Management

### **Multiple Environments**

You can maintain different environments:

```
.env                 → Production (PythonAnywhere or Railway)
.env.development     → Local development
.env.staging         → Staging server (optional)
```

### **Switching Environments**

To use development environment:

```bash
# Rename files temporarily
mv .env .env.production
mv .env.development .env

# Run app
flutter run

# Switch back
mv .env .env.development
mv .env.production .env
```

---

## 📝 Configuration Reference

### **All Available Variables**

```env
# Backend APIs
API_BASE_URL=https://your-backend-url.com/
IMAGE_BASE_URL=https://your-backend-url.com
PAYMENT_API_URL=https://payment-service-url.com/api/payment/

# Firebase
FIREBASE_API_KEY=your_key
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:android:abc123
FIREBASE_MEASUREMENT_ID=G-ABC123

# Google Maps
GOOGLE_MAPS_API_KEY=your_maps_key

# App Settings
APP_NAME=TapTrade
APP_VERSION=1.0.0
ENVIRONMENT=production
```

---

## 🔐 Security Best Practices

### **1. Never Commit `.env` Files**

The `.env` file is already in `.gitignore`. Never commit it to Git!

```bash
# Check if .env is ignored
git status

# .env should NOT appear in the list
```

### **2. Use Different Keys for Each Environment**

- **Development**: Use test Firebase project, test API keys
- **Production**: Use production Firebase project, production API keys

### **3. Secure Your Railway Deployment**

- Enable HTTPS (Railway does this automatically)
- Set up proper CORS policies
- Use environment variables for all secrets
- Enable rate limiting on your API

---

## 🧪 Testing the Migration

### **1. Test API Connectivity**

Add this to your app temporarily to verify the configuration:

```dart
// In main.dart, after AppConfig.initialize()
AppConfig.printConfig();
```

This will print your current configuration in the console.

### **2. Test All Features**

After switching to Railway, test:

- ✅ User registration/login
- ✅ Product listing
- ✅ Image uploads
- ✅ Location services
- ✅ Push notifications
- ✅ Payment processing
- ✅ Trade matching

### **3. Monitor Railway Logs**

In Railway dashboard:
- Go to your project
- Click "Deployments"
- View logs to monitor API calls

---

## 🆘 Troubleshooting

### **Problem: App can't connect to backend**

**Solution:**
1. Check `.env` file exists in project root
2. Verify `API_BASE_URL` is correct
3. Ensure backend is running on Railway
4. Check Railway logs for errors

### **Problem: Images not loading**

**Solution:**
1. Verify `IMAGE_BASE_URL` in `.env`
2. Check if images are accessible via browser
3. Ensure CORS is enabled on backend

### **Problem: Environment variables not loading**

**Solution:**
1. Run `flutter clean`
2. Run `flutter pub get`
3. Rebuild the app completely
4. Check that `.env` is in `pubspec.yaml` assets

---

## 📊 Why Railway?

| Feature | Railway Advantage |
|---------|-------------------|
| **Deployment** | Git-based auto-deploy (push to deploy) |
| **Scaling** | Auto-scaling based on traffic |
| **Database** | PostgreSQL with automatic backups |
| **Custom Domain** | Free custom domains |
| **SSL/HTTPS** | Automatic SSL certificates |
| **Logs** | Real-time streaming logs |
| **Performance** | Fast global edge network |
| **CI/CD** | Built-in continuous deployment |
| **Monitoring** | Built-in metrics and alerts |
| **Cost** | $5/month credit included, pay as you grow |

---

## 🎯 Deployment Path

### **Phase 1: Setup (Complete)**
✅ Environment configuration implemented
✅ Code configured for Railway
✅ Documentation created

### **Phase 2: Backend Deployment**
1. Deploy your Django/Python backend to Railway
2. Follow `RAILWAY_BACKEND_SETUP.md`
3. Get your Railway backend URL

### **Phase 3: Flutter App Update**
1. Update `.env` with your Railway URL
2. Test locally
3. Deploy to stores/web

### **Phase 4: Production**
1. Monitor Railway metrics
2. Set up alerts and backups
3. Scale as needed

---

## 📞 Support

If you encounter issues during migration:

1. **Check Railway Docs**: https://docs.railway.app
2. **Check Flutter Dotenv**: https://pub.dev/packages/flutter_dotenv
3. **Review logs**: Both Railway and Flutter console
4. **Test incrementally**: Don't switch everything at once

---

## ✨ Benefits of This Approach

✅ **Zero code changes** to switch backends
✅ **Easy testing** with multiple environments
✅ **Secure** - secrets not in code
✅ **Flexible** - switch providers anytime
✅ **Professional** - industry best practice
✅ **Maintainable** - centralized configuration

---

## 🎉 You're Ready!

Your app is now configured for Railway deployment!

**Current Status:** ✅ Configured for Railway

**Next Steps:** 
1. Deploy backend to Railway (see `RAILWAY_BACKEND_SETUP.md`)
2. Update `.env` with your Railway URL
3. Test and deploy!

**Questions?** Check the troubleshooting section or review the configuration reference.

