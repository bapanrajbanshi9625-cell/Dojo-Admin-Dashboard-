// File:
// lib/features/walker_availability/widgets/insta_walk_availability.dart

import 'package:flutter/material.dart';

import '../models/walker_availability_model.dart';
import '../services/walker_availability_service.dart';
import 'walker_availability_card.dart';

class InstaWalkAvailability extends StatelessWidget {
  const InstaWalkAvailability({
    super.key,
    required this.service,
    this.searchQuery = '',
  });

  final WalkerAvailabilityService service;
  final String searchQuery;

  static const Color primaryOrange = Color(0xFFD35435);
  static const Color secondaryBlue = Color(0xFF3F6FA5);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WalkerAvailabilityModel>>(
      stream: service.watchInstaWalkAvailability(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: primaryOrange,
            ),
          );
        }

        if (snapshot.hasError) {
          return _ErrorState(
            message: snapshot.error.toString(),
          );
        }

        final walkers = _filterWalkers(
          snapshot.data ?? const [],
        );

        if (walkers.isEmpty) {
          return const _EmptyState();
        }

        return _ResponsiveWalkerList(
          walkers: walkers,
        );
      },
    );
  }

  List<WalkerAvailabilityModel> _filterWalkers(
    List<WalkerAvailabilityModel> walkers,
  ) {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return walkers;
    }

    return walkers.where((walker) {
      final walkerId = walker.walkerId.toLowerCase();
      final walkerName = walker.walkerName.toLowerCase();

      return walkerId.contains(query) ||
          walkerName.contains(query);
    }).toList();
  }
}

class _ResponsiveWalkerList extends StatelessWidget {
  const _ResponsiveWalkerList({
    required this.walkers,
  });

  final List<WalkerAvailabilityModel> walkers;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        if (isDesktop) {
          return _DesktopTable(
            walkers: walkers,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: walkers.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return WalkerAvailabilityCard(
              walker: walkers[index],
              isDaily: false,
            );
          },
        );
      },
    );
  }
}

class _DesktopTable extends StatelessWidget {
  const _DesktopTable({
    required this.walkers,
  });

  final List<WalkerAvailabilityModel> walkers;

  static const Color secondaryBlue = Color(0xFF3F6FA5);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            ...walkers.map(
              (walker) => _DesktopRow(
                walker: walker,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 2,
            child: _HeaderText('Walker ID'),
          ),
          Expanded(
            flex: 3,
            child: _HeaderText('Walker Name'),
          ),
          Expanded(
            flex: 3,
            child: _HeaderText('Status'),
          ),
          SizedBox(
            width: 110,
            child: _HeaderText('Action'),
          ),
        ],
      ),
    );
  }
}

class _DesktopRow extends StatefulWidget {
  const _DesktopRow({
    required this.walker,
  });

  final WalkerAvailabilityModel walker;

  @override
  State<_DesktopRow> createState() => _DesktopRowState();
}

class _DesktopRowState extends State<_DesktopRow> {
  bool _expanded = false;

  static const Color secondaryBlue = Color(0xFF3F6FA5);

  @override
  Widget build(BuildContext context) {
    final walker = widget.walker;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 13,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  walker.walkerId,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF171717),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  walker.walkerName.isEmpty
                      ? 'Unknown Walker'
                      : walker.walkerName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF171717),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: _StatusBadge(
                  available:
                      walker.isInstaWalkAvailable,
                  status:
                      walker.status ?? 'Searching',
                ),
              ),
              SizedBox(
                width: 110,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: secondaryBlue,
                  ),
                  child: Text(
                    _expanded
                        ? 'Hide Details'
                        : 'View Details',
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_expanded)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              18,
              12,
              18,
              14,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              border: Border(
                top: BorderSide(
                  color: Color(0xFFE5E7EB),
                ),
              ),
            ),
            child: Wrap(
              spacing: 30,
              runSpacing: 12,
              children: [
                _Detail(
                  label: 'Walker ID',
                  value: walker.walkerId,
                ),
                _Detail(
                  label: 'Walker Name',
                  value: walker.walkerName,
                ),
                _Detail(
                  label: 'Status',
                  value: walker.status ?? 'Searching',
                ),
                if (walker.latitude != null &&
                    walker.longitude != null)
                  _Detail(
                    label: 'Location',
                    value:
                        '${walker.latitude!.toStringAsFixed(5)}, '
                        '${walker.longitude!.toStringAsFixed(5)}',
                  ),
                if (walker.lastLocationUpdate != null)
                  _Detail(
                    label: 'Last Update',
                    value: _formatDateTime(
                      walker.lastLocationUpdate!,
                    ),
                  ),
              ],
            ),
          ),
        const Divider(
          height: 1,
          color: Color(0xFFE5E7EB),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.available,
    required this.status,
  });

  final bool available;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: available
              ? const Color(0xFFECFDF3)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: available
                    ? const Color(0xFF16A34A)
                    : const Color(0xFF9CA3AF),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              available ? 'Available' : status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: available
                    ? const Color(0xFF15803D)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF6B7280),
        letterSpacing: .2,
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 180,
        maxWidth: 280,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  static const Color primaryOrange = Color(0xFFD35435);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1E8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flash_off_rounded,
                size: 30,
                color: primaryOrange,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'No Insta Walkers Available',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF171717),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Currently no walker is searching for an Insta Walk.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
  });

  final String message;

  static const Color primaryOrange = Color(0xFFD35435);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 42,
              color: primaryOrange,
            ),
            const SizedBox(height: 10),
            const Text(
              'Unable to load Insta Walk availability',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF171717),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime dateTime) {
  final local = dateTime.toLocal();

  final hour = local.hour == 0
      ? 12
      : local.hour > 12
          ? local.hour - 12
          : local.hour;

  final minute =
      local.minute.toString().padLeft(2, '0');

  final period =
      local.hour >= 12 ? 'PM' : 'AM';

  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/'
      '${local.year} $hour:$minute $period';
}
