import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoRed = Color(0xFFC62828);
const Color dojoDark = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);
const Color dojoBackground = Color(0xFFF7F8FA);

class WalkersScreen extends StatefulWidget {
  const WalkersScreen({super.key});

  @override
  State<WalkersScreen> createState() => _WalkersScreenState();
}

class _WalkersScreenState extends State<WalkersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController searchController = TextEditingController();

  String selectedFilter = 'All';
  bool _busy = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get _walkerStream {
    return _firestore.collection('walkerProfiles').snapshots();
  }

  List<WalkerData> _convert(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final list = snapshot.docs
        .map((doc) => WalkerData.fromFirestore(doc))
        .toList();

    list.sort((a, b) {
      final ad = a.createdAt;
      final bd = b.createdAt;

      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;

      return bd.compareTo(ad);
    });

    return list;
  }

  List<WalkerData> _filtered(List<WalkerData> walkers) {
    final query = searchController.text.trim().toLowerCase();

    return walkers.where((walker) {
      final matchesSearch =
          query.isEmpty ||
          walker.uid.toLowerCase().contains(query) ||
          walker.walkerId.toLowerCase().contains(query) ||
          walker.name.toLowerCase().contains(query) ||
          walker.phone.toLowerCase().contains(query) ||
          walker.aadhaar.toLowerCase().contains(query);

      final status = walker.verificationStatus.toLowerCase();

      final matchesFilter = switch (selectedFilter) {
        'Pending' => status == 'pending',
        'Approved' => status == 'approved',
        'Rejected' => status == 'rejected',
        'Online' => walker.isOnline,
        'Offline' => !walker.isOnline,
        _ => true,
      };

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _walkerStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _errorState(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingState();
        }

        final walkers = _convert(snapshot.data!);
        final filtered = _filtered(walkers);

        final online = walkers.where((e) => e.isOnline).length;
        final offline = walkers.length - online;

        final pending = walkers
            .where((e) => e.verificationStatus == 'pending')
            .length;

        final approved = walkers
            .where((e) => e.verificationStatus == 'approved')
            .length;

        final rejected = walkers
            .where((e) => e.verificationStatus == 'rejected')
            .length;

        final activeWalks = walkers.fold<int>(
          0,
          (sum, walker) => sum + walker.activeWalks,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 20),
            _summaryCards(
              online: online,
              offline: offline,
              pending: pending,
              approved: approved,
              rejected: rejected,
              activeWalks: activeWalks,
            ),
            const SizedBox(height: 20),
            _toolbar(),
            const SizedBox(height: 16),
            if (filtered.isEmpty)
              _emptyState()
            else
              _walkerList(filtered),
          ],
        );
      },
    );
  }

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Walkers',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            color: dojoDark,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Manage walkers and verify their profiles',
          style: TextStyle(
            color: dojoGrey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _summaryCards({
    required int online,
    required int offline,
    required int pending,
    required int approved,
    required int rejected,
    required int activeWalks,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1200
            ? 6
            : constraints.maxWidth >= 750
                ? 3
                : 2;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: columns <= 2 ? 1.7 : 1.45,
          children: [
            _SummaryCard(
              title: 'Online',
              value: '$online',
              icon: Icons.wifi,
              color: dojoGreen,
            ),
            _SummaryCard(
              title: 'Offline',
              value: '$offline',
              icon: Icons.wifi_off,
              color: dojoGrey,
            ),
            _SummaryCard(
              title: 'Pending',
              value: '$pending',
              icon: Icons.pending_actions_outlined,
              color: dojoOrange,
            ),
            _SummaryCard(
              title: 'Approved',
              value: '$approved',
              icon: Icons.verified_outlined,
              color: dojoGreen,
            ),
            _SummaryCard(
              title: 'Rejected',
              value: '$rejected',
              icon: Icons.cancel_outlined,
              color: dojoRed,
            ),
            _SummaryCard(
              title: 'Active Walks',
              value: '$activeWalks',
              icon: Icons.directions_walk_outlined,
              color: dojoBlue,
            ),
          ],
        );
      },
    );
  }

  Widget _toolbar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dojoBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 700) {
            return Column(
              children: [
                _searchBox(),
                const SizedBox(height: 12),
                _filters(),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: _searchBox()),
              const SizedBox(width: 12),
              Flexible(child: _filters()),
            ],
          );
        },
      ),
    );
  }

  Widget _searchBox() {
    return TextField(
      controller: searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Search name, phone, Aadhaar, Walker ID or UID...',
        hintStyle: const TextStyle(
          color: dojoGrey,
          fontSize: 12,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 20,
          color: dojoGrey,
        ),
        suffixIcon: searchController.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  searchController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.close, size: 18),
              ),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: dojoBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: dojoBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: dojoOrange),
        ),
      ),
    );
  }

  Widget _filters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterButton('All'),
          _filterButton('Pending'),
          _filterButton('Approved'),
          _filterButton('Rejected'),
          _filterButton('Online'),
          _filterButton('Offline'),
        ],
      ),
    );
  }

  Widget _filterButton(String title) {
    final selected = selectedFilter == title;

    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          setState(() {
            selectedFilter = title;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? dojoOrange
                : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? dojoOrange : dojoBorder,
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : dojoDark,
              fontSize: 12,
              fontWeight: selected
                  ? FontWeight.w800
                  : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _walkerList(List<WalkerData> walkers) {
    return Column(
      children: walkers.map((walker) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _walkerCard(walker),
        );
      }).toList(),
    );
  }

  Widget _walkerCard(WalkerData walker) {
    final online = walker.isOnline;
    final statusColor = online ? dojoGreen : dojoGrey;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 700) {
            return _mobileCard(walker, statusColor);
          }

          return _desktopCard(walker, statusColor);
        },
      ),
    );
  }

  Widget _desktopCard(
    WalkerData walker,
    Color statusColor,
  ) {
    return Row(
      children: [
        _avatar(walker),
        const SizedBox(width: 14),
        Expanded(
          flex: 3,
          child: _mainInfo(walker),
        ),
        Expanded(
          child: _info(
            Icons.phone_outlined,
            'Phone',
            walker.phone,
          ),
        ),
        Expanded(
          child: _info(
            Icons.directions_walk_outlined,
            'Walks',
            '${walker.walks}',
          ),
        ),
        Expanded(
          child: _info(
            Icons.star_outline,
            'Rating',
            walker.rating.toStringAsFixed(1),
          ),
        ),
        _verificationChip(walker.verificationStatus),
        const SizedBox(width: 7),
        _statusChip(
          walker.isOnline ? 'Online' : 'Offline',
          statusColor,
        ),
        const SizedBox(width: 10),
        _viewButton(walker),
      ],
    );
  }

  Widget _mobileCard(
    WalkerData walker,
    Color statusColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _avatar(walker),
            const SizedBox(width: 12),
            Expanded(child: _mainInfo(walker)),
            _verificationChip(walker.verificationStatus),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _info(
                Icons.phone_outlined,
                'Phone',
                walker.phone,
              ),
            ),
            Expanded(
              child: _info(
                Icons.directions_walk_outlined,
                'Walks',
                '${walker.walks}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _info(
                Icons.star_outline,
                'Rating',
                walker.rating.toStringAsFixed(1),
              ),
            ),
            Expanded(
              child: _info(
                Icons.play_circle_outline,
                'Active',
                '${walker.activeWalks}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _statusChip(
              walker.isOnline ? 'Online' : 'Offline',
              statusColor,
            ),
            const Spacer(),
            _viewButton(walker),
          ],
        ),
        if (walker.verificationStatus == 'pending') ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _approveButton(walker),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _rejectButton(walker),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _avatar(WalkerData walker) {
    final online = walker.isOnline;

    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0F7),
            borderRadius: BorderRadius.circular(15),
          ),
          child: walker.profileSelfie.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    walker.profileSelfie,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const Icon(
                        Icons.badge_outlined,
                        color: dojoBlue,
                        size: 26,
                      );
                    },
                  ),
                )
              : const Icon(
                  Icons.badge_outlined,
                  color: dojoBlue,
                  size: 26,
                ),
        ),
        Positioned(
          right: 1,
          bottom: 1,
          child: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: online ? dojoGreen : dojoGrey,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _mainInfo(WalkerData walker) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          walker.walkerId.isEmpty
              ? 'UID: ${walker.uid}'
              : walker.walkerId,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            color: dojoGrey,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          walker.name.isEmpty ? 'Unnamed Walker' : walker.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: dojoDark,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          walker.uid,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            color: dojoGrey,
          ),
        ),
      ],
    );
  }

  Widget _info(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: dojoBlue),
        const SizedBox(width: 7),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: dojoGrey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? '-' : value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _verificationChip(String status) {
    final normalized = status.toLowerCase();

    final Color color;
    final String label;
    final IconData icon;

    switch (normalized) {
      case 'approved':
        color = dojoGreen;
        label = 'Approved';
        icon = Icons.verified;
        break;
      case 'rejected':
        color = dojoRed;
        label = 'Rejected';
        icon = Icons.cancel;
        break;
      default:
        color = dojoOrange;
        label = 'Pending';
        icon = Icons.pending_actions;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: color),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewButton(WalkerData walker) {
    return OutlinedButton.icon(
      onPressed: () => _showWalkerDetails(walker),
      icon: const Icon(
        Icons.visibility_outlined,
        size: 17,
      ),
      label: const Text('View'),
      style: OutlinedButton.styleFrom(
        foregroundColor: dojoOrange,
        side: const BorderSide(color: dojoOrange),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 11,
        ),
      ),
    );
  }

  Widget _approveButton(WalkerData walker) {
    return ElevatedButton.icon(
      onPressed: _busy ? null : () => _showApproveDialog(walker),
      icon: const Icon(Icons.verified_outlined, size: 17),
      label: const Text('Approve'),
      style: ElevatedButton.styleFrom(
        backgroundColor: dojoGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 11),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _rejectButton(WalkerData walker) {
    return OutlinedButton.icon(
      onPressed: _busy ? null : () => _showRejectDialog(walker),
      icon: const Icon(Icons.close, size: 17),
      label: const Text('Reject'),
      style: OutlinedButton.styleFrom(
        foregroundColor: dojoRed,
        side: const BorderSide(color: dojoRed),
        padding: const EdgeInsets.symmetric(vertical: 11),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showWalkerDetails(WalkerData walker) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.badge_outlined,
                color: dojoBlue,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  walker.name.isEmpty
                      ? 'Walker Details'
                      : walker.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailSection('Identity'),
                  _detailRow('Walker ID', walker.walkerId),
                  _detailRow('Auth UID', walker.uid),
                  _detailRow('Full Name', walker.name),
                  _detailRow('Mobile', walker.phone),
                  _detailRow('DOB', walker.dob),
                  _detailRow('Aadhaar', walker.aadhaar),
                  _detailRow('Address', walker.address),
                  _detailRow('Pincode', walker.pincode),
                  const SizedBox(height: 8),
                  _detailSection('Verification'),
                  _detailRow(
                    'Profile Completed',
                    walker.profileCompleted ? 'Yes' : 'No',
                  ),
                  _detailRow(
                    'Aadhaar Front',
                    walker.aadhaarFrontUploaded ? 'Uploaded' : 'Missing',
                  ),
                  _detailRow(
                    'Aadhaar Back',
                    walker.aadhaarBackUploaded ? 'Uploaded' : 'Missing',
                  ),
                  _detailRow(
                    'Aadhaar Verified',
                    walker.aadhaarVerified ? 'Yes' : 'No',
                  ),
                  _detailRow(
                    'Selfie Verified',
                    walker.selfieVerified ? 'Yes' : 'No',
                  ),
                  _detailRow(
                    'Verification',
                    walker.verificationStatus,
                  ),
                  const SizedBox(height: 8),
                  _detailSection('Activity'),
                  _detailRow('Online', walker.isOnline ? 'Yes' : 'No'),
                  _detailRow('Active', walker.isActive ? 'Yes' : 'No'),
                  _detailRow('Walks', '${walker.walks}'),
                  _detailRow(
                    'Active Walks',
                    '${walker.activeWalks}',
                  ),
                  _detailRow(
                    'Rating',
                    walker.rating.toStringAsFixed(1),
                  ),
                  const SizedBox(height: 12),
                  if (walker.profileSelfie.isNotEmpty)
                    _imagePreview(
                      title: 'Profile Selfie',
                      url: walker.profileSelfie,
                    ),
                  if (walker.aadhaarFront.isNotEmpty)
                    _imagePreview(
                      title: 'Aadhaar Front',
                      url: walker.aadhaarFront,
                    ),
                  if (walker.aadhaarBack.isNotEmpty)
                    _imagePreview(
                      title: 'Aadhaar Back',
                      url: walker.aadhaarBack,
                    ),
                ],
              ),
            ),
          ),
          actions: [
            if (walker.verificationStatus == 'pending') ...[
              _rejectButton(walker),
              _approveButton(walker),
            ],
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: dojoOrange,
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              title,
              style: const TextStyle(
                color: dojoGrey,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePreview({
    required String title,
    required String url,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: dojoDark,
            ),
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              width: double.infinity,
              height: 180,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return Container(
                  height: 100,
                  alignment: Alignment.center,
                  color: dojoBackground,
                  child: const Text(
                    'Image could not be loaded',
                    style: TextStyle(color: dojoGrey),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showApproveDialog(WalkerData walker) async {
    bool aadhaarVerified = walker.aadhaarVerified;
    bool selfieVerified = walker.selfieVerified;

    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final canApprove =
                aadhaarVerified && selfieVerified;

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(
                    Icons.verified_outlined,
                    color: dojoGreen,
                  ),
                  SizedBox(width: 9),
                  Text(
                    'Approve Walker',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verify the documents before approving ${walker.name.isEmpty ? 'this walker' : walker.name}.',
                    style: const TextStyle(
                      color: dojoGrey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: aadhaarVerified,
                    onChanged: (value) {
                      setDialogState(() {
                        aadhaarVerified = value ?? false;
                      });
                    },
                    title: const Text(
                      'Aadhaar Verified',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      walker.aadhaar.isEmpty
                          ? 'Aadhaar number not available'
                          : 'Aadhaar: ${walker.aadhaar}',
                    ),
                    controlAffinity:
                        ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: dojoGreen,
                  ),
                  CheckboxListTile(
                    value: selfieVerified,
                    onChanged: (value) {
                      setDialogState(() {
                        selfieVerified = value ?? false;
                      });
                    },
                    title: const Text(
                      'Selfie Verified',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      walker.profileSelfie.isEmpty
                          ? 'Profile selfie not available'
                          : 'Profile selfie uploaded',
                    ),
                    controlAffinity:
                        ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: dojoGreen,
                  ),
                  if (!canApprove)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Both Aadhaar and Selfie verification are required.',
                        style: TextStyle(
                          color: dojoRed,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: canApprove
                      ? () => Navigator.pop(dialogContext, true)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dojoGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Confirm Approval'),
                ),
              ],
            );
          },
        );
      },
    );

    if (approved != true || !mounted) return;

    await _approveWalker(
      walker,
      aadhaarVerified: aadhaarVerified,
      selfieVerified: selfieVerified,
    );
  }

  Future<void> _approveWalker(
    WalkerData walker, {
    required bool aadhaarVerified,
    required bool selfieVerified,
  }) async {
    setState(() {
      _busy = true;
    });

    try {
      await _firestore.collection('walkerProfiles').doc(walker.uid).set(
        {
          'verificationStatus': 'approved',
          'aadhaarVerified': aadhaarVerified,
          'selfieVerified': selfieVerified,
          'isVerified': true,
          'approvedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      _showMessage(
        'Walker approved successfully.',
        dojoGreen,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Approval failed: $e',
        dojoRed,
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _showRejectDialog(WalkerData walker) async {
    final reasonController = TextEditingController();

    final rejected = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.cancel_outlined,
                color: dojoRed,
              ),
              SizedBox(width: 9),
              Text(
                'Reject Walker?',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to reject ${walker.name.isEmpty ? 'this walker' : walker.name}?',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Reason',
                  hintText: 'Enter rejection reason',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: dojoRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm Reject'),
            ),
          ],
        );
      },
    );

    final reason = reasonController.text.trim();
    reasonController.dispose();

    if (rejected != true || !mounted) return;

    await _rejectWalker(
      walker,
      reason: reason,
    );
  }

  Future<void> _rejectWalker(
    WalkerData walker, {
    required String reason,
  }) async {
    setState(() {
      _busy = true;
    });

    try {
      await _firestore.collection('walkerProfiles').doc(walker.uid).set(
        {
          'verificationStatus': 'rejected',
          'isVerified': false,
          'rejectionReason': reason,
          'rejectedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      _showMessage(
        'Walker rejected.',
        dojoRed,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Rejection failed: $e',
        dojoRed,
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Widget _loadingState() {
    return const SizedBox(
      height: 350,
      child: Center(
        child: CircularProgressIndicator(
          color: dojoOrange,
        ),
      ),
    );
  }

  Widget _errorState(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: dojoRed,
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to load walkers',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          SelectableText(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: dojoGrey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.badge_outlined,
              size: 50,
              color: dojoGrey,
            ),
            SizedBox(height: 12),
            Text(
              'No walkers found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Walkers will appear here from Firebase.',
              style: TextStyle(
                color: dojoGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WalkerData {
  final String uid;
  final String walkerId;
  final String name;
  final String phone;
  final String email;
  final String dob;
  final String address;
  final String pincode;
  final String aadhaar;
  final String profileSelfie;
  final String aadhaarFront;
  final String aadhaarBack;

  final bool profileCompleted;
  final bool aadhaarFrontUploaded;
  final bool aadhaarBackUploaded;
  final bool aadhaarVerified;
  final bool selfieVerified;
  final bool isActive;
  final bool isOnline;
  final bool isVerified;

  final String verificationStatus;
  final String rejectionReason;

  final int walks;
  final int activeWalks;
  final double rating;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WalkerData({
    required this.uid,
    required this.walkerId,
    required this.name,
    required this.phone,
    required this.email,
    required this.dob,
    required this.address,
    required this.pincode,
    required this.aadhaar,
    required this.profileSelfie,
    required this.aadhaarFront,
    required this.aadhaarBack,
    required this.profileCompleted,
    required this.aadhaarFrontUploaded,
    required this.aadhaarBackUploaded,
    required this.aadhaarVerified,
    required this.selfieVerified,
    required this.isActive,
    required this.isOnline,
    required this.isVerified,
    required this.verificationStatus,
    required this.rejectionReason,
    required this.walks,
    required this.activeWalks,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalkerData.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return WalkerData(
      uid: doc.id,
      walkerId: _string(
        data['Walker Id'] ??
            data['Walker ID'] ??
            data['walkerId'] ??
            data['walkerID'],
      ),
      name: _string(
        data['Full Name'] ??
            data['fullName'] ??
            data['name'],
      ),
      phone: _string(
        data['Mobile number'] ??
            data['mobileNumber'] ??
            data['mobile'] ??
            data['phone'] ??
            data['phoneNumber'],
      ),
      email: _string(data['email']),
      dob: _string(
        data['Date Of Birth'] ??
            data['dateOfBirth'] ??
            data['dob'],
      ),
      address: _string(
        data['Adress'] ??
            data['Address'] ??
            data['address'],
      ),
      pincode: _string(
        data['Pincode'] ??
            data['pincode'] ??
            data['pinCode'],
      ),
      aadhaar: _string(
        data['Aadhar Number'] ??
            data['Aadhaar Number'] ??
            data['aadhaarNumber'] ??
            data['aadhaar'],
      ),
      profileSelfie: _string(
        data['Profile Selfie'] ??
            data['profileSelfie'] ??
            data['profileImage'] ??
            data['profileImageUrl'],
      ),
      aadhaarFront: _string(
        data['Aadhar Front'] ??
            data['Aadhaar Front'] ??
            data['aadhaarFront'] ??
            data['aadhaarFrontUrl'],
      ),
      aadhaarBack: _string(
        data['Aadhar Back'] ??
            data['Aadhaar Back'] ??
            data['aadhaarBack'] ??
            data['aadhaarBackUrl'],
      ),
      profileCompleted: _bool(
        data['profileCompleted'],
      ),
      aadhaarFrontUploaded: _bool(
        data['aadhaar_front_uploaded'] ??
            data['aadhaarFrontUploaded'],
      ),
      aadhaarBackUploaded: _bool(
        data['aadhaar_back_uploaded'] ??
            data['aadhaarBackUploaded'],
      ),
      aadhaarVerified: _bool(
        data['aadhaarVerified'],
      ),
      selfieVerified: _bool(
        data['selfieVerified'],
      ),
      isActive: _bool(
        data['isActive'],
        fallback: true,
      ),
      isOnline: _bool(
        data['isOnline'],
      ),
      isVerified: _bool(
        data['isVerified'],
      ),
      verificationStatus: _status(data),
      rejectionReason: _string(
        data['rejectionReason'],
      ),
      walks: _int(
        data['totalWalks'] ??
            data['completedWalks'] ??
            data['walks'],
      ),
      activeWalks: _int(
        data['activeWalks'],
      ),
      rating: _double(
        data['rating'],
      ),
      createdAt: _date(data['createdAt']),
      updatedAt: _date(data['updatedAt']),
    );
  }

  static String _status(
    Map<String, dynamic> data,
  ) {
    final value = _string(
      data['verificationStatus'] ??
          data['verification_status'],
    ).toLowerCase();

    if (value == 'approved') return 'approved';
    if (value == 'rejected') return 'rejected';

    return 'pending';
  }

  static String _string(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static bool _bool(
    dynamic value, {
    bool fallback = false,
  }) {
    if (value is bool) return value;
    return fallback;
  }

  static int _int(dynamic value) {
    if (value is num) return value.toInt();

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static double _double(dynamic value) {
    if (value is num) return value.toDouble();

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static DateTime? _date(dynamic value) {
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
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dojoBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: dojoGrey,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: dojoDark,
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
