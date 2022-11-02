import 'dart:developer';

import 'package:database_diagrams/authentication/controllers/google_controller_web.dart';
import 'package:database_diagrams/profile/profile_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Login controller.
class LoginController {
  /// Default constructor.
  const LoginController(this.ref, this.auth);

  /// Auth.
  final FirebaseAuth auth;

  /// Provider.
  static final provider = Provider.autoDispose<LoginController>(
    (ref) => LoginController(
      ref,
      FirebaseAuth.instance,
    ),
  );

  /// Ref.
  final Ref ref;

  /// Logs the user in with google and creates/fetches their profile.
  Future<void> loginWithGoogle() async {
    final googleCtl = ref.read(GoogleControllerWeb.provider);

    final either = await googleCtl.signInWithGoogle();

    await either.fold(
      (exception) {
        log('Exception with sign in with google:  $exception');
      },
      (userCredential) async {
        log('Successful sign in with google');

        final profileCtl = ref.read(ProfileController.provider);

        final res = await profileCtl.createProfileFromUserCredential(userCredential);

        if (res) {
          log('Profile created');
        } else {
          log('Profile not created');
        }
      },
    );
  }

  /// Logout.
  Future<void> logout() async {
    await auth.signOut();
  }
}
