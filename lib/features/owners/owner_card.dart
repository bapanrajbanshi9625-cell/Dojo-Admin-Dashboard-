import 'package:flutter/material.dart';

import 'owner_data.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoDark = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);

class OwnerCard extends StatelessWidget {
  final OwnerData owner;
  final VoidCallback onView;

  const OwnerCard({
    super.key,
    required this.owner,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final active = owner.status == 'Active';
    final statusColor = active ? dojoGreen : dojoOrange;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 650) {
            return _mobile(statusColor);
          }

          return _desktop(statusColor);
        },
      ),
    );
  }

  Widget _desktop(Color statusColor) {
    return Row(
      children: [
        _avatar(),
        const SizedBox(width: 14),
        Expanded(
          flex: 3,
          child: _mainInfo(),
        ),
        Expanded(
          child: _info(
            Icons.phone_outlined,
            'Phone',
            owner.phone,
          ),
        ),
        Expanded(
          child: _info(
            Icons.pets_outlined,
            'Pets',
            '${owner.pets}',
          ),
        ),
        Expanded(
          child: _info(
            Icons.directions_walk_outlined,
            'Walks',
            '${owner.walks}',
          ),
        ),
        _statusChip(statusColor),
        const SizedBox(width: 12),
        _viewButton(),
      ],
    );
  }

  Widget _mobile(Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _avatar(),
            const SizedBox(width: 12),
            Expanded(child: _mainInfo()),
            _statusChip(statusColor),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _info(
                Icons.phone_outlined,
                'Phone',
                owner.phone,
              ),
            ),
            Expanded(
              child: _info(
                Icons.pets_outlined,
                'Pets',
                '${owner.pets}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _info(
                Icons.directions_walk_outlined,
                'Walks',
                '${owner.walks}',
              ),
            ),
            Expanded(
              child: _info(
                Icons.email_outlined,
                'Email',
                owner.email,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: _viewButton(),
        ),
      ],
    );
  }

  Widget _avatar() {
    if (owner.photoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(
          owner.photoUrl,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _defaultAvatar(),
        ),
      );
    }

    return _defaultAvatar();
  }

  Widget _defaultAvatar() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0F7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(
        Icons.person_outline,
        color: dojoBlue,
        size: 26,
      ),
    );
  }

  Widget _mainInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          owner.uid,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            color: dojoGrey,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          owner.name.isEmpty ? 'Unknown Owner' : owner.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: dojoDark,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          owner.email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            color: dojoGrey,
          ),
        ),
      ],
    );
  }

  Widget _info(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: dojoBlue,
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: dojoGrey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? '-' : value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusChip(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 7,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            owner.status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewButton() {
    return OutlinedButton.icon(
      onPressed: onView,
      icon: const Icon(
        Icons.visibility_outlined,
        size: 17,
      ),
      label: const Text('View'),
      style: OutlinedButton.styleFrom(
        foregroundColor: dojoOrange,
        side: const BorderSide(color: dojoOrange),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 11,
        ),
      ),
    );
  }
}
