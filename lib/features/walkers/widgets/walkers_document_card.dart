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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
              child: AspectRatio(
                aspectRatio: 1.55,
                child: Image.network(
                  documentUrl,
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
