import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoGrey = Color(0xFF6B7280);

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final Color? backgroundColor;
  final bool showOnline;
  final bool showBorder;

  const UserAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 42,
    this.backgroundColor,
    this.showOnline = false,
    this.showBorder = false,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.isEmpty || name.trim().isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first.substring(
        0,
        1,
      ).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
            '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? const Color(0xFFFFEEE9),
        border: showBorder
            ? Border.all(
                color: Colors.white,
                width: 2,
              )
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl!.trim().isNotEmpty
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return _initials();
              },
            )
          : _initials(),
    );

    if (!showOnline) {
      return avatar;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: size * .28,
            height: size * .28,
            decoration: BoxDecoration(
              color: dojoGreen,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _initials() {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: dojoOrange,
          fontSize: size * .32,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
