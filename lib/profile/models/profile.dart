import 'package:cloud_firestore/cloud_firestore.dart';

/// User profile model.
class Profile {
  /// Default constructor.
  const Profile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.createdAt,
    required this.profileImage,
  });

  /// Empty profile.
  Profile.empty()
      : firstName = '',
        lastName = '',
        email = '',
        createdAt = Timestamp(0, 0),
        profileImage = '';

  /// Creates a profile from a snapshot.
  factory Profile.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data()! as Map<String, dynamic>;

    return Profile(
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      profileImage: data['profileImage'],
    );
  }

  /// First name.
  final String firstName;

  /// Last name.
  final String lastName;

  /// Email.
  final String email;

  /// Creation date.
  final Timestamp createdAt;

  /// Image url.
  final String? profileImage;

  /// Returns the initials of the first and last name or the first two letters of the email.
  String get initials {
    if (firstName.isEmpty || lastName.isEmpty) {
      return email.substring(0, 2).toUpperCase();
    }
    return '${firstName[0]}${lastName[0]}'.toUpperCase();
  }

  /// Converts the profile to a map.
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'createdAt': createdAt,
    };
  }
}
