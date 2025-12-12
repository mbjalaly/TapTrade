# ⚡ Quick Start Guide - Railway Deployment

## 🎯 Get Running in 3 Steps

### Step 1: Deploy Backend to Railway (Required First)

Your app needs a backend API. Deploy it to Railway first:

```bash
# Read the backend deployment guide
cat RAILWAY_BACKEND_SETUP.md
```

Once deployed, you'll get a URL like:
`https://taptrade-backend-production.up.railway.app/`

### Step 2: Configure Environment

Open `.env` and update with your Railway backend URL and API keys:

```bash
nano .env
```

Update these values:
```env
# Your Railway backend URL (from Step 1)
API_BASE_URL=https://taptrade-backend-production.up.railway.app/
IMAGE_BASE_URL=https://taptrade-backend-production.up.railway.app

# Your Google Maps API key
GOOGLE_MAPS_API_KEY=AIzaSyC_your_actual_key_here
```

**Need API keys?**
- Google Maps: https://console.cloud.google.com/
- Firebase: Already configured

### Step 3: Install & Run

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

That's it! Your app should connect to Railway. 🎉

---

## 🚀 Deploy to Railway (Web Version)

### Step 1: Push to GitHub

```bash
git add .
git commit -m "Add Railway deployment configuration"
git push origin main
```

### Step 2: Deploy on Railway

1. Go to [railway.app](https://railway.app)
2. Click "New Project" → "Deploy from GitHub repo"
3. Select your TapTrade repository
4. Add environment variables (copy from `.env`)
5. Deploy!

Your web app will be live in ~10 minutes at:
`https://taptrade-production.up.railway.app`

---

## 📱 Build for App Stores

### Android

```bash
flutter build appbundle
```

Upload to Google Play Console.

### iOS

```bash
flutter build ipa
```

Upload to App Store Connect.

---

## 📚 Full Documentation

- **Environment Setup**: `README_ENV_SETUP.md`
- **Railway Deployment**: `RAILWAY_DEPLOYMENT.md`
- **Backend Migration**: `MIGRATION_GUIDE.md`
- **Complete Summary**: `DEPLOYMENT_SUMMARY.md`

---

## ⚠️ Important

- Never commit `.env` file (it's in `.gitignore`)
- Keep your API keys secure
- Test thoroughly before deploying to production

---

**Need help?** Check the documentation files above! 📖

