# 🚂 Railway Backend Deployment Guide

This guide explains how to deploy your TapTrade backend (Python/Django) to Railway.

---

## 📋 Prerequisites

- Railway account (sign up at [railway.app](https://railway.app))
- Your backend code in a Git repository
- Database (PostgreSQL recommended)
- Environment variables ready

---

## 🏗️ Backend Architecture

```
┌─────────────────────────────────────────┐
│         TapTrade Backend                │
│                                         │
│  ┌──────────────┐    ┌──────────────┐  │
│  │   Django/    │    │  PostgreSQL  │  │
│  │   Python     │───▶│   Database   │  │
│  │   API        │    │              │  │
│  └──────────────┘    └──────────────┘  │
│         │                               │
│         ▼                               │
│  ┌──────────────┐                      │
│  │   Media      │                      │
│  │   Storage    │                      │
│  └──────────────┘                      │
└─────────────────────────────────────────┘
         │
         ▼
   Railway Public URL
   https://taptrade-backend-production.up.railway.app
```

---

## 🚀 Step 1: Prepare Your Backend

### **1.1 Create Required Files**

Your backend repository needs these files:

#### **`Procfile`** (for Railway)
```
web: gunicorn your_project.wsgi --log-file -
```

#### **`runtime.txt`** (Python version)
```
python-3.11.0
```

#### **`requirements.txt`** (Dependencies)
```
Django==4.2.0
djangorestframework==3.14.0
django-cors-headers==4.0.0
gunicorn==20.1.0
psycopg2-binary==2.9.6
django-environ==0.10.0
Pillow==9.5.0
boto3==1.26.137  # if using S3 for media
whitenoise==6.4.0  # for static files
```

#### **`railway.json`**
```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "python manage.py migrate && gunicorn your_project.wsgi",
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

### **1.2 Update Django Settings**

Update your `settings.py`:

```python
import os
import environ

# Initialize environment variables
env = environ.Env()
environ.Env.read_env()

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = env('SECRET_KEY', default='your-secret-key-here')

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = env.bool('DEBUG', default=False)

ALLOWED_HOSTS = env.list('ALLOWED_HOSTS', default=[
    'taptrade-backend-production.up.railway.app',
    'localhost',
    '127.0.0.1'
])

# Database
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': env('PGDATABASE'),
        'USER': env('PGUSER'),
        'PASSWORD': env('PGPASSWORD'),
        'HOST': env('PGHOST'),
        'PORT': env('PGPORT', default='5432'),
    }
}

# CORS Settings
CORS_ALLOWED_ORIGINS = env.list('CORS_ALLOWED_ORIGINS', default=[
    'https://taptrade-production.up.railway.app',
])

CORS_ALLOW_ALL_ORIGINS = env.bool('CORS_ALLOW_ALL_ORIGINS', default=False)

# Static files (CSS, JavaScript, Images)
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

# Media files
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')
```

---

## 🚀 Step 2: Deploy Backend to Railway

### **2.1 Create Railway Project**

1. Go to [railway.app](https://railway.app)
2. Click **"New Project"**
3. Select **"Deploy from GitHub repo"**
4. Choose your backend repository
5. Railway will detect your Python app

### **2.2 Add PostgreSQL Database**

1. In your project, click **"New"** → **"Database"** → **"Add PostgreSQL"**
2. Railway automatically creates database and injects variables:
   - `PGHOST`
   - `PGPORT`
   - `PGUSER`
   - `PGPASSWORD`
   - `PGDATABASE`

### **2.3 Configure Environment Variables**

Go to your backend service → **Variables** tab:

```bash
# Django Settings
SECRET_KEY=your-super-secret-key-here-use-random-string
DEBUG=False
DJANGO_SETTINGS_MODULE=your_project.settings
ALLOWED_HOSTS=taptrade-backend-production.up.railway.app,localhost

# CORS Settings
CORS_ALLOWED_ORIGINS=https://taptrade-production.up.railway.app
CORS_ALLOW_ALL_ORIGINS=False

# Firebase Admin (if using server-side Firebase)
FIREBASE_SERVICE_ACCOUNT_KEY={"type":"service_account",...}

# AWS S3 (if using for media storage)
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_STORAGE_BUCKET_NAME=taptrade-media
AWS_S3_REGION_NAME=us-east-1

# Email Settings (optional)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password

# Other API Keys
GOOGLE_MAPS_API_KEY=your_maps_api_key
PAYMENT_GATEWAY_KEY=your_payment_key
```

### **2.4 Deploy**

1. Railway automatically builds and deploys
2. Check **Deployments** tab for progress
3. View logs for any errors
4. Get your public URL from **Settings** → **Domains**

---

## 🚀 Step 3: Update Flutter App

### **3.1 Update `.env` File**

Replace the URL with your Railway backend URL:

```env
API_BASE_URL=https://taptrade-backend-production.up.railway.app/
IMAGE_BASE_URL=https://taptrade-backend-production.up.railway.app
```

### **3.2 Test the Connection**

```bash
# Run Flutter app
flutter run

# Test API endpoints
curl https://taptrade-backend-production.up.railway.app/api/health
```

---

## 🗄️ Database Management

### **Run Migrations**

```bash
# In Railway dashboard, go to your service
# Click "Deploy" → "Run Command"
python manage.py migrate
python manage.py createsuperuser
python manage.py collectstatic --noinput
```

### **Access Database**

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Link to project
railway link

# Connect to database
railway connect postgres
```

---

## 📦 Media File Storage Options

### **Option 1: Railway Volumes (Simple)**

In `settings.py`:
```python
MEDIA_ROOT = '/app/media'
MEDIA_URL = '/media/'
```

In `railway.json`:
```json
{
  "deploy": {
    "volumeMounts": [
      {
        "mountPath": "/app/media",
        "name": "media"
      }
    ]
  }
}
```

### **Option 2: AWS S3 (Recommended for Production)**

Install package:
```bash
pip install django-storages boto3
```

In `settings.py`:
```python
# AWS S3 Settings
AWS_ACCESS_KEY_ID = env('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = env('AWS_SECRET_ACCESS_KEY')
AWS_STORAGE_BUCKET_NAME = env('AWS_STORAGE_BUCKET_NAME')
AWS_S3_REGION_NAME = env('AWS_S3_REGION_NAME', default='us-east-1')
AWS_S3_CUSTOM_DOMAIN = f'{AWS_STORAGE_BUCKET_NAME}.s3.amazonaws.com'

# Media files
DEFAULT_FILE_STORAGE = 'storages.backends.s3boto3.S3Boto3Storage'
MEDIA_URL = f'https://{AWS_S3_CUSTOM_DOMAIN}/media/'
```

---

## 🔒 Security Checklist

- [ ] `DEBUG=False` in production
- [ ] Strong `SECRET_KEY` (use random generator)
- [ ] HTTPS only (Railway provides this)
- [ ] Proper CORS configuration
- [ ] Database backups enabled
- [ ] Environment variables secured
- [ ] ALLOWED_HOSTS configured
- [ ] Static files served via WhiteNoise or CDN
- [ ] Media files secured (S3 with proper permissions)

---

## 📊 Monitoring & Logs

### **View Logs**

In Railway dashboard:
1. Go to your service
2. Click **Logs** tab
3. Filter by level (Info, Warning, Error)

### **Set Up Alerts**

1. Go to **Settings** → **Notifications**
2. Add webhook for deployment failures
3. Set up monitoring (Sentry, etc.)

---

## 🔄 CI/CD Pipeline

Railway automatically deploys when you push to your main branch:

```bash
# Make changes
git add .
git commit -m "Update feature"
git push origin main

# Railway automatically:
# 1. Detects push
# 2. Builds new image
# 3. Runs migrations
# 4. Deploys
# 5. Switches to new version
```

---

## 🧪 Testing

### **Health Check Endpoint**

Create a health check in your Django app:

```python
# views.py
from django.http import JsonResponse
from django.db import connection

def health_check(request):
    try:
        # Check database
        connection.ensure_connection()
        return JsonResponse({
            'status': 'healthy',
            'database': 'connected'
        })
    except Exception as e:
        return JsonResponse({
            'status': 'unhealthy',
            'error': str(e)
        }, status=500)

# urls.py
urlpatterns = [
    path('health/', health_check),
]
```

Test it:
```bash
curl https://taptrade-backend-production.up.railway.app/health/
```

---

## 💰 Pricing Estimate

Railway pricing (as of 2024):

- **Free Tier**: $5/month credit
- **Pro Plan**: $20/month + usage

Typical costs for TapTrade:
- Backend Service: ~$5-10/month
- PostgreSQL Database: ~$5/month
- Egress (bandwidth): ~$1-5/month
- **Total**: ~$11-20/month

---

## 🆘 Troubleshooting

### **Build Fails**

```bash
# Check requirements.txt
pip freeze > requirements.txt

# Verify runtime.txt
python --version
```

### **Database Connection Error**

- Verify PostgreSQL service is running
- Check DATABASE_URL is injected
- Test connection in logs

### **Static Files Not Loading**

```bash
# Collect static files
python manage.py collectstatic --noinput

# Check STATIC_ROOT and STATIC_URL
```

### **CORS Errors**

```python
# Update CORS_ALLOWED_ORIGINS
CORS_ALLOWED_ORIGINS = [
    'https://your-flutter-web.up.railway.app',
]
```

---

## 📚 Additional Resources

- [Railway Docs](https://docs.railway.app/)
- [Django Deployment Checklist](https://docs.djangoproject.com/en/4.2/howto/deployment/checklist/)
- [PostgreSQL on Railway](https://docs.railway.app/databases/postgresql)
- [Railway Python Guide](https://docs.railway.app/guides/python)

---

## ✅ Deployment Checklist

- [ ] Backend code in Git repository
- [ ] Required files created (Procfile, requirements.txt, etc.)
- [ ] Django settings updated for production
- [ ] Railway project created
- [ ] PostgreSQL database added
- [ ] Environment variables configured
- [ ] Backend deployed successfully
- [ ] Migrations run
- [ ] Static files collected
- [ ] Health check endpoint working
- [ ] Flutter app .env updated with Railway URL
- [ ] End-to-end testing completed

---

**Your Backend URL:** `https://taptrade-backend-production.up.railway.app/`

Update this in your Flutter app's `.env` file to connect! 🚀

