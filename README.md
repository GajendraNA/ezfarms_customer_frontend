# customer

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Web app

Live at **https://ez-farms-customer.vercel.app**. Vercel builds it from this repo on every push to `responsive-upgrade` (preview deployments for other branches), using `vercel-build.sh`: it installs Flutter 3.44.6 and runs `flutter build web --release --dart-define=API_BASE_URL=https://ez-farms-api.onrender.com`.

The backend sleeps on Render's free plan; open https://ez-farms-api.onrender.com/api/health first and wait for `{"status":"UP"}`.
