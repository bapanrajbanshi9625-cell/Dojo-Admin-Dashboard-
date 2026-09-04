import 'package:flutter/material.dart';

class WalkersDocumentCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String url;
  final Color roleColor;

  const WalkersDocumentCard({
    super.key,
    required this.title,
    required this.icon,
    required this.url,
    this.roleColor = const Color(0xFFFF6600),
  });

  void _openFullScreen(BuildContext context) {
    final documentUrl = url.trim();

    if (documentUrl.isEmpty) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _DocumentViewerScreen(
          title: title,
          imageUrl: documentUrl,
          roleColor: roleColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final documentUrl = url.trim();
    final uploaded = documentUrl.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 21,
                  color: roleColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                Text(
                  uploaded ? 'Uploaded' : 'Not Uploaded',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: uploaded
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),

          if (uploaded)
            GestureDetector(
              onTap: () => _openFullScreen(context),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.55,
                      child: Image.network(
                        documentUrl,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        loadingBuilder:
                            (context, child, progress) {
                          if (progress == null) {
                            return child;
                          }

                          return Center(
                            child: CircularProgressIndicator(
                              color: roleColor,
                            ),
                          );
                        },
                        errorBuilder:
                            (context, error, stackTrace) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.broken_image_outlined,
                                    size: 40,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Unable to load document',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.zoom_in,
                              size: 16,
                              color: Colors.white,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'View',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.fromLTRB(
                14,
                0,
                14,
                14,
              ),
              child: Text(
                'Document has not been uploaded.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DocumentViewerScreen extends StatelessWidget {
  final String title;
  final String imageUrl;
  final Color roleColor;

  const _DocumentViewerScreen({
    required this.title,
    required this.imageUrl,
    required this.roleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 5.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder:
                (context, child, progress) {
              if (progress == null) {
                return child;
              }

              return CircularProgressIndicator(
                color: roleColor,
              );
            },
            errorBuilder:
                (context, error, stackTrace) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    size: 52,
                    color: Colors.white54,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Unable to load document',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
