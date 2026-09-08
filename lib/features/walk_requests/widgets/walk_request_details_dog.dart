// File:
// lib/features/walk_requests/widgets/walk_request_details_dog.dart

import 'package:flutter/material.dart';

class WalkRequestDetailsDog extends StatelessWidget {
  const WalkRequestDetailsDog({
    super.key,
    required this.dogName,
    required this.dogBreed,
    required this.dogPhoto,
  });

  final String dogName;
  final String dogBreed;
  final String dogPhoto;

  static const Color orange = Color(0xFFD35435);
  static const Color dark = Color(0xFF0F172A);
  static const Color grey = Color(0xFF64748B);
  static const Color white = Colors.white;
  static const Color border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Dog Details',
      icon: Icons.pets_rounded,
      child: Row(
        children: [
          _DogAvatar(photo: dogPhoto),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dogName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: dark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dogBreed,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  static const Color blue = Color(0xFF2563EB);
  static const Color dark = Color(0xFF0F172A);
  static const Color white = Colors.white;
  static const Color border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: blue,
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  color: dark,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _DogAvatar extends StatelessWidget {
  const _DogAvatar({
    required this.photo,
  });

  final String photo;

  static const Color orange = Color(0xFFD35435);

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        photo != '—' && photo.trim().isNotEmpty;

    return Container(
      width: 58,
      height: 58,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: orange.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: hasPhoto
          ? Image.network(
              photo,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.pets_rounded,
                  color: orange,
                );
              },
            )
          : const Icon(
              Icons.pets_rounded,
              color: orange,
            ),
    );
  }
}
