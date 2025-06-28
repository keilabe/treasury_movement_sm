# Treasury Movement App - Deployment Guide

## 🚀 Hosting on bolt.new

### Prerequisites
- Flutter web build completed
- GitHub repository with the project
- bolt.new account

### Step-by-Step Deployment

#### 1. Prepare Your Repository
Ensure your repository contains:
- Complete Flutter project
- `build/web` directory (after running `flutter build web`)
- `README.md` with project description
- `pubspec.yaml` with dependencies

#### 2. Deploy to bolt.new
1. **Visit bolt.new**: Go to [bolt.new](https://bolt.new)
2. **Connect Repository**: Link your GitHub repository
3. **Configure Build**:
   - **Framework**: Flutter
   - **Build Command**: `flutter build web --release`
   - **Output Directory**: `build/web`
   - **Node Version**: Latest LTS
4. **Environment Variables** (if needed):
   ```
   FLUTTER_VERSION=3.7.2
   ```
5. **Deploy**: Click deploy and wait for build completion

#### 3. Custom Domain (Optional)
- Add custom domain in bolt.new settings
- Configure DNS records
- Enable HTTPS

### Alternative Hosting Options

#### Firebase Hosting
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase project
firebase init hosting

# Build the app
flutter build web --release

# Deploy
firebase deploy
```

#### Netlify
1. Connect GitHub repository
2. Build command: `flutter build web --release`
3. Publish directory: `build/web`
4. Deploy automatically on push

#### Vercel
1. Import GitHub repository
2. Framework preset: Other
3. Build command: `flutter build web --release`
4. Output directory: `build/web`

## 📱 Mobile App Deployment

### Android APK
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### iOS App Store
```bash
# Build for iOS
flutter build ios --release

# Archive and upload via Xcode
```

## 🔧 Environment Configuration

### Firebase Configuration
1. Create Firebase project
2. Enable Firestore Database
3. Add web app to Firebase project
4. Copy configuration to `lib/firebase_options.dart`

### Environment Variables
```bash
# Development
FIREBASE_PROJECT_ID=your-dev-project
FIREBASE_API_KEY=your-dev-api-key

# Production
FIREBASE_PROJECT_ID=your-prod-project
FIREBASE_API_KEY=your-prod-api-key
```

## 📊 Performance Optimization

### Web Optimization
- Enable tree shaking: `flutter build web --tree-shake-icons`
- Compress assets
- Enable caching headers
- Use CDN for static assets

### Mobile Optimization
- Enable R8/ProGuard for Android
- Optimize images and assets
- Implement lazy loading
- Use appropriate app icons

## 🔒 Security Considerations

### Firebase Security Rules
```javascript
// Firestore rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /accounts/{accountId} {
      allow read, write: if request.auth != null;
    }
    match /transactions/{transactionId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Web Security
- Enable HTTPS
- Set security headers
- Implement CSP (Content Security Policy)
- Validate all inputs

## 📈 Monitoring and Analytics

### Firebase Analytics
```dart
// Add to main.dart
import 'package:firebase_analytics/firebase_analytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  runApp(MyApp());
}
```

### Error Tracking
```dart
// Add crashlytics
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  runApp(MyApp());
}
```

## 🔄 CI/CD Pipeline

### GitHub Actions
```yaml
name: Deploy to bolt.new
on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.7.2'
      - run: flutter pub get
      - run: flutter build web --release
      - name: Deploy to bolt.new
        run: |
          # Add bolt.new deployment commands
```

## 📋 Deployment Checklist

### Pre-Deployment
- [ ] All tests passing
- [ ] Code review completed
- [ ] Environment variables configured
- [ ] Firebase project set up
- [ ] Security rules implemented

### Deployment
- [ ] Build successful
- [ ] Assets optimized
- [ ] Performance tested
- [ ] Security scan completed
- [ ] Documentation updated

### Post-Deployment
- [ ] Functionality verified
- [ ] Performance monitored
- [ ] Error tracking enabled
- [ ] Analytics configured
- [ ] Backup procedures tested

## 🆘 Troubleshooting

### Common Issues

#### Build Failures
```bash
# Clear cache
flutter clean
flutter pub get

# Check Flutter version
flutter --version

# Verify dependencies
flutter doctor
```

#### Firebase Issues
- Check Firebase configuration
- Verify security rules
- Test database connectivity
- Review error logs

#### Performance Issues
- Optimize images
- Enable compression
- Implement caching
- Monitor bundle size

## 📞 Support

For deployment issues:
- Check Flutter documentation
- Review platform-specific guides
- Contact platform support
- Check community forums

---

**Last updated**: January 2024 