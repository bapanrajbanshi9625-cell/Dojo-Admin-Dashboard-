import 'package:cloud_firestore/cloud_firestore.dart';

class OwnerModel {
  final String uid;
  final String name;
  final String mobile;
  final String email;
  final String profileImage;
  final String role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OwnerModel({
    required this.uid,
    this.name = '',
    this.mobile = '',
    this.email = '',
    this.profileImage = '',
    this.role = 'owner',
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory OwnerModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return OwnerModel(
      uid: doc.id,
      name: _string(data['name']),
      mobile: _string(
        data['mobile'] ?? data['phone'] ?? data['phoneNumber'],
      ),
      email: _string(data['email']),
      profileImage: _string(
        data['profileImage'] ?? data['profileImageUrl'],
      ),
      role: _string(data['role']).isEmpty
          ? 'owner'
          : _string(data['role']),
      isActive: data['isActive'] is bool
          ? data['isActive'] as bool
          : true,
      createdAt: _date(data['createdAt']),
      updatedAt: _date(data['updatedAt']),
    );
  }

  factory OwnerModel.fromMap(
    Map<String, dynamic> data, {
    String? documentId,
  }) {
    return OwnerModel(
      uid: documentId ?? _string(data['uid']),
      name: _string(data['name']),
      mobile: _string(
        data['mobile'] ?? data['phone'] ?? data['phoneNumber'],
      ),
      email: _string(data['email']),
      profileImage: _string(
        data['profileImage'] ?? data['profileImageUrl'],
      ),
      role: _string(data['role']).isEmpty
          ? 'owner'
          : _string(data['role']),
      isActive: data['isActive'] is bool
          ? data['isActive'] as bool
          : true,
      createdAt: _date(data['createdAt']),
      updatedAt: _date(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'mobile': mobile,
      'email': email,
      'profileImage': profileImage,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'updatedAt': updatedAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(updatedAt!),
    };
  }

  OwnerModel copyWith({
    String? uid,
    String? name,
    String? mobile,
    String? email,
    String? profileImage,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OwnerModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String _string(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static DateTime? _date(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}
