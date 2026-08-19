import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  late bool nameMatched;
  late bool dobMatched;
  late bool aadhaarVerified;

  bool savingVerification = false;
  bool changingActivation = false;
  bool changingReVerification = false;

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

      if (value is String) {
        final normalized =
            value.trim().toLowerCase();

        if (normalized == 'true') return true;
        if (normalized == 'false') return false;
      }

      if (value is num) {
        return value != 0;
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

  String get _name {
    return _readValue(
      const [
        'fullName',
        'Full Name',
        'name',
        'walkerName',
      ],
      'Unknown Walker',
    );
  }

  String get _mobile {
    return _readValue(
      const [
        'phoneNumber',
        'Mobile number',
        'mobileNumber',
        'mobile',
        'phone',
      ],
    );
  }

  String get _walkerId {
    return _readValue(
      const [
        'walkerId',
        'Walker ID',
      ],
    );
  }

  String get _uid {
    return _readValue(
      const [
        'authUid',
        'Walker Uid',
        'walkerUid',
        'uid',
      ],
      widget.doc.id,
    );
  }

  String get _gender {
    return _readValue(
      const [
        'gender',
        'Gender',
      ],
    );
  }

  String get _dateOfBirth {
    return _readValue(
      const [
        'dateofbirth',
        'Date Of Birth',
        'dateOfBirth',
        'dob',
      ],
    );
  }

  String get _aadhaarNumber {
    return _readValue(
      const [
        'aadhaarNumber',
        'Aadhar Number',
        'Aadhaar Number',
        'aadharNumber',
      ],
    );
  }

  String get _selfie {
    return _readValue(
      const [
        'selfie',
        'Profile Selfie',
        'profileSelfie',
        'profileImage',
        'photoUrl',
      ],
    );
  }

  String get _aadhaarFront {
    return _readValue(
      const [
        'aadhaarfront',
        'aadhaarFront',
        'Aadhaar Front',
        'Aadhar Front',
      ],
    );
  }

  String get _aadhaarBack {
    return _readValue(
      const [
        'aadhaarback',
        'aadhaarBack',
        'Aadhaar Back',
        'Aadhar Back',
      ],
    );
  }

  String get _village {
    return _readValue(
      const [
        'village',
        'Village',
      ],
    );
  }

  String get _city {
    return _readValue(
      const [
        'city',
        'City',
      ],
    );
  }

  String get _district {
    return _readValue(
      const [
        'district',
        'District',
      ],
    );
  }

  String get _state {
    return _readValue(
      const [
        'state',
        'State',
      ],
    );
  }

  String get _pincode {
    return _readValue(
      const [
        'pincode',
        'Pincode',
        'pinCode',
        'postalCode',
      ],
    );
  }

  String get _address {
    return _readValue(
      const [
        'address',
        'Adress',
        'Address',
      ],
    );
  }

  String get _emergencyName {
    return _readValue(
      const [
        'emergencyContactName',
        'Emergency Contact Name',
      ],
    );
  }

  String get _emergencyMobile {
    return _readValue(
      const [
        'emergencyContactMobile',
        'Emergency Contact Mobile',
      ],
    );
  }

  String get _role {
    return _readValue(
      const [
        'role',
        'Role',
      ],
      'walker',
    );
  }

  String get _verificationStatus {
    return _readValue(
      const [
        'verificationStatus',
        'status',
        'approvalStatus',
        'walkerStatus',
      ],
      'pending',
    );
  }

  bool get _isApproved {
    return _readBool(
          const [
            'adminApproved',
            'approved',
            'isApproved',
          ],
        ) ||
        _verificationStatus
                .trim()
                .toLowerCase() ==
            'approved';
  }

  bool get _isActive {
    return _readBool(
      const [
        'isActive',
        'active',
      ],
    );
  }

  bool get _reVerificationRequired {
    return _readBool(
      const [
        'reVerificationRequired',
        'reverificationRequired',
        'reVerifyRequired',
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    nameMatched = _readBool(
      const [
        'nameMatched',
        'name_match',
      ],
    );

    dobMatched = _readBool(
      const [
        'dobMatched',
        'dob_match',
      ],
    );

    aadhaarVerified = _readBool(
      const [
        'aadhaarVerified',
        'aadharVerified',
        'aadhaar_verified',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor =
        _getStatusColor(_verificationStatus);

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context).size.height *
                  0.92,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              _handle(),
              const SizedBox(height: 18),

              _header(statusColor),

              const SizedBox(height: 18),

              Expanded(
                child: SingleChildScrollView(
                  physics:
                      const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    28,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        Icons.person_outline_rounded,
                        'Walker Profile',
                      ),
                      const SizedBox(height: 10),
                      _infoCard(
                        children: [
                          _infoRow(
                            Icons.person_outline,
                            'Full Name',
                            _name,
                          ),
                          _divider(),
                          _infoRow(
                            Icons.phone_outlined,
                            'Mobile Number',
                            _mobile,
                          ),
                          _divider(),
                          _infoRow(
                            Icons.badge_outlined,
                            'Walker ID',
                            _walkerId,
                          ),
                          _divider(),
                          _infoRow(
                            Icons.fingerprint,
                            'Auth UID',
                            _uid,
                          ),
                          _divider(),
                          _infoRow(
                            Icons.wc_outlined,
                            'Gender',
                            _gender,
                          ),
                          _divider(),
                          _infoRow(
                            Icons.calendar_today_outlined,
                            'Date Of Birth',
                            _dateOfBirth,
                          ),
                          _divider(),
                          _infoRow(
                            Icons.shield_outlined,
                            'Role',
                            _role,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _sectionTitle(
                        Icons.location_on_outlined,
                        'Complete Address',
                      ),
                      const SizedBox(height: 10),
                      _infoCard(
                        children: [
                          _infoRow(
                            Icons.home_outlined,
                            'Full Address',
                            _address,
                          ),
                          _divider(),
                          _infoRow(
                            Icons.holiday_village_outlined,
                            'Village / Locality',
                            _village,
                          ),
                          _divider(),
                          _infoRow(
                            Icons.location_city_outlined,
                            'City / Town',
                            _city,
                          ),
                          _divider(),
                          _infoRow(
                            Icons.map_outlined,
                            'District',
                            _district,
                          ),
                          _divider(),
                          _infoRow(
                            Icons.public_outlined,
                            'State',
                            _state,
                          ),
                          _divider(),
                          _infoRow(
                            Icons.pin_drop_outlined,
                            'Pincode',
                            _pincode,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _sectionTitle(
                        Icons.contact_phone_outlined,
                        'Emergency Contact',
                      ),
                      const SizedBox(height: 10),
                      _infoCard(
                        children: [
                          _infoRow(
                            Icons.person_outline,
                            'Contact Name',
                            _emergencyName,
                          ),
                          _divider(),
                          _infoRow(
                            Icons.phone_outlined,
                            'Contact Mobile',
                            _emergencyMobile,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _sectionTitle(
                        Icons.description_outlined,
                        'Documents',
                      ),
                      const SizedBox(height: 10),

                      _infoCard(
                        children: [
                          _infoRow(
                            Icons.credit_card_outlined,
                            'Aadhaar Number',
                            _aadhaarNumber,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      _documentPreview(
                        title: 'Selfie',
                        icon:
                            Icons.camera_alt_outlined,
                        imageUrl: _selfie,
                      ),

                      const SizedBox(height: 12),

                      _documentPreview(
                        title: 'Aadhaar Front',
                        icon:
                            Icons.credit_card_outlined,
                        imageUrl: _aadhaarFront,
                      ),

                      const SizedBox(height: 12),

                      _documentPreview(
                        title: 'Aadhaar Back',
                        icon:
                            Icons.credit_card_outlined,
                        imageUrl: _aadhaarBack,
                      ),

                      const SizedBox(height: 20),

                      _sectionTitle(
                        Icons.verified_user_outlined,
                        'Verification',
                      ),
                      const SizedBox(height: 10),

                      _verificationCard(),

                      const SizedBox(height: 20),

                      _sectionTitle(
                        Icons.admin_panel_settings_outlined,
                        'Admin Status',
                      ),
                      const SizedBox(height: 10),

                      _infoCard(
                        children: [
                          _infoRow(
                            Icons.verified_outlined,
                            'Verification Status',
                            _verificationStatus,
                          ),
                          _divider(),
                          _verificationStatusRow(
                            'Admin Approved',
                            _readBool(
                              const [
                                'adminApproved',
                                'approved',
                                'isApproved',
                              ],
                            ),
                          ),
                          _divider(),
                          _verificationStatusRow(
                            'Admin Rejected',
                            _readBool(
                              const [
                                'adminRejected',
                                'rejected',
                                'isRejected',
                              ],
                            ),
                          ),
                          _divider(),
                          _verificationStatusRow(
                            'Profile Completed',
                            _readBool(
                              const [
                                'profileCompleted',
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (_isApproved) ...[
                        const SizedBox(height: 20),
                        _sectionTitle(
                          Icons.power_settings_new_rounded,
                          'Walker ID Control',
                        ),
                        const SizedBox(height: 10),
                        _activationCard(),
                      ],

                      const SizedBox(height: 20),

                      _sectionTitle(
                        Icons.refresh_rounded,
                        'Re-Verification',
                      ),
                      const SizedBox(height: 10),
                      _reVerificationCard(),

                      const SizedBox(height: 20),

                      _sectionTitle(
                        Icons.access_time_outlined,
                        'System Information',
                      ),
                      const SizedBox(height: 10),

                      _infoCard(
                        children: [
                          _infoRow(
                            Icons.add_circle_outline,
                            'Created At',
                            _readTimestamp(
                              const ['createdAt'],
                            ),
                          ),
                          _divider(),
                          _infoRow(
                            Icons.send_outlined,
                            'Submitted At',
                            _readTimestamp(
                              const ['submittedAt'],
                            ),
                          ),
                          _divider(),
                          _infoRow(
                            Icons.update_outlined,
                            'Updated At',
                            _readTimestamp(
                              const ['updatedAt'],
                            ),
                          ),
                          _divider(),
                          _infoRow(
                            Icons.check_circle_outline,
                            'Approved At',
                            _readTimestamp(
                              const ['approvedAt'],
                            ),
                          ),
                          _divider(),
                          _infoRow(
                            Icons.cancel_outlined,
                            'Rejected At',
                            _readTimestamp(
                              const ['rejectedAt'],
                            ),
                          ),
                          _divider(),
                          _infoRow(
                            Icons.power_outlined,
                            'Activated At',
                            _readTimestamp(
                              const ['activatedAt'],
                            ),
                          ),
                          _divider(),
                          _infoRow(
                            Icons.power_off_outlined,
                            'Deactivated At',
                            _readTimestamp(
                              const ['deactivatedAt'],
                            ),
                          ),
                          _divider(),
                          _infoRow(
                            Icons.verified_outlined,
                            'Re-Verified At',
                            _readTimestamp(
                              const ['reVerifiedAt'],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      _actionButtons(),

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

  Widget _header(Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        children: [
          _avatar(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                if (_mobile.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _mobile,
                    style: const TextStyle(
                      fontSize: 13,
                      color: secondaryText,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                _statusBadge(
                  _verificationStatus,
                  statusColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    if (_selfie.isNotEmpty) {
      return CircleAvatar(
        radius: 32,
        backgroundColor:
            const Color(0xFFFFF1E8),
        backgroundImage:
            NetworkImage(_selfie),
        onBackgroundImageError:
            (_, __) {},
      );
    }

    return CircleAvatar(
      radius: 32,
      backgroundColor:
          const Color(0xFFFFF1E8),
      child: Text(
        _initials(_name),
        style: const TextStyle(
          color: walkerOrange,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _documentPreview({
    required String title,
    required IconData icon,
    required String imageUrl,
  }) {
    final hasImage = imageUrl.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 21,
                  color: walkerOrange,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ),
                Text(
                  hasImage
                      ? 'Uploaded'
                      : 'Not Uploaded',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: hasImage
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          if (hasImage)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
              child: AspectRatio(
                aspectRatio: 1.55,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (
                    context,
                    child,
                    progress,
                  ) {
                    if (progress == null) {
                      return child;
                    }

                    return const Center(
                      child:
                          CircularProgressIndicator(
                        color: walkerOrange,
                      ),
                    );
                  },
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Icon(
                              Icons
                                  .broken_image_outlined,
                              size: 40,
                              color:
                                  Color(0xFF9CA3AF),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Unable to load document',
                              style: TextStyle(
                                color:
                                    secondaryText,
                                fontSize: 12,
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
                  color: secondaryText,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _verificationCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          _verificationCheckbox(
            title: 'Name Matched',
            value: nameMatched,
            onChanged: (value) {
              setState(() {
                nameMatched = value;
              });
            },
          ),
          _divider(),
          _verificationCheckbox(
            title: 'DOB Matched',
            value: dobMatched,
            onChanged: (value) {
              setState(() {
                dobMatched = value;
              });
            },
          ),
          _divider(),
          _verificationCheckbox(
            title: 'Aadhaar Verified',
            value: aadhaarVerified,
            onChanged: (value) {
              setState(() {
                aadhaarVerified = value;
              });
            },
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              14,
              0,
              14,
              14,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: savingVerification
                    ? null
                    : _saveVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: walkerOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize:
                      const Size.fromHeight(46),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
                child: savingVerification
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Verification',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verificationCheckbox({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return CheckboxListTile(
      value: value,
      onChanged: (newValue) {
        onChanged(newValue ?? false);
      },
      activeColor: walkerOrange,
      checkColor: Colors.white,
      controlAffinity:
          ListTileControlAffinity.leading,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _activationCard() {
    final active = _isActive;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFF0FDF4)
            : const Color(0xFFFEF2F2),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: active
              ? const Color(0xFFBBF7D0)
              : const Color(0xFFFECACA),
        ),
      ),
      child: Row(
        children: [
          Icon(
            active
                ? Icons.check_circle_outline
                : Icons.pause_circle_outline,
            color: active
                ? const Color(0xFF16A34A)
                : const Color(0xFFDC2626),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  active
                      ? 'ID Active'
                      : 'ID Deactivated',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  active
                      ? 'Walker can use the active ID.'
                      : 'Walker ID is currently disabled.',
                  style: const TextStyle(
                    fontSize: 11,
                    color: secondaryText,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: changingActivation
                ? null
                : _toggleActivation,
            style: TextButton.styleFrom(
              foregroundColor: active
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF16A34A),
            ),
            child: Text(
              active ? 'Deactivate' : 'Activate',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reVerificationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _reVerificationRequired
                ? Icons.warning_amber_rounded
                : Icons.verified_outlined,
            color: _reVerificationRequired
                ? const Color(0xFFF59E0B)
                : walkerOrange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _reVerificationRequired
                      ? 'Re-verification required'
                      : 'Verification is current',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _reVerificationRequired
                      ? 'Documents should be checked again.'
                      : 'No re-verification is currently required.',
                  style: const TextStyle(
                    fontSize: 11,
                    color: secondaryText,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed:
                changingReVerification
                    ? null
                    : _toggleReVerification,
            style: TextButton.styleFrom(
              foregroundColor: walkerOrange,
            ),
            child: Text(
              _reVerificationRequired
                  ? 'Mark Verified'
                  : 'Require',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style:
                    OutlinedButton.styleFrom(
                  foregroundColor:
                      const Color(0xFF374151),
                  side: const BorderSide(
                    color: borderColor,
                  ),
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
            if (!_isApproved &&
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
                    elevation: 0,
                    minimumSize:
                        const Size.fromHeight(48),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Approve',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (!_isApproved &&
            widget.onReject != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: widget.onReject,
              style:
                  TextButton.styleFrom(
                foregroundColor:
                    const Color(0xFFDC2626),
                minimumSize:
                    const Size.fromHeight(42),
              ),
              child: const Text(
                'Reject',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _saveVerification() async {
    setState(() {
      savingVerification = true;
    });

    try {
      await widget.doc.reference.set(
        {
          'nameMatched': nameMatched,
          'dobMatched': dobMatched,
          'aadhaarVerified':
              aadhaarVerified,
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Verification saved successfully.',
          ),
          backgroundColor:
              Color(0xFF16A34A),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save verification: $e',
          ),
          backgroundColor:
              Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          savingVerification = false;
        });
      }
    }
  }

  Future<void> _toggleActivation() async {
    final nextActive = !_isActive;

    setState(() {
      changingActivation = true;
    });

    try {
      await widget.doc.reference.set(
        {
          'isActive': nextActive,
          'active': nextActive,
          'updatedAt':
              FieldValue.serverTimestamp(),
          if (nextActive)
            'activatedAt':
                FieldValue.serverTimestamp(),
          if (!nextActive)
            'deactivatedAt':
                FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            nextActive
                ? 'Walker ID activated.'
                : 'Walker ID deactivated.',
          ),
          backgroundColor: nextActive
              ? const Color(0xFF16A34A)
              : const Color(0xFFDC2626),
        ),
      );

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to change ID status: $e',
          ),
          backgroundColor:
              const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          changingActivation = false;
        });
      }
    }
  }

  Future<void> _toggleReVerification() async {
    final nextRequired =
        !_reVerificationRequired;

    setState(() {
      changingReVerification = true;
    });

    try {
      await widget.doc.reference.set(
        {
          'reVerificationRequired':
              nextRequired,
          'reVerificationStatus':
              nextRequired
                  ? 'required'
                  : 'verified',
          'updatedAt':
              FieldValue.serverTimestamp(),
          if (!nextRequired)
            'reVerifiedAt':
                FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            nextRequired
                ? 'Re-verification required.'
                : 'Walker marked as re-verified.',
          ),
          backgroundColor:
              const Color(0xFF16A34A),
        ),
      );

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update re-verification: $e',
          ),
          backgroundColor:
              const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          changingReVerification =
              false;
        });
      }
    }
  }

  Widget _sectionTitle(
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

  Widget _infoCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
  ) {
    final displayValue =
        value.trim().isEmpty
            ? 'Not available'
            : value.trim();

    return Padding(
      padding:
          const EdgeInsets.symmetric(
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
                  displayValue,
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

  Widget _verificationStatusRow(
    String label,
    bool value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
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

  Widget _statusBadge(
    String status,
    Color color,
  ) {
    final display =
        status.trim().isEmpty
            ? 'Pending'
            : status;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        display,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      color: borderColor,
    );
  }

  Widget _handle() {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFE7E9ED),
          borderRadius:
              BorderRadius.circular(10),
        ),
      ),
    );
  }

  String _initials(String name) {
    final cleaned = name.trim();

    if (cleaned.isEmpty ||
        cleaned.toLowerCase() ==
            'unknown walker') {
      return 'W';
    }

    final parts = cleaned
        .split(RegExp(r'\s+'))
        .where(
          (part) => part.isNotEmpty,
        )
        .toList();

    if (parts.length == 1) {
      return parts.first
          .substring(0, 1)
          .toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
            '${parts.last.substring(0, 1)}'
        .toUpperCase();
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

  Color _getStatusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'approved':
      case 'active':
      case 'online':
        return const Color(0xFF16A34A);

      case 'rejected':
      case 'blocked':
      case 'suspended':
        return const Color(0xFFDC2626);

      case 'pending':
      case 'pending approval':
        return const Color(0xFFF59E0B);

      case 'offline':
        return const Color(0xFF6B7280);

      default:
        return const Color(0xFFF59E0B);
    }
  }
}
