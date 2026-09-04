import 'package:flutter/material.dart';

import 'walkers_details_image_viewer.dart';
import 'walkers_details_photo_card.dart';

class WalkerDetailsDocuments extends StatelessWidget {
  final String selfie;
  final String aadhaarFront;
  final String aadhaarBack;
  final String panCard;

  const WalkerDetailsDocuments({
    super.key,
    required this.selfie,
    required this.aadhaarFront,
    required this.aadhaarBack,
    required this.panCard,
  });

  void _openImage(
    BuildContext context,
    String title,
    String imageUrl,
  ) {
    WalkerDetailsImageViewer.open(
      context,
      title: title,
      imageUrl: imageUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        // ======================================================
        // PROFILE SELFIE
        // ======================================================

        WalkerDetailsPhotoCard(
          title: 'Profile Selfie',
          imageUrl: selfie,
          icon: Icons.person_rounded,
          onTap: selfie.trim().isEmpty
              ? null
              : () {
                  _openImage(
                    context,
                    'Profile Selfie',
                    selfie,
                  );
                },
        ),

        // ======================================================
        // AADHAAR FRONT
        // ======================================================

        WalkerDetailsPhotoCard(
          title: 'Aadhaar Front',
          imageUrl: aadhaarFront,
          icon: Icons.credit_card_rounded,
          onTap: aadhaarFront.trim().isEmpty
              ? null
              : () {
                  _openImage(
                    context,
                    'Aadhaar Front',
                    aadhaarFront,
                  );
                },
        ),

        // ======================================================
        // AADHAAR BACK
        // ======================================================

        WalkerDetailsPhotoCard(
          title: 'Aadhaar Back',
          imageUrl: aadhaarBack,
          icon: Icons.credit_card_rounded,
          onTap: aadhaarBack.trim().isEmpty
              ? null
              : () {
                  _openImage(
                    context,
                    'Aadhaar Back',
                    aadhaarBack,
                  );
                },
        ),

        // ======================================================
        // PAN CARD
        // ======================================================

        WalkerDetailsPhotoCard(
          title: 'PAN Card',
          imageUrl: panCard,
          icon: Icons.badge_rounded,
          onTap: panCard.trim().isEmpty
              ? null
              : () {
                  _openImage(
                    context,
                    'PAN Card',
                    panCard,
                  );
                },
        ),
      ],
    );
  }
}
