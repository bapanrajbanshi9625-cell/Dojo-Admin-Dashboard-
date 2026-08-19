import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class WalkerDetailsUploadService {
  WalkerDetailsUploadService({
    ImagePicker? picker,
  }) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<String?> pickAndUpload({
    required BuildContext context,
    required DocumentSnapshot<Map<String, dynamic>> doc,
    required Map<String, dynamic> data,
    required String fieldName,
    required String title,
  }) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (picked == null) {
        return null;
      }

      final bytes = await picked.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception('Selected image is empty.');
      }

      final extension = _getExtension(
        picked.name,
      );

      final contentType = _getContentType(
        extension,
      );

      final safeFieldName = fieldName
          .replaceAll(' ', '_')
          .replaceAll('/', '_')
          .toLowerCase();

      final timestamp =
          DateTime.now().millisecondsSinceEpoch;

      final storagePath =
          'walkers/${doc.id}/admin_uploads/'
          '${safeFieldName}_$timestamp.$extension';

      final storageRef =
          FirebaseStorage.instance.ref().child(
                storagePath,
              );

      await storageRef.putData(
        bytes,
        SettableMetadata(
          contentType: contentType,
        ),
      );

      final downloadUrl =
          await storageRef.getDownloadURL();

      await doc.reference.update({
        fieldName: downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      data[fieldName] = downloadUrl;

      if (!context.mounted) {
        return downloadUrl;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$title uploaded successfully.',
          ),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );

      return downloadUrl;
    } catch (e) {
      if (!context.mounted) {
        return null;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Upload failed: $e',
          ),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );

      return null;
    }
  }

  String _getExtension(String fileName) {
    final name = fileName.toLowerCase();

    if (name.endsWith('.png')) {
      return 'png';
    }

    if (name.endsWith('.webp')) {
      return 'webp';
    }

    if (name.endsWith('.jpeg')) {
      return 'jpeg';
    }

    if (name.endsWith('.jpg')) {
      return 'jpg';
    }

    return 'jpg';
  }

  String _getContentType(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';

      case 'webp':
        return 'image/webp';

      case 'jpeg':
      case 'jpg':
      default:
        return 'image/jpeg';
    }
  }
}
