import 'dart:async';

import 'package:database_diagrams/logging/log_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:functional/functional.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Auth store.
class AuthStore extends StateNotifier<Option<User>> {
  /// Default constructor.
  AuthStore(
    this.auth,
  ) : super(const None()) {
    _subscription = auth.authStateChanges().listen(
          (user) => effect(() {
            Option.of(user).match(
              none: () => state = const None(),
              some: (user) => state = Some(user),
            );
            myLog.d('Auth state changed: $user');
          }),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  late final StreamSubscription _subscription;

  /// Auth.
  FirebaseAuth auth;

  /// Provider.
  static final provider =
      StateNotifierProvider.autoDispose<AuthStore, Option<User>>(
    (ref) => AuthStore(
      FirebaseAuth.instance,
    ),
  );

  /// Is logged in.
  bool get isLoggedIn => state.match(none: () => false, some: (user) => true);

  /// Returns the current user.
  Option<User> get user => state;
}
