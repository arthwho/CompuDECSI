import 'package:compudecsi/services/shared_pref.dart';
import 'package:compudecsi/services/user_service.dart';
import 'package:compudecsi/utils/terms_acceptance_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;
  // Create a single instance of GoogleSignIn to prevent conflicts
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  getCurrentUser() async {
    return await auth.currentUser;
  }

  signInWithGoogle(BuildContext context) async {
    try {
      // Check if user has already accepted terms
      final termsAccepted = await SharedpreferenceHelper().getTermsAccepted();

      if (termsAccepted != true) {
        // Show terms acceptance dialog
        final accepted = await _showTermsAcceptanceDialog(context);
        if (!accepted) {
          return; // User didn't accept terms
        }
      }

      // Check if user is already signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn
          .signIn();

      // Hide loading indicator
      try {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        print("Error dismissing loading dialog: $e");
      }

      if (googleSignInAccount == null) {
        // User cancelled the sign-in
        return;
      }

      final GoogleSignInAuthentication? googleSignInAuthentication =
          await googleSignInAccount.authentication;

      if (googleSignInAuthentication == null) {
        throw Exception('Failed to get authentication from Google Sign-In');
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      UserCredential result = await auth.signInWithCredential(credential);
      User? userDetails = result.user;

      if (userDetails != null) {
        await SharedpreferenceHelper().saveUserId(userDetails.uid);
        await SharedpreferenceHelper().saveUserName(
          userDetails.displayName ?? 'Unknown User',
        );
        await SharedpreferenceHelper().saveUserEmail(userDetails.email ?? '');
        await SharedpreferenceHelper().saveUserImage(
          userDetails.photoURL ?? '',
        );
      } else {
        throw Exception('Failed to get user details from Google Sign-In');
      }

      if (result.user != null) {
        // Ensure user doc exists with default role without overwriting role if present
        await UserService().ensureUserOnSignIn(
          uid: userDetails.uid,
          name: userDetails.displayName ?? 'Unknown User',
          email: userDetails.email ?? '',
          image: userDetails.photoURL ?? '',
        );

        // Show success message
        try {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: Text("Login realizado com sucesso"),
              ),
            );
          }
        } catch (snackbarError) {
          print("Error showing success message: $snackbarError");
        }

        // Navigation is now handled automatically by AuthWrapper
        // No need to manually navigate here
      }
    } catch (e) {
      // Hide loading indicator if it's still showing
      try {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      } catch (dialogError) {
        print("Error dismissing loading dialog in catch block: $dialogError");
      }

      // Show error message
      try {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text("Erro no login: ${e.toString()}"),
            ),
          );
        }
      } catch (snackbarError) {
        print("Error showing error message: $snackbarError");
      }
      print("Google Sign-In Error: $e");
    }
  }

  // Method to sign out
  signOut() async {
    try {
      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Sign out from Firebase
      await auth.signOut();

      // Sign out from Google
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (e) {
      print("Sign out error: $e");
      // Continue with sign out even if there's an error
    }
  }

  // Show terms acceptance dialog
  Future<bool> _showTermsAcceptanceDialog(BuildContext context) async {
    bool accepted = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TermsAcceptanceDialog(
          onAccept: () async {
            // Save that user accepted terms
            await SharedpreferenceHelper().saveTermsAccepted(true);
            accepted = true;
          },
        );
      },
    );

    return accepted;
  }
}
