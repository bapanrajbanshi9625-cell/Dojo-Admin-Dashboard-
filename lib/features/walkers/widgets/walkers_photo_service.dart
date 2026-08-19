import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class WalkersPhotoService {
  WalkersPhotoService({
    FirebaseStorage? storage,
    ImagePicker? picker,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _picker = picker ?? ImagePicker();

  final FirebaseStorage _storage;
  final ImagePicker _picker;

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<XFile?> pickImage() async {
    return _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
  }

  // ============================================================
  // UPLOAD PHOTO
  // ============================================================

  Future<String> uploadPhoto({
    required DocumentSnapshot<Map<String, dynamic>> doc,
    required String fieldName,
  }) async {
    final XFile? picked = await pickImage();

    if (picked == null) {
      throw const WalkersPhotoUploadCancelled();
    }

    final bytes = await picked.readAsBytes();

    if (bytes.isEmpty) {
      throw Exception(
        'Selected image is empty.',
      );
    }

    // ==========================================================
    // FILE EXTENSION
    // ==========================================================

    String extension = 'jpg';

    final fileName = picked.name.toLowerCase();

    if (fileName.endsWith('.png')) {
      extension = 'png';
    } else if (fileName.endsWith('.webp')) {
      extension = 'webp';
    } else if (fileName.endsWith('.jpeg')) {
      extension = 'jpeg';
    } else if (fileName.endsWith('.jpg')) {
      extension = 'jpg';
    }

    // ==========================================================
    // CONTENT TYPE
    // ==========================================================

    String contentType = 'image/jpeg';

    if (extension == 'png') {
      contentType = 'image/png';
    } else if (extension == 'webp') {
      contentType = 'image/webp';
    }

    // ==========================================================
    // SAFE FIELD NAME
    // ==========================================================

    final safeFieldName = fieldName
        .replaceAll(' ', '_')
        .replaceAll('/', '_')
        .toLowerCase();

    final timestamp =
        DateTime.now().millisecondsSinceEpoch;

    // ==========================================================
    // STORAGE PATH
    // ==========================================================

    final storagePath =
        'walkers/${doc.id}/admin_uploads/'
        '${safeFieldName}_$timestamp.$extension';

    final storageRef = _storage.ref().child(
      storagePath,
    );

    // ==========================================================
    // UPLOAD
    // ==========================================================

    await storageRef.putData(
      bytes,
      SettableMetadata(
        contentType: contentType,
      ),
    );

    // ==========================================================
    // DOWNLOAD URL
    // ==========================================================

    final downloadUrl =
        await storageRef.getDownloadURL();

    // ==========================================================
    // FIRESTORE
    // ==========================================================

    await doc.reference.update({
      fieldName: downloadUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return downloadUrl;
  }
}

// ============================================================
// UPLOAD CANCELLED
// ============================================================

class WalkersPhotoUploadCancelled
    implements Exception {
  const WalkersPhotoUploadCancelled();

  @override
  String toString() {
    return 'Image selection cancelled.';
  }
}
