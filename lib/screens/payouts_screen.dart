import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoRed = Color(0xFFC94A4A);
const Color dojoBlack = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);

class PayoutsScreen extends StatefulWidget {
  const PayoutsScreen({super.key});

  @override
  State<PayoutsScreen> createState() => _PayoutsScreenState();
}

class _PayoutsScreenState extends State<PayoutsScreen> {
  String selectedFilter = 'All';

  final List<PayoutData> payouts = const [
    PayoutData(
      id: 'PO-001',
      walker: 'Walker 01',
      amount: 850,
      walks: 5,
      date: '14 Aug 2026',
      status: 'Pending',
    ),
    PayoutData(
      id: 'PO-002',
      walker: 'Walker 02',
      amount: 1250,
      walks: 8,
      date: '14 Aug 2026',
      status: 'Paid',
    ),
    PayoutData(
      id: 'PO-003',
      walker: 'Walker 03',
      amount: 650,
      walks: 4,
      date: '13 Aug 2026',
      status: 'Pending',
    ),
    PayoutData(
      id: 'PO-004',
      walker: 'Walker 04',
      amount: 980,
      walks: 6,
      date: '13 Aug 2026',
      status: 'Paid',
    ),
  ];

  List<PayoutData> get filteredPayouts {
    if (selectedFilter == 'All') {
      return payouts;
    }

    return payouts
        .where((p) => p.status == selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final pending = payouts
        .where((p) => p.status == 'Pending')
        .fold<double>(0, (sum, p) => sum + p.amount);

    final paid = payouts
        .where((p) => p.status == 'Paid')
        .fold<double>(0, (sum, p) => sum + p.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const SizedBox(height: 20),
        _summary(pending, paid),
        const SizedBox(height: 20),
        _filters(),
        const SizedBox(height: 16),
        _payoutList(),
      ],
    );
  }

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payouts',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            color: dojoBlack,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Manage walker earnings and payouts',
          style: TextStyle(
            color: dojoGrey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _summary(double pending, double paid) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= 900
                ? 3
                : constraints.maxWidth >= 550
                    ? 2
                    : 1;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio:
              columns == 1 ? 3.2 : 2.4,
          children: [
            _SummaryCard(
              title: 'Pending Payouts',
              value: '₹${pending.toStringAsFixed(0)}',
              icon: Icons.pending_actions_outlined,
              color: dojoOrange,
            ),
            _SummaryCard(
              title: 'Paid Payouts',
              value: '₹${paid.toStringAsFixed(0)}',
              icon: Icons.check_circle_outline,
              color: dojoGreen,
            ),
            _SummaryCard(
              title: 'Total Payouts',
              value: '${payouts.length}',
              icon: Icons.account_balance_wallet_outlined,
              color: dojoBlue,
            ),
          ],
        );
      },
    );
  }

  Widget _filters() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dojoBorder),
      ),
      child: Wrap(
        spacing: 5,
        children: [
          _filterButton('All'),
          _filterButton('Pending'),
          _filterButton('Paid'),
        ],
      ),
    );
  }

  Widget _filterButton(String title) {
    final selected = selectedFilter == title;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() {
          selectedFilter = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? dojoOrange
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: selected
                ? Colors.white
                : dojoBlack,
          ),
        ),
      ),
    );
  }

  Widget _payoutList() {
    final list = filteredPayouts;

    if (list.isEmpty) {
      return _emptyState();
    }

    return Column(
      children: list.map((payout) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _payoutCard(payout),
        );
      }).toList(),
    );
  }

  Widget _payoutCard(PayoutData payout) {
    final color = payout.status == 'Paid'
        ? dojoGreen
        : dojoOrange;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 650) {
            return _mobileCard(payout, color);
          }

          return _desktopCard(payout, color);
        },
      ),
    );
  }

  Widget _desktopCard(
    PayoutData payout,
    Color color,
  ) {
    return Row(
      children: [
        _payoutIcon(color),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: _mainInfo(payout),
        ),
        Expanded(
          child: _info(
            Icons.person_outline,
            'Walker',
            payout.walker,
          ),
        ),
        Expanded(
          child: _info(
            Icons.directions_walk_outlined,
            'Walks',
            '${payout.walks}',
          ),
        ),
        Expanded(
          child: _info(
            Icons.currency_rupee,
            'Amount',
            '₹${payout.amount}',
          ),
        ),
        _statusChip(payout.status, color),
        const SizedBox(width: 12),
        _viewButton(payout),
      ],
    );
  }

  Widget _mobileCard(
    PayoutData payout,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _payoutIcon(color),
            const SizedBox(width: 12),
            Expanded(
              child: _mainInfo(payout),
            ),
            _statusChip(payout.status, color),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _info(
                Icons.person_outline,
                'Walker',
                payout.walker,
              ),
            ),
            Expanded(
              child: _info(
                Icons.currency_rupee,
                'Amount',
                '₹${payout.amount}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _info(
                Icons.directions_walk_outlined,
                'Walks',
                '${payout.walks}',
              ),
            ),
            Expanded(
              child: _info(
                Icons.calendar_today_outlined,
                'Date',
                payout.date,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: _viewButton(payout),
        ),
      ],
    );
  }

  Widget _payoutIcon(Color color) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        Icons.account_balance_wallet_outlined,
        color: color,
        size: 26,
      ),
    );
  }

  Widget _mainInfo(PayoutData payout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          payout.id,
          style: const TextStyle(
            fontSize: 11,
            color: dojoGrey,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          payout.walker,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: dojoBlack,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          payout.date,
          style: const TextStyle(
            fontSize: 11,
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
        Icon(
          icon,
          size: 18,
          color: dojoBlue,
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
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
                value,
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

  Widget _statusChip(
    String status,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 7,
            color: color,
          ),
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

  Widget _viewButton(PayoutData payout) {
    return OutlinedButton.icon(
      onPressed: () {
        _showDetails(payout);
      },
      icon: const Icon(
        Icons.visibility_outlined,
        size: 17,
      ),
      label: const Text('View'),
      style: OutlinedButton.styleFrom(
        foregroundColor: dojoOrange,
        side: const BorderSide(
          color: dojoOrange,
        ),
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

  void _showDetails(PayoutData payout) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Payout Details',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _detailRow('Payout ID', payout.id),
              _detailRow('Walker', payout.walker),
              _detailRow('Walks', '${payout.walks}'),
              _detailRow(
                'Amount',
                '₹${payout.amount}',
              ),
              _detailRow('Date', payout.date),
              _detailRow('Status', payout.status),
            ],
          ),
          actions: [
            if (payout.status == 'Pending')
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Payout action will connect to Firebase.',
                      ),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: dojoGreen,
                ),
                child: const Text('Mark Paid'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          SizedBox(
            width: 75,
            child: Text(
              title,
              style: const TextStyle(
                color: dojoGrey,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
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
              Icons.account_balance_wallet_outlined,
              size: 50,
              color: dojoGrey,
            ),
            SizedBox(height: 12),
            Text(
              'No payouts found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Walker payout records will appear here.',
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

class PayoutData {
  final String id;
  final String walker;
  final double amount;
  final int walks;
  final String date;
  final String status;

  const PayoutData({
    required this.id,
    required this.walker,
    required this.amount,
    required this.walks,
    required this.date,
    required this.status,
  });
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
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dojoBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: color.withOpacity(.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: dojoGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: dojoBlack,
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
