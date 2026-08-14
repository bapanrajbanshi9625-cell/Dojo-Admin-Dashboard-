import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintData {
  final String id;
  final String userId;
  final String userName;
  final String subject;
  final String description;
  final String category;
  final String status;
  final String createdAt;

  const ComplaintData({
    required this.id,
    required this.userId,
    required this.userName,
    required this.subject,
    required this.description,
    required this.category,
    required this.status,
    required this.createdAt,
  });

  factory ComplaintData.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final timestamp = data['createdAt'];

    String date = 'Unknown';

    if (timestamp is Timestamp) {
      date = timestamp.toDate().toString();
    } else if (timestamp != null) {
      date = timestamp.toString();
    }

    return ComplaintData(
      id: id,
      userId: data['userId']?.toString() ?? '',
      userName: data['userName']?.toString() ?? 'Unknown User',
      subject: data['subject']?.toString() ?? 'No Subject',
      description: data['description']?.toString() ?? '',
      category: data['category']?.toString() ?? 'General',
      status: data['status']?.toString() ?? 'Pending',
      createdAt: date,
    );
  }
}
