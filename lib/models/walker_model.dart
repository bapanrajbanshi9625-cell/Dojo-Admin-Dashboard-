import 'package:cloud_firestore/cloud_firestore.dart';

class WalkerModel {
  final String uid;
  final String name;
  final String mobile;
  final String email;
  final String profileImage;
  final String role;
  final bool isActive;
  final bool isOnline;
  final bool isVerified;
  final double rating;
  final int totalWalks;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WalkerModel({
    required this.uid,
    this.name = '',
    this.mobile = '',
    this.email = '',
    this.profileImage = '',
    this.role = 'walker',
    this.isActive = true,
    this.isOnline = false,
    this.isVerified = false,
    this.rating = 0,
    this.totalWalks = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory WalkerModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return WalkerModel.fromMap(
      data,
      documentId: doc.id,
    );
  }

  factory WalkerModel.fromMap(
    Map<String, dynamic> data, {
    String? documentId,
  }) {
    return WalkerModel(
      uid: documentId ?? _string(data['uid']),
      name: _string(data['name']),
      mobile: _string(
        data['mobile'] ??
            data['phone'] ??
            data['phoneNumber'],
      ),
      email: _string(data['email']),
      profileImage: _string(
        data['profileImage'] ??
            data['profileImageUrl'],
      ),
      role: _string(data['role']).isEmpty
          ? 'walker'
          : _string(data['role']),
      isActive: _bool(
        data['isActive'],
        fallback: true,
      ),
      isOnline: _bool(
        data['isOnline'],
      ),
      isVerified: _bool(
        data['isVerified'],
      ),
      rating: _double(data['rating']),
      totalWalks: _int(
        data['totalWalks'] ??
            data['completedWalks'],
      ),
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
      'isOnline': isOnline,
      'isVerified': isVerified,
      'rating': rating,
      'totalWalks': totalWalks,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'updatedAt': updatedAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(updatedAt!),
    };
  }

  WalkerModel copyWith({
    String? uid,
    String? name,
    String? mobile,
    String? email,
    String? profileImage,
    String? role,
    bool? isActive,
    bool? isOnline,
    bool? isVerified,
    double? rating,
    int? totalWalks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalkerModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isOnline: isOnline ?? this.isOnline,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      totalWalks: totalWalks ?? this.totalWalks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String _string(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static bool _bool(
    dynamic value, {
    bool fallback = false,
  }) {
    if (value is bool) return value;
    return fallback;
  }

  static double _double(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static int _int(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
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
