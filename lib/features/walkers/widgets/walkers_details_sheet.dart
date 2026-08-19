import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'walkers_document_card.dart';
import 'walkers_header.dart';
import 'walkers_verification_card.dart';

class WalkerDetailsSheet extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>> doc;
  final Map<String, dynamic>? data;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const WalkerDetailsSheet({
    super.key,
    required this.doc,
    this.data,
    this.onApprove,
    this.onReject,
  });

  @override
  State<WalkerDetailsSheet> createState() =>
      _WalkerDetailsSheetState();
}

class _WalkerDetailsSheetState
    extends State<WalkerDetailsSheet> {
  static const Color walkerOrange =
      Color(0xFFFF6600);

  static const Color textColor =
      Color(0xFF111827);

  static const Color secondaryText =
      Color(0xFF6B7280);

  static const Color borderColor =
      Color(0xFFE5E7EB);

  Map<String, dynamic> get _data {
    return widget.data ??
        widget.doc.data() ??
        <String, dynamic>{};
  }

  String _readValue(
    List<String> keys, [
    String fallback = '',
  ]) {
    for (final key in keys) {
      final value = _data[key];

      if (value != null &&
          value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return fallback;
  }

  bool _readBool(List<String> keys) {
    for (final key in keys) {
      final value = _data[key];

      if (value is bool) {
        return value;
      }

      if (value is num) {
        return value != 0;
      }

      if (value is String) {
        final normalized =
            value.trim().toLowerCase();

        if (normalized == 'true' ||
            normalized == 'yes' ||
            normalized == '1') {
          return true;
        }

        if (normalized == 'false' ||
            normalized == 'no' ||
            normalized == '0') {
          return false;
        }
      }
    }

    return false;
  }

  String _readTimestamp(List<String> keys) {
    for (final key in keys) {
      final value = _data[key];

      if (value == null) continue;

      if (value is Timestamp) {
        return _formatDateTime(value.toDate());
      }

      if (value is DateTime) {
        return _formatDateTime(value);
      }

      final text = value.toString().trim();

      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
  }

  String get _name => _readValue(
        const [
          'Full Name',
          'fullName',
          'name',
          'walkerName',
        ],
        'Unknown Walker',
      );

  String get _mobile => _readValue(
        const [
          'Mobile number',
          'phoneNumber',
          'mobileNumber',
          'mobile',
          'phone',
        ],
      );

  String get _walkerId => _readValue(
        const [
          'walkerId',
          'Walker ID',
        ],
      );

  String get _uid => _readValue(
        const [
          'authUid',
          'Walker Uid',
          'walkerUid',
          'uid',
        ],
        widget.doc.id,
      );

  String get _gender => _readValue(
        const [
          'gender',
          'Gender',
        ],
      );

  String get _dob => _readValue(
        const [
          'dateofbirth',
          'Date Of Birth',
          'dateOfBirth',
          'dob',
        ],
      );

  String get _role => _readValue(
        const [
          'role',
          'Role',
        ],
        'walker',
      );

  String get _aadhaarNumber => _readValue(
        const [
          'Aadhar Number',
          'Aadhaar Number',
          'aadhaarNumber',
          'aadharNumber',
        ],
      );

  String get _selfie => _readValue(
        const [
          'Profile Selfie',
          'selfie',
          'profileSelfie',
          'profileImage',
          'photoUrl',
        ],
      );

  String get _aadhaarFront => _readValue(
        const [
          'aadhaarfront',
          'aadhaarFront',
          'Aadhaar Front',
          'Aadhar Front',
        ],
      );

  String get _aadhaarBack => _readValue(
        const [
          'aadhaarback',
          'aadhaarBack',
          'Aadhaar Back',
          'Aadhar Back',
        ],
      );

  String get _address => _readValue(
        const [
          'Adress',
          'Address',
          'address',
        ],
      );

  String get _village => _readValue(
        const [
          'village',
          'Village',
        ],
      );

  String get _city => _readValue(
        const [
          'city',
          'City',
        ],
      );

  String get _district => _readValue(
        const [
          'district',
          'District',
        ],
      );

  String get _state => _readValue(
        const [
          'state',
          'State',
        ],
      );

  String get _pincode => _readValue(
        const [
          'Pincode',
          'pincode',
          'pinCode',
          'postalCode',
        ],
      );

  String get _emergencyName => _readValue(
        const [
          'emergencyContactName',
          'Emergency Contact Name',
        ],
      );

  String get _emergencyMobile => _readValue(
        const [
          'emergencyContactMobile',
          'Emergency Contact Mobile',
        ],
      );

  String get _status => _readValue(
        const [
          'verificationStatus',
          'status',
          'approvalStatus',
          'walkerStatus',
        ],
        'pending',
      );

  bool get _approved => _readBool(
        const [
          'adminApproved',
          'approved',
          'isApproved',
        ],
      );

  bool get _active => _readBool(
        const [
          'isActive',
          'active',
        ],
      );

  bool get _reVerificationRequired =>
      _readBool(
        const [
          'reVerificationRequired',
          'reverificationRequired',
          'reVerifyRequired',
        ],
      );

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'active':
      case 'online':
        return const Color(0xFF16A34A);

      case 'rejected':
      case 'blocked':
      case 'suspended':
        return const Color(0xFFDC2626);

      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context).size.height * 0.92,
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
              const SizedBox(height: 10),
              _handle(),
              const SizedBox(height: 18),

              WalkersHeader(
                name: _name,
                mobile: _mobile,
                selfie: _selfie,
                status: _status,
                roleColor: walkerOrange,
                statusColor: _statusColor(_status),
              ),

              const SizedBox(height: 18),

              Expanded(
                child: SingleChildScrollView(
                  physics:
                      const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    30,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _title(
                        Icons.person_outline_rounded,
                        'Walker Profile',
                      ),
                      const SizedBox(height: 10),

                      _infoCard([
                        _row(
                          Icons.person_outline,
                          'Full Name',
                          _name,
                        ),
                        _divider(),
                        _row(
                          Icons.phone_outlined,
                          'Mobile Number',
                          _mobile,
                        ),
                        _divider(),
                        _row(
                          Icons.badge_outlined,
                          'Walker ID',
                          _walkerId,
                        ),
                        _divider(),
                        _row(
                          Icons.fingerprint,
                          'Auth UID',
                          _uid,
                        ),
                        _divider(),
                        _row(
                          Icons.wc_outlined,
                          'Gender',
                          _gender,
                        ),
                        _divider(),
                        _row(
                          Icons.calendar_today_outlined,
                          'Date Of Birth',
                          _dob,
                        ),
                        _divider(),
                        _row(
                          Icons.shield_outlined,
                          'Role',
                          _role,
                        ),
                      ]),

                      const SizedBox(height: 20),

                      _title(
                        Icons.location_on_outlined,
                        'Complete Address',
                      ),
                      const SizedBox(height: 10),

                      _infoCard([
                        _row(
                          Icons.home_outlined,
                          'Full Address',
                          _address,
                        ),
                        _divider(),
                        _row(
                          Icons.holiday_village_outlined,
                          'Village / Locality',
                          _village,
                        ),
                        _divider(),
                        _row(
                          Icons.location_city_outlined,
                          'City / Town',
                          _city,
                        ),
                        _divider(),
                        _row(
                          Icons.map_outlined,
                          'District',
                          _district,
                        ),
                        _divider(),
                        _row(
                          Icons.public_outlined,
                          'State',
                          _state,
                        ),
                        _divider(),
                        _row(
                          Icons.pin_drop_outlined,
                          'Pincode',
                          _pincode,
                        ),
                      ]),

                      const SizedBox(height: 20),

                      _title(
                        Icons.contact_phone_outlined,
                        'Emergency Contact',
                      ),
                      const SizedBox(height: 10),

                      _infoCard([
                        _row(
                          Icons.person_outline,
                          'Contact Name',
                          _emergencyName,
                        ),
                        _divider(),
                        _row(
                          Icons.phone_outlined,
                          'Contact Mobile',
                          _emergencyMobile,
                        ),
                      ]),

                      const SizedBox(height: 20),

                      _title(
                        Icons.description_outlined,
                        'Documents',
                      ),
                      const SizedBox(height: 10),

                      _infoCard([
                        _row(
                          Icons.credit_card_outlined,
                          'Aadhaar Number',
                          _aadhaarNumber,
                        ),
                      ]),

                      const SizedBox(height: 12),

                      WalkersDocumentCard(
                        title: 'Selfie',
                        icon: Icons.camera_alt_outlined,
                        url: _selfie,
                      ),

                      const SizedBox(height: 12),

                      WalkersDocumentCard(
                        title: 'Aadhaar Front',
                        icon: Icons.credit_card_outlined,
                        url: _aadhaarFront,
                      ),

                      const SizedBox(height: 12),

                      WalkersDocumentCard(
                        title: 'Aadhaar Back',
                        icon: Icons.credit_card_outlined,
                        url: _aadhaarBack,
                      ),

                      const SizedBox(height: 20),

                      _title(
                        Icons.verified_user_outlined,
                        'Verification',
                      ),
                      const SizedBox(height: 10),

                      WalkersVerificationCard(
                        data: _data,
                      ),

                      const SizedBox(height: 20),

                      _title(
                        Icons.admin_panel_settings_outlined,
                        'Admin Status',
                      ),
                      const SizedBox(height: 10),

                      _infoCard([
                        _row(
                          Icons.verified_outlined,
                          'Verification Status',
                          _status,
                        ),
                        _divider(),
                        _statusRow(
                          'Admin Approved',
                          _approved,
                        ),
                        _divider(),
                        _statusRow(
                          'Admin Rejected',
                          _readBool([
                            'adminRejected',
                            'rejected',
                            'isRejected',
                          ]),
                        ),
                        _divider(),
                        _statusRow(
                          'Profile Completed',
                          _readBool([
                            'profileCompleted',
                          ]),
                        ),
                      ]),

                      if (_approved) ...[
                        const SizedBox(height: 20),
                        _title(
                          Icons.power_settings_new_rounded,
                          'Walker ID Control',
                        ),
                        const SizedBox(height: 10),
                        _activationCard(),
                      ],

                      const SizedBox(height: 20),

                      _title(
                        Icons.refresh_rounded,
                        'Re-Verification',
                      ),
                      const SizedBox(height: 10),

                      _reVerificationCard(),

                      const SizedBox(height: 20),

                      _title(
                        Icons.access_time_outlined,
                        'System Information',
                      ),
                      const SizedBox(height: 10),

                      _infoCard([
                        _row(
                          Icons.add_circle_outline,
                          'Created At',
                          _readTimestamp([
                            'createdAt',
                          ]),
                        ),
                        _divider(),
                        _row(
                          Icons.send_outlined,
                          'Submitted At',
                          _readTimestamp([
                            'submittedAt',
                          ]),
                        ),
                        _divider(),
                        _row(
                          Icons.update_outlined,
                          'Updated At',
                          _readTimestamp([
                            'updatedAt',
                          ]),
                        ),
                        _divider(),
                        _row(
                          Icons.check_circle_outline,
                          'Approved At',
                          _readTimestamp([
                            'approvedAt',
                          ]),
                        ),
                        _divider(),
                        _row(
                          Icons.cancel_outlined,
                          'Rejected At',
                          _readTimestamp([
                            'rejectedAt',
                          ]),
                        ),
                        _divider(),
                        _row(
                          Icons.power_outlined,
                          'Activated At',
                          _readTimestamp([
                            'activatedAt',
                          ]),
                        ),
                        _divider(),
                        _row(
                          Icons.power_off_outlined,
                          'Deactivated At',
                          _readTimestamp([
                            'deactivatedAt',
                          ]),
                        ),
                        _divider(),
                        _row(
                          Icons.verified_outlined,
                          'Re-Verified At',
                          _readTimestamp([
                            'reVerifiedAt',
                          ]),
                        ),
                      ]),

                      const SizedBox(height: 24),

                      _actions(),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _handle() {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFE7E9ED),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _title(
    IconData icon,
    String title,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: walkerOrange,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _row(
    IconData icon,
    String label,
    String value,
  ) {
    final display = value.trim().isEmpty
        ? 'Not available'
        : value.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 11,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: walkerOrange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  display,
                  style: const TextStyle(
                    fontSize: 13,
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusRow(
    String label,
    bool value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 11,
      ),
      child: Row(
        children: [
          Icon(
            value
                ? Icons.check_circle
                : Icons.cancel_outlined,
            size: 20,
            color: value
                ? const Color(0xFF16A34A)
                : const Color(0xFFDC2626),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
          Text(
            value ? 'Yes' : 'No',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: value
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      color: borderColor,
    );
  }

  Widget _activationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _active
            ? const Color(0xFFF0FDF4)
            : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _active
              ? const Color(0xFFBBF7D0)
              : const Color(0xFFFECACA),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _active
                ? Icons.check_circle_outline
                : Icons.pause_circle_outline,
            color: _active
                ? const Color(0xFF16A34A)
                : const Color(0xFFDC2626),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _active
                  ? 'Walker ID is Active'
                  : 'Walker ID is Deactivated',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reVerificationCard() {
    final required = _reVerificationRequired;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Icon(
            required
                ? Icons.warning_amber_rounded
                : Icons.verified_outlined,
            color: required
                ? const Color(0xFFF59E0B)
                : const Color(0xFF16A34A),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              required
                  ? 'Re-verification required'
                  : 'Verification is current',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  minimumSize:
                      const Size.fromHeight(48),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            if (!_approved &&
                widget.onApprove != null) ...[
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onApprove,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF16A34A),
                    foregroundColor:
                        Colors.white,
                    minimumSize:
                        const Size.fromHeight(48),
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Approve',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (!_approved &&
            widget.onReject != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: widget.onReject,
              child: const Text(
                'Reject',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDateTime(DateTime date) {
    final d =
        date.day.toString().padLeft(2, '0');
    final m =
        date.month.toString().padLeft(2, '0');
    final y = date.year.toString();

    final hour =
        date.hour.toString().padLeft(2, '0');
    final minute =
        date.minute.toString().padLeft(2, '0');

    return '$d/$m/$y $hour:$minute';
  }
}
