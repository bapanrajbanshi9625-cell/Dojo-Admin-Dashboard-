import 'package:flutter/material.dart';

import 'walkers_helpers.dart';
import 'walkers_image_viewer.dart';

class WalkersPhotoCard extends StatelessWidget {
  const WalkersPhotoCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.icon,
  });

  final String title;
  final String imageUrl;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.trim().isNotEmpty;

    return Container(
      width: 150,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: walkerDetailsBorder,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(9),
            onTap: hasImage
                ? () {
                    showWalkerImageViewer(
                      context,
                      title: title,
                      imageUrl: imageUrl,
                    );
                  }
                : null,
            child: Container(
              height: 95,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(9),
              ),
              child: hasImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return Icon(
                            icon,
                            size: 38,
                            color: Colors.grey,
                          );
                        },
                      ),
                    )
                  : Icon(
                      icon,
                      size: 38,
                      color: Colors.grey,
                    ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: walkerDetailsTextDark,
            ),
          ),

          const SizedBox(height: 5),

          if (hasImage)
            InkWell(
              onTap: () {
                showWalkerImageViewer(
                  context,
                  title: title,
                  imageUrl: imageUrl,
                );
              },
              child: const Text(
                'Tap to view',
                style: TextStyle(
                  fontSize: 9,
                  color: walkerDetailsOrange,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else
            const Text(
              'Not available',
              style: TextStyle(
                fontSize: 9,
                color: walkerDetailsTextGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
