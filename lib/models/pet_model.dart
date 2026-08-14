import 'package:cloud_firestore/cloud_firestore.dart';

class PetModel {
  final String id;
  final String ownerId;
  final String name;
  final String breed;
  final String type;
  final String gender;
  final String profileImage;
  final int age;
  final double weight;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PetModel({
    required this.id,
    this.ownerId = '',
    this.name = '',
    this.breed = '',
    this.type = 'dog',
    this.gender = '',
    this.profileImage = '',
    this.age = 0,
    this.weight = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory PetModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return PetModel.fromMap(
      doc.data() ?? {},
      documentId: doc.id,
    );
  }

  factory PetModel.fromMap(
    Map<String, dynamic> data, {
    String? documentId,
  }) {
    return PetModel(
      id: documentId ?? _string(data['id']),
      ownerId: _string(data['ownerId']),
      name: _string(data['name']),
      breed: _string(data['breed']),
      type: _string(data['type']).isEmpty
          ? 'dog'
          : _string(data['type']),
      gender: _string(data['gender']),
      profileImage: _string(
        data['profileImage'] ??
            data['profileImageUrl'],
      ),
      age: _int(data['age']),
      weight: _double(data['weight']),
      isActive: data['isActive'] is bool
          ? data['isActive'] as bool
          : true,
      createdAt: _date(data['createdAt']),
      updatedAt: _date(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'breed': breed,
      'type': type,
      'gender': gender,
      'profileImage': profileImage,
      'age': age,
      'weight': weight,
      'isActive': isActive,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'updatedAt': updatedAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(updatedAt!),
    };
  }

  PetModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? breed,
    String? type,
    String? gender,
    String? profileImage,
    int? age,
    double? weight,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PetModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      type: type ?? this.type,
      gender: gender ?? this.gender,
      profileImage:
          profileImage ?? this.profileImage,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String _string(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static int _int(dynamic value) {
    if (value is num) return value.toInt();

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static double _double(dynamic value) {
    if (value is num) return value.toDouble();

    return double.tryParse(
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
