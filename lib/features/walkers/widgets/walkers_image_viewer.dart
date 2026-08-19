import 'package:flutter/material.dart';

import 'walkers_details_helpers.dart';

/// ============================================================
/// WALKER IMAGE VIEWER
/// ============================================================
///
/// Opens walker photos/documents in a dialog.
///
/// Features:
/// - Zoom
/// - Pan
/// - Loading indicator
/// - Error handling
/// - Close button
/// ============================================================

void showWalkerImageViewer(
  BuildContext context, {
  required String title,
  required String imageUrl,
}) {
  final url = imageUrl.trim();

  // ==========================================================
  // IMAGE NOT AVAILABLE
  // ==========================================================

  if (url.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Image is not available.',
        ),
      ),
    );

    return;
  }

  // ==========================================================
  // IMAGE DIALOG
  // ==========================================================

  showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 700,
            maxHeight: 850,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  12,
                  8,
                  10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: walkerDetailsTextDark,
                        ),
                      ),
                    ),

                    IconButton(
                      tooltip: 'Close',
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // DIVIDER
              // ==================================================

              const Divider(
                height: 1,
                color: walkerDetailsBorder,
              ),

              // ==================================================
              // IMAGE
              // ==================================================

              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        url,
                        fit: BoxFit.contain,

                        // ========================================
                        // LOADING
                        // ========================================

                        loadingBuilder: (
                          context,
                          child,
                          loadingProgress,
                        ) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return const SizedBox(
                            height: 350,
                            width: double.infinity,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: walkerDetailsOrange,
                              ),
                            ),
                          );
                        },

                        // ========================================
                        // ERROR
                        // ========================================

                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const SizedBox(
                            height: 350,
                            width: double.infinity,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.broken_image_outlined,
                                    size: 55,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Unable to load image',
                                    style: TextStyle(
                                      color:
                                          walkerDetailsTextGrey,
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
