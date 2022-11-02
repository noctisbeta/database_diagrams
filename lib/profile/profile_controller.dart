import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:database_diagrams/profile/models/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Profile controller.
class ProfileController {
  /// Default constructor.
  ProfileController(
    this.ref,
    this.auth,
    this.db,
  );

  /// Provides the controller.
  static final provider = Provider.autoDispose<ProfileController>(
    (ref) => ProfileController(
      ref,
      FirebaseAuth.instance,
      FirebaseFirestore.instance,
    ),
  );

  /// Riverpod reference.
  final Ref ref;

  /// Firebase auth.
  final FirebaseAuth auth;

  /// Firestore database.
  final FirebaseFirestore db;

  /// Provides the profile stream.
  static final profileStreamProvider = StreamProvider.autoDispose((ref) {
    final db = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    return db.collection('users').doc(auth.currentUser!.uid).snapshots().map(Profile.fromSnapshot);
  });

  /// Creates a new profile.
  Future<bool> createProfileFromUserCredential(UserCredential userCredential) async {
    final user = {
      'firstName': userCredential.user!.displayName!.split(' ')[0],
      'lastName': userCredential.user!.displayName!.split(' ')[1],
      'email': userCredential.user!.email,
      'createdAt': FieldValue.serverTimestamp(),
      'profileImage': userCredential.user!.photoURL,
    };

    try {
      await db.collection('users').doc(userCredential.user!.uid).set(
            user,
            SetOptions(merge: true),
          );

      log('Profile created: $user');
      return true;
    } on FirebaseException catch (e) {
      log('Error creating profile: ${e.message}');
      return false;
    }
  }

  /// Creates a user document in firestore.
  Future<bool> createProfileFromMap(Map<String, dynamic> map) async {
    final user = {
      'firstName': map['firstName'],
      'lastName': map['lastName'],
      'email': map['email'],
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await db.collection('users').doc(map['uid']).set(
            user,
            SetOptions(merge: true),
          );

      log('Profile created: $user');
      return true;
    } on FirebaseException catch (e) {
      log('Error creating profile: ${e.message}');
      return false;
    }
  }

  /// Returns true if the user already has a profile.
  // Future<bool> userHasProfile() async {
  //   if (!ref.read(LoginController.provider.notifier).isUserLoggedIn()) {
  //     log('User is not logged in');
  //     return false;
  //   }

  //   return db.collection('users').doc(auth.currentUser!.uid).get().then(
  //     (value) {
  //       log('User has profile: ${value.exists}');
  //       return value.exists;
  //     },
  //   );
  // }

  /// Signs the user out.
  Future<void> signOut() async {
    // Stop the database reads when the user is signed out, to prevent errors caused by rules.
    await db.terminate();

    await auth.signOut();
    log('Signed out the user.');
  }

  OverlayEntry? _profileMenuEntry;

  /// Is profile menu open.
  bool get isProfileMenuOpen => _profileMenuEntry != null;

  /// Show overlay.
  void showProfileMenu(BuildContext context, OverlayEntry entry) {
    _profileMenuEntry = entry;
    Overlay.of(context)!.insert(_profileMenuEntry!);
  }

  /// Hide overlay.
  void closeProfileMenu() {
    _profileMenuEntry?.remove();
    _profileMenuEntry = null;
  }
}
