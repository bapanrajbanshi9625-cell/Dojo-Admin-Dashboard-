import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import 'walk_request_map_preview.dart';

class WalkRequestDetailsSheet extends StatelessWidget {
  final String requestId;
  final Map<String, dynamic> data;

  final VoidCallback onAssign;
  final VoidCallback onCancel;

  final Future<void> Function(LatLng location) onOpenMaps;

  const WalkRequestDetailsSheet({
    super.key,
    required this.requestId,
    required this.data,
    required this.onAssign,
    required this.onCancel,
    required this.onOpenMaps,
  });

  // ==========================================================
  // VALUE
  // ==========================================================

  String _value(String key) {
    final value = data[key];

    if (value == null) {
      return '';
    }

    return value.toString().trim();
  }

  // ==========================================================
  // STATUS
  // ==========================================================

  String _status() {
    return _value('status').toLowerCase();
  }

  String _displayStatus() {
    final status = _status();

    if (status.isEmpty) {
      return 'Unknown';
    }

    return status[0].toUpperCase() +
        status.substring(1);
  }

  // ==========================================================
  // DATE
  // ==========================================================

  DateTime? _date(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  String _dateText(dynamic value) {
    final date = _date(value);

    if (date == null) {
      return 'Not available';
    }

    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    final hour =
        date.hour.toString().padLeft(2, '0');

    final minute =
        date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} '
        '$hour:$minute';
  }

  // ==========================================================
  // LOCATION
  // ==========================================================

  LatLng? _location() {
    final value = data['ownerLocation'];

    if (value is GeoPoint) {
      return LatLng(
        value.latitude,
        value.longitude,
      );
    }

    return null;
  }

  // ==========================================================
  // RADIUS
  // ==========================================================

  String _formatRadius() {
    final value = data['searchRadiusKm'];

    if (value == null) {
      return 'Not available';
    }

    if (value is num) {
      return '${value.toStringAsFixed(1)} km';
    }

    final parsed = double.tryParse(
      value.toString(),
    );

    if (parsed != null) {
      return '${parsed.toStringAsFixed(1)} km';
    }

    return value.toString();
  }

  // ==========================================================
  // COPY
  // ==========================================================

  Future<void> _copy(
    BuildContext context,
    String value,
    String label,
  ) async {
    if (value.trim().isEmpty) {
      return;
    }

    await Clipboard.setData(
      ClipboardData(text: value),
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$label copied'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(
            seconds: 1,
          ),
        ),
      );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final status = _status();
    final location = _location();

    final pending =
        status == 'searching' ||
        status == 'pending';

    final assigned =
        status == 'accepted' ||
        status == 'active';

    final canCancel =
        pending || assigned;

    final walkerName =
        _value('walkerName');

    return Material(
      color: Theme.of(context)
          .colorScheme
          .surface,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            14,
            20,
            30,
          ),
          children: [
            // ==================================================
            // MOBILE HANDLE
            // ==================================================

            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // HEADER
            // ==================================================

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Walk Request',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Manage this walk request',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _StatusBadge(
                  status: _displayStatus(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ==================================================
            // REQUEST SUMMARY
            // ==================================================

            _buildSummaryCard(context),

            const SizedBox(height: 18),

            // ==================================================
            // OWNER
            // ==================================================

            _buildSection(
              context,
              title: 'Owner',
              icon: Icons.person_outline,
              children: [
                _buildCopyDetail(
                  context,
                  title: 'Owner ID',
                  value: _value('ownerId'),
                ),
                _buildDetail(
                  'Name',
                  _value('ownerName'),
                ),
                _buildDetail(
                  'Mobile',
                  _firstAvailable([
                    'ownerPhone',
                    'ownerMobile',
                    'phone',
                    'mobile',
                  ]),
                ),
              ],
            ),

            // ==================================================
            // DOG
            // ==================================================

            if (_hasDogInformation())
              _buildSection(
                context,
                title: 'Dog',
                icon: Icons.pets_outlined,
                children: [
                  _buildDetail(
                    'Name',
                    _firstAvailable([
                      'dogName',
                      'petName',
                    ]),
                  ),
                  _buildDetail(
                    'Breed',
                    _firstAvailable([
                      'dogBreed',
                      'petBreed',
                    ]),
                  ),
                  _buildDetail(
                    'Age',
                    _firstAvailable([
                      'dogAge',
                      'petAge',
                    ]),
                  ),
                ],
              ),

            // ==================================================
            // LOCATION
            // ==================================================

            _buildSection(
              context,
              title: 'Pickup Location',
              icon: Icons.location_on_outlined,
              children: [
                _buildDetail(
                  'Address',
                  _value('address'),
                ),
                _buildDetail(
                  'Location Type',
                  _value('ownerLocationType'),
                ),
              ],
            ),

            if (location != null) ...[
              WalkRequestMapPreview(
                location: location,
                onOpenMaps: () {
                  onOpenMaps(location);
                },
              ),
              const SizedBox(height: 18),
            ],

            // ==================================================
            // WALKER
            // ==================================================

            _buildSection(
              context,
              title: 'Walker',
              icon: Icons.directions_walk,
              children: [
                _buildDetail(
                  'Name',
                  walkerName.isEmpty
                      ? 'Not assigned'
                      : walkerName,
                ),
                _buildCopyDetail(
                  context,
                  title: 'Walker ID',
                  value: _value('walkerId'),
                ),
              ],
            ),

            // ==================================================
            // WALK INFORMATION
            // ==================================================

            _buildSection(
              context,
              title: 'Walk Information',
              icon: Icons.receipt_long_outlined,
              children: [
                _buildCopyDetail(
                  context,
                  title: 'Walk ID',
                  value: requestId,
                ),
                _buildDetail(
                  'Status',
                  _displayStatus(),
                ),
                _buildDetail(
                  'Walk Type',
                  _value('searchType'),
                ),
                _buildDetail(
                  'Search Radius',
                  _formatRadius(),
                ),
                _buildDetail(
                  'Created',
                  _dateText(
                    data['createdAt'],
                  ),
                ),
                if (status == 'accepted' ||
                    status == 'active' ||
                    status == 'completed')
                  _buildDetail(
                    'Accepted',
                    _dateText(
                      data['acceptedAt'],
                    ),
                  ),
                if (status == 'cancelled' ||
                    status == 'canceled')
                  _buildDetail(
                    'Cancellation Reason',
                    _value(
                      'cancellationReason',
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 4),

            // ==================================================
            // ACTIONS
            // ==================================================

            if (pending)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onAssign,
                  icon: const Icon(
                    Icons.person_add_alt_1,
                  ),
                  label: const Text(
                    'Assign Walker',
                  ),
                ),
              ),

            if (assigned)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onAssign,
                  icon: const Icon(
                    Icons.swap_horiz,
                  ),
                  label: const Text(
                    'Change Walker',
                  ),
                ),
              ),

            if (canCancel) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(
                    Icons.cancel_outlined,
                  ),
                  label: const Text(
                    'Cancel Request',
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // SUMMARY CARD
  // ==========================================================

  Widget _buildSummaryCard(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final ownerName =
        _value('ownerName');

    final walkerName =
        _value('walkerName');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme
            .primaryContainer
            .withValues(alpha: 0.35),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme
              .primary
              .withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_walk,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ownerName.isEmpty
                      ? 'Walk Request'
                      : '$ownerName\'s Walk',
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(
                icon: Icons.schedule,
                text: _dateText(
                  data['createdAt'],
                ),
              ),
              _InfoPill(
                icon: Icons.search,
                text: _formatRadius(),
              ),
              _InfoPill(
                icon: Icons.person_outline,
                text: walkerName.isEmpty
                    ? 'Walker not assigned'
                    : walkerName,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DOG CHECK
  // ==========================================================

  bool _hasDogInformation() {
    return _firstAvailable([
          'dogName',
          'petName',
          'dogBreed',
          'petBreed',
          'dogAge',
          'petAge',
        ]).isNotEmpty;
  }

  // ==========================================================
  // FIRST AVAILABLE
  // ==========================================================

  String _firstAvailable(
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = _value(key);

      if (value.isNotEmpty) {
        return value;
      }
    }

    return '';
  }

  // ==========================================================
  // SECTION
  // ==========================================================

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 18,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(15),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant,
              ),
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // NORMAL DETAIL
  // ==========================================================

  Widget _buildDetail(
    String title,
    String value,
  ) {
    final displayValue =
        value.trim().isEmpty
            ? 'Not available'
            : value;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final narrow =
              constraints.maxWidth < 360;

          if (narrow) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                SelectableText(
                  displayValue,
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: SelectableText(
                  displayValue,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================================
  // COPYABLE DETAIL
  // ==========================================================

  Widget _buildCopyDetail(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    final displayValue =
        value.trim().isEmpty
            ? 'Not available'
            : value;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final narrow =
              constraints.maxWidth < 360;

          final content = Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SelectableText(
                  displayValue,
                ),
              ),
              if (value.trim().isNotEmpty)
                IconButton(
                  tooltip: 'Copy',
                  visualDensity:
                      VisualDensity.compact,
                  onPressed: () {
                    _copy(
                      context,
                      value,
                      title,
                    );
                  },
                  icon: const Icon(
                    Icons.copy_outlined,
                    size: 18,
                  ),
                ),
            ],
          );

          if (narrow) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                content,
              ],
            );
          }

          return Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: content,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// INFO PILL
// ============================================================

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface,
        borderRadius:
            BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STATUS BADGE
// ============================================================

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final statusLower =
        status.toLowerCase();

    ColorScheme scheme =
        colorScheme;

    if (statusLower == 'cancelled' ||
        statusLower == 'canceled') {
      scheme = ColorScheme.fromSeed(
        seedColor: Colors.red,
        brightness:
            Theme.of(context)
                .brightness,
      );
    } else if (statusLower ==
        'completed') {
      scheme = ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness:
            Theme.of(context)
                .brightness,
      );
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(30),
        color: scheme.primary
            .withValues(alpha: 0.10),
      ),
      child: Text(
        status.isEmpty
            ? 'Unknown'
            : status,
        style: TextStyle(
          fontSize: 12,
          fontWeight:
              FontWeight.w700,
          color: scheme.primary,
        ),
      ),
    );
  }
}
