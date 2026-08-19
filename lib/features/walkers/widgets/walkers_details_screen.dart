import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'walkers_details_actions.dart';
import 'walkers_details_documents.dart';
import 'walkers_details_image_viewer.dart';
import 'walkers_details_row.dart';
import 'walkers_details_section.dart';
import 'walkers_details_upload_service.dart';
import 'walkers_helpers.dart';

class WalkerDetailsScreen extends StatefulWidget {
  const WalkerDetailsScreen({
    super.key,
    required this.doc,
    required this.data,
    required this.onApprove,
    required this.onReject,
    required this.onActivate,
    required this.onDeactivate,
  });

  final DocumentSnapshot<Map<String, dynamic>> doc;
  final Map<String, dynamic> data;

  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onActivate;
  final VoidCallback onDeactivate;

  @override
  State<WalkerDetailsScreen> createState() =>
      _WalkerDetailsScreenState();
}

class _WalkerDetailsScreenState extends State<WalkerDetailsScreen> {
  // ============================================================
  // SERVICES
  // ============================================================

  final WalkerDetailsUploadService _uploadService =
      WalkerDetailsUploadService();

  // ============================================================
  // UPLOAD STATE
  // ============================================================

  final Set<String> _uploadingFields = <String>{};

  // ============================================================
  // GETTERS
  // ============================================================

  Map<String, dynamic> get data => widget.data;

  DocumentSnapshot<Map<String, dynamic>> get doc => widget.doc;

  // ============================================================
  // SAFE BOOLEAN - MULTIPLE POSSIBLE FIRESTORE FIELD NAMES
  // ============================================================

  bool _boolAny(
    List<String> keys, {
    bool fallback = false,
  }) {
    for (final key in keys) {
      if (!data.containsKey(key)) {
        continue;
      }

      return walkerDetailsBool(
        data,
        key,
        fallback: fallback,
      );
    }

    return fallback;
  }

  // ============================================================
  // BASIC VALUES
  // ============================================================

  String get name {
    return walkerDetailsFirstValue(
      data,
      const [
        'Full Name',
        'fullName',
        'name',
        'walkerName',
      ],
      fallback: 'Walker',
    );
  }

  String get mobile {
    return walkerDetailsFirstValue(
      data,
      const [
        'Mobile number',
        'mobileNumber',
        'mobile',
        'phone',
        'phoneNumber',
      ],
    );
  }

  String get walkerId {
    return walkerDetailsFirstValue(
      data,
      const [
        'Walker ID',
        'walkerId',
      ],
      fallback: doc.id,
    );
  }

  String get walkerUid {
    return walkerDetailsFirstValue(
      data,
      const [
        'Walker Uid',
        'walkerUid',
        'authUid',
        'uid',
      ],
    );
  }

  // ============================================================
  // IMAGE VALUES
  // ============================================================

  String get selfie {
    return walkerDetailsFirstImage(
      data,
      const [
        'Profile Selfie',
        'profileSelfie',
        'profileSelfieUrl',
        'profile_selfie',
        'profile_selfie_url',
        'selfie',
        'selfieUrl',
      ],
    );
  }

  String get aadhaarFront {
    return walkerDetailsFirstImage(
      data,
      const [
        'Aadhar Front',
        'Aadhaar Front',
        'Aadhar Front URL',
        'Aadhaar Front URL',
        'aadhaarFront',
        'aadhaarFrontUrl',
        'aadhaar_front',
        'aadhaar_front_url',
      ],
    );
  }

  String get aadhaarBack {
    return walkerDetailsFirstImage(
      data,
      const [
        'Aadhar Back',
        'Aadhaar Back',
        'Aadhar Back URL',
        'Aadhaar Back URL',
        'aadhaarBack',
        'aadhaarBackUrl',
        'aadhaar_back',
        'aadhaar_back_url',
      ],
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  String get status {
    return walkerDetailsStatus(data);
  }

  bool get isActive {
    return _boolAny(
      const [
        'isActive',
        'active',
      ],
    );
  }

  // ============================================================
  // VERIFICATION
  // ============================================================

  bool get profileCompleted {
    return _boolAny(
      const [
        'profileCompleted',
        'profile_completed',
      ],
    );
  }

  bool get aadhaarFrontUploaded {
    return _boolAny(
      const [
        'aadhaar_front_uploaded',
        'aadhar_front_uploaded',
        'aadhaarFrontUploaded',
        'aadharFrontUploaded',
      ],
    );
  }

  bool get aadhaarBackUploaded {
    return _boolAny(
      const [
        'aadhaar_back_uploaded',
        'aadhar_back_uploaded',
        'aadhaarBackUploaded',
        'aadharBackUploaded',
      ],
    );
  }

  // ============================================================
  // OPEN IMAGE
  // ============================================================

  void _openImage(
    String title,
    String imageUrl,
  ) {
    WalkerDetailsImageViewer.open(
      context,
      title: title,
      imageUrl: imageUrl,
    );
  }

  // ============================================================
  // UPLOAD
  // ============================================================

  Future<void> _uploadPhoto({
    required String fieldName,
    required String title,
  }) async {
    if (_uploadingFields.contains(fieldName)) {
      return;
    }

    setState(() {
      _uploadingFields.add(fieldName);
    });

    try {
      await _uploadService.pickAndUpload(
        context: context,
        doc: doc,
        data: data,
        fieldName: fieldName,
        title: title,
      );
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _uploadingFields.remove(fieldName);
      });
    }
  }

  // ============================================================
  // PROFILE SELFIE
  // ============================================================

  Future<void> _uploadSelfie() async {
    await _uploadPhoto(
      fieldName: 'Profile Selfie',
      title: 'Profile Selfie',
    );
  }

  // ============================================================
  // AADHAAR FRONT
  // ============================================================

  Future<void> _uploadAadhaarFront() async {
    await _uploadPhoto(
      fieldName: 'Aadhar Front',
      title: 'Aadhaar Front',
    );
  }

  // ============================================================
  // AADHAAR BACK
  // ============================================================

  Future<void> _uploadAadhaarBack() async {
    await _uploadPhoto(
      fieldName: 'Aadhar Back',
      title: 'Aadhaar Back',
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: walkerDetailsPageBg,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),
        title: const Text(
          'Walker Details',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: walkerDetailsTextDark,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: walkerDetailsBorder,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _avatar(),

                        const SizedBox(width: 13),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: walkerDetailsTextDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                walkerId,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: walkerDetailsTextGrey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        _statusBadge(),
                      ],
                    ),

                    // =================================================
                    // PROFILE SELFIE UPLOAD
                    // =================================================

                    if (selfie.isEmpty) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _smallUploadButton(
                          fieldName: 'Profile Selfie',
                          title: 'Profile Selfie',
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    const Divider(
                      height: 1,
                      color: walkerDetailsBorder,
                    ),

                    const SizedBox(height: 14),

                    // =================================================
                    // ACTIONS
                    // =================================================

                    WalkerDetailsActions(
                      status: status,
                      isActive: isActive,
                      onApprove: widget.onApprove,
                      onReject: widget.onReject,
                      onActivate: widget.onActivate,
                      onDeactivate: widget.onDeactivate,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // BASIC DETAILS
              // ==================================================

              WalkerDetailsSection(
                title: 'Basic Details',
                icon: Icons.person_outline_rounded,
                children: [
                  WalkerDetailsRow(
                    label: 'Full Name',
                    value: name,
                  ),

                  WalkerDetailsRow(
                    label: 'Mobile Number',
                    value: mobile,
                    selectable: true,
                  ),

                  WalkerDetailsRow(
                    label: 'Walker ID',
                    value: walkerId,
                    selectable: true,
                  ),

                  WalkerDetailsRow(
                    label: 'Walker UID',
                    value: walkerUid,
                    selectable: true,
                  ),

                  WalkerDetailsRow(
                    label: 'Role',
                    value: walkerDetailsFirstValue(
                      data,
                      const ['role', 'Role'],
                    ),
                  ),

                  WalkerDetailsRow(
                    label: 'Gender',
                    value: walkerDetailsFirstValue(
                      data,
                      const [
                        'Gender',
                        'gender',
                      ],
                    ),
                  ),

                  WalkerDetailsRow(
                    label: 'Date Of Birth',
                    value: walkerDetailsFirstValue(
                      data,
                      const [
                        'Date Of Birth',
                        'dateOfBirth',
                        'dob',
                      ],
                    ),
                  ),
                ],
              ),

              // ==================================================
              // IDENTITY & VERIFICATION
              // ==================================================

              WalkerDetailsSection(
                title: 'Identity & Verification',
                icon: Icons.verified_user_outlined,
                children: [
                  WalkerDetailsRow(
                    label: 'Aadhaar Number',
                    value: walkerDetailsFirstValue(
                      data,
                      const [
                        'Aadhar Number',
                        'Aadhaar Number',
                        'aadhaarNumber',
                        'aadharNumber',
                      ],
                    ),
                    selectable: true,
                  ),

                  WalkerDetailsRow(
                    label: 'Verification',
                    value: status,
                  ),

                  WalkerDetailsRow(
                    label: 'Active',
                    value: isActive ? 'Yes' : 'No',
                  ),

                  WalkerDetailsRow(
                    label: 'Profile Completed',
                    value: profileCompleted ? 'Yes' : 'No',
                  ),

                  WalkerDetailsRow(
                    label: 'Aadhaar Front Uploaded',
                    value:
                        aadhaarFrontUploaded ? 'Yes' : 'No',
                  ),

                  WalkerDetailsRow(
                    label: 'Aadhaar Back Uploaded',
                    value:
                        aadhaarBackUploaded ? 'Yes' : 'No',
                  ),

                  const SizedBox(height: 8),

                  WalkerDetailsDocuments(
                    selfie: selfie,
                    aadhaarFront: aadhaarFront,
                    aadhaarBack: aadhaarBack,
                    uploadingFields: _uploadingFields,
                    onOpenImage: _openImage,
                    onUploadSelfie: _uploadSelfie,
                    onUploadAadhaarFront:
                        _uploadAadhaarFront,
                    onUploadAadhaarBack:
                        _uploadAadhaarBack,
                  ),
                ],
              ),

              // ==================================================
              // ADDRESS
              // ==================================================

              WalkerDetailsSection(
                title: 'Address',
                icon: Icons.location_on_outlined,
                children: [
                  WalkerDetailsRow(
                    label: 'Address',
                    value: walkerDetailsFirstValue(
                      data,
                      const [
                        'Adress',
                        'Address',
                        'address',
                      ],
                    ),
                  ),

                  WalkerDetailsRow(
                    label: 'Village',
                    value: walkerDetailsFirstValue(
                      data,
                      const [
                        'Village',
                        'village',
                      ],
                    ),
                  ),

                  WalkerDetailsRow(
                    label: 'City',
                    value: walkerDetailsFirstValue(
                      data,
                      const [
                        'City',
                        'city',
                      ],
                    ),
                  ),

                  WalkerDetailsRow(
                    label: 'District',
                    value: walkerDetailsFirstValue(
                      data,
                      const [
                        'District',
                        'district',
                      ],
                    ),
                  ),

                  WalkerDetailsRow(
                    label: 'State',
                    value: walkerDetailsFirstValue(
                      data,
                      const [
                        'State',
                        'state',
                      ],
                    ),
                  ),

                  WalkerDetailsRow(
                    label: 'Pincode',
                    value: walkerDetailsFirstValue(
                      data,
                      const [
                        'Pincode',
                        'pincode',
                        'pinCode',
                        'postalCode',
                      ],
                    ),
                    selectable: true,
                  ),
                ],
              ),

              // ==================================================
              // EMERGENCY CONTACT
              // ==================================================

              WalkerDetailsSection(
                title: 'Emergency Contact',
                icon: Icons.emergency_outlined,
                children: [
                  WalkerDetailsRow(
                    label: 'Name',
                    value: walkerDetailsFirstValue(
                      data,
                      const [
                        'Emergency Name',
                        'emergencyName',
                      ],
                    ),
                  ),

                  WalkerDetailsRow(
                    label: 'Mobile',
                    value: walkerDetailsFirstValue(
                      data,
                      const [
                        'Emergency Mobile',
                        'emergencyMobile',
                        'emergencyPhone',
                      ],
                    ),
                    selectable: true,
                  ),
                ],
              ),

              // ==================================================
              // ACCOUNT STATUS
              // ==================================================

              WalkerDetailsSection(
                title: 'Account Status',
                icon: Icons.account_circle_outlined,
                children: [
                  WalkerDetailsRow(
                    label: 'Approved',
                    value: _boolAny(
                      const [
                        'approved',
                        'isApproved',
                        'adminApproved',
                      ],
                    )
                        ? 'Yes'
                        : 'No',
                  ),

                  WalkerDetailsRow(
                    label: 'Rejected',
                    value: _boolAny(
                      const [
                        'rejected',
                        'isRejected',
                        'adminRejected',
                      ],
                    )
                        ? 'Yes'
                        : 'No',
                  ),

                  WalkerDetailsRow(
                    label: 'Active',
                    value: isActive ? 'Yes' : 'No',
                  ),

                  WalkerDetailsRow(
                    label: 'Online',
                    value: _boolAny(
                      const [
                        'isOnline',
                        'online',
                      ],
                    )
                        ? 'Online'
                        : 'Offline',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // AVATAR
  // ============================================================

  Widget _avatar() {
    final hasImage = selfie.trim().isNotEmpty;

    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: walkerDetailsOrange.withValues(
          alpha: 0.10,
        ),
        border: Border.all(
          color: walkerDetailsOrange.withValues(
            alpha: 0.20,
          ),
        ),
      ),
      child: hasImage
          ? ClipOval(
              child: Image.network(
                selfie,
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const Icon(
                    Icons.person_rounded,
                    color: walkerDetailsOrange,
                    size: 32,
                  );
                },
              ),
            )
          : const Icon(
              Icons.person_rounded,
              color: walkerDetailsOrange,
              size: 32,
            ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge() {
    final color = walkerDetailsStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 7),

          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SMALL UPLOAD BUTTON
  // ============================================================

  Widget _smallUploadButton({
    required String fieldName,
    required String title,
  }) {
    final uploading =
        _uploadingFields.contains(fieldName);

    return SizedBox(
      height: 34,
      child: OutlinedButton.icon(
        onPressed: uploading
            ? null
            : () {
                _uploadPhoto(
                  fieldName: fieldName,
                  title: title,
                );
              },
        icon: uploading
            ? const SizedBox(
                height: 14,
                width: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: walkerDetailsOrange,
                ),
              )
            : const Icon(
                Icons.upload_rounded,
                size: 16,
              ),
        label: Text(
          uploading ? 'Uploading...' : 'Upload',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: walkerDetailsOrange,
          side: BorderSide(
            color: walkerDetailsOrange.withValues(
              alpha: 0.55,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
