import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String role; // e.g., 'user', 'admin'
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.isAdmin,
  });

  // Factory constructor for creating a UserModel from a Firestore map
  // Note: Firestore data() returns Map<String, dynamic>?
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'N/A',
      role: map['role'] as String? ?? 'user',
      isAdmin: map['isAdmin'] as bool? ?? false,
    );
  }

  // Method to convert UserModel to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
      'isAdmin': isAdmin,
    };
  }
}
