import 'package:flutter/material.dart';

/// ===============================================================
/// DOJO ADMIN — DASHBOARD DESIGN SYSTEM
/// Primary  : Orange
/// Secondary: Blue
/// Style    : Light / Professional / Responsive
/// ===============================================================

const Color orange = Color(0xFFD35435);
const Color blue = Color(0xFF2563EB);
const Color green = Color(0xFF16A34A);
const Color dark = Color(0xFF0F172A);
const Color grey = Color(0xFF64748B);
const Color background = Color(0xFFF8FAFC);
const Color border = Color(0xFFE2E8F0);

const Color danger = Color(0xFFDC2626);
const Color warning = Color(0xFFD97706);

/// ===============================================================
/// DATA PANEL
/// ===============================================================

class DataPanel extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const DataPanel({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  State<DataPanel> createState() => _DataPanelState();
}

class _DataPanelState extends State<DataPanel> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) {
        if (mounted) {
          setState(() => _hovered = true);
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() => _hovered = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: double.infinity,
        transform: Matrix4.identity()
          ..translate(
            0.0,
            _hovered ? -1.5 : 0.0,
          ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hovered
                ? widget.color.withValues(alpha: 0.28)
                : border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: _hovered ? 0.055 : 0.025,
              ),
              blurRadius: _hovered ? 18 : 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: dark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 17),
            child,
          ],
        ),
      ),
    );
  }
}

/// ===============================================================
/// EMPTY MESSAGE
/// ===============================================================

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
      constraints: const BoxConstraints(
        minHeight: 100,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 20,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: blue.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 19,
              color: blue,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: grey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================================================
/// STAT CARD
/// ===============================================================

class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        if (mounted) {
          setState(() => _hovered = true);
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() => _hovered = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(17),
        transform: Matrix4.identity()
          ..translate(
            0.0,
            _hovered ? -2.0 : 0.0,
          ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: _hovered
                ? widget.iconColor.withValues(alpha: 0.25)
                : border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: _hovered ? 0.055 : 0.025,
              ),
              blurRadius: _hovered ? 18 : 11,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: widget.iconColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: grey,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 23,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                      color: dark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================================================
/// ACTION BUTTON
/// ===============================================================

class ActionButton extends StatefulWidget {
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
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        if (mounted) {
          setState(() => _hovered = true);
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() {
            _hovered = false;
            _pressed = false;
          });
        }
      },
      child: GestureDetector(
        onTapDown: (_) {
          if (mounted) {
            setState(() => _pressed = true);
          }
        },
        onTapUp: (_) {
          if (mounted) {
            setState(() => _pressed = false);
          }
        },
        onTapCancel: () {
          if (mounted) {
            setState(() => _pressed = false);
          }
        },
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 10,
          ),
          transform: Matrix4.identity()
            ..scale(_pressed ? 0.97 : 1.0),
          decoration: BoxDecoration(
            color: _hovered
                ? widget.color.withValues(alpha: 0.13)
                : widget.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: widget.color.withValues(
                alpha: _hovered ? 0.28 : 0.18,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: widget.color,
              ),
              const SizedBox(width: 7),
              Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===============================================================
/// PHOTO AVATAR
/// ===============================================================

Widget photoAvatar({
  required String? imageUrl,
  required IconData icon,
  required Color color,
}) {
  final String? cleanUrl =
      imageUrl?.trim().isNotEmpty == true
          ? imageUrl!.trim()
          : null;

  return Container(
    width: 44,
    height: 44,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: color.withValues(alpha: 0.10),
      ),
    ),
    child: cleanUrl != null
        ? Image.network(
            cleanUrl,
            fit: BoxFit.cover,
            loadingBuilder: (
              context,
              child,
              loadingProgress,
            ) {
              if (loadingProgress == null) {
                return child;
              }

              return Center(
                child: SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: loadingProgress.expectedTotalBytes !=
                            null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: color,
                  ),
                ),
              );
            },
            errorBuilder: (_, __, ___) {
              return Center(
                child: Icon(
                  icon,
                  color: color,
                  size: 21,
                ),
              );
            },
          )
        : Center(
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),
  );
}
