import 'package:flutter/material.dart';

import 'models/walker_data.dart';
import 'services/walker_service.dart';
import 'utils/walker_helpers.dart';
import 'widgets/walker_card.dart';
import 'widgets/walker_header.dart';
import 'widgets/walker_summary_cards.dart';
import 'widgets/walker_toolbar.dart';

class WalkersScreen extends StatefulWidget {
  const WalkersScreen({
    super.key,
  });

  @override
  State<WalkersScreen> createState() =>
      _WalkersScreenState();
}

class _WalkersScreenState
    extends State<WalkersScreen> {
  final TextEditingController
      searchController =
      TextEditingController();

  final WalkerService _walkerService =
      WalkerService.instance;

  String selectedFilter = 'All';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<WalkerData> _filterWalkers(
    List<WalkerData> walkers,
  ) {
    final query =
        searchController.text.trim().toLowerCase();

    return walkers.where((walker) {
      final matchesSearch =
          query.isEmpty ||
          walker.walkerId
              .toLowerCase()
              .contains(query) ||
          walker.uid
              .toLowerCase()
              .contains(query) ||
          walker.name
              .toLowerCase()
              .contains(query) ||
          walker.phone
              .toLowerCase()
              .contains(query) ||
          walker.email
              .toLowerCase()
              .contains(query) ||
          walker.aadhaarNumber
              .toLowerCase()
              .contains(query);

      if (!matchesSearch) {
        return false;
      }

      switch (selectedFilter) {
        case 'Pending':
          return walker.isPending;

        case 'Approved':
          return walker.isApproved;

        case 'Rejected':
          return walker.isRejected;

        case 'Online':
          return walker.isOnline;

        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return StreamBuilder(
      stream: _walkerService.walkersStream,
      builder: (
        context,
        snapshot,
      ) {
        if (snapshot.hasError) {
          return _errorState(
            snapshot.error.toString(),
          );
        }

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(60),
              child: CircularProgressIndicator(
                color: dojoOrange,
              ),
            ),
          );
        }

        final documents =
            snapshot.data?.docs ?? [];

        final walkers = documents
            .map(
              (document) =>
                  WalkerData.fromDocument(
                document,
              ),
            )
            .toList();

        final filteredWalkers =
            _filterWalkers(walkers);

        final total = walkers.length;

        final online = walkers
            .where(
              (walker) => walker.isOnline,
            )
            .length;

        final pending = walkers
            .where(
              (walker) => walker.isPending,
            )
            .length;

        final approved = walkers
            .where(
              (walker) => walker.isApproved,
            )
            .length;

        final rejected = walkers
            .where(
              (walker) => walker.isRejected,
            )
            .length;

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const WalkerHeader(),

            const SizedBox(
              height: 20,
            ),

            WalkerSummaryCards(
              total: total,
              online: online,
              pending: pending,
              approved: approved,
              rejected: rejected,
            ),

            const SizedBox(
              height: 20,
            ),

            WalkerToolbar(
              controller: searchController,
              selectedFilter:
                  selectedFilter,
              onSearchChanged: (_) {
                setState(() {});
              },
              onClearSearch: () {
                searchController.clear();
                setState(() {});
              },
              onFilterChanged: (filter) {
                setState(() {
                  selectedFilter = filter;
                });
              },
            ),

            const SizedBox(
              height: 16,
            ),

            if (filteredWalkers.isEmpty)
              _emptyState()
            else
              ...filteredWalkers.map(
                (walker) => Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: WalkerCard(
                    walker: walker,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
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
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Walkers will appear here.',
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

  Widget _errorState(
    String error,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              rejectedColor.withOpacity(.25),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: rejectedColor,
            size: 42,
          ),
          const SizedBox(height: 10),
          const Text(
            'Unable to load walkers',
            style: TextStyle(
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            error,
            textAlign:
                TextAlign.center,
            style: const TextStyle(
              color: dojoGrey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
