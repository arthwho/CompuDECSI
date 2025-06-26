# compudecsi

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase Configuration

This project uses Firebase for backend services. To set up Firebase:

1. Copy `android/app/google-services.json.template` to `android/app/google-services.json`
2. Replace the placeholder values in `google-services.json` with your actual Firebase project credentials
3. For iOS, copy `ios/Runner/GoogleService-Info.plist.template` to `ios/Runner/GoogleService-Info.plist` and update the values

**Important**: Never commit the actual `google-services.json` or `GoogleService-Info.plist` files to version control as they contain sensitive API keys. These files are already added to `.gitignore`.

## Security Notes

- Firebase configuration files containing API keys have been removed from Git history
- Template files are provided for reference
- Always use environment variables or secure storage for sensitive data in production
