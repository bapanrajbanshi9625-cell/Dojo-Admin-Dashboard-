import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoRed = Color(0xFFC94A4A);
const Color dojoBlack = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final TextEditingController searchController =
      TextEditingController();

  String selectedFilter = 'All';

  final List<PaymentData> payments = const [
    PaymentData(
      id: 'PAY-001',
      owner: 'Owner 01',
      walkId: 'WALK-001',
      amount: 499,
      method: 'UPI',
      date: '14 Aug 2026',
      status: 'Paid',
    ),
    PaymentData(
      id: 'PAY-002',
      owner: 'Owner 02',
      walkId: 'WALK-002',
      amount: 699,
      method: 'Card',
      date: '14 Aug 2026',
      status: 'Paid',
    ),
    PaymentData(
      id: 'PAY-003',
      owner: 'Owner 03',
      walkId: 'WALK-003',
      amount: 399,
      method: 'UPI',
      date: '13 Aug 2026',
      status: 'Pending',
    ),
    PaymentData(
      id: 'PAY-004',
      owner: 'Owner 04',
      walkId: 'WALK-004',
      amount: 599,
      method: 'UPI',
      date: '13 Aug 2026',
      status: 'Failed',
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<PaymentData> get filteredPayments {
    final query = searchController.text.trim().toLowerCase();

    return payments.where((payment) {
      final matchesSearch =
          query.isEmpty ||
          payment.id.toLowerCase().contains(query) ||
          payment.owner.toLowerCase().contains(query) ||
          payment.walkId.toLowerCase().contains(query) ||
          payment.method.toLowerCase().contains(query);

      final matchesFilter =
          selectedFilter == 'All' ||
          payment.status == selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final paid = payments
        .where((p) => p.status == 'Paid')
        .fold<double>(0, (sum, p) => sum + p.amount);

    final pending = payments
        .where((p) => p.status == 'Pending')
        .fold<double>(0, (sum, p) => sum + p.amount);

    final failed = payments
        .where((p) => p.status == 'Failed')
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const SizedBox(height: 20),
        _summary(paid, pending, failed),
        const SizedBox(height: 20),
        _toolbar(),
        const SizedBox(height: 16),
        _paymentList(),
      ],
    );
  }

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payments',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            color: dojoBlack,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'View and manage owner payments',
          style: TextStyle(
            color: dojoGrey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _summary(
    double paid,
    double pending,
    int failed,
  ) {
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
              title: 'Paid Amount',
              value: '₹${paid.toStringAsFixed(0)}',
              icon: Icons.check_circle_outline,
              color: dojoGreen,
            ),
            _SummaryCard(
              title: 'Pending Amount',
              value: '₹${pending.toStringAsFixed(0)}',
              icon: Icons.pending_outlined,
              color: dojoOrange,
            ),
            _SummaryCard(
              title: 'Failed Payments',
              value: '$failed',
              icon: Icons.error_outline,
              color: dojoRed,
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
          if (constraints.maxWidth < 650) {
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
              _filters(),
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
        hintText: 'Search payment, owner or walk ID...',
        hintStyle: const TextStyle(
          color: dojoGrey,
          fontSize: 12,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 20,
          color: dojoGrey,
        ),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  searchController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.close, size: 18),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: dojoBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: dojoBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: dojoOrange,
          ),
        ),
      ),
    );
  }

  Widget _filters() {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        _filterButton('All'),
        _filterButton('Paid'),
        _filterButton('Pending'),
        _filterButton('Failed'),
      ],
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
          horizontal: 13,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? dojoOrange
              : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? dojoOrange
                : dojoBorder,
          ),
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

  Widget _paymentList() {
    final list = filteredPayments;

    if (list.isEmpty) {
      return _emptyState();
    }

    return Column(
      children: list.map((payment) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _paymentCard(payment),
        );
      }).toList(),
    );
  }

  Widget _paymentCard(PaymentData payment) {
    final statusColor = _statusColor(payment.status);

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
            return _mobileCard(payment, statusColor);
          }

          return _desktopCard(payment, statusColor);
        },
      ),
    );
  }

  Widget _desktopCard(
    PaymentData payment,
    Color statusColor,
  ) {
    return Row(
      children: [
        _paymentIcon(payment.status),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: _mainInfo(payment),
        ),
        Expanded(
          child: _info(
            Icons.person_outline,
            'Owner',
            payment.owner,
          ),
        ),
        Expanded(
          child: _info(
            Icons.currency_rupee,
            'Amount',
            '₹${payment.amount.toStringAsFixed(0)}',
          ),
        ),
        Expanded(
          child: _info(
            Icons.payment_outlined,
            'Method',
            payment.method,
          ),
        ),
        _statusChip(
          payment.status,
          statusColor,
        ),
        const SizedBox(width: 12),
        _viewButton(payment),
      ],
    );
  }

  Widget _mobileCard(
    PaymentData payment,
    Color statusColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _paymentIcon(payment.status),
            const SizedBox(width: 12),
            Expanded(
              child: _mainInfo(payment),
            ),
            _statusChip(
              payment.status,
              statusColor,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _info(
                Icons.person_outline,
                'Owner',
                payment.owner,
              ),
            ),
            Expanded(
              child: _info(
                Icons.currency_rupee,
                'Amount',
                '₹${payment.amount.toStringAsFixed(0)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _info(
                Icons.payment_outlined,
                'Method',
                payment.method,
              ),
            ),
            Expanded(
              child: _info(
                Icons.calendar_today_outlined,
                'Date',
                payment.date,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: _viewButton(payment),
        ),
      ],
    );
  }

  Widget _paymentIcon(String status) {
    final color = _statusColor(status);

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        Icons.payments_outlined,
        color: color,
        size: 26,
      ),
    );
  }

  Widget _mainInfo(PaymentData payment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          payment.id,
          style: const TextStyle(
            fontSize: 11,
            color: dojoGrey,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          payment.walkId,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: dojoBlack,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          payment.date,
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

  Widget _viewButton(PaymentData payment) {
    return OutlinedButton.icon(
      onPressed: () {
        _showDetails(payment);
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

  void _showDetails(PaymentData payment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Payment Details',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _detailRow('Payment ID', payment.id),
              _detailRow('Walk ID', payment.walkId),
              _detailRow('Owner', payment.owner),
              _detailRow(
                'Amount',
                '₹${payment.amount.toStringAsFixed(0)}',
              ),
              _detailRow('Method', payment.method),
              _detailRow('Date', payment.date),
              _detailRow('Status', payment.status),
            ],
          ),
          actions: [
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
            width: 82,
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
              Icons.payments_outlined,
              size: 50,
              color: dojoGrey,
            ),
            SizedBox(height: 12),
            Text(
              'No payments found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Payment records will appear here.',
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

  Color _statusColor(String status) {
    switch (status) {
      case 'Paid':
        return dojoGreen;
      case 'Pending':
        return dojoOrange;
      case 'Failed':
        return dojoRed;
      default:
        return dojoGrey;
    }
  }
}

class PaymentData {
  final String id;
  final String owner;
  final String walkId;
  final double amount;
  final String method;
  final String date;
  final String status;

  const PaymentData({
    required this.id,
    required this.owner,
    required this.walkId,
    required this.amount,
    required this.method,
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
