// File: lib/features/walk_requests/screens/walk_request_details_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/walk_request_map_preview.dart';

class _WalkRequestDetailsColors {
  static const Color orange = Color(0xFFD35435);
  static const Color blue = Color(0xFF2563EB);
  static const Color green = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);
  static const Color dark = Color(0xFF0F172A);
  static const Color grey = Color(0xFF64748B);
  static const Color background = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);
  static const Color white = Colors.white;
}

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
  final VoidCallback? onOpenMaps;

  String _value(String key, [String fallback = '—']) {
    final value = data[key];

    if (value == null) return fallback;

    final text = value.toString().trim();

    if (text.isEmpty || text == 'null') return fallback;

    return text;
  }

  String _firstAvailable(
    List<String> keys, [
    String fallback = '—',
  ]) {
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

  String get status => _value('status', 'pending');

  String get ownerName => _firstAvailable([
        'ownerName',
        'ownerDisplayName',
        'name',
      ], 'Unknown Owner');

  String get ownerId => _firstAvailable([
        'ownerId',
        'ownerAuthUid',
        'ownerUid',
      ]);

  String get ownerPhone => _firstAvailable([
        'ownerPhone',
        'ownerMobile',
        'ownerPhoneNumber',
        'phone',
        'mobile',
      ]);

  String get walkerName => _firstAvailable([
        'walkerName',
        'walkerDisplayName',
      ]);

  String get walkerId => _firstAvailable([
        'walkerId',
        'walkerUid',
        'walkerAuthUid',
      ]);

  String get walkerPhone => _firstAvailable([
        'walkerPhone',
        'walkerMobile',
        'walkerPhoneNumber',
        'walkerMobileNumber',
        'phone',
        'mobile',
      ]);

  String get dogName => _firstAvailable([
        'dogName',
        'petName',
      ], 'Dog');

  String get dogBreed => _firstAvailable([
        'dogBreed',
        'petBreed',
        'breed',
      ]);

  String get dogPhoto => _firstAvailable([
        'dogPhoto',
        'petPhoto',
        'dogImage',
        'petImage',
      ]);

  String get address => _firstAvailable([
        'address',
        'pickupAddress',
        'location',
      ]);

  String get searchType => _value('searchType', 'Instant Walk');

  String get radius => data['searchRadiusKm'] == null
      ? '—'
      : '${data['searchRadiusKm']} km';

  String get createdAt {
    final value = data['createdAt'];

    if (value == null) return '—';

    if (value is Timestamp) {
      return _formatDate(value.toDate());
    }

    if (value is DateTime) {
      return _formatDate(value);
    }

    return value.toString();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  bool get isPending {
    final value = status.toLowerCase();

    return value == 'pending' ||
        value == 'searching' ||
        value == 'requested';
  }

  bool get hasWalker {
    return walkerName != '—' ||
        walkerId != '—' ||
        data['walkerId'] != null;
  }

  Future<void> _callNumber(String phone) async {
    if (phone == '—' || phone.trim().isEmpty) return;

    final uri = Uri.parse('tel:$phone');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _copy(BuildContext context, String value) async {
    if (value == '—' || value.isEmpty) return;

    await Clipboard.setData(
      ClipboardData(text: value),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _WalkRequestDetailsColors.background,
      appBar: AppBar(
        backgroundColor: _WalkRequestDetailsColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Walk Request Details',
          style: TextStyle(
            color: _WalkRequestDetailsColors.dark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 1050;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(wide ? 28 : 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1450,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(
                      requestId: requestId,
                      status: status,
                      onCopy: () => _copy(context, requestId),
                    ),
                    const SizedBox(height: 20),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: _leftColumn(context),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 4,
                            child: _rightColumn(context),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _leftColumn(context),
                          const SizedBox(height: 16),
                          _rightColumn(context),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _leftColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InvoiceCard(
          title: 'Request Summary',
          icon: Icons.receipt_long_rounded,
          child: Column(
            children: [
              _SummaryRow(
                label: 'Request ID',
                value: requestId,
                copy: () => _copy(context, requestId),
              ),
              _SummaryRow(
                label: 'Status',
                value: status.toUpperCase(),
                valueColor: _statusColor(status),
              ),
              _SummaryRow(
                label: 'Search Type',
                value: searchType,
              ),
              _SummaryRow(
                label: 'Search Radius',
                value: radius,
              ),
              _SummaryRow(
                label: 'Created',
                value: createdAt,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InvoiceCard(
          title: 'Owner Details',
          icon: Icons.person_rounded,
          child: Column(
            children: [
              _ProfileHeader(
                name: ownerName,
                subtitle: ownerId,
              ),
              const SizedBox(height: 14),
              _PhoneRow(
                phone: ownerPhone,
                onCall: () => _callNumber(ownerPhone),
              ),
              const SizedBox(height: 10),
              _CopyRow(
                label: 'Owner ID',
                value: ownerId,
                onCopy: () => _copy(context, ownerId),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InvoiceCard(
          title: 'Dog Details',
          icon: Icons.pets_rounded,
          child: Row(
            children: [
              _DogAvatar(photo: dogPhoto),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dogName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _WalkRequestDetailsColors.dark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dogBreed,
                      style: const TextStyle(
                        color: _WalkRequestDetailsColors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InvoiceCard(
          title: 'Walker Details',
          icon: Icons.directions_walk_rounded,
          child: hasWalker
              ? Column(
                  children: [
                    _ProfileHeader(
                      name: walkerName,
                      subtitle: walkerId,
                    ),
                    const SizedBox(height: 14),
                    _PhoneRow(
                      phone: walkerPhone,
                      onCall: () => _callNumber(walkerPhone),
                    ),
                    const SizedBox(height: 10),
                    _CopyRow(
                      label: 'Walker ID',
                      value: walkerId,
                      onCopy: () => _copy(context, walkerId),
                    ),
                  ],
                )
              : const _EmptyWalker(),
        ),
      ],
    );
  }

  Widget _rightColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InvoiceCard(
          title: 'Pickup Location',
          icon: Icons.location_on_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _WalkRequestDetailsColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _WalkRequestDetailsColors.border,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: _WalkRequestDetailsColors.orange,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        address,
                        style: const TextStyle(
                          color: _WalkRequestDetailsColors.dark,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (onOpenMaps != null) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onOpenMaps,
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Open in Maps'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _WalkRequestDetailsColors.blue,
                    side: const BorderSide(
                      color: _WalkRequestDetailsColors.border,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InvoiceCard(
          title: 'Map',
          icon: Icons.map_rounded,
          child: SizedBox(
            height: 360,
            child: WalkRequestMapPreview(
              data: data,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _InvoiceCard(
          title: 'Walk Information',
          icon: Icons.info_outline_rounded,
          child: Column(
            children: [
              _InvoiceRow(
                label: 'Request ID',
                value: requestId,
              ),
              _InvoiceRow(
                label: 'Owner',
                value: ownerName,
              ),
              _InvoiceRow(
                label: 'Dog',
                value: dogName,
              ),
              _InvoiceRow(
                label: 'Walker',
                value: hasWalker ? walkerName : 'Not assigned',
              ),
              _InvoiceRow(
                label: 'Status',
                value: status.toUpperCase(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ActionsCard(
          isPending: isPending,
          hasWalker: hasWalker,
          onAssign: onAssign,
          onCancel: onCancel,
        ),
      ],
    );
  }

  Color _statusColor(String value) {
    switch (value.toLowerCase()) {
      case 'accepted':
      case 'assigned':
      case 'completed':
        return _WalkRequestDetailsColors.green;

      case 'cancelled':
      case 'canceled':
      case 'rejected':
        return _WalkRequestDetailsColors.danger;

      default:
        return _WalkRequestDetailsColors.blue;
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.requestId,
    required this.status,
    required this.onCopy,
  });

  final String requestId;
  final String status;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _WalkRequestDetailsColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _WalkRequestDetailsColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _WalkRequestDetailsColors.orange.withValues(
                alpha: .10,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: _WalkRequestDetailsColors.orange,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Walk Request',
                  style: TextStyle(
                    color: _WalkRequestDetailsColors.dark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                InkWell(
                  onTap: onCopy,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          requestId,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _WalkRequestDetailsColors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.copy_rounded,
                        size: 15,
                        color: _WalkRequestDetailsColors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _StatusBadge(status: status),
        ],
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _WalkRequestDetailsColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _WalkRequestDetailsColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: _WalkRequestDetailsColors.blue,
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  color: _WalkRequestDetailsColors.dark,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.copy,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback? copy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _WalkRequestDetailsColors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: valueColor ??
                          _WalkRequestDetailsColors.dark,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (copy != null) ...[
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: copy,
                    child: const Icon(
                      Icons.copy_rounded,
                      size: 14,
                      color: _WalkRequestDetailsColors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.subtitle,
  });

  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _WalkRequestDetailsColors.blue.withValues(
              alpha: .10,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: _WalkRequestDetailsColors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _WalkRequestDetailsColors.dark,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _WalkRequestDetailsColors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhoneRow extends StatelessWidget {
  const _PhoneRow({
    required this.phone,
    required this.onCall,
  });

  final String phone;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final enabled = phone != '—';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: _WalkRequestDetailsColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _WalkRequestDetailsColors.border,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.phone_outlined,
            size: 18,
            color: _WalkRequestDetailsColors.green,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              phone,
              style: const TextStyle(
                color: _WalkRequestDetailsColors.dark,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: enabled ? onCall : null,
            icon: const Icon(Icons.call_rounded, size: 16),
            label: const Text('Call'),
            style: TextButton.styleFrom(
              foregroundColor: _WalkRequestDetailsColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyRow extends StatelessWidget {
  const _CopyRow({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  final String label;
  final String value;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onCopy,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: _WalkRequestDetailsColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _WalkRequestDetailsColors.border,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: _WalkRequestDetailsColors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _WalkRequestDetailsColors.dark,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.copy_rounded,
              size: 16,
              color: _WalkRequestDetailsColors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

class _DogAvatar extends StatelessWidget {
  const _DogAvatar({
    required this.photo,
  });

  final String photo;

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        photo != '—' && photo.trim().isNotEmpty;

    return Container(
      width: 58,
      height: 58,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _WalkRequestDetailsColors.orange.withValues(
          alpha: .10,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: hasPhoto
          ? Image.network(
              photo,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.pets_rounded,
                  color: _WalkRequestDetailsColors.orange,
                );
              },
            )
          : const Icon(
              Icons.pets_rounded,
              color: _WalkRequestDetailsColors.orange,
            ),
    );
  }
}

class _EmptyWalker extends StatelessWidget {
  const _EmptyWalker();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _WalkRequestDetailsColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _WalkRequestDetailsColors.border,
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.person_search_rounded,
            color: _WalkRequestDetailsColors.grey,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No walker assigned yet.',
              style: TextStyle(
                color: _WalkRequestDetailsColors.grey,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _WalkRequestDetailsColors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _WalkRequestDetailsColors.dark,
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final value = status.toLowerCase();

    Color color;

    if (value == 'accepted' ||
        value == 'assigned' ||
        value == 'completed') {
      color = _WalkRequestDetailsColors.green;
    } else if (value == 'cancelled' ||
        value == 'canceled' ||
        value == 'rejected') {
      color = _WalkRequestDetailsColors.danger;
    } else {
      color = _WalkRequestDetailsColors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ActionsCard extends StatelessWidget {
  const _ActionsCard({
    required this.isPending,
    required this.hasWalker,
    required this.onAssign,
    required this.onCancel,
  });

  final bool isPending;
  final bool hasWalker;
  final VoidCallback? onAssign;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _WalkRequestDetailsColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _WalkRequestDetailsColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Actions',
            style: TextStyle(
              color: _WalkRequestDetailsColors.dark,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          if (onAssign != null)
            SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: onAssign,
                icon: Icon(
                  hasWalker
                      ? Icons.swap_horiz_rounded
                      : Icons.person_add_alt_1_rounded,
                ),
                label: Text(
                  hasWalker ? 'Change Walker' : 'Assign Walker',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _WalkRequestDetailsColors.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          if (onAssign != null && onCancel != null)
            const SizedBox(height: 10),
          if (onCancel != null && isPending)
            SizedBox(
              height: 46,
              child: OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel Request'),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      _WalkRequestDetailsColors.danger,
                  side: const BorderSide(
                    color: _WalkRequestDetailsColors.danger,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
