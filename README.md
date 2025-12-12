# 🔄 TapTrade App

A modern Flutter-based trading platform that connects users to swap items locally. Built with Firebase, Google Maps, and a flexible backend architecture.

---

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (>=3.2.0)
- Firebase account
- Google Maps API key
- Node.js (for Railway web deployment)

### Setup in 3 Steps

1. **Clone and Install**
   ```bash
   git clone <your-repo-url>
   cd TapTradeApp-main
   flutter pub get
   ```

2. **Configure Environment**
   ```bash
   # Copy example file
   cp env.example .env
   
   # Edit .env and add your API keys
   nano .env
   ```

3. **Run**
   ```bash
   flutter run
   ```

📖 **Full setup guide:** [QUICK_START.md](QUICK_START.md)

---

## 📦 Features

- 🔐 **Authentication**: Firebase Auth with Google & Apple Sign-In
- 📍 **Location-Based**: Find nearby trading opportunities
- 🎴 **Swipe Interface**: Tinder-style product matching
- 💬 **Real-time Chat**: Communicate with traders
- 🔔 **Push Notifications**: Stay updated on matches
- 📸 **Image Upload**: Showcase your products
- 💳 **Payment Integration**: Secure transactions
- 🌐 **Multi-Platform**: iOS, Android, and Web

---

## 🏗️ Architecture

### **Current Setup**

```
Mobile Apps (iOS/Android)
    ↓
AppConfig (.env)
    ↓
Backend API (PythonAnywhere)
    ↓
Firebase + Google Maps
```

### **Flexible Deployment**

- **Mobile**: Deploy to App Stores
- **Web**: Deploy to Railway
- **Backend**: Switch between PythonAnywhere and Railway

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [QUICK_START.md](QUICK_START.md) | Get running in 5 minutes |
| [DEPLOYMENT_SUMMARY.md](DEPLOYMENT_SUMMARY.md) | Complete overview of changes |
| [RAILWAY_DEPLOYMENT.md](RAILWAY_DEPLOYMENT.md) | Deploy web version to Railway |
| [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) | Migrate backend to Railway |
| [README_ENV_SETUP.md](README_ENV_SETUP.md) | Environment configuration guide |

---

## 🔧 Configuration

### Environment Variables

All configuration is managed through `.env` files:

```env
# Backend
API_BASE_URL=https://your-backend-url.com/
IMAGE_BASE_URL=https://your-backend-url.com

# Firebase
FIREBASE_API_KEY=your_key
FIREBASE_PROJECT_ID=your_project

# Google Maps
GOOGLE_MAPS_API_KEY=your_key
```

**See:** [env.example](env.example) for full template

---

## 🚢 Deployment

### Mobile Apps

```bash
# Android
flutter build appbundle

# iOS
flutter build ipa
```

Then upload to respective app stores.

### Web (Railway)

```bash
# Push to GitHub
git push origin main

# Deploy on Railway
# Follow: RAILWAY_DEPLOYMENT.md
```

Your web app will be live at: `https://taptrade-production.up.railway.app`

---

## 🛠️ Tech Stack

### **Frontend**
- Flutter 3.2+
- GetX (State Management)
- Firebase Auth
- Google Maps Flutter
- Swipe Cards
- Lottie Animations

### **Backend**
- Python/Django (PythonAnywhere)
- Firebase Cloud Messaging
- PostgreSQL/MySQL

### **Deployment**
- Railway (Web & Backend)
- App Stores (Mobile)
- Docker (Containerization)

---

## 📱 Platforms

| Platform | Status | Deployment |
|----------|--------|------------|
| Android | ✅ Ready | Google Play Store |
| iOS | ✅ Ready | Apple App Store |
| Web | ✅ Ready | Railway |

---

## 🔐 Security

- ✅ Environment variables (no hardcoded secrets)
- ✅ Firebase Authentication
- ✅ Secure API communication (HTTPS)
- ✅ `.env` files in `.gitignore`
- ✅ API key restrictions enabled

---

## 🧪 Testing

```bash
# Run tests
flutter test

# Run on device
flutter run

# Build release
flutter build appbundle --release
```

---

## 📊 Project Structure

```
TapTradeApp-main/
├── lib/
│   ├── Const/           # Configuration & constants
│   │   ├── appConfig.dart    # Environment config
│   │   ├── apiEndPoint.dart  # API endpoints
│   │   └── globleKey.dart    # Global keys
│   ├── Controller/      # State management
│   ├── Models/          # Data models
│   ├── Screens/         # UI screens
│   ├── Services/        # Business logic
│   ├── Utills/          # Utilities
│   └── Widgets/         # Reusable widgets
├── assets/              # Images, fonts, sounds
├── .env                 # Environment variables (not in Git)
├── Dockerfile           # Docker configuration
├── railway.json         # Railway deployment config
├── server.js            # Express server for web
└── package.json         # Node.js dependencies
```

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is private and proprietary.

---

## 🆘 Support

- **Environment Setup Issues**: See [README_ENV_SETUP.md](README_ENV_SETUP.md)
- **Deployment Issues**: See [RAILWAY_DEPLOYMENT.md](RAILWAY_DEPLOYMENT.md)
- **Migration Questions**: See [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)

---

## 🎯 Roadmap

- [x] Environment-based configuration
- [x] Railway deployment setup
- [x] Multi-platform support
- [ ] Backend migration to Railway
- [ ] CI/CD pipeline
- [ ] Automated testing
- [ ] Analytics integration
- [ ] Performance monitoring

---

## 👥 Team

**TapTrade Development Team**

---

## 🙏 Acknowledgments

- Flutter Team
- Firebase
- Railway
- Google Maps Platform
- All open-source contributors

---

## 📞 Contact

For questions or support, please refer to the documentation files or create an issue.

---

**Version:** 1.0.0  
**Last Updated:** December 12, 2025  
**Status:** ✅ Production Ready
