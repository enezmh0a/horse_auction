class UserProfile {
  final String id;
  final String? displayName;
  final String? email;
  final bool? isAdmin;

  UserProfile({
    required this.id,
    this.displayName,
    this.email,
    this.isAdmin,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String id) {
    return UserProfile(
      id: id,
      displayName: map['displayName'] as String?,
      email: map['email'] as String?,
      isAdmin: map['isAdmin'] as bool?,
    );
  }

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'email': email,
        'isAdmin': isAdmin,
      };
}
