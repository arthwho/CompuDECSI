import 'package:compudecsi/pages/bottom_nav.dart';
import 'package:compudecsi/services/database.dart';
import 'package:compudecsi/services/shared_pref.dart';
import 'package:compudecsi/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;
  // Create a single instance of GoogleSignIn to prevent conflicts
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  getCurrentUser() async {
    return await auth.currentUser;
  }

  signInWithGoogle(BuildContext context) async {
    try {
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
      Navigator.of(context).pop();

      if (googleSignInAccount == null) {
        // User cancelled the sign-in
        return;
      }

      final GoogleSignInAuthentication? googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication?.idToken,
        accessToken: googleSignInAuthentication?.accessToken,
      );

      UserCredential result = await auth.signInWithCredential(credential);
      User? userDetails = result.user;
      await SharedpreferenceHelper().saveUserId(userDetails!.uid);
      await SharedpreferenceHelper().saveUserName(userDetails.displayName!);
      await SharedpreferenceHelper().saveUserEmail(userDetails.email!);
      await SharedpreferenceHelper().saveUserImage(userDetails.photoURL!);

      if (result.user != null) {
        // Ensure user doc exists with default role without overwriting role if present
        await UserService().ensureUserOnSignIn(
          uid: userDetails.uid,
          name: userDetails.displayName,
          email: userDetails.email,
          image: userDetails.photoURL,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text("Login realizado com sucesso"),
          ),
        );

        // Navigate to bottom navigation
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNav()),
        );
      }
    } catch (e) {
      // Hide loading indicator if it's still showing
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Erro no login: ${e.toString()}"),
        ),
      );
      print("Google Sign-In Error: $e");
    }
  }

  // Method to sign out
  signOut() async {
    await auth.signOut();
    await _googleSignIn.signOut();
  }
}
