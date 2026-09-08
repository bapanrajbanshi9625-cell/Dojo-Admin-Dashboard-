// File:
// lib/features/walk_requests/widgets/walk_request_card.dart

import 'package:flutter/material.dart';

import 'walk_request_status_badge.dart';

class WalkRequestCard extends StatefulWidget {
  final String requestId;
  final Map<String, dynamic> data;

  final VoidCallback onTap;
  final VoidCallback onAssign;
  final VoidCallback onCancel;

  const WalkRequestCard({
    super.key,
    required this.requestId,
    required this.data,
    required this.onTap,
    required this.onAssign,
    required this.onCancel,
  });

  @override
  State<WalkRequestCard> createState() =>
      _WalkRequestCardState();
}

class _WalkRequestCardState extends State<WalkRequestCard> {
  bool _hovering = false;

  String _value(String key) {
    final value = widget.data[key];

    if (value == null) return '';

    final text = value.toString().trim();

    if (text.isEmpty || text == 'null') {
      return '';
    }

    return text;
  }

  String _firstAvailable(List<String> keys) {
    for (final key in keys) {
      final value = _value(key);

      if (value.isNotEmpty) {
        return value;
      }
    }

    return '';
  }

  String _status() {
    final value = _value('status').toLowerCase();

    return value.isEmpty ? 'pending' : value;
  }

  Color _statusColor() {
    switch (_status()) {
      case 'accepted':
      case 'assigned':
        return _WalkRequestCardColors.blue;

      case 'active':
      case 'started':
      case 'in_progress':
        return _WalkRequestCardColors.orange;

      case 'completed':
        return _WalkRequestCardColors.green;

      case 'cancelled':
      case 'canceled':
      case 'rejected':
        return _WalkRequestCardColors.danger;

      default:
        return _WalkRequestCardColors.warning;
    }
  }

  bool get isPending {
    final status = _status();

    return status == 'searching' ||
        status == 'pending' ||
        status == 'requested';
  }

  bool get isAccepted {
    final status = _status();

    return status == 'accepted' ||
        status == 'assigned';
  }

  bool get isActive {
    final status = _status();

    return status == 'active' ||
        status == 'started' ||
        status == 'in_progress';
  }

  bool get hasWalker {
    return _firstAvailable([
      'walkerName',
      'walkerId',
      'walkerUid',
      'walkerAuthUid',
    ]).isNotEmpty;
  }

  String get ownerName {
    final value = _firstAvailable([
      'ownerName',
      'ownerDisplayName',
    ]);

    return value.isEmpty ? 'Unknown Owner' : value;
  }

  String get ownerPhone {
    return _firstAvailable([
      'ownerPhone',
      'ownerMobile',
      'ownerPhoneNumber',
      'phone',
      'mobile',
    ]);
  }

  String get dogName {
    final value = _firstAvailable([
      'dogName',
      'petName',
    ]);

    return value.isEmpty ? 'Dog' : value;
  }

  String get dogBreed {
    return _firstAvailable([
      'dogBreed',
      'petBreed',
      'breed',
    ]);
  }

  String get dogPhoto {
    return _firstAvailable([
      'dogPhoto',
      'petPhoto',
      'dogImage',
      'petImage',
    ]);
  }

  String get address {
    final value = _firstAvailable([
      'address',
      'pickupAddress',
      'location',
    ]);

    return value.isEmpty
        ? 'Pickup address unavailable'
        : value;
  }

  String get walkerName {
    return _firstAvailable([
      'walkerName',
      'walkerDisplayName',
    ]);
  }

  String get walkerPhone {
    return _firstAvailable([
      'walkerPhone',
      'walkerMobile',
      'walkerPhoneNumber',
      'walkerMobileNumber',
    ]);
  }

  String get searchType {
    final value = _firstAvailable([
      'searchType',
      'walkType',
    ]);

    return value.isEmpty ? 'Walk Request' : value;
  }

  String get radius {
    final value = _firstAvailable([
      'searchRadiusKm',
      'radiusKm',
    ]);

    return value.isEmpty ? '—' : '$value km';
  }

  String get dogInitial {
    if (dogName.trim().isEmpty) {
      return 'D';
    }

    return dogName
        .trim()
        .substring(0, 1)
        .toUpperCase();
  }

  String get ownerInitial {
    if (ownerName.trim().isEmpty) {
      return 'O';
    }

    return ownerName
        .trim()
        .substring(0, 1)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        if (!mounted) return;

        setState(() {
          _hovering = true;
        });
      },
      onExit: (_) {
        if (!mounted) return;

        setState(() {
          _hovering = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 14),
        transform: Matrix4.translationValues(
          0,
          _hovering ? -2 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: _WalkRequestCardColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hovering
                ? statusColor.withValues(alpha: .35)
                : _WalkRequestCardColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: _hovering ? .08 : .035,
              ),
              blurRadius: _hovering ? 22 : 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 4,
                child: Container(
                  color: statusColor,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  splashColor: statusColor.withValues(
                    alpha: .05,
                  ),
                  highlightColor: statusColor.withValues(
                    alpha: .025,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      18,
                      18,
                      17,
                    ),
                    child: LayoutBuilder(
                      builder: (
                        context,
                        constraints,
                      ) {
                        final compact =
                            constraints.maxWidth < 620;

                        return Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(
                              context,
                              statusColor,
                              compact,
                            ),

                            const SizedBox(height: 16),

                            _buildLocation(),

                            const SizedBox(height: 14),

                            _buildInformation(),

                            if (hasWalker &&
                                (isAccepted || isActive)) ...[
                              const SizedBox(height: 14),
                              _buildWalkerSection(),
                            ],

                            const SizedBox(height: 16),

                            _buildActions(compact),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Color statusColor,
    bool compact,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE8795B),
                Color(0xFFD35435),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _WalkRequestCardColors.orange
                    .withValues(alpha: .18),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Text(
              ownerInitial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      ownerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color:
                            _WalkRequestCardColors.dark,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.15,
                      ),
                    ),
                  ),

                  if (!compact) ...[
                    const SizedBox(width: 7),
                    _OwnerBadge(),
                  ],
                ],
              ),

              if (compact) ...[
                const SizedBox(height: 5),
                _OwnerBadge(),
              ],

              const SizedBox(height: 5),

              Row(
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 14,
                    color:
                        _WalkRequestCardColors.grey,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      widget.requestId.isEmpty
                          ? 'Request ID unavailable'
                          : widget.requestId,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color:
                            _WalkRequestCardColors.grey,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        Column(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            RequestStatusBadge(
              status: _status(),
            ),

            const SizedBox(height: 6),

            AnimatedContainer(
              duration:
                  const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: _hovering
                    ? statusColor.withValues(
                        alpha: .08,
                      )
                    : Colors.transparent,
                borderRadius:
                    BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: _hovering
                    ? statusColor
                    : _WalkRequestCardColors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _WalkRequestCardColors.background,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: _WalkRequestCardColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: _WalkRequestCardColors.orange
                  .withValues(alpha: .10),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              size: 18,
              color: _WalkRequestCardColors.orange,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'PICKUP LOCATION',
                  style: TextStyle(
                    color:
                        _WalkRequestCardColors.grey,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color:
                        _WalkRequestCardColors.dark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformation() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _InfoChip(
          icon: Icons.pets_rounded,
          label: dogName,
          emphasized: true,
        ),

        if (dogBreed.isNotEmpty)
          _InfoChip(
            icon: Icons.category_outlined,
            label: dogBreed,
          ),

        _InfoChip(
          icon: Icons.route_rounded,
          label: searchType,
        ),

        _InfoChip(
          icon: Icons.radar_rounded,
          label: radius,
        ),
      ],
    );
  }

  Widget _buildWalkerSection() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _WalkRequestCardColors.blue
            .withValues(alpha: .035),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: _WalkRequestCardColors.blue
              .withValues(alpha: .12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _WalkRequestCardColors.blue
                  .withValues(alpha: .10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_walk_rounded,
              size: 20,
              color: _WalkRequestCardColors.blue,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'ASSIGNED WALKER',
                  style: TextStyle(
                    color:
                        _WalkRequestCardColors.grey,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .6,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  walkerName.isEmpty
                      ? 'Walker assigned'
                      : walkerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color:
                        _WalkRequestCardColors.dark,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                if (walkerPhone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    walkerPhone,
                    style: const TextStyle(
                      color:
                          _WalkRequestCardColors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          _SmallActionButton(
            icon: Icons.swap_horiz_rounded,
            label: 'Change',
            onPressed: widget.onAssign,
          ),
        ],
      ),
    );
  }

  Widget _buildActions(bool compact) {
    if (compact) {
      return Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          _PrimaryActionButton(
            icon: Icons.visibility_rounded,
            label: 'View Details',
            onPressed: widget.onTap,
          ),

          if (isPending) ...[
            const SizedBox(height: 8),
            _SecondaryActionButton(
              icon: Icons.person_add_alt_1_rounded,
              label: 'Assign Walker',
              onPressed: widget.onAssign,
            ),
          ],

          if (isAccepted) ...[
            const SizedBox(height: 8),
            _SecondaryActionButton(
              icon: Icons.swap_horiz_rounded,
              label: 'Change Walker',
              onPressed: widget.onAssign,
            ),
          ],

          if (isPending ||
              isAccepted ||
              isActive) ...[
            const SizedBox(height: 5),
            _CancelButton(
              onPressed: widget.onCancel,
            ),
          ],
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _PrimaryActionButton(
            icon: Icons.visibility_rounded,
            label: 'View Details',
            onPressed: widget.onTap,
          ),
        ),

        if (isPending) ...[
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _SecondaryActionButton(
              icon: Icons.person_add_alt_1_rounded,
              label: 'Assign Walker',
              onPressed: widget.onAssign,
            ),
          ),
        ],

        if (isAccepted) ...[
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _SecondaryActionButton(
              icon: Icons.swap_horiz_rounded,
              label: 'Change Walker',
              onPressed: widget.onAssign,
            ),
          ),
        ],

        const SizedBox(width: 8),

        _CancelButton(
          onPressed: widget.onCancel,
          compact: true,
        ),
      ],
    );
  }
}

// ============================================================
// OWNER BADGE
// ============================================================

class _OwnerBadge extends StatelessWidget {
  const _OwnerBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: _WalkRequestCardColors.green
            .withValues(alpha: .09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            size: 12,
            color: _WalkRequestCardColors.green,
          ),
          SizedBox(width: 3),
          Text(
            'Owner',
            style: TextStyle(
              color: _WalkRequestCardColors.green,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INFO CHIP
// ============================================================

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 220,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: emphasized
            ? _WalkRequestCardColors.orange
                .withValues(alpha: .08)
            : _WalkRequestCardColors.background,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: emphasized
              ? _WalkRequestCardColors.orange
                  .withValues(alpha: .14)
              : _WalkRequestCardColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: emphasized
                ? _WalkRequestCardColors.orange
                : _WalkRequestCardColors.grey,
          ),

          const SizedBox(width: 6),

          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: emphasized
                    ? _WalkRequestCardColors.orange
                    : _WalkRequestCardColors.dark,
                fontSize: 11.5,
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
// PRIMARY ACTION
// ============================================================

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 17,
        ),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _WalkRequestCardColors.orange,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(11),
          ),
          textStyle: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SECONDARY ACTION
// ============================================================

class _SecondaryActionButton
    extends StatelessWidget {
  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 17,
        ),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor:
              _WalkRequestCardColors.blue,
          backgroundColor:
              _WalkRequestCardColors.white,
          side: const BorderSide(
            color: _WalkRequestCardColors.border,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(11),
          ),
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SMALL ACTION
// ============================================================

class _SmallActionButton
    extends StatelessWidget {
  const _SmallActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 15,
      ),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor:
            _WalkRequestCardColors.blue,
        backgroundColor:
            _WalkRequestCardColors.white,
        side: BorderSide(
          color: _WalkRequestCardColors.blue
              .withValues(alpha: .18),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        minimumSize: Size.zero,
        tapTargetSize:
            MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(9),
        ),
        textStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ============================================================
// CANCEL BUTTON
// ============================================================

class _CancelButton extends StatelessWidget {
  const _CancelButton({
    required this.onPressed,
    this.compact = false,
  });

  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return SizedBox(
        height: 44,
        child: TextButton.icon(
          onPressed: onPressed,
          icon: const Icon(
            Icons.cancel_outlined,
            size: 16,
          ),
          label: const Text('Cancel'),
          style: TextButton.styleFrom(
            foregroundColor:
                _WalkRequestCardColors.danger,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 40,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(
          Icons.cancel_outlined,
          size: 17,
        ),
        label: const Text('Cancel Request'),
        style: TextButton.styleFrom(
          foregroundColor:
              _WalkRequestCardColors.danger,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// COLORS
// ============================================================

class _WalkRequestCardColors {
  static const Color orange =
      Color(0xFFD35435);

  static const Color blue =
      Color(0xFF2563EB);

  static const Color green =
      Color(0xFF16A34A);

  static const Color danger =
      Color(0xFFDC2626);

  static const Color warning =
      Color(0xFFF59E0B);

  static const Color dark =
      Color(0xFF0F172A);

  static const Color grey =
      Color(0xFF64748B);

  static const Color background =
      Color(0xFFF8FAFC);

  static const Color white =
      Color(0xFFFFFFFF);

  static const Color border =
      Color(0xFFE2E8F0);
}
