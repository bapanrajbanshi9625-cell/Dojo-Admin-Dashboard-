import 'package:flutter/material.dart';

import 'walker_helpers.dart';

class WalkerDetailsSheet extends StatelessWidget {
  final dynamic walker;

  const WalkerDetailsSheet({
    super.key,
    required this.walker,
  });

  @override
  Widget build(BuildContext context) {
    final name = WalkerHelpers.name(walker);
    final mobile = WalkerHelpers.mobile(walker);
    final address = WalkerHelpers.address(walker);
    final pincode = WalkerHelpers.pincode(walker);
    final dob = WalkerHelpers.dateOfBirth(walker);
    final aadhaar = WalkerHelpers.aadhaarNumber(walker);
    final uid = WalkerHelpers.walkerUid(walker);
    final selfie = WalkerHelpers.profileSelfie(walker);
    final status = WalkerHelpers.status(walker);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  _profileImage(
                    selfie,
                    name,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _statusBadge(status),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Walker Information',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 12),

              _infoTile(
                icon: Icons.phone_outlined,
                title: 'Mobile number',
                value: mobile,
              ),

              _infoTile(
                icon: Icons.cake_outlined,
                title: 'Date Of Birth',
                value: dob,
              ),

              _infoTile(
                icon: Icons.location_on_outlined,
                title: 'Address',
                value: address,
              ),

              _infoTile(
                icon: Icons.pin_drop_outlined,
                title: 'Pincode',
                value: pincode,
              ),

              _infoTile(
                icon: Icons.badge_outlined,
                title: 'Aadhar Number',
                value: aadhaar,
              ),

              _infoTile(
                icon: Icons.fingerprint,
                title: 'Walker Uid',
                value: uid,
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(
                      color: Color(0xFFE5E7EB),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileImage(
    String imageUrl,
    String name,
  ) {
    if (imageUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _initialAvatar(name);
          },
        ),
      );
    }

    return _initialAvatar(name);
  }

  Widget _initialAvatar(String name) {
    return CircleAvatar(
      radius: 32,
      backgroundColor: const Color(0xFFFFF1E8),
      child: Text(
        WalkerHelpers.initials(walker),
        style: const TextStyle(
          color: Color(0xFFFF6600),
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final displayStatus =
        status.isEmpty ? 'Pending' : status;

    final color =
        WalkerHelpers.statusColor(displayStatus);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    final displayValue =
        value.isEmpty ? 'Not available' : value;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 21,
            color: const Color(0xFFFF6600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  displayValue,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
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
