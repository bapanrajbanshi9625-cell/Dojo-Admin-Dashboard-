import 'package:flutter/material.dart';

// ============================================================
// DOJO DASHBOARD COLORS
// ============================================================

const Color background = Color(0xFFF7F8FA);
const Color dark = Color(0xFF263238);
const Color grey = Color(0xFF6B7280);
const Color border = Color(0xFFE7E9ED);

const Color orange = Color(0xFFD35435);
const Color blue = Color(0xFF3F6FA5);
const Color green = Color(0xFF3F8F68);

// ============================================================
// STAT CARD
// ============================================================

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 92,
          ),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withValues(
                    alpha: .10,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 21,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w600,
                        color: grey,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      value,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight:
                            FontWeight.w900,
                        color: dark,
                      ),
                    ),
                  ],
                ),
              ),

              if (onTap != null)
                const Icon(
                  Icons.chevron_right,
                  size: 19,
                  color: grey,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ACTION BUTTON
// ============================================================

class ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 120,
            minHeight: 46,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: color,
              ),

              const SizedBox(width: 8),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: dark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DATA PANEL
// ============================================================

class DataPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  final VoidCallback? onTap;

  const DataPanel({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: .10,
                  ),
                  borderRadius:
                      BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: color,
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w800,
                    color: dark,
                  ),
                ),
              ),

              if (onTap != null)
                InkWell(
                  onTap: onTap,
                  borderRadius:
                      BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.chevron_right,
                      size: 19,
                      color: grey,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          child,
        ],
      ),
    );
  }
}

// ============================================================
// EMPTY MESSAGE
// ============================================================

class EmptyMessage extends StatelessWidget {
  final String text;

  const EmptyMessage({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 28,
            color: grey,
          ),

          const SizedBox(height: 8),

          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PHOTO AVATAR
// ============================================================

Widget photoAvatar({
  required String? imageUrl,
  required IconData icon,
  required Color color,
  double size = 40,
}) {
  final hasImage =
      imageUrl != null &&
      imageUrl.trim().isNotEmpty;

  return Container(
    width: size,
    height: size,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: color.withValues(
        alpha: .10,
      ),
      borderRadius: BorderRadius.circular(
        size * .25,
      ),
    ),
    child: hasImage
        ? Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return Icon(
                icon,
                color: color,
                size: size * .48,
              );
            },
          )
        : Icon(
            icon,
            color: color,
            size: size * .48,
          ),
  );
}
