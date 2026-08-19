import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

class _WalkerDetailsScreenState
    extends State<WalkerDetailsScreen> {
  static const Color orange = Color(0xFFFF6600);
  static const Color green = Color(0xFF16A34A);
  static const Color red = Color(0xFFDC2626);
  static const Color blue = Color(0xFF2563EB);
  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color pageBg = Color(0xFFF7F8FA);

  final ImagePicker _picker = ImagePicker();

  final Set<String> _uploadingFields = {};

  Map<String, dynamic> get data => widget.data;

  DocumentSnapshot<Map<String, dynamic>> get doc =>
      widget.doc;

  // ============================================================
  // VALUE
  // ============================================================

  String _value(
    List<String> keys, {
    String fallback = 'Not available',
  }) {
    for (final key in keys) {
      final value = data[key];

      if (value == null) continue;

      final text = value.toString().trim();

      if (text.isNotEmpty && text != 'null') {
        return text;
      }
    }

    return fallback;
  }

  // ============================================================
  // BOOLEAN
  // ============================================================

  bool _bool(List<String> keys) {
    for (final key in keys) {
      final value = data[key];

      if (value is bool) {
        return value;
      }

      if (value != null) {
        final text =
            value.toString().toLowerCase().trim();

        if (text == 'true' || text == '1') {
          return true;
        }

        if (text == 'false' || text == '0') {
          return false;
        }
      }
    }

    return false;
  }

  // ============================================================
  // STATUS
  // ============================================================

  String _status() {
    final status = _value(
      [
        'verificationStatus',
        'approvalStatus',
        'status',
      ],
      fallback: '',
    ).toLowerCase().trim();

    if (status == 'approved') {
      return 'Approved';
    }

    if (status == 'rejected') {
      return 'Rejected';
    }

    if (status == 'pending') {
      return 'Pending';
    }

    if (_bool([
      'approved',
      'isApproved',
      'adminApproved',
    ])) {
      return 'Approved';
    }

    if (_bool([
      'rejected',
      'isRejected',
      'adminRejected',
    ])) {
      return 'Rejected';
    }

    return 'Pending';
  }

  // ============================================================
  // ACTIVE
  // ============================================================

  bool _isActive() {
    return _bool([
      'isActive',
      'active',
    ]);
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return green;

      case 'Rejected':
        return red;

      default:
        return orange;
    }
  }

  // ============================================================
  // IMAGE URL
  // ============================================================

  String _imageUrl(List<String> keys) {
    return _value(
      keys,
      fallback: '',
    );
  }

  // ============================================================
  // OPEN IMAGE
  // ============================================================

  void _openImage(
    BuildContext context,
    String title,
    String imageUrl,
  ) {
    if (imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Image is not available.',
          ),
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(18),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 700,
              maxHeight: 800,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    14,
                    10,
                    10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () {
                          Navigator.of(
                            dialogContext,
                          ).pop();
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                  color: border,
                ),
                Flexible(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(18),
                    child: InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4,
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (
                            context,
                            child,
                            loadingProgress,
                          ) {
                            if (loadingProgress ==
                                null) {
                              return child;
                            }

                            return const SizedBox(
                              height: 350,
                              child: Center(
                                child:
                                    CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const SizedBox(
                              height: 350,
                              child: Center(
                                child: Column(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons
                                          .broken_image_outlined,
                                      size: 55,
                                      color:
                                          Colors.grey,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'Unable to load image',
                                      style:
                                          TextStyle(
                                        color:
                                            textGrey,
                                        fontWeight:
                                            FontWeight
                                                .w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // WALKER AVATAR
  // ============================================================

  Widget _walkerAvatar({
    double size = 56,
    String? imageUrl,
  }) {
    if (imageUrl != null &&
        imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor:
            orange.withValues(alpha: 0.10),
        backgroundImage:
            NetworkImage(imageUrl),
      );
    }

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: orange.withValues(alpha: 0.10),
        border: Border.all(
          color:
              orange.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: size * 0.78,
            width: size * 0.78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  orange.withValues(alpha: 0.08),
            ),
          ),

          // Branded default walker avatar
          Icon(
            Icons.person_rounded,
            size: size * 0.58,
            color: orange,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // UPLOAD PHOTO
  // ============================================================

  Future<void> _uploadPhoto({
    required String fieldName,
    required String title,
  }) async {
    if (_uploadingFields.contains(fieldName)) {
      return;
    }

    try {
      final XFile? picked =
          await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (picked == null) {
        return;
      }

      if (!mounted) return;

      setState(() {
        _uploadingFields.add(fieldName);
      });

      final bytes = await picked.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception(
          'Selected image is empty.',
        );
      }

      String extension = 'jpg';

      final fileName =
          picked.name.toLowerCase();

      if (fileName.endsWith('.png')) {
        extension = 'png';
      } else if (fileName.endsWith('.webp')) {
        extension = 'webp';
      } else if (fileName.endsWith('.jpeg')) {
        extension = 'jpeg';
      } else if (fileName.endsWith('.jpg')) {
        extension = 'jpg';
      }

      final timestamp =
          DateTime.now().millisecondsSinceEpoch;

      final storagePath =
          'walkers/${doc.id}/admin_uploads/'
          '${fieldName}_$timestamp.$extension';

      final storageRef =
          FirebaseStorage.instance.ref().child(
                storagePath,
              );

      String contentType =
          'image/jpeg';

      if (extension == 'png') {
        contentType = 'image/png';
      } else if (extension == 'webp') {
        contentType = 'image/webp';
      }

      await storageRef.putData(
        bytes,
        SettableMetadata(
          contentType: contentType,
        ),
      );

      final downloadUrl =
          await storageRef.getDownloadURL();

      // Save URL into Firestore.
      await doc.reference.update({
        fieldName: downloadUrl,
      });

      // Update current screen immediately.
      data[fieldName] = downloadUrl;

      if (!mounted) return;

      setState(() {
        _uploadingFields.remove(fieldName);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$title uploaded successfully.',
          ),
          backgroundColor: green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _uploadingFields.remove(fieldName);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Upload failed: $e',
          ),
          backgroundColor: red,
        ),
      );
    }
  }

  // ============================================================
  // UPLOAD BUTTON
  // ============================================================

  Widget _uploadButton({
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
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Icon(
                Icons.upload_rounded,
                size: 16,
              ),
        label: Text(
          uploading
              ? 'Uploading...'
              : 'Upload',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: orange,
          side: BorderSide(
            color:
                orange.withValues(alpha: 0.55),
          ),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PHOTO CARD
  // ============================================================

  Widget _photoCard(
    BuildContext context, {
    required String title,
    required String imageUrl,
    required IconData icon,
    required String uploadField,
  }) {
    final hasImage = imageUrl.isNotEmpty;

    return Container(
      width: 150,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius:
                BorderRadius.circular(9),
            onTap: hasImage
                ? () {
                    _openImage(
                      context,
                      title,
                      imageUrl,
                    );
                  }
                : null,
            child: Container(
              height: 95,
              width: double.infinity,
              decoration: BoxDecoration(
                color:
                    const Color(0xFFF3F4F6),
                borderRadius:
                    BorderRadius.circular(9),
              ),
              child: hasImage
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.circular(
                        9,
                      ),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return Icon(
                            icon,
                            size: 38,
                            color: Colors.grey,
                          );
                        },
                      ),
                    )
                  : Icon(
                      icon,
                      size: 38,
                      color: Colors.grey,
                    ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),

          const SizedBox(height: 5),

          if (hasImage)
            InkWell(
              onTap: () {
                _openImage(
                  context,
                  title,
                  imageUrl,
                );
              },
              child: const Text(
                'Tap to view',
                style: TextStyle(
                  fontSize: 9,
                  color: orange,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else
            _uploadButton(
              fieldName: uploadField,
              title: title,
            ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _section(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              18,
              16,
              18,
              12,
            ),
            child: Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color:
                        orange.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w800,
                    color: textDark,
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            color: border,
          ),

          Padding(
            padding:
                const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DETAIL ROW
  // LABEL TOP / VALUE BELOW / LEFT
  // ============================================================

  Widget _row(
    String label,
    String value, {
    bool selectable = false,
  }) {
    final valueWidget = selectable
        ? SelectableText(
            value,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          )
        : Text(
            value,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          );

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 12,
              color: textGrey,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          valueWidget,
        ],
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge() {
    final status = _status();
    final color = _statusColor(status);

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color:
            color.withValues(alpha: 0.10),
        borderRadius:
            BorderRadius.circular(30),
        border: Border.all(
          color:
              color.withValues(alpha: 0.25),
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
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION BUTTON
  // ============================================================

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool filled = false,
  }) {
    if (filled) {
      return SizedBox(
        height: 38,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: 17,
          ),
          label: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          style:
              FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor:
                Colors.white,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 13,
            ),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                9,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 38,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 17,
        ),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.w800,
          ),
        ),
        style:
            OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(
            color:
                color.withValues(
              alpha: 0.55,
            ),
          ),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 13,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              9,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TOP ACTIONS
  // ============================================================

  Widget _topActions() {
    final status = _status();
    final active = _isActive();

    final List<Widget> buttons = [];

    if (status == 'Pending') {
      buttons.add(
        _actionButton(
          label: 'Reject',
          icon: Icons.close_rounded,
          color: red,
          onPressed: widget.onReject,
        ),
      );

      buttons.add(
        _actionButton(
          label: 'Approve',
          icon: Icons.check_rounded,
          color: green,
          onPressed: widget.onApprove,
          filled: true,
        ),
      );
    } else if (status == 'Rejected') {
      buttons.add(
        _actionButton(
          label: 'Approve',
          icon: Icons.check_rounded,
          color: green,
          onPressed: widget.onApprove,
          filled: true,
        ),
      );
    } else if (status == 'Approved') {
      if (active) {
        buttons.add(
          _actionButton(
            label: 'Deactivate ID',
            icon:
                Icons.person_off_outlined,
            color: red,
            onPressed:
                widget.onDeactivate,
          ),
        );
      } else {
        buttons.add(
          _actionButton(
            label: 'Activate ID',
            icon:
                Icons.person_outline_rounded,
            color: blue,
            onPressed:
                widget.onActivate,
            filled: true,
          ),
        );
      }
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      alignment:
          WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: buttons,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final name = _value(
      [
        'Full Name',
        'fullName',
        'name',
        'walkerName',
      ],
      fallback: 'Walker',
    );

    final selfie = _imageUrl([
      'Profile Selfie',
      'profileSelfie',
      'profileSelfieUrl',
      'selfie',
      'selfieUrl',
    ]);

    final aadhaarFront =
        _imageUrl([
      'Aadhar Front',
      'Aadhaar Front',
      'aadhaarFront',
      'aadhaarFrontUrl',
      'aadhaar_front',
      'aadhaar_front_url',
    ]);

    final aadhaarBack =
        _imageUrl([
      'Aadhar Back',
      'Aadhaar Back',
      'aadhaarBack',
      'aadhaarBackUrl',
      'aadhaar_back',
      'aadhaar_back_url',
    ]);

    final status = _status();
    final isActive = _isActive();

    return Scaffold(
      backgroundColor: pageBg,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor:
            Colors.white,
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
            fontWeight:
                FontWeight.w800,
            color: textDark,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                  border: Border.all(
                    color: border,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // ----------------------------------------
                        // WALKER PHOTO / AVATAR
                        // ----------------------------------------

                        _walkerAvatar(
                          size: 56,
                          imageUrl:
                              selfie.isNotEmpty
                                  ? selfie
                                  : null,
                        ),

                        const SizedBox(
                          width: 13,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                  color:
                                      textDark,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                _value(
                                  [
                                    'Walker ID',
                                    'walkerId',
                                  ],
                                  fallback:
                                      doc.id,
                                ),
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  fontSize: 11,
                                  color:
                                      textGrey,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        _statusBadge(),
                      ],
                    ),

                    // --------------------------------------------
                    // ADMIN UPLOAD PROFILE PHOTO
                    // --------------------------------------------

                    if (selfie.isEmpty) ...[
                      const SizedBox(
                        height: 12,
                      ),
                      Align(
                        alignment:
                            Alignment.centerLeft,
                        child: _uploadButton(
                          fieldName:
                              'Profile Selfie',
                          title:
                              'Profile Selfie',
                        ),
                      ),
                    ],

                    const SizedBox(
                      height: 14,
                    ),

                    const Divider(
                      height: 1,
                      color: border,
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Expanded(
                          child:
                              _topActions(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              // ==================================================
              // BASIC DETAILS
              // ==================================================

              _section(
                'Basic Details',
                Icons.person_outline_rounded,
                [
                  _row(
                    'Full Name',
                    name,
                  ),

                  _row(
                    'Mobile Number',
                    _value([
                      'Mobile number',
                      'mobileNumber',
                      'mobile',
                      'phone',
                      'phoneNumber',
                    ]),
                    selectable: true,
                  ),

                  _row(
                    'Walker ID',
                    _value(
                      [
                        'Walker ID',
                        'walkerId',
                      ],
                      fallback:
                          doc.id,
                    ),
                    selectable: true,
                  ),

                  _row(
                    'Walker UID',
                    _value([
                      'Walker Uid',
                      'walkerUid',
                      'authUid',
                      'uid',
                    ]),
                    selectable: true,
                  ),

                  _row(
                    'Role',
                    _value([
                      'role',
                    ]),
                  ),

                  _row(
                    'Gender',
                    _value([
                      'Gender',
                      'gender',
                    ]),
                  ),

                  _row(
                    'Date Of Birth',
                    _value([
                      'Date Of Birth',
                      'dateOfBirth',
                      'dob',
                    ]),
                  ),
                ],
              ),

              // ==================================================
              // IDENTITY & VERIFICATION
              // ==================================================

              _section(
                'Identity & Verification',
                Icons.verified_user_outlined,
                [
                  _row(
                    'Aadhaar Number',
                    _value([
                      'Aadhar Number',
                      'Aadhaar Number',
                      'aadhaarNumber',
                      'aadharNumber',
                    ]),
                    selectable: true,
                  ),

                  _row(
                    'Verification',
                    status,
                  ),

                  _row(
                    'Active',
                    isActive
                        ? 'Yes'
                        : 'No',
                  ),

                  _row(
                    'Profile Completed',
                    _bool([
                      'profileCompleted',
                    ])
                        ? 'Yes'
                        : 'No',
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  // ----------------------------------------------
                  // DOCUMENT PHOTOS
                  // ----------------------------------------------

                  Align(
                    alignment:
                        Alignment.centerLeft,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _photoCard(
                          context,
                          title:
                              'Profile Selfie',
                          imageUrl:
                              selfie,
                          icon:
                              Icons.person_rounded,
                          uploadField:
                              'Profile Selfie',
                        ),

                        _photoCard(
                          context,
                          title:
                              'Aadhaar Front',
                          imageUrl:
                              aadhaarFront,
                          icon:
                              Icons.credit_card,
                          uploadField:
                              'Aadhar Front',
                        ),

                        _photoCard(
                          context,
                          title:
                              'Aadhaar Back',
                          imageUrl:
                              aadhaarBack,
                          icon:
                              Icons.credit_card,
                          uploadField:
                              'Aadhar Back',
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ==================================================
              // ADDRESS
              // ==================================================

              _section(
                'Address',
                Icons.location_on_outlined,
                [
                  _row(
                    'Address',
                    _value([
                      'Adress',
                      'Address',
                      'address',
                    ]),
                  ),

                  _row(
                    'Village',
                    _value([
                      'Village',
                      'village',
                    ]),
                  ),

                  _row(
                    'City',
                    _value([
                      'City',
                      'city',
                    ]),
                  ),

                  _row(
                    'District',
                    _value([
                      'District',
                      'district',
                    ]),
                  ),

                  _row(
                    'State',
                    _value([
                      'State',
                      'state',
                    ]),
                  ),

                  _row(
                    'Pincode',
                    _value([
                      'Pincode',
                      'pincode',
                      'pinCode',
                      'postalCode',
                    ]),
                    selectable: true,
                  ),
                ],
              ),

              // ==================================================
              // EMERGENCY CONTACT
              // ==================================================

              _section(
                'Emergency Contact',
                Icons.emergency_outlined,
                [
                  _row(
                    'Name',
                    _value([
                      'Emergency Name',
                      'emergencyName',
                    ]),
                  ),

                  _row(
                    'Mobile',
                    _value([
                      'Emergency Mobile',
                      'emergencyMobile',
                      'emergencyPhone',
                    ]),
                    selectable: true,
                  ),
                ],
              ),

              // ==================================================
              // ACCOUNT STATUS
              // ==================================================

              _section(
                'Account Status',
                Icons.account_circle_outlined,
                [
                  _row(
                    'Approved',
                    _bool([
                      'approved',
                      'isApproved',
                      'adminApproved',
                    ])
                        ? 'Yes'
                        : 'No',
                  ),

                  _row(
                    'Rejected',
                    _bool([
                      'rejected',
                      'isRejected',
                      'adminRejected',
                    ])
                        ? 'Yes'
                        : 'No',
                  ),

                  _row(
                    'Active',
                    isActive
                        ? 'Yes'
                        : 'No',
                  ),

                  _row(
                    'Online',
                    _bool([
                      'isOnline',
                      'online',
                    ])
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
}
