import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_project/model/user.dart';
import 'package:first_project/screens/homepage.dart';
import 'package:first_project/screens/user_setup_page_content.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart'; // Add this dependency


class AuthService {
  Future<String?> registration({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else {
        return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else {
        return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> LoginWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return 'user is null';
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final String uid = userCredential.user!.uid;

      final users = FirebaseFirestore.instance.collection('QawlUsers');
      final userDoc = await users.doc(uid).get();

      if (!userDoc.exists) {
        await QawlUser.createQawlUser(userCredential.user);
      }
      await checkUserDetailsAndNavigate(userCredential.user, context);
      return 'Success';

    } catch (error) {
      debugPrint("Google Sign-In failed: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In failed: $error")),
      );
      return 'Error: $error';
    } 
  }

  Future<String> LoginWithApple(BuildContext context) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthCredential oAuthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(oAuthCredential);

      final String uid = userCredential.user!.uid;

      final users = FirebaseFirestore.instance.collection('QawlUsers');
      final userDoc = await users.doc(uid).get();

      if (!userDoc.exists) {
        await QawlUser.createQawlUser(userCredential.user);
      }
      await checkUserDetailsAndNavigate(userCredential.user, context);
      return 'Success';

    } catch (error) {
      debugPrint("Apple Sign-In failed: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Apple Sign-In failed: $error")),
      );
      return 'Error: $error';
    }
  }

  Future<void> checkUserDetailsAndNavigate(
      User? user, BuildContext context) async {
    final currentUser = await QawlUser.getCurrentQawlUser();

    if (currentUser == null) {
      return;
    }

    if (currentUser.gender == null ||
        currentUser.gender == "" ||
        currentUser.gender.isEmpty ||
        currentUser.country == null ||
        currentUser.country.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserSetupPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }
}
