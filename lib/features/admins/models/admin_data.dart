import 'package:cloud_firestore/cloud_firestore.dart';

class AdminData {
  final String id;
  final String uid;
  final String name;
  final String email;
  final String role;
  final String status;
  final String lastActive;
  final DateTime? createdAt;

  const AdminData({
    required this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.lastActive,
    this.createdAt,
  });

  factory AdminData.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final created = data['createdAt'];

    DateTime? createdAt;

    if (created is Timestamp) {
      createdAt = created.toDate();
    } else if (created is DateTime) {
      createdAt = created;
    }

    return AdminData(
      id: id,
      uid: (data['uid'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      role: (data['role'] ?? 'Admin').toString(),
      status: (data['status'] ?? 'Active').toString(),
      lastActive: (data['lastActive'] ?? '-').toString(),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'status': status,
      'lastActive': lastActive,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }
}
