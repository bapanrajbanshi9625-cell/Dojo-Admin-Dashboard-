import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils/walker_helpers.dart';
import 'walker_document_card.dart';
import 'walker_verification_card.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoDark = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);

const Color pendingColor = Color(0xFFD99000);
const Color rejectedColor = Color(0xFFC62828);

class WalkerDetailsSheet extends StatelessWidget {
  final DocumentSnapshot<Map<String, dynamic>> doc;
  final Map<String, dynamic> data;

  final VoidCallback onApprove;
  final VoidCallback onReject;

  const WalkerDetailsSheet({
    super.key,
    required this.doc,
    required this.data,
    required this.onApprove,
    required this.onReject,
  });

  String get walkerId => WalkerHelpers.walkerId(doc);

  String get uid => WalkerHelpers.uid(doc);

  String get name => WalkerHelpers.name(data);

  String get phone => WalkerHelpers.phone(data);

  String get email => WalkerHelpers.email(data);

  String get dob => WalkerHelpers.dateOfBirth(data);

  String get address => WalkerHelpers.address(data);

  String get pincode => WalkerHelpers.pincode(data);

  String get aadhaarNumber =>
      WalkerHelpers.aadhaarNumber(data);

  String get profileSelfie =>
      WalkerHelpers.profileImage(data);

  String get aadhaarFront =>
      WalkerHelpers.aadhaarFront(data);

  String get aadhaarBack =>
      WalkerHelpers.aadhaarBack(data);

  bool get aadhaarFrontUploaded =>
      WalkerHelpers.aadhaarFrontUploaded(data);

  bool get aadhaarBackUploaded =>
      WalkerHelpers.aadhaarBackUploaded(data);

  bool get profileCompleted =>
      WalkerHelpers.profileCompleted(data);

  String get verificationStatus =>
      WalkerHelpers.verificationStatus(data);

  Color get statusColor {
    switch (verificationStatus) {
      case 'approved':
        return dojoGreen;
      case 'rejected':
        return rejectedColor;
      default:
        return pendingColor;
    }
  }

  String get statusLabel {
    switch (verificationStatus) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 720,
      ),
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _handle(),
            const SizedBox(height: 16),
            _header(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Identity'),
                    _identityCard(),

                    const SizedBox(height: 14),

                    _sectionTitle('Verification'),
                    WalkerVerificationCard(
                      data: data,
                    ),

                    const SizedBox(height: 14),

                    _sectionTitle('Documents'),
                    _documents(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            _actionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _handle() {
    return Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: dojoBorder,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        _profileAvatar(),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                name.isEmpty ? 'Walker' : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: dojoDark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                walkerId.isEmpty
                    ? 'Walker ID not set'
                    : walkerId,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: dojoOrange,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        _statusChip(),
      ],
    );
  }

  Widget _profileAvatar() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0F7),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: profileSelfie.isNotEmpty
          ? Image.network(
              profileSelfie,
              fit: BoxFit.cover,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons.person_outline,
                  color: dojoBlue,
                  size: 29,
                );
              },
            )
          : const Icon(
              Icons.person_outline,
              color: dojoBlue,
              size: 29,
            ),
    );
  }

  Widget _statusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusLabel,
        style: TextStyle(
          color: statusColor,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: dojoDark,
        ),
      ),
    );
  }

  Widget _identityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Column(
        children: [
          _row('Walker ID', walkerId),
          _row('Auth UID', uid),
          _row('Full Name', name),
          _row('Mobile', phone),
          _row('Email', email),
          _row('Date Of Birth', dob),
          _row('Address', address),
          _row('Pincode', pincode),
          _row('Aadhaar', aadhaarNumber),
        ],
      ),
    );
  }

  Widget _row(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 9,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: dojoGrey,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value.isEmpty ? 'Not set' : value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: dojoDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _documents() {
    return Column(
      children: [
        WalkerDocumentCard(
          title: 'Profile Selfie',
          icon: Icons.person_outline,
          url: profileSelfie,
        ),
        const SizedBox(height: 10),
        WalkerDocumentCard(
          title: 'Aadhaar Front',
          icon: Icons.credit_card_outlined,
          url: aadhaarFront,
        ),
        const SizedBox(height: 10),
        WalkerDocumentCard(
          title: 'Aadhaar Back',
          icon: Icons.credit_card_outlined,
          url: aadhaarBack,
        ),
      ],
    );
  }

  Widget _actionButtons() {
    if (verificationStatus == 'approved') {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.verified),
          label: const Text(
            'Walker Approved',
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onReject,
            icon: const Icon(Icons.close),
            label: const Text('Reject'),
            style: OutlinedButton.styleFrom(
              foregroundColor: rejectedColor,
              side: const BorderSide(
                color: rejectedColor,
              ),
              minimumSize:
                  const Size(0, 48),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onApprove,
            icon: const Icon(
              Icons.check_circle_outline,
            ),
            label: const Text('Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: dojoGreen,
              foregroundColor: Colors.white,
              minimumSize:
                  const Size(0, 48),
            ),
          ),
        ),
      ],
    );
  }
}
