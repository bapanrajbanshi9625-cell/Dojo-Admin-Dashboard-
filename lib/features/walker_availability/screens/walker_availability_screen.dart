import 'package:flutter/material.dart';

import '../../../core/theme/dojo_colors.dart';
import '../models/walker_availability_model.dart';
import '../services/walker_availability_service.dart';

class WalkerAvailabilityScreen extends StatefulWidget {
  const WalkerAvailabilityScreen({
    super.key,
  });

  @override
  State<WalkerAvailabilityScreen> createState() =>
      _WalkerAvailabilityScreenState();
}

class _WalkerAvailabilityScreenState
    extends State<WalkerAvailabilityScreen> {
  final WalkerAvailabilityService _service =
      WalkerAvailabilityService();

  int _selectedTab = 0;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F8FA),
      child: Column(
        children: [
          _buildHeader(),
          _buildTabs(),
          Expanded(
            child: _selectedTab == 0
                ? _buildInstaWalk()
                : _buildDailyWalk(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        14,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 650;

          if (compact) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Walker Availability',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF171717),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedTab == 0
                      ? 'Insta Walk availability'
                      : 'Daily Walk booked slots',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 14),
                _buildSearchField(),
              ],
            );
          }

          return Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Walker Availability',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF171717),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Monitor Insta Walk and Daily Walk availability',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 300,
                child: _buildSearchField(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value.trim().toLowerCase();
        });
      },
      decoration: InputDecoration(
        hintText: 'Search walker ID or name',
        prefixIcon: const Icon(
          Icons.search_rounded,
          size: 20,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(
                  Icons.close_rounded,
                  size: 19,
                ),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        children: [
          _buildTab(
            title: 'Insta Walk',
            icon: Icons.flash_on_rounded,
            index: 0,
          ),
          const SizedBox(width: 8),
          _buildTab(
            title: 'Daily Walk',
            icon: Icons.schedule_rounded,
            index: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required IconData icon,
    required int index,
  }) {
    final selected = _selectedTab == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = index;
          _searchQuery = '';
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFFF1E8)
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(8),
          border: Border(
            bottom: BorderSide(
              color: selected
                  ? AppColors.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? AppColors.primary
                  : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 7),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: selected
                    ? AppColors.primary
                    : const Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstaWalk() {
    return StreamBuilder<
        List<WalkerAvailabilityModel>>(
      stream:
          _service.watchInstaWalkAvailability(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
                ConnectionState.waiting &&
            !snapshot.hasData) {
          return _buildLoading();
        }

        if (snapshot.hasError) {
          return _buildError(
            snapshot.error.toString(),
          );
        }

        final walkers =
            _filterWalkers(snapshot.data ?? []);

        if (walkers.isEmpty) {
          return _buildEmpty(
            icon: Icons.flash_off_rounded,
            title: 'No Insta Walkers Available',
            message:
                'Currently no walker is searching for an Insta Walk.',
          );
        }

        return _buildResponsiveList(
          walkers,
          isDaily: false,
        );
      },
    );
  }

  Widget _buildDailyWalk() {
    return StreamBuilder<
        List<WalkerAvailabilityModel>>(
      stream:
          _service.watchDailyWalkAvailability(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
                ConnectionState.waiting &&
            !snapshot.hasData) {
          return _buildLoading();
        }

        if (snapshot.hasError) {
          return _buildError(
            snapshot.error.toString(),
          );
        }

        final walkers =
            _filterWalkers(snapshot.data ?? []);

        if (walkers.isEmpty) {
          return _buildEmpty(
            icon: Icons.schedule_rounded,
            title: 'No Daily Walk Availability',
            message:
                'No walker has booked a Daily Walk slot yet.',
          );
        }

        return _buildResponsiveList(
          walkers,
          isDaily: true,
        );
      },
    );
  }

  List<WalkerAvailabilityModel> _filterWalkers(
    List<WalkerAvailabilityModel> walkers,
  ) {
    if (_searchQuery.isEmpty) {
      return walkers;
    }

    return walkers.where((walker) {
      return walker.walkerId
              .toLowerCase()
              .contains(_searchQuery) ||
          walker.walkerName
              .toLowerCase()
              .contains(_searchQuery);
    }).toList();
  }

  Widget _buildResponsiveList(
    List<WalkerAvailabilityModel> walkers, {
    required bool isDaily,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop =
            constraints.maxWidth >= 900;

        if (desktop) {
          return _buildDesktopTable(
            walkers,
            isDaily: isDaily,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: walkers.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return _WalkerAvailabilityCard(
              walker: walkers[index],
              isDaily: isDaily,
            );
          },
        );
      },
    );
  }

  Widget _buildDesktopTable(
    List<WalkerAvailabilityModel> walkers, {
    required bool isDaily,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
          ),
        ),
        child: Column(
          children: [
            Container(
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
              child: Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: _TableHeader(
                      'Walker ID',
                    ),
                  ),
                  const Expanded(
                    flex: 3,
                    child: _TableHeader(
                      'Walker Name',
                    ),
                  ),
                  Expanded(
                    flex: isDaily ? 5 : 3,
                    child: _TableHeader(
                      isDaily
                          ? 'Booked Time Slots'
                          : 'Status',
                    ),
                  ),
                  const SizedBox(
                    width: 110,
                    child: _TableHeader(
                      'Action',
                    ),
                  ),
                ],
              ),
            ),
            ...walkers.map(
              (walker) => _DesktopWalkerRow(
                walker: walker,
                isDaily: isDaily,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 42,
              color: Color(0xFFD35435),
            ),
            const SizedBox(height: 10),
            const Text(
              'Unable to load availability',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
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

  Widget _buildEmpty({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1E8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF171717),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
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

class _WalkerAvailabilityCard
    extends StatefulWidget {
  const _WalkerAvailabilityCard({
    required this.walker,
    required this.isDaily,
  });

  final WalkerAvailabilityModel walker;
  final bool isDaily;

  @override
  State<_WalkerAvailabilityCard> createState() =>
      _WalkerAvailabilityCardState();
}

class _WalkerAvailabilityCardState
    extends State<_WalkerAvailabilityCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final walker = widget.walker;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                _WalkerAvatar(
                  walkerName: walker.walkerName,
                  photoUrl: walker.photoUrl,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        walker.walkerName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.w700,
                          color: Color(0xFF171717),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        walker.walkerId,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusDot(
                  isOnline:
                      !widget.isDaily &&
                      walker.isInstaWalkAvailable,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.isDaily)
              _InfoRow(
                icon: Icons.schedule_rounded,
                title: 'Booked Slots',
                value: _formatSlots(
                  walker.dailyWalkSlots,
                ),
              )
            else
              _InfoRow(
                icon: Icons.flash_on_rounded,
                title: 'Status',
                value: walker.status ??
                    'Searching',
              ),
            const SizedBox(height: 11),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                icon: Icon(
                  _expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  size: 18,
                ),
                label: Text(
                  _expanded
                      ? 'Hide Details'
                      : 'View Details',
                ),
              ),
            ),
            if (_expanded)
              _buildDetails(walker),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails(
    WalkerAvailabilityModel walker,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        top: 4,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius:
            BorderRadius.circular(9),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _DetailLine(
            label: 'Walker ID',
            value: walker.walkerId,
          ),
          _DetailLine(
            label: 'Walker Name',
            value: walker.walkerName,
          ),
          _DetailLine(
            label: 'Insta Walk',
            value: walker
                    .isInstaWalkAvailable
                ? 'Available'
                : 'Not Available',
          ),
          if (walker.latitude != null &&
              walker.longitude != null)
            _DetailLine(
              label: 'Location',
              value:
                  '${walker.latitude!.toStringAsFixed(5)}, '
                  '${walker.longitude!.toStringAsFixed(5)}',
            ),
          if (walker.lastLocationUpdate !=
              null)
            _DetailLine(
              label: 'Last Update',
              value:
                  _formatDateTime(
                walker.lastLocationUpdate!,
              ),
            ),
        ],
      ),
    );
  }
}

class _DesktopWalkerRow
    extends StatefulWidget {
  const _DesktopWalkerRow({
    required this.walker,
    required this.isDaily,
  });

  final WalkerAvailabilityModel walker;
  final bool isDaily;

  @override
  State<_DesktopWalkerRow> createState() =>
      _DesktopWalkerRowState();
}

class _DesktopWalkerRowState
    extends State<_DesktopWalkerRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final walker = widget.walker;

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    walker.walkerId,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    walker.walkerName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: widget.isDaily ? 5 : 3,
                  child: widget.isDaily
                      ? Text(
                          _formatSlots(
                            walker
                                .dailyWalkSlots,
                          ),
                          style:
                              const TextStyle(
                            fontSize: 13,
                            color: Color(
                              0xFF4B5563,
                            ),
                          ),
                        )
                      : _StatusBadge(
                          available: walker
                              .isInstaWalkAvailable,
                          status:
                              walker.status ??
                                  'Searching',
                        ),
                ),
                SizedBox(
                  width: 110,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _expanded =
                            !_expanded;
                      });
                    },
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
        ),
        if (_expanded)
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.fromLTRB(
              18,
              12,
              18,
              14,
            ),
            decoration:
                const BoxDecoration(
              color: Color(0xFFF9FAFB),
              border: Border(
                top: BorderSide(
                  color: Color(0xFFE5E7EB),
                ),
              ),
            ),
            child: Wrap(
              spacing: 30,
              runSpacing: 10,
              children: [
                _DesktopDetail(
                  label: 'Walker ID',
                  value: walker.walkerId,
                ),
                _DesktopDetail(
                  label: 'Walker Name',
                  value: walker.walkerName,
                ),
                _DesktopDetail(
                  label: 'Insta Walk',
                  value: walker
                          .isInstaWalkAvailable
                      ? 'Available'
                      : 'Not Available',
                ),
                if (walker.latitude !=
                        null &&
                    walker.longitude != null)
                  _DesktopDetail(
                    label: 'Location',
                    value:
                        '${walker.latitude!.toStringAsFixed(5)}, '
                        '${walker.longitude!.toStringAsFixed(5)}',
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

class _WalkerAvatar extends StatelessWidget {
  const _WalkerAvatar({
    required this.walkerName,
    required this.photoUrl,
  });

  final String walkerName;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final initial = walkerName.isNotEmpty
        ? walkerName[0].toUpperCase()
        : 'W';

    if (photoUrl != null &&
        photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 21,
        backgroundImage:
            NetworkImage(photoUrl!),
      );
    }

    return CircleAvatar(
      radius: 21,
      backgroundColor:
          const Color(0xFFFFF1E8),
      child: Text(
        initial,
        style: const TextStyle(
          color: Color(0xFFD35435),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({
    required this.isOnline,
  });

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: isOnline
            ? const Color(0xFF16A34A)
            : const Color(0xFF9CA3AF),
        shape: BoxShape.circle,
      );
    }
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
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: available
            ? const Color(0xFFECFDF3)
            : const Color(0xFFF3F4F6),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        available ? 'Available' : status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: available
              ? const Color(0xFF15803D)
              : const Color(0xFF6B7280),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFFD35435),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF374151),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopDetail extends StatelessWidget {
  const _DesktopDetail({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:
          const BoxConstraints(
        minWidth: 180,
        maxWidth: 280,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader(this.text);

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

String _formatSlots(List<String> slots) {
  if (slots.isEmpty) {
    return 'No booked slots';
  }

  return slots
      .map(_formatSingleSlot)
      .where((slot) => slot.isNotEmpty)
      .join(', ');
}

String _formatSingleSlot(String slot) {
  final value = slot.trim();

  if (value.isEmpty) {
    return '';
  }

  if (value.contains('–')) {
    return value;
  }

  if (value.contains(' - ')) {
    return value.replaceAll(
      ' - ',
      '–',
    );
  }

  return value;
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
