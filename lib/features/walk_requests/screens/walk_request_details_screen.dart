import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/walk_request_map_preview.dart';

class WalkRequestDetailsScreen extends StatelessWidget {
  final String requestId;
  final Map<String, dynamic> data;

  final VoidCallback onAssign;
  final VoidCallback onCancel;
  final Future<void> Function(LatLng location) onOpenMaps;

  const WalkRequestDetailsScreen({
    super.key,
    required this.requestId,
    required this.data,
    required this.onAssign,
    required this.onCancel,
    required this.onOpenMaps,
  });

  static const Color orange = Color(0xFFD35435);
  static const Color blue = Color(0xFF2563EB);
  static const Color green = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);
  static const Color dark = Color(0xFF0F172A);
  static const Color grey = Color(0xFF64748B);
  static const Color background = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);

  String _value(String key) {
    final value = data[key];
    if (value == null) return '';
    return value.toString().trim();
  }

  String _firstAvailable(List<String> keys) {
    for (final key in keys) {
      final value = _value(key);
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  String get _status => _value('status').toLowerCase();

  String get _displayStatus {
    if (_status.isEmpty) return 'Unknown';

    return _status[0].toUpperCase() + _status.substring(1);
  }

  bool get _pending =>
      _status == 'searching' || _status == 'pending';

  bool get _assigned =>
      _status == 'accepted' || _status == 'active';

  bool get _canCancel => _pending || _assigned;

  String get _ownerName => _value('ownerName');

  String get _ownerPhone => _firstAvailable([
        'ownerPhone',
        'ownerMobile',
        'ownerPhoneNumber',
        'phone',
        'mobile',
      ]);

  String get _ownerId => _value('ownerId');

  String get _walkerName => _value('walkerName');

  String get _walkerPhone => _firstAvailable([
        'walkerPhone',
        'walkerMobile',
        'walkerPhoneNumber',
        'walkerMobileNumber',
        'phone',
        'mobile',
      ]);

  String get _walkerId => _value('walkerId');

  String get _walkerUid => _value('walkerUid');

  String get _dogName => _firstAvailable([
        'dogName',
        'petName',
      ]);

  String get _dogBreed => _firstAvailable([
        'dogBreed',
        'petBreed',
      ]);

  String get _dogAge => _firstAvailable([
        'dogAge',
        'petAge',
      ]);

  String get _address => _value('address');

  String get _searchType => _value('searchType');

  // ============================================================
  // DATE
  // ============================================================

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

    if (date == null) return 'Not available';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} $hour:$minute';
  }

  // ============================================================
  // LOCATION
  // ============================================================

  LatLng? _ownerLocation() {
    const keys = [
      'ownerLocation',
      'pickupLocation',
      'location',
    ];

    for (final key in keys) {
      final value = data[key];

      if (value is GeoPoint) {
        return LatLng(
          value.latitude,
          value.longitude,
        );
      }

      if (value is Map) {
        final map = Map<String, dynamic>.from(value);

        final lat = _toDouble(
          map['latitude'] ?? map['lat'],
        );

        final lng = _toDouble(
          map['longitude'] ??
              map['lng'] ??
              map['lon'],
        );

        if (lat != null && lng != null) {
          return LatLng(lat, lng);
        }
      }
    }

    final lat = _toDouble(data['latitude']);
    final lng = _toDouble(data['longitude']);

    if (lat != null && lng != null) {
      return LatLng(lat, lng);
    }

    return null;
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value.trim());
    }

    return null;
  }

  String _radius() {
    final value = data['searchRadiusKm'];

    if (value == null) return 'Not available';

    if (value is num) {
      return '${value.toStringAsFixed(1)} km';
    }

    final parsed = double.tryParse(value.toString());

    if (parsed != null) {
      return '${parsed.toStringAsFixed(1)} km';
    }

    return value.toString();
  }

  // ============================================================
  // COPY
  // ============================================================

  Future<void> _copy(
    BuildContext context,
    String value,
    String label,
  ) async {
    if (value.trim().isEmpty) return;

    await Clipboard.setData(
      ClipboardData(text: value),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$label copied'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
  }

  // ============================================================
  // CALL
  // ============================================================

  Future<void> _call(
    BuildContext context,
    String phone,
    String label,
  ) async {
    final number = phone.trim();

    if (number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label number is not available'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final uri = Uri(
      scheme: 'tel',
      path: number,
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open phone dialer'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open phone dialer'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 1180 : double.infinity,
                ),
                child: ListView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? 28 : 16,
                    22,
                    isDesktop ? 28 : 16,
                    40,
                  ),
                  children: [
                    _buildHero(context),
                    const SizedBox(height: 18),

                    if (isDesktop)
                      _buildDesktopContent(context)
                    else
                      _buildMobileContent(context),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: dark,
        ),
      ),
      titleSpacing: 0,
      title: const Text(
        'Walk Details',
        style: TextStyle(
          color: dark,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(
          height: 1,
          color: border,
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            orange.withValues(alpha: 0.10),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: orange.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: orange,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'WALK REQUEST',
                  style: TextStyle(
                    color: dark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Request ID: $requestId',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                _StatusBadge(
                  status: _displayStatus,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DESKTOP
  // ============================================================

  Widget _buildDesktopContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Column(
            children: [
              _buildSummary(context),
              const SizedBox(height: 14),
              _buildOwnerCard(context),
              const SizedBox(height: 14),
              _buildDogCard(context),
              const SizedBox(height: 14),
              _buildWalkerCard(context),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _buildPickupCard(context),
              const SizedBox(height: 14),
              _buildMap(context),
              const SizedBox(height: 14),
              _buildInformationCard(context),
              const SizedBox(height: 14),
              _buildActions(context),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _buildMobileContent(BuildContext context) {
    return Column(
      children: [
        _buildSummary(context),
        const SizedBox(height: 14),
        _buildOwnerCard(context),
        const SizedBox(height: 14),
        _buildDogCard(context),
        const SizedBox(height: 14),
        _buildWalkerCard(context),
        const SizedBox(height: 14),
        _buildPickupCard(context),
        const SizedBox(height: 14),
        _buildMap(context),
        const SizedBox(height: 14),
        _buildInformationCard(context),
        const SizedBox(height: 18),
        _buildActions(context),
      ],
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary(BuildContext context) {
    return _InvoiceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.summarize_outlined,
            title: 'Request Summary',
          ),
          const SizedBox(height: 16),

          _SummaryRow(
            icon: Icons.person_outline_rounded,
            label: 'Owner',
            value: _ownerName.isEmpty
                ? 'Not available'
                : _ownerName,
          ),

          const _Line(),

          _SummaryRow(
            icon: Icons.pets_rounded,
            label: 'Dog',
            value: _dogName.isEmpty
                ? 'Not available'
                : _dogName,
          ),

          const _Line(),

          _SummaryRow(
            icon: Icons.directions_walk_rounded,
            label: 'Walker',
            value: _walkerName.isEmpty
                ? 'Not assigned'
                : _walkerName,
          ),

          const _Line(),

          _SummaryRow(
            icon: Icons.schedule_rounded,
            label: 'Created',
            value: _dateText(data['createdAt']),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OWNER
  // ============================================================

  Widget _buildOwnerCard(BuildContext context) {
    return _InvoiceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.person_outline_rounded,
            title: 'Owner Details',
          ),
          const SizedBox(height: 15),

          _ProfileHeader(
            icon: Icons.person_rounded,
            name: _ownerName.isEmpty
                ? 'Owner not available'
                : _ownerName,
            subtitle: 'Walk request owner',
            color: blue,
          ),

          const SizedBox(height: 13),

          if (_ownerPhone.isNotEmpty)
            _PhoneRow(
              label: 'Mobile',
              phone: _ownerPhone,
              color: blue,
              onCall: () => _call(
                context,
                _ownerPhone,
                'Owner',
              ),
            )
          else
            const _DetailRow(
              label: 'Mobile',
              value: 'Not available',
            ),

          if (_ownerId.isNotEmpty)
            _CopyRow(
              context: context,
              label: 'Owner ID',
              value: _ownerId,
              onCopy: () => _copy(
                context,
                _ownerId,
                'Owner ID',
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // DOG
  // ============================================================

  Widget _buildDogCard(BuildContext context) {
    if (_dogName.isEmpty &&
        _dogBreed.isEmpty &&
        _dogAge.isEmpty) {
      return const SizedBox.shrink();
    }

    return _InvoiceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.pets_rounded,
            title: 'Dog Details',
          ),
          const SizedBox(height: 15),

          _ProfileHeader(
            icon: Icons.pets_rounded,
            name: _dogName.isEmpty
                ? 'Dog'
                : _dogName,
            subtitle: _dogBreed.isEmpty
                ? 'Pet information'
                : _dogBreed,
            color: orange,
          ),

          if (_dogBreed.isNotEmpty)
            _DetailRow(
              label: 'Breed',
              value: _dogBreed,
            ),

          if (_dogAge.isNotEmpty)
            _DetailRow(
              label: 'Age',
              value: _dogAge,
            ),
        ],
      ),
    );
  }

  // ============================================================
  // WALKER
  // ============================================================

  Widget _buildWalkerCard(BuildContext context) {
    return _InvoiceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.directions_walk_rounded,
            title: 'Walker Details',
          ),
          const SizedBox(height: 15),

          _ProfileHeader(
            icon: Icons.directions_walk_rounded,
            name: _walkerName.isEmpty
                ? 'Walker not assigned'
                : _walkerName,
            subtitle: _assigned
                ? 'Assigned walker'
                : 'Waiting for assignment',
            color: green,
          ),

          const SizedBox(height: 13),

          if (_walkerPhone.isNotEmpty)
            _PhoneRow(
              label: 'Mobile',
              phone: _walkerPhone,
              color: green,
              onCall: () => _call(
                context,
                _walkerPhone,
                'Walker',
              ),
            )
          else
            const _DetailRow(
              label: 'Mobile',
              value: 'Not available',
            ),

          if (_walkerId.isNotEmpty)
            _CopyRow(
              context: context,
              label: 'Walker ID',
              value: _walkerId,
              onCopy: () => _copy(
                context,
                _walkerId,
                'Walker ID',
              ),
            ),

          if (_walkerUid.isNotEmpty)
            _CopyRow(
              context: context,
              label: 'Walker UID',
              value: _walkerUid,
              onCopy: () => _copy(
                context,
                _walkerUid,
                'Walker UID',
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // PICKUP
  // ============================================================

  Widget _buildPickupCard(BuildContext context) {
    return _InvoiceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.location_on_outlined,
            title: 'Pickup Location',
          ),
          const SizedBox(height: 15),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: orange.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: orange.withValues(alpha: 0.14),
              ),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: orange.withValues(alpha: 0.11),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: orange,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _address.isEmpty
                        ? 'Address not available'
                        : _address,
                    style: const TextStyle(
                      color: dark,
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_value('ownerLocationType').isNotEmpty)
            _DetailRow(
              label: 'Location Type',
              value: _value('ownerLocationType'),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // MAP
  // ============================================================

  Widget _buildMap(BuildContext context) {
    final location = _ownerLocation();

    if (location == null) {
      return const SizedBox.shrink();
    }

    return WalkRequestMapPreview(
      ownerLocation: location,
      walkerId: _assigned && _walkerId.isNotEmpty
          ? _walkerId
          : null,
      walkerUid: _assigned && _walkerUid.isNotEmpty
          ? _walkerUid
          : null,
      walkerName: _walkerName,
      onOpenMaps: () => onOpenMaps(location),
    );
  }

  // ============================================================
  // WALK INFORMATION
  // ============================================================

  Widget _buildInformationCard(BuildContext context) {
    return _InvoiceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.receipt_long_outlined,
            title: 'Walk Information',
          ),
          const SizedBox(height: 10),

          _InvoiceRow(
            label: 'Walk ID',
            value: requestId,
            copy: true,
            onCopy: () => _copy(
              context,
              requestId,
              'Walk ID',
            ),
          ),

          _InvoiceRow(
            label: 'Status',
            value: _displayStatus,
          ),

          _InvoiceRow(
            label: 'Walk Type',
            value: _searchType.isEmpty
                ? 'Not available'
                : _searchType,
          ),

          _InvoiceRow(
            label: 'Search Radius',
            value: _radius(),
          ),

          _InvoiceRow(
            label: 'Created',
            value: _dateText(data['createdAt']),
          ),

          if (_status == 'accepted' ||
              _status == 'active' ||
              _status == 'completed')
            _InvoiceRow(
              label: 'Accepted',
              value: _dateText(data['acceptedAt']),
            ),

          if (_status == 'cancelled' ||
              _status == 'canceled')
            _InvoiceRow(
              label: 'Cancellation',
              value: _value('cancellationReason').isEmpty
                  ? 'Not specified'
                  : _value('cancellationReason'),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        if (_pending)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: onAssign,
              style: FilledButton.styleFrom(
                backgroundColor: orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(
                Icons.person_add_alt_1_rounded,
              ),
              label: const Text(
                'Assign Walker',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

        if (_assigned)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: onAssign,
              style: FilledButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(
                Icons.swap_horiz_rounded,
              ),
              label: const Text(
                'Change Walker',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

        if (_canCancel) ...[
          const SizedBox(height: 9),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: danger,
                side: BorderSide(
                  color: danger.withValues(alpha: 0.40),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(
                Icons.cancel_outlined,
              ),
              label: const Text(
                'Cancel Request',
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
}

// ============================================================
// INVOICE CARD
// ============================================================

class _InvoiceCard extends StatelessWidget {
  final Widget child;

  const _InvoiceCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: blue.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: blue,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: dark,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PROFILE HEADER
// ============================================================

class _ProfileHeader extends StatelessWidget {
  final IconData icon;
  final String name;
  final String subtitle;
  final Color color;

  const _ProfileHeader({
    required this.icon,
    required this.name,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),
        const SizedBox(width: 11),
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
                  color: dark,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
    );
  }
}

// ============================================================
// PHONE ROW
// ============================================================

class _PhoneRow extends StatelessWidget {
  final String label;
  final String phone;
  final Color color;
  final VoidCallback onCall;

  const _PhoneRow({
    required this.label,
    required this.phone,
    required this.color,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 88,
            child: Text(
              'Mobile',
              style: TextStyle(
                color: grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              phone,
              style: const TextStyle(
                color: dark,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Call',
            onPressed: onCall,
            style: IconButton.styleFrom(
              backgroundColor:
                  color.withValues(alpha: 0.10),
              foregroundColor: color,
            ),
            icon: const Icon(
              Icons.phone_rounded,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DETAIL ROW
// ============================================================

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value.isEmpty
                  ? 'Not available'
                  : value,
              style: const TextStyle(
                color: dark,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// COPY ROW
// ============================================================

class _CopyRow extends StatelessWidget {
  final BuildContext context;
  final String label;
  final String value;
  final VoidCallback onCopy;

  const _CopyRow({
    required this.context,
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                color: dark,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(7),
            onTap: onCopy,
            child: const Padding(
              padding: EdgeInsets.all(5),
              child: Icon(
                Icons.copy_outlined,
                size: 16,
                color: blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SUMMARY ROW
// ============================================================

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: blue,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(
              color: grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: dark,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// INVOICE ROW
// ============================================================

class _InvoiceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool copy;
  final VoidCallback? onCopy;

  const _InvoiceRow({
    required this.label,
    required this.value,
    this.copy = false,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 11,
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
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 6,
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SelectableText(
                    value,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: dark,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (copy && onCopy != null)
                  IconButton(
                    tooltip: 'Copy',
                    onPressed: onCopy,
                    visualDensity:
                        VisualDensity.compact,
                    icon: const Icon(
                      Icons.copy_outlined,
                      size: 15,
                      color: blue,
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

// ============================================================
// LINE
// ============================================================

class _Line extends StatelessWidget {
  const _Line();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 22,
      color: border,
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
  Widget build(BuildContext context) {
    final lower = status.toLowerCase();

    Color color = blue;
    IconData icon = Icons.info_outline_rounded;

    if (lower == 'searching' ||
        lower == 'pending') {
      color = orange;
      icon = Icons.search_rounded;
    } else if (lower == 'accepted') {
      color = green;
      icon = Icons.check_circle_outline_rounded;
    } else if (lower == 'active') {
      color = blue;
      icon = Icons.directions_walk_rounded;
    } else if (lower == 'completed') {
      color = green;
      icon = Icons.verified_rounded;
    } else if (lower == 'cancelled' ||
        lower == 'canceled') {
      color = danger;
      icon = Icons.cancel_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            status.isEmpty ? 'Unknown' : status,
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
}
