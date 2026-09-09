// File:
// lib/features/walk_requests/screens/walk_request_details_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
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
  static const Color background = Color(0xFFF8FAFC);
  static const Color dark = Color(0xFF0F172A);
  static const Color grey = Color(0xFF64748B);
  static const Color green = Color(0xFF16A34A);
  static const Color blue = Color(0xFF2563EB);
  static const Color red = Color(0xFFDC2626);
  static const Color amber = Color(0xFFD97706);
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

    final hasWalker =
        WalkRequestDetailsHelpers.hasWalker(data);

    final isPending =
        WalkRequestDetailsHelpers.isPending(data);

    final ownerLocation =
        WalkRequestDetailsHelpers.ownerLocation(data);

    final walkerLocation =
        WalkRequestDetailsHelpers.walkerLocation(data);

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
                        onCopy: () => _copyText(
                          context,
                          requestId,
                          'Request ID',
                        ),
                      ),

                      const SizedBox(height: 16),

                      _RequestSummaryCard(
                        requestId: requestId,
                        ownerName: ownerName,
                        dogName: dogName,
                        walkerName: walkerName,
                        status: status,
                        data: data,
                      ),

                      const SizedBox(height: 16),

                      _WalkTimelineCard(
                        data: data,
                      ),

                      const SizedBox(height: 16),

                      _PickupMetricsCard(
                        data: data,
                      ),

                      const SizedBox(height: 16),

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
                                      requestId: requestId,
                                      ownerLocation:
                                          ownerLocation,
                                      walkerLocation:
                                          walkerLocation,
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
                                requestId: requestId,
                                ownerLocation:
                                    ownerLocation,
                                walkerLocation:
                                    walkerLocation,
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
    required this.data,
  });

  final String requestId;
  final String ownerName;
  final String dogName;
  final String walkerName;
  final String status;
  final Map<String, dynamic> data;

  static const Color orange = Color(0xFFD35435);
  static const Color dark = Color(0xFF0F172A);
  static const Color grey = Color(0xFF64748B);
  static const Color green = Color(0xFF16A34A);
  static const Color blue = Color(0xFF2563EB);
  static const Color red = Color(0xFFDC2626);
  static const Color amber = Color(0xFFD97706);
  static const Color white = Colors.white;
  static const Color border = Color(0xFFE2E8F0);

  Color _statusColor() {
    final value = status.trim().toLowerCase();

    if (value == 'completed' ||
        value == 'complete') {
      return green;
    }

    if (value == 'cancelled' ||
        value == 'canceled' ||
        value == 'rejected') {
      return red;
    }

    if (value == 'accepted' ||
        value == 'assigned') {
      return blue;
    }

    if (value == 'active' ||
        value == 'started' ||
        value == 'in_progress' ||
        value == 'in-progress' ||
        value == 'live') {
      return orange;
    }

    return amber;
  }

  @override
  Widget build(BuildContext context) {
    final createdAt =
        WalkRequestDetailsHelpers.createdAt(data);

    final acceptedAt =
        WalkRequestDetailsHelpers.acceptedAt(data);

    final reachedAt =
        WalkRequestDetailsHelpers.reachedAt(data);

    final completedAt =
        _firstDateTime(
      data,
      const [
        'completedAt',
        'completeAt',
        'completionAt',
        'endedAt',
        'finishedAt',
      ],
    );

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
              _StatusBadge(
                status: status,
                color: _statusColor(),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _SummaryItem(
            label: 'Request ID',
            value: requestId,
          ),

          _SummaryItem(
            label: 'Owner',
            value: ownerName,
          ),

          _SummaryItem(
            label: 'Dog',
            value: dogName,
          ),

          _SummaryItem(
            label: 'Walker',
            value: walkerName.isEmpty
                ? 'Not assigned'
                : walkerName,
          ),

          _SummaryItem(
            label: 'Requested',
            value: _formatDateTime(createdAt),
          ),

          _SummaryItem(
            label: 'Accepted',
            value: _formatDateTime(acceptedAt),
          ),

          _SummaryItem(
            label: 'Pickup',
            value: _formatDateTime(reachedAt),
          ),

          _SummaryItem(
            label: 'Completed',
            value: _formatDateTime(completedAt),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// STATUS BADGE
// ============================================================================

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    required this.color,
  });

  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ============================================================================
// WALK TIMELINE
// ============================================================================

class _WalkTimelineCard extends StatelessWidget {
  const _WalkTimelineCard({
    required this.data,
  });

  final Map<String, dynamic> data;

  static const Color dark = Color(0xFF0F172A);
  static const Color grey = Color(0xFF64748B);
  static const Color green = Color(0xFF16A34A);
  static const Color blue = Color(0xFF2563EB);
  static const Color orange = Color(0xFFD35435);
  static const Color border = Color(0xFFE2E8F0);
  static const Color white = Colors.white;

  @override
  Widget build(BuildContext context) {
    final requested =
        WalkRequestDetailsHelpers.createdAt(data);

    final accepted =
        WalkRequestDetailsHelpers.acceptedAt(data);

    final reached =
        WalkRequestDetailsHelpers.reachedAt(data);

    final completed = _firstDateTime(
      data,
      const [
        'completedAt',
        'completeAt',
        'completionAt',
        'endedAt',
        'finishedAt',
      ],
    );

    final status =
        WalkRequestDetailsHelpers.value(
      data,
      'status',
    ).trim().toLowerCase();

    final isCompleted =
        status == 'completed' ||
        status == 'complete' ||
        completed != null;

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
          const Row(
            children: [
              Icon(
                Icons.timeline_rounded,
                color: orange,
                size: 21,
              ),
              SizedBox(width: 10),
              Text(
                'Walk Timeline',
                style: TextStyle(
                  color: dark,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _TimelineRow(
            icon: Icons.add_location_alt_rounded,
            title: 'Request Created',
            value: _formatDateTime(requested),
            color: blue,
            completed: requested != null,
          ),

          _TimelineConnector(),

          _TimelineRow(
            icon: Icons.person_pin_circle_rounded,
            title: 'Walker Accepted',
            value: _formatDateTime(accepted),
            color: blue,
            completed: accepted != null,
          ),

          _TimelineConnector(),

          _TimelineRow(
            icon: Icons.directions_walk_rounded,
            title: 'Reached Pickup',
            value: _formatDateTime(reached),
            color: green,
            completed: reached != null,
          ),

          _TimelineConnector(),

          _TimelineRow(
            icon: Icons.flag_rounded,
            title: 'Walk Completed',
            value: isCompleted
                ? _formatDateTime(completed)
                : 'Not completed',
            color: green,
            completed: isCompleted,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TIMELINE ROW
// ============================================================================

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.completed,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool completed;

  static const Color dark = Color(0xFF0F172A);
  static const Color grey = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: completed
                ? color.withValues(alpha: 0.10)
                : Colors.grey.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 19,
            color: completed
                ? color
                : grey.withValues(alpha: 0.60),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: dark,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: value == 'Not completed'
                      ? grey
                      : grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (completed)
          Icon(
            Icons.check_circle_rounded,
            color: color,
            size: 19,
          ),
      ],
    );
  }
}

// ============================================================================
// TIMELINE CONNECTOR
// ============================================================================

class _TimelineConnector extends StatelessWidget {
  const _TimelineConnector();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 19,
        top: 3,
        bottom: 3,
      ),
      width: 2,
      height: 20,
      color: const Color(0xFFE2E8F0),
    );
  }
}

// ============================================================================
// PICKUP METRICS
// ============================================================================

class _PickupMetricsCard extends StatelessWidget {
  const _PickupMetricsCard({
    required this.data,
  });

  final Map<String, dynamic> data;

  static const Color dark = Color(0xFF0F172A);
  static const Color grey = Color(0xFF64748B);
  static const Color green = Color(0xFF16A34A);
  static const Color blue = Color(0xFF2563EB);
  static const Color orange = Color(0xFFD35435);
  static const Color border = Color(0xFFE2E8F0);
  static const Color white = Colors.white;

  @override
  Widget build(BuildContext context) {
    final distanceKm =
        _numberValue(
      data,
      const [
        'arrivalDistanceKm',
        'pickupDistanceKm',
      ],
    );

    final distanceMeters =
        _numberValue(
      data,
      const [
        'arrivalDistanceMeters',
        'pickupDistanceMeters',
      ],
    );

    final durationMinutes =
        _numberValue(
      data,
      const [
        'arrivalDurationMinutes',
        'pickupDurationMinutes',
      ],
    );

    final reached =
        WalkRequestDetailsHelpers.reachedAt(data);

    final locationUpdated =
        WalkRequestDetailsHelpers.locationUpdatedAt(data);

    final hasWalkerLocation =
        WalkRequestDetailsHelpers.walkerLocation(data) != null;

    final distanceText =
        distanceKm != null
            ? '${distanceKm.toStringAsFixed(2)} km'
            : distanceMeters != null
                ? '${distanceMeters.toStringAsFixed(0)} m'
                : '—';

    final meterText =
        distanceMeters != null
            ? '${distanceMeters.toStringAsFixed(0)} m'
            : distanceKm != null
                ? '${(distanceKm * 1000).toStringAsFixed(0)} m'
                : '—';

    final durationText =
        durationMinutes != null
            ? '${durationMinutes.toStringAsFixed(0)} min'
            : '—';

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
          const Row(
            children: [
              Icon(
                Icons.route_rounded,
                color: orange,
                size: 21,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pickup & Walker Metrics',
                  style: TextStyle(
                    color: dark,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (true)
                _LiveIndicator(),
            ],
          ),

          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              final compact =
                  constraints.maxWidth < 650;

              final items = [
                _MetricItem(
                  icon: Icons.social_distance_rounded,
                  title: 'Pickup Distance',
                  value: distanceText,
                  color: blue,
                ),
                _MetricItem(
                  icon: Icons.straighten_rounded,
                  title: 'Distance',
                  value: meterText,
                  color: orange,
                ),
                _MetricItem(
                  icon: Icons.timer_rounded,
                  title: 'Arrival Time',
                  value: durationText,
                  color: green,
                ),
                _MetricItem(
                  icon: Icons.location_on_rounded,
                  title: 'Pickup',
                  value: reached != null
                      ? 'Reached'
                      : 'Not reached',
                  color: reached != null
                      ? green
                      : grey,
                ),
              ];

              if (compact) {
                return Column(
                  children: items
                      .map(
                        (item) => Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: item,
                        ),
                      )
                      .toList(),
                );
              }

              return Row(
                children: items
                    .map(
                      (item) => Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.only(
                            right: 8,
                          ),
                          child: item,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasWalkerLocation
                  ? green.withValues(alpha: 0.06)
                  : grey.withValues(alpha: 0.06),
              borderRadius:
                  BorderRadius.circular(12),
              border: Border.all(
                color: hasWalkerLocation
                    ? green.withValues(alpha: 0.15)
                    : border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasWalkerLocation
                      ? Icons.gps_fixed_rounded
                      : Icons.gps_off_rounded,
                  size: 18,
                  color: hasWalkerLocation
                      ? green
                      : grey,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    hasWalkerLocation
                        ? 'Walker live location available'
                        : 'Walker live location not available yet',
                    style: TextStyle(
                      color: hasWalkerLocation
                          ? green
                          : grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (locationUpdated != null)
                  Text(
                    _formatTime(locationUpdated),
                    style: const TextStyle(
                      color: grey,
                      fontSize: 11,
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

// ============================================================================
// LIVE INDICATOR
// ============================================================================

class _LiveIndicator extends StatelessWidget {
  const _LiveIndicator();

  static const Color green = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 7,
            color: green,
          ),
          SizedBox(width: 5),
          Text(
            'LIVE',
            style: TextStyle(
              color: green,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// METRIC ITEM
// ============================================================================

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  static const Color dark = Color(0xFF0F172A);
  static const Color grey = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: grey,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: dark,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
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

// ============================================================================
// SUMMARY ITEM
// ============================================================================

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
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

// ============================================================================
// DATE / NUMBER HELPERS
// ============================================================================

DateTime? _firstDateTime(
  Map<String, dynamic> data,
  List<String> keys,
) {
  for (final key in keys) {
    final value = data[key];

    final parsed = _parseDateTime(value);

    if (parsed != null) {
      return parsed;
    }
  }

  return null;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is Timestamp) {
    return value.toDate();
  }

  if (value is DateTime) {
    return value;
  }

  if (value is String) {
    return DateTime.tryParse(value);
  }

  return null;
}

double? _numberValue(
  Map<String, dynamic> data,
  List<String> keys,
) {
  for (final key in keys) {
    final value = data[key];

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      final parsed = double.tryParse(value);

      if (parsed != null) {
        return parsed;
      }
    }
  }

  return null;
}

String _formatDateTime(DateTime? value) {
  if (value == null) {
    return 'Not available';
  }

  final local = value.toLocal();

  final day =
      local.day.toString().padLeft(2, '0');

  final month =
      local.month.toString().padLeft(2, '0');

  final year = local.year.toString();

  final hour =
      local.hour.toString().padLeft(2, '0');

  final minute =
      local.minute.toString().padLeft(2, '0');

  return '$day/$month/$year • $hour:$minute';
}

String _formatTime(DateTime value) {
  final local = value.toLocal();

  final hour =
      local.hour.toString().padLeft(2, '0');

  final minute =
      local.minute.toString().padLeft(2, '0');

  return '$hour:$minute';
}
