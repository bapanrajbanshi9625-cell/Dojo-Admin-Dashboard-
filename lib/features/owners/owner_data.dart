class OwnerData {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final int pets;
  final int walks;
  final String status;
  final String photoUrl;

  const OwnerData({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.pets,
    required this.walks,
    required this.status,
    required this.photoUrl,
  });

  factory OwnerData.fromFirestore(
    String uid,
    Map<String, dynamic> data,
  ) {
    return OwnerData(
      uid: uid,
      name: data['name']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      pets: _toInt(data['pets']),
      walks: _toInt(data['walks']),
      status: data['status']?.toString() ?? 'Active',
      photoUrl: data['photoUrl']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
