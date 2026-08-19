import 'package:flutter/material.dart';

import 'walkers_details_photo_card.dart';
import 'walkers_details_upload_button.dart';
import 'walkers_details_helpers.dart';

class WalkerDetailsDocuments extends StatelessWidget {
  final String selfie;
  final String aadhaarFront;
  final String aadhaarBack;

  final Set<String> uploadingFields;
  final void Function(String title, String imageUrl) onOpenImage;
  final VoidCallback onUploadSelfie;
  final VoidCallback onUploadAadhaarFront;
  final VoidCallback onUploadAadhaarBack;

  const WalkerDetailsDocuments({
    super.key,
    required this.selfie,
    required this.aadhaarFront,
    required this.aadhaarBack,
    required this.uploadingFields,
    required this.onOpenImage,
    required this.onUploadSelfie,
    required this.onUploadAadhaarFront,
    required this.onUploadAadhaarBack,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        WalkerDetailsPhotoCard(
          title: 'Profile Selfie',
          imageUrl: selfie,
          icon: Icons.person_rounded,
          onTap: selfie.trim().isEmpty
              ? null
              : () {
                  onOpenImage(
                    'Profile Selfie',
                    selfie,
                  );
                },
          uploadButton: WalkerDetailsUploadButton(
            fieldName: 'Profile Selfie',
            title: 'Profile Selfie',
            uploading: uploadingFields.contains(
              'Profile Selfie',
            ),
            onPressed: onUploadSelfie,
          ),
        ),

        WalkerDetailsPhotoCard(
          title: 'Aadhaar Front',
          imageUrl: aadhaarFront,
          icon: Icons.credit_card,
          onTap: aadhaarFront.trim().isEmpty
              ? null
              : () {
                  onOpenImage(
                    'Aadhaar Front',
                    aadhaarFront,
                  );
                },
          uploadButton: WalkerDetailsUploadButton(
            fieldName: 'Aadhar Front',
            title: 'Aadhaar Front',
            uploading: uploadingFields.contains(
              'Aadhar Front',
            ),
            onPressed: onUploadAadhaarFront,
          ),
        ),

        WalkerDetailsPhotoCard(
          title: 'Aadhaar Back',
          imageUrl: aadhaarBack,
          icon: Icons.credit_card,
          onTap: aadhaarBack.trim().isEmpty
              ? null
              : () {
                  onOpenImage(
                    'Aadhaar Back',
                    aadhaarBack,
                  );
                },
          uploadButton: WalkerDetailsUploadButton(
            fieldName: 'Aadhar Back',
            title: 'Aadhaar Back',
            uploading: uploadingFields.contains(
              'Aadhar Back',
            ),
            onPressed: onUploadAadhaarBack,
          ),
        ),
      ],
    );
  }
}
