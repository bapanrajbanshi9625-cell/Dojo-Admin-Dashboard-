import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoBlack = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  String selectedTab = 'Overview';

  final List<String> tabs = const [
    'Overview',
    'Revenue',
    'Payments',
    'Payouts',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const SizedBox(height: 20),
        _tabs(),
        const SizedBox(height: 20),
        _content(),
      ],
    );
  }

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Finance',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            color: dojoBlack,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Manage DOJO revenue, payments and walker payouts',
          style: TextStyle(
            color: dojoGrey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _tabs() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dojoBorder),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((tab) {
            final selected = selectedTab == tab;

            return Padding(
              padding: const EdgeInsets.only(right: 5),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  setState(() {
                    selectedTab = tab;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? dojoOrange
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tab,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? Colors.white
                          : dojoBlack,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _content() {
    switch (selectedTab) {
      case 'Revenue':
        return _revenue();
      case 'Payments':
        return _payments();
      case 'Payouts':
        return _payouts();
      default:
        return _overview();
    }
  }

  Widget _overview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stats(),
        const SizedBox(height: 20),
        _sectionTitle(
          'Financial Overview',
          Icons.analytics_outlined,
        ),
        const SizedBox(height: 12),
        _chartCard(),
        const SizedBox(height: 20),
        _recentTransactions(),
      ],
    );
  }

  Widget _stats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= 1000
                ? 4
                : constraints.maxWidth >= 600
                    ? 2
                    : 1;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio:
              columns == 1 ? 3.2 : 2.2,
          children: const [
            FinanceStatCard(
              title: 'Total Revenue',
              value: '₹0',
              icon: Icons.currency_rupee,
              color: dojoGreen,
            ),
            FinanceStatCard(
              title: 'Today Revenue',
              value: '₹0',
              icon: Icons.trending_up,
              color: dojoBlue,
            ),
            FinanceStatCard(
              title: 'Payments',
              value: '0',
              icon: Icons.payments_outlined,
              color: dojoOrange,
            ),
            FinanceStatCard(
              title: 'Pending Payouts',
              value: '₹0',
              icon: Icons.account_balance_wallet_outlined,
              color: dojoGrey,
            ),
          ],
        );
      },
    );
  }

  Widget _revenue() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stats(),
        const SizedBox(height: 20),
        _sectionTitle(
          'Revenue',
          Icons.trending_up,
        ),
        const SizedBox(height: 12),
        _chartCard(),
        const SizedBox(height: 20),
        _emptyFinanceCard(
          Icons.receipt_long_outlined,
          'No revenue records',
          'Revenue data from completed walks will appear here.',
        ),
      ],
    );
  }

  Widget _payments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Payments',
          Icons.payments_outlined,
        ),
        const SizedBox(height: 12),
        _emptyFinanceCard(
          Icons.payments_outlined,
          'No payments yet',
          'Owner payments will appear here after Firebase is connected.',
        ),
      ],
    );
  }

  Widget _payouts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Walker Payouts',
          Icons.account_balance_wallet_outlined,
        ),
        const SizedBox(height: 12),
        _emptyFinanceCard(
          Icons.account_balance_wallet_outlined,
          'No pending payouts',
          'Walker payout information will appear here.',
        ),
      ],
    );
  }

  Widget _chartCard() {
    return Container(
      height: 300,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Last 7 days',
            style: TextStyle(
              fontSize: 11,
              color: dojoGrey,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: CustomPaint(
              painter: RevenueChartPainter(),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentTransactions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: dojoOrange,
                size: 20,
              ),
              SizedBox(width: 9),
              Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 45),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 42,
                  color: dojoGrey,
                ),
                SizedBox(height: 10),
                Text(
                  'No transactions yet',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Transactions will appear here.',
                  style: TextStyle(
                    color: dojoGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 45),
        ],
      ),
    );
  }

  Widget _emptyFinanceCard(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: dojoGrey,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
              ),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: dojoGrey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: dojoOrange,
          size: 21,
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: dojoBlack,
          ),
        ),
      ],
    );
  }
}

class FinanceStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const FinanceStatCard({
    super.key,
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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

class RevenueChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE9ECEF)
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = dojoOrange
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = dojoOrange.withOpacity(.08)
      ..style = PaintingStyle.fill;

    const rows = 4;

    for (int i = 0; i <= rows; i++) {
      final y = size.height * i / rows;

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    final points = [
      Offset(size.width * .02, size.height * .80),
      Offset(size.width * .17, size.height * .67),
      Offset(size.width * .32, size.height * .73),
      Offset(size.width * .47, size.height * .45),
      Offset(size.width * .62, size.height * .58),
      Offset(size.width * .77, size.height * .27),
      Offset(size.width * .94, size.height * .38),
    ];

    final path = Path()
      ..moveTo(points.first.dx, size.height)
      ..lineTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(
        points[i].dx,
        points[i].dy,
      );
    }

    path.lineTo(points.last.dx, size.height);
    path.close();

    canvas.drawPath(path, fillPaint);

    final linePath = Path()
      ..moveTo(
        points.first.dx,
        points.first.dy,
      );

    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(
        points[i].dx,
        points[i].dy,
      );
    }

    canvas.drawPath(linePath, linePaint);

    final dotPaint = Paint()
      ..color = dojoOrange;

    for (final point in points) {
      canvas.drawCircle(point, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}
