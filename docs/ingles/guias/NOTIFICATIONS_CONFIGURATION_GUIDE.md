# Push Notifications Configuration Guide

This guide explains how to configure push notifications for the CompuDECSI app.

## Implemented Features

✅ **Local Notifications**: Scheduled 30 minutes before events  
✅ **Firebase Cloud Messaging (FCM)**: For push notifications  
✅ **Notification Settings Page**: User can manage preferences  
✅ **Automatic Scheduling**: When users enroll in events  
✅ **Automatic Cancellation**: When users cancel event enrollment  

## Configuration Instructions

### 1. Firebase Configuration

#### 1.1 Enable Firebase Cloud Messaging
1. Access Firebase Console
2. Navigate to Project Settings > Cloud Messaging
3. Enable Cloud Messaging if not already enabled
4. Note your Server Key (you'll need this for Cloud Functions)

#### 1.2 Update Firebase Configuration Files

**For Android (`android/app/google-services.json`):**
- Make sure the file is updated with your Firebase project
- Verify that Cloud Messaging is enabled in Firebase console

**For iOS (`ios/Runner/GoogleService-Info.plist`):**
- Make sure the file is updated with your Firebase project
- Add the following to your `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### 2. Android Configuration

#### 2.1 Update Android Manifest
Add the following permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

#### 2.2 Add Notification Icons (Optional)
Create notification icons and place them in:
- `android/app/src/main/res/drawable-hdpi/`
- `android/app/src/main/res/drawable-mdpi/`
- `android/app/src/main/res/drawable-xhdpi/`
- `android/app/src/main/res/drawable-xxhdpi/`

### 3. iOS Configuration

#### 3.1 Update iOS Project
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner target
3. Go to Signing & Capabilities
4. Add "Push Notifications" capability
5. Add "Background Modes" capability and check:
   - Remote notifications
   - Background fetch

#### 3.2 Update Info.plist
Add the following to `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### 4. Cloud Functions Configuration

#### 4.1 Install Firebase CLI
```bash
npm install -g firebase-tools
```

#### 4.2 Initialize Firebase Functions
```bash
firebase login
firebase init functions
```

#### 4.3 Deploy Cloud Functions
```bash
cd functions
npm install
firebase deploy --only functions
```

### 5. Testing the Implementation

#### 5.1 Test Local Notifications
1. Run the app on a device (not emulator for best results)
2. Go to Profile > Notifications
3. Grant notification permissions
4. Enroll in an event that starts in more than 30 minutes
5. Wait for the notification (or test with a closer time)

#### 5.2 Test Push Notifications
1. Use Firebase Console to send a test message
2. Or use Cloud Functions to send notifications

## How It Works

### 1. User Enrollment Flow
1. User enrolls in an event
2. App schedules a local notification for 30 minutes before the event
3. Notification includes event name, location, and description

### 2. Enrollment Cancellation Flow
1. User cancels enrollment
2. App cancels the scheduled notification for that event
3. User won't receive the reminder

### 3. Notification Content
- **Title**: "Reminder: [Event Name]"
- **Body**: Event description + location
- **Time**: 30 minutes before event start

### 4. Notification Channels
- **Event Reminders**: For scheduled event notifications
- **Event Notifications**: For push notifications

## Troubleshooting

### Common Issues

#### 1. Notifications Don't Appear
- Check if notifications are enabled in device settings
- Verify Firebase configuration files are correct
- Check if the app has notification permissions

#### 2. Local Notifications Don't Work
- Make sure the device is not in battery optimization mode
- Check if the notification time is in the future
- Check timezone settings

#### 3. Push Notifications Don't Work
- Check Firebase Cloud Messaging configuration
- Verify Cloud Functions were deployed
- Check FCM token generation

#### 4. iOS-Specific Issues
- Make sure Push Notifications capability was added
- Check APNs certificate configuration
- Verify background modes are enabled

### Debug Commands

```bash
# Check Firebase configuration
firebase projects:list

# Deploy functions
firebase deploy --only functions

# View function logs
firebase functions:log

# Test FCM token
# Use Firebase Console > Cloud Messaging > Send test message
```

## Security Considerations

1. **FCM Tokens**: Stored securely in Firestore
2. **User Permissions**: Users can control notification settings
3. **Data Privacy**: Only necessary event information is included
4. **Token Updates**: Managed automatically by Firebase

## Performance Considerations

1. **Local Notifications**: More reliable than push notifications
2. **Battery Optimization**: Notifications are scheduled efficiently
3. **Network Usage**: Minimal - only for FCM token updates
4. **Storage**: Notifications are managed by the system

## Future Improvements

- [ ] Custom notification sounds
- [ ] Rich notifications with images
- [ ] Notification categories
- [ ] Notification history
- [ ] Batch notifications
- [ ] Timezone handling improvements

## Support

For issues related to:
- **Firebase Configuration**: Consult Firebase documentation
- **App Implementation**: Check code comments
- **Device Issues**: Check device notification settings
- **Cloud Functions**: Check Firebase Functions logs
