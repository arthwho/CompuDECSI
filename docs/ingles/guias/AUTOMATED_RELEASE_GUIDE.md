# Automated Release Guide

This project uses GitHub Actions to automatically build and release APKs when you push a new version tag.

## How to Create a Release

### 1. Update Version (Optional)
If you want to update the app version, modify `pubspec.yaml`:
```yaml
version: 1.0.0+1  # Change this to your new version
```

### 2. Commit Changes
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
- ✅ Create a release on GitHub
- ✅ Upload the APK file
- ✅ Generate release notes

## What Happens When You Push a Tag

1. **Trigger**: Pushing a tag like `v1.0.0` triggers the workflow
2. **Build**: Flutter builds the release APK
3. **Release**: Creates a release on GitHub with the APK attached
4. **Download**: Users can download the APK directly from the release

## Tag Versioning Convention

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
The APK will be in: `build/app/outputs/flutter-apk/app-release.apk`

## Troubleshooting

- **Workflow fails**: Check the Actions tab in your GitHub repository
- **APK not generated**: Make sure all dependencies are in `pubspec.yaml`
- **Permission issues**: Make sure the repository has Actions enabled

## Next Steps

1. Push this workflow to your repository
2. Create your first release by tagging: `git tag v1.0.0 && git push origin v1.0.0`
3. Check the Actions tab to monitor the build process
4. Download the APK from the generated release

## Workflow Configuration

### File `.github/workflows/release.yml`:
```yaml
name: Build and Release APK

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.32.4'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Build APK
      run: flutter build apk --release
    
    - name: Create Release
      uses: softprops/action-gh-release@v1
      with:
        files: build/app/outputs/flutter-apk/app-release.apk
        generate_release_notes: true
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Benefits of Automated Release

### ✅ **Consistency**:
- Builds always done in the same environment
- Standardized configuration
- Fewer human errors

### ✅ **Efficiency**:
- Automated process
- No need for manual builds
- Faster releases

### ✅ **Traceability**:
- Release history
- Build logs available
- Easy rollback if needed

## Security Configuration

### GitHub Secrets:
- `GITHUB_TOKEN`: Automatic token for releases
- `KEYSTORE_FILE`: Keystore file (if using signing)
- `KEYSTORE_PASSWORD`: Keystore password
- `KEY_ALIAS`: Key alias
- `KEY_PASSWORD`: Key password

## Monitoring

### Check Status:
1. Go to your repository on GitHub
2. Click on the "Actions" tab
3. Check the status of the most recent workflow

### Build Logs:
- Click on the workflow to see detailed logs
- Check for compilation errors
- Confirm if the APK was generated

## Advanced Troubleshooting

### Common Issues:

1. **Build fails due to dependencies**:
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Permission issues**:
   - Check if the repository has Actions enabled
   - Confirm if the token has adequate permissions

3. **APK doesn't appear in release**:
   - Check the file path in the workflow
   - Confirm if the build was successful

### Debug Commands:
```bash
# Check Flutter version
flutter --version

# Check dependencies
flutter pub deps

# Test local build
flutter build apk --release
```
