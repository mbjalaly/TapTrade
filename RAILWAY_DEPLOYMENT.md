# 🚂 TapTrade Railway Deployment Guide

This guide will help you deploy your TapTrade Flutter app to Railway as a web application.

## 📋 Prerequisites

1. **Railway Account**: Sign up at [railway.app](https://railway.app)
2. **GitHub Repository**: Your code should be in a GitHub repository
3. **Firebase Project**: You need Firebase credentials
4. **Google Maps API Key**: Required for map functionality

---

## 🚀 Step-by-Step Deployment

### Step 1: Prepare Your Repository

1. Make sure all the deployment files are committed:
   - `Dockerfile`
   - `railway.json`
   - `server.js`
   - `package.json`
   - `env.example`

2. Push your code to GitHub:
   ```bash
   git add .
   git commit -m "Add Railway deployment configuration"
   git push origin main
   ```

### Step 2: Create a New Railway Project

1. Go to [railway.app](https://railway.app) and log in
2. Click **"New Project"**
3. Select **"Deploy from GitHub repo"**
4. Choose your TapTrade repository
5. Railway will automatically detect the Dockerfile

### Step 3: Configure Environment Variables

In your Railway project dashboard, go to **Variables** tab and add these:

#### Required Variables:

```bash
# Firebase Configuration
FIREBASE_API_KEY=your_actual_firebase_api_key
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abc123
FIREBASE_MEASUREMENT_ID=G-ABC123

# Google Maps
GOOGLE_MAPS_API_KEY=your_actual_google_maps_api_key

# API Configuration (if you have a backend)
API_BASE_URL=https://your-api-url.com

# Port (Railway provides this automatically)
PORT=8080
```

#### Where to Find These Values:

**Firebase Configuration:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Project Settings (gear icon)
4. Scroll down to "Your apps" section
5. Select your web app or create one
6. Copy the config values from `firebaseConfig` object

**Google Maps API Key:**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Go to "APIs & Services" > "Credentials"
4. Copy your API key or create a new one
5. Make sure these APIs are enabled:
   - Maps JavaScript API
   - Geocoding API
   - Geolocation API

### Step 4: Update Flutter Web Configuration

Before deploying, you may need to update your Flutter web configuration to use environment variables.

Create or update `web/index.html` to inject environment variables:

```html
<!-- In your web/index.html, add this before loading main.dart.js -->
<script>
  window.ENV = {
    FIREBASE_API_KEY: '%FIREBASE_API_KEY%',
    FIREBASE_AUTH_DOMAIN: '%FIREBASE_AUTH_DOMAIN%',
    FIREBASE_PROJECT_ID: '%FIREBASE_PROJECT_ID%',
    FIREBASE_STORAGE_BUCKET: '%FIREBASE_STORAGE_BUCKET%',
    FIREBASE_MESSAGING_SENDER_ID: '%FIREBASE_MESSAGING_SENDER_ID%',
    FIREBASE_APP_ID: '%FIREBASE_APP_ID%',
    FIREBASE_MEASUREMENT_ID: '%FIREBASE_MEASUREMENT_ID%',
    GOOGLE_MAPS_API_KEY: '%GOOGLE_MAPS_API_KEY%',
  };
</script>
```

### Step 5: Deploy

1. Railway will automatically start building your app
2. The build process takes 5-10 minutes (Flutter compilation)
3. Once deployed, you'll get a public URL like: `https://taptrade-production.up.railway.app`

### Step 6: Configure Custom Domain (Optional)

1. In Railway dashboard, go to **Settings** tab
2. Scroll to **Domains** section
3. Click **Generate Domain** for a Railway subdomain
4. Or add your **Custom Domain** if you have one

---

## 🔧 Troubleshooting

### Build Fails

**Problem**: Docker build fails or times out

**Solution**:
- Check Railway build logs for specific errors
- Ensure your `pubspec.yaml` dependencies are compatible with web
- Some Flutter packages don't support web - remove or replace them

### App Loads but Features Don't Work

**Problem**: Firebase or Google Maps not working

**Solution**:
- Verify all environment variables are set correctly
- Check browser console for errors
- Ensure Firebase web configuration is correct
- Verify Google Maps API has the right permissions

### Connection Errors

**Problem**: "Connection refused" or API errors

**Solution**:
- Check if your backend API URL is correct
- Ensure CORS is configured on your backend
- Verify network requests in browser DevTools

---

## 📱 Mobile App vs Web App

**Important Notes:**

1. **Web Limitations**: Some features may not work on web:
   - Camera/Image picker (works differently)
   - Native notifications
   - Background services
   - Some hardware features

2. **Mobile Distribution**: For Android/iOS apps:
   - **Android**: Build APK/AAB for Google Play Store
   - **iOS**: Build IPA for Apple App Store
   - Railway is ONLY for the web version

3. **Multi-Platform Strategy**:
   ```
   ├── Mobile Apps (Android/iOS) → App Stores
   ├── Web App → Railway (for web access)
   └── Backend API → Railway (if needed)
   ```

---

## 🔄 Updating Your Deployment

Every time you push to your main branch, Railway will automatically rebuild and redeploy:

```bash
# Make your changes
git add .
git commit -m "Update feature X"
git push origin main

# Railway automatically rebuilds
```

---

## 💰 Pricing

Railway offers:
- **Free Tier**: $5 credit per month (enough for small apps)
- **Pro Plan**: $20/month + usage
- Web apps typically use ~$3-10/month depending on traffic

---

## 🛠️ Local Testing

Before deploying, test locally:

```bash
# Build Flutter web
flutter build web --release

# Install Node dependencies
npm install

# Start the server
npm start

# Open browser
open http://localhost:8080
```

---

## 📞 Support

- **Railway Docs**: https://docs.railway.app
- **Flutter Web**: https://flutter.dev/web
- **Railway Discord**: https://discord.gg/railway

---

## ✅ Checklist

Before deploying, ensure:

- [ ] All deployment files are in your repository
- [ ] Firebase project is set up and configured
- [ ] Google Maps API key is created and enabled
- [ ] Environment variables are ready
- [ ] Code is pushed to GitHub
- [ ] Railway project is created
- [ ] Environment variables are set in Railway
- [ ] Domain is configured (optional)

---

## 🎉 Success!

Once deployed, your TapTrade web app will be accessible at your Railway URL!

**Example**: `https://taptrade-production.up.railway.app`

Share this URL with your users for web access while your mobile apps are on the app stores!

