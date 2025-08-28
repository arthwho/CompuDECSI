# QR Code Feature - CompuDECSI

## Overview

The QR Code feature was implemented to replace numeric enrollment codes with QR codes to facilitate check-in management. This allows administrators and additional Staff members to quickly scan QR codes to check in participants instead of manually typing codes.

## Features

### For Users (Students)
- **QR Code Generation**: When a user enrolls in an event, a unique QR code is generated instead of a literal code
- **QR Code Display**: Users can view their QR code in a modal dialog with clean and professional design
- **Copy Functionality**: Users can still copy their enrollment code as text if needed
- **Instructions**: Clear instructions on how to use the QR code for check-in

### For Administrators and Staff
- **QR Code Scanner**: Dedicated scanner page accessible through the administrative panel
- **Real-time Scanning**: Live camera feed with QR code detection
- **User Verification**: Shows user and event details before confirming check-in
- **Automatic Check-in**: Processes check-in automatically after confirmation
- **Error Handling**: Appropriate error messages for invalid or expired codes

## Technical Implementation

### Added Dependencies
- `qr_flutter: ^4.1.0` - For generating QR codes
- `mobile_scanner: ^3.5.6` - For scanning QR codes (replaces qr_code_scanner for better compatibility)

### Created/Modified Files

#### New Files
- `lib/widgets/qr_code_widget.dart` - Reusable widget for QR code display
- `lib/widgets/qr_code_dialog.dart` - Modal dialog for displaying QR codes
- `lib/admin/qr_scanner_page.dart` - Administrative scanner page
- `test/widgets/qr_code_widget_test.dart` - Tests for the QR code widget

#### Modified Files
- `lib/pages/detail_page.dart` - Updated enrollment card to show QR code button
- `lib/admin/admin_panel.dart` - Added QR scanner option to administrative panel
- `pubspec.yaml` - Added QR code dependencies
- `android/app/src/main/AndroidManifest.xml` - Added camera permissions
- `ios/Runner/Info.plist` - Added camera usage description

### Database Structure
The enrollment system remains the same, with enrollment codes stored in the `enrollments` collection:
```json
{
  "userId": "user_id",
  "eventId": "event_id", 
  "enrollmentCode": "123456",
  "enrolledAt": "timestamp"
}
```

## Usage Instructions

### For Users
1. Enroll in an event as usual
2. Instead of seeing a literal code, you'll see a "Show QR Code" button
3. Tap the button to open the QR code dialog
4. Present the QR code to the administrator for check-in
5. Optionally, you can copy the code as text using the "Copy code" button

### For Administrators
1. Access the administrative panel
2. Tap the "QR Code Scanner" option
3. Grant camera permissions when prompted
4. Point the camera at the user's QR code
5. Review user and event details in the confirmation dialog
6. Tap "Confirm Check-in" to complete the process

## Security Features
- Each enrollment code is unique per user per event
- QR codes contain only the enrollment code, not sensitive user data
- Administrative verification shows user details before check-in
- Error handling prevents invalid check-ins

## Required Permissions
- **Android**: Camera permission for QR scanning
- **iOS**: Camera usage description for QR scanning

## Testing
Run the QR code widget tests:
```bash
flutter test test/widgets/qr_code_widget_test.dart
```

## Future Improvements
- QR code expiration functionality
- Batch QR code generation for events
- Offline QR code validation
- QR code analytics and tracking
