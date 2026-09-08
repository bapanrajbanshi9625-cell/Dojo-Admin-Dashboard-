// File:
// lib/features/walk_requests/screens/walk_request_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/walk_request_details_helpers.dart';
import '../widgets/walk_request_details_actions.dart';
import '../widgets/walk_request_details_dog.dart';
import '../widgets/walk_request_details_header.dart';
import '../widgets/walk_request_details_information.dart';
import '../widgets/walk_request_details_location.dart';
import '../widgets/walk_request_details_map.dart';
import '../widgets/walk_request_details_owner.dart';
import '../widgets/walk_request_details_walker.dart';

typedef WalkRequestOpenMapsCallback = Future<void> Function(
  LatLng location,
);

class WalkRequestDetailsScreen extends StatelessWidget {
  const WalkRequestDetailsScreen({
    super.key,
    required this.requestId,
    required this.data,
    this.onAssign,
    this.onCancel,
    this.onOpenMaps,
  });

  final String requestId;
  final Map<String, dynamic> data;

  final VoidCallback? onAssign;
  final VoidCallback? onCancel;
  final WalkRequestOpenMapsCallback? onOpenMaps;

  static const Color orange = Color(0xFFD35435);
  static const Color blue = Color(0xFF2563EB);
  static const Color background = Color(0xFFF8FAFC);
  static const Color dark = Color(0xFF0F172A);
  static const Color grey = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color white = Colors.white;

  String _status() {
    final value = WalkRequestDetailsHelpers.value(
      data,
      'status',
    );

    return value.trim().isEmpty ? 'pending' : value;
  }

  Future<void> _copyText(
    BuildContext context,
    String value,
    String label,
  ) async {
    final text = value.trim();

    if (text.isEmpty || text == '—') {
      return;
    }

    await Clipboard.setData(
      ClipboardData(text: text),
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _callPhone(
    BuildContext context,
    String phone,
  ) async {
    final value = phone.trim();

    if (value.isEmpty || value == '—') {
      return;
    }

    final uri = Uri(
      scheme: 'tel',
      path: value,
    );

    try {
      final launched = await launchUrl(uri);

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open phone dialer'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open phone dialer'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openMaps(LatLng location) {
    onOpenMaps?.call(location);
  }

  @override
  Widget build(BuildContext context) {
    final ownerName =
        WalkRequestDetailsHelpers.ownerName(data);

    final ownerId =
        WalkRequestDetailsHelpers.ownerId(data);

    final ownerPhone =
        WalkRequestDetailsHelpers.ownerPhone(data);

    final walkerName =
        WalkRequestDetailsHelpers.walkerName(data);

    final walkerId =
        WalkRequestDetailsHelpers.walkerId(data);

    final walkerPhone =
        WalkRequestDetailsHelpers.walkerPhone(data);

    final dogName =
        WalkRequestDetailsHelpers.dogName(data);

    final dogBreed =
        WalkRequestDetailsHelpers.dogBreed(data);

    final dogPhoto =
        WalkRequestDetailsHelpers.dogPhoto(data);

    final address =
        WalkRequestDetailsHelpers.address(data);

    final status = _status();

    final createdAt =
        WalkRequestDetailsHelpers.createdAt(data);

    final hasWalker =
        WalkRequestDetailsHelpers.hasWalker(data);

    final isPending =
        WalkRequestDetailsHelpers.isPending(data);

    final ownerLocation =
        WalkRequestDetailsHelpers.ownerLocation(data);

    final walkerUid =
        WalkRequestDetailsHelpers.value(
      data,
      'walkerUid',
    );

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: white,
        surfaceTintColor: white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 18,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () {
            Navigator.of(context).maybePop();
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: dark,
          ),
        ),
        title: const Text(
          'Walk Request Details',
          style: TextStyle(
            color: dark,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: border,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop =
                constraints.maxWidth >= 1000;

            return SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                isDesktop ? 32 : 16,
                20,
                isDesktop ? 32 : 16,
                40,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1250,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      WalkRequestDetailsHeader(
                        requestId: requestId,
                        status: status,
                        createdAt: createdAt,
                      ),

                      const SizedBox(height: 16),

                      // =====================================================
                      // REQUEST SUMMARY
                      // =====================================================
                      _RequestSummaryCard(
                        requestId: requestId,
                        ownerName: ownerName,
                        dogName: dogName,
                        walkerName: walkerName,
                        status: status,
                      ),

                      const SizedBox(height: 16),

                      // =====================================================
                      // DESKTOP LAYOUT
                      // =====================================================
                      if (isDesktop)
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  WalkRequestDetailsOwner(
                                    ownerName: ownerName,
                                    ownerId: ownerId,
                                    ownerPhone: ownerPhone,
                                    onCall: () {
                                      _callPhone(
                                        context,
                                        ownerPhone,
                                      );
                                    },
                                    onCopy: () {
                                      _copyText(
                                        context,
                                        ownerId,
                                        'Owner ID',
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  WalkRequestDetailsDog(
                                    dogName: dogName,
                                    dogBreed: dogBreed,
                                    dogPhoto: dogPhoto,
                                  ),

                                  const SizedBox(height: 16),

                                  WalkRequestDetailsLocation(
                                    address: address,
                                    hasLocation:
                                        ownerLocation != null,
                                    onOpenMaps:
                                        ownerLocation != null &&
                                                onOpenMaps != null
                                            ? () {
                                                _openMaps(
                                                  ownerLocation,
                                                );
                                              }
                                            : null,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  WalkRequestDetailsWalker(
                                    hasWalker: hasWalker,
                                    walkerName: walkerName,
                                    walkerId: walkerId,
                                    walkerPhone: walkerPhone,
                                    onCall: () {
                                      _callPhone(
                                        context,
                                        walkerPhone,
                                      );
                                    },
                                    onCopy: () {
                                      _copyText(
                                        context,
                                        walkerId,
                                        'Walker ID',
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  WalkRequestDetailsInformation(
                                    requestId: requestId,
                                    ownerName: ownerName,
                                    dogName: dogName,
                                    walkerName: walkerName,
                                    hasWalker: hasWalker,
                                    status: status,
                                  ),

                                  if (ownerLocation != null) ...[
                                    const SizedBox(height: 16),
                                    WalkRequestDetailsMap(
                                      ownerLocation:
                                          ownerLocation,
                                      walkerId: walkerId,
                                      walkerUid: walkerUid,
                                      walkerName: walkerName,
                                      onOpenMaps:
                                          onOpenMaps != null
                                              ? () {
                                                  _openMaps(
                                                    ownerLocation,
                                                  );
                                                }
                                              : null,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        )

                      // =====================================================
                      // MOBILE LAYOUT
                      // =====================================================
                      else
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            WalkRequestDetailsOwner(
                              ownerName: ownerName,
                              ownerId: ownerId,
                              ownerPhone: ownerPhone,
                              onCall: () {
                                _callPhone(
                                  context,
                                  ownerPhone,
                                );
                              },
                              onCopy: () {
                                _copyText(
                                  context,
                                  ownerId,
                                  'Owner ID',
                                );
                              },
                            ),

                            const SizedBox(height: 16),

                            WalkRequestDetailsDog(
                              dogName: dogName,
                              dogBreed: dogBreed,
                              dogPhoto: dogPhoto,
                            ),

                            const SizedBox(height: 16),

                            WalkRequestDetailsWalker(
                              hasWalker: hasWalker,
                              walkerName: walkerName,
                              walkerId: walkerId,
                              walkerPhone: walkerPhone,
                              onCall: () {
                                _callPhone(
                                  context,
                                  walkerPhone,
                                );
                              },
                              onCopy: () {
                                _copyText(
                                  context,
                                  walkerId,
                                  'Walker ID',
                                );
                              },
                            ),

                            const SizedBox(height: 16),

                            WalkRequestDetailsLocation(
                              address: address,
                              hasLocation:
                                  ownerLocation != null,
                              onOpenMaps:
                                  ownerLocation != null &&
                                          onOpenMaps != null
                                      ? () {
                                          _openMaps(
                                            ownerLocation,
                                          );
                                        }
                                      : null,
                            ),

                            if (ownerLocation != null) ...[
                              const SizedBox(height: 16),
                              WalkRequestDetailsMap(
                                ownerLocation:
                                    ownerLocation,
                                walkerId: walkerId,
                                walkerUid: walkerUid,
                                walkerName: walkerName,
                                onOpenMaps:
                                    onOpenMaps != null
                                        ? () {
                                            _openMaps(
                                              ownerLocation,
                                            );
                                          }
                                        : null,
                              ),
                            ],

                            const SizedBox(height: 16),

                            WalkRequestDetailsInformation(
                              requestId: requestId,
                              ownerName: ownerName,
                              dogName: dogName,
                              walkerName: walkerName,
                              hasWalker: hasWalker,
                              status: status,
                            ),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // =====================================================
                      // ACTIONS
                      // =====================================================
                      WalkRequestDetailsActions(
                        isPending: isPending,
                        hasWalker: hasWalker,
                        onAssign: onAssign,
                        onCancel: onCancel,
                      ),

                      const SizedBox(height: 24),

                      _BottomReference(
                        requestId: requestId,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// REQUEST SUMMARY CARD
// ============================================================================

class _RequestSummaryCard extends StatelessWidget {
  const _RequestSummaryCard({
    required this.requestId,
    required this.ownerName,
    required this.dogName,
    required this.walkerName,
    required this.status,
  });

  final String requestId;
  final String ownerName;
  final String dogName;
  final String walkerName;
  final String status;

  static const Color orange = Color(0xFFD35435);
  static const Color blue = Color(0xFF2563EB);
  static const Color dark = Color(0xFF0F172A);
  static const Color grey = Color(0xFF64748B);
  static const Color white = Colors.white;
  static const Color border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      orange.withValues(alpha: 0.10),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: orange,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Request Summary',
                  style: TextStyle(
                    color: dark,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _SummaryRow(
            label: 'Request ID',
            value: requestId,
          ),

          _SummaryRow(
            label: 'Owner',
            value: ownerName,
          ),

          _SummaryRow(
            label: 'Dog',
            value: dogName,
          ),

          _SummaryRow(
            label: 'Walker',
            value: walkerName.isEmpty
                ? 'Not assigned'
                : walkerName,
          ),

          _SummaryRow(
            label: 'Status',
            value: status.toUpperCase(),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SUMMARY ROW
// ============================================================================

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  static const Color dark = Color(0xFF0F172A);
  static const Color grey = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: border,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: grey,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Flexible(
            child: Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: dark,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BOTTOM REFERENCE
// ============================================================================

class _BottomReference extends StatelessWidget {
  const _BottomReference({
    required this.requestId,
  });

  final String requestId;

  static const Color grey = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(
          color: border,
          height: 1,
        ),
        const SizedBox(height: 14),
        Text(
          'Request ID: $requestId',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: grey,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
