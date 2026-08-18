import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WalkerDetailsSheet extends StatelessWidget {
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

  Map<String, dynamic> get _data {
    return data ?? doc.data() ?? <String, dynamic>{};
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
        final normalized = value.trim().toLowerCase();

        if (normalized == 'true') {
          return true;
        }

        if (normalized == 'false') {
          return false;
        }
      }

      if (value is num) {
        return value != 0;
      }
    }

    return false;
  }

  String get _name {
    return _readValue(
      const [
        'Full Name',
        'fullName',
        'name',
        'walkerName',
      ],
      'Unknown Walker',
    );
  }

  String get _mobile {
    return _readValue(
      const [
        'Mobile number',
        'mobileNumber',
        'mobile',
        'phone',
        'phoneNumber',
      ],
    );
  }

  String get _address {
    return _readValue(
      const [
        'Adress',
        'Address',
        'address',
      ],
    );
  }

  String get _pincode {
    return _readValue(
      const [
        'Pincode',
        'pincode',
        'pinCode',
        'postalCode',
      ],
    );
  }

  String get _dateOfBirth {
    return _readValue(
      const [
        'Date Of Birth',
        'dateOfBirth',
        'dob',
      ],
    );
  }

  String get _aadhaarNumber {
    return _readValue(
      const [
        'Aadhar Number',
        'Aadhaar Number',
        'aadhaarNumber',
        'aadharNumber',
      ],
    );
  }

  String get _walkerUid {
    return _readValue(
      const [
        'Walker Uid',
        'walkerUid',
        'uid',
      ],
      doc.id,
    );
  }

  String get _selfie {
    return _readValue(
      const [
        'Profile Selfie',
        'profileSelfie',
        'profileImage',
        'photoUrl',
      ],
    );
  }

  String get _status {
    final status = _readValue(
      const [
        'status',
        'verificationStatus',
        'approvalStatus',
        'walkerStatus',
      ],
      'Pending',
    );

    return status.isEmpty ? 'Pending' : status;
  }

  bool get _isApproved {
    return _readBool(
          const [
            'approved',
            'isApproved',
          ],
        ) ||
        _status.trim().toLowerCase() == 'approved';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(_status);

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 760,
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

              Padding(
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF263238),
                            ),
                          ),

                          if (_mobile.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              _mobile,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],

                          const SizedBox(height: 8),

                          _statusBadge(
                            _status,
                            statusColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        'Walker Information',
                      ),

                      const SizedBox(height: 10),

                      _infoCard(
                        children: [
                          _infoRow(
                            Icons.phone_outlined,
                            'Mobile Number',
                            _mobile,
                          ),
                          _divider(),
                          _infoRow(
                            Icons.location_on_outlined,
                            'Address',
                            _address,
                          ),
                          _divider(),
                          _infoRow(
                            Icons.pin_drop_outlined,
                            'Pincode',
                            _pincode,
                          ),
                          _divider(),
                          _infoRow(
                            Icons.calendar_today_outlined,
                            'Date Of Birth',
                            _dateOfBirth,
                          ),
                          _divider(),
                          _infoRow(
                            Icons.badge_outlined,
                            'Aadhaar Number',
                            _aadhaarNumber,
                          ),
                          _divider(),
                          _infoRow(
                            Icons.fingerprint,
                            'Walker UID',
                            _walkerUid,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _sectionTitle(
                        'Verification',
                      ),

                      const SizedBox(height: 10),

                      _infoCard(
                        children: [
                          _verificationRow(
                            'Aadhaar Verified',
                            _readBool(
                              const [
                                'aadhaarVerified',
                                'aadharVerified',
                                'aadhaar_verified',
                              ],
                            ),
                          ),
                          _divider(),
                          _verificationRow(
                            'Selfie Verified',
                            _readBool(
                              const [
                                'selfieVerified',
                                'selfie_verified',
                              ],
                            ),
                          ),
                          _divider(),
                          _verificationRow(
                            'Profile Completed',
                            _readBool(
                              const [
                                'profileCompleted',
                              ],
                            ),
                          ),
                          _divider(),
                          _verificationRow(
                            'Active',
                            _readBool(
                              const [
                                'isActive',
                                'active',
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (_selfie.isNotEmpty) ...[
                        const SizedBox(height: 20),

                        _sectionTitle(
                          'Profile Selfie',
                        ),

                        const SizedBox(height: 10),

                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: 1.4,
                            child: Image.network(
                              _selfie,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress ==
                                    null) {
                                  return child;
                                }

                                return Container(
                                  color:
                                      const Color(0xFFF3F4F6),
                                  alignment:
                                      Alignment.center,
                                  child:
                                      const CircularProgressIndicator(
                                    color:
                                        Color(0xFFFF6600),
                                  ),
                                );
                              },
                              errorBuilder: (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return Container(
                                  color:
                                      const Color(0xFFF3F4F6),
                                  alignment:
                                      Alignment.center,
                                  child: const Column(
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
                                      SizedBox(height: 6),
                                      Text(
                                        'Unable to load selfie',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color:
                                              Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

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
                                  color: Color(0xFFE5E7EB),
                                ),
                                minimumSize:
                                    const Size.fromHeight(
                                  48,
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    12,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Close',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                            ),
                          ),

                          if (!_isApproved &&
                              onApprove != null) ...[
                            const SizedBox(width: 10),

                            Expanded(
                              child: ElevatedButton(
                                onPressed: onApprove,
                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF16A34A),
                                  foregroundColor:
                                      Colors.white,
                                  minimumSize:
                                      const Size.fromHeight(
                                    48,
                                  ),
                                  elevation: 0,
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      12,
                                    ),
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
                          onReject != null) ...[
                        const SizedBox(height: 8),

                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: onReject,
                            style:
                                TextButton.styleFrom(
                              foregroundColor:
                                  const Color(0xFFDC2626),
                              minimumSize:
                                  const Size.fromHeight(
                                42,
                              ),
                            ),
                            child: const Text(
                              'Reject',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],

                      if (_isApproved) ...[
                        const SizedBox(height: 8),

                        const Center(
                          child: Text(
                            'This walker is approved.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF16A34A),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
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

  Widget _avatar() {
    if (_selfie.isNotEmpty) {
      return CircleAvatar(
        radius: 32,
        backgroundColor: const Color(0xFFFFF1E8),
        backgroundImage: NetworkImage(_selfie),
      );
    }

    return CircleAvatar(
      radius: 32,
      backgroundColor: const Color(0xFFFFF1E8),
      child: Text(
        _initials(_name),
        style: const TextStyle(
          color: Color(0xFFFF6600),
          fontSize: 22,
          fontWeight: FontWeight.w900,
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

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w900,
        color: Color(0xFF263238),
      ),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
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
        value.trim().isEmpty ? 'Not available' : value;

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
            color: const Color(0xFF6B7280),
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
                Text(
                  displayValue,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF111827),
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

  Widget _verificationRow(
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
                color: Color(0xFF111827),
              ),
            ),
          ),
          Text(
            value ? 'Verified' : 'Not Verified',
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
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
      color: Color(0xFFE5E7EB),
    );
  }

  String _initials(String name) {
    final cleaned = name.trim();

    if (cleaned.isEmpty ||
        cleaned.toLowerCase() == 'unknown walker') {
      return 'W';
    }

    final parts = cleaned
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
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
