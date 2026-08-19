import 'package:flutter/material.dart';

import 'walkers_helpers.dart';

class WalkersUploadButton extends StatelessWidget {
  const WalkersUploadButton({
    super.key,
    required this.fieldName,
    required this.title,
    required this.uploading,
    required this.onPressed,
  });

  final String fieldName;
  final String title;
  final bool uploading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: OutlinedButton.icon(
        onPressed: uploading ? null : onPressed,
        icon: uploading
            ? const SizedBox(
                height: 14,
                width: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: walkerDetailsOrange,
                ),
              )
            : const Icon(
                Icons.upload_rounded,
                size: 16,
              ),
        label: Text(
          uploading ? 'Uploading...' : 'Upload',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: walkerDetailsOrange,
          side: BorderSide(
            color: walkerDetailsOrange.withValues(
              alpha: 0.55,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
