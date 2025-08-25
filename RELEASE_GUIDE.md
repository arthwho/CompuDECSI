# Automated Release Guide

This project uses GitHub Actions to automatically build and release APKs when you push a new version tag.

## How to Create a Release

### 1. Update Version (Optional)
If you want to update the app version, modify `pubspec.yaml`:
```yaml
version: 1.0.0+1  # Change this to your new version
```

### 2. Commit Your Changes
```bash
git add .
git commit -m "Prepare for release v1.0.0"
git push origin main
```

### 3. Create and Push a Tag
```bash
git tag v1.0.0
git push origin v1.0.0
```

### 4. GitHub Actions Will Automatically:
- ✅ Build the APK in a clean environment
- ✅ Run all tests
- ✅ Create a GitHub release
- ✅ Upload the APK file
- ✅ Generate release notes

## What Happens When You Push a Tag

1. **Trigger**: Pushing a tag like `v1.0.0` triggers the workflow
2. **Build**: Flutter builds the release APK
3. **Release**: Creates a GitHub release with the APK attached
4. **Download**: Users can download the APK directly from the release

## Version Tagging Convention

Use semantic versioning:
- `v1.0.0` - Major release
- `v1.1.0` - Minor release  
- `v1.0.1` - Patch release
- `v1.0.0-beta.1` - Pre-release

## Manual Release (Alternative)

If you prefer to build manually:
```bash
flutter build apk --release
```
The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

## Troubleshooting

- **Workflow fails**: Check the Actions tab in your GitHub repository
- **APK not generated**: Ensure all dependencies are in `pubspec.yaml`
- **Permission issues**: Make sure the repository has Actions enabled

## Next Steps

1. Push this workflow to your repository
2. Create your first release by tagging: `git tag v1.0.0 && git push origin v1.0.0`
3. Check the Actions tab to monitor the build process
4. Download the APK from the generated release
