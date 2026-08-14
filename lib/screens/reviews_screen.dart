import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoBlack = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  String selectedFilter = 'All';
  int selectedRating = 0;

  final List<ReviewData> reviews = const [
    ReviewData(
      owner: 'Owner 01',
      walker: 'Walker 01',
      rating: 5,
      comment: 'Great walk and very friendly walker.',
      date: '14 Aug 2026',
    ),
    ReviewData(
      owner: 'Owner 02',
      walker: 'Walker 02',
      rating: 4,
      comment: 'Good service and the walk was completed on time.',
      date: '14 Aug 2026',
    ),
    ReviewData(
      owner: 'Owner 03',
      walker: 'Walker 03',
      rating: 3,
      comment: 'Service was okay. Could be improved.',
      date: '13 Aug 2026',
    ),
    ReviewData(
      owner: 'Owner 04',
      walker: 'Walker 04',
      rating: 5,
      comment: 'Excellent experience.',
      date: '13 Aug 2026',
    ),
  ];

  List<ReviewData> get filteredReviews {
    return reviews.where((review) {
      if (selectedFilter == 'All') return true;
      return review.rating == int.parse(selectedFilter);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final average = reviews.isEmpty
        ? 0.0
        : reviews.fold<int>(
                0,
                (sum, review) => sum + review.rating,
              ) /
              reviews.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const SizedBox(height: 20),
        _summary(average),
        const SizedBox(height: 20),
        _filters(),
        const SizedBox(height: 16),
        _reviewList(),
      ],
    );
  }

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            color: dojoBlack,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Monitor owner feedback and walker ratings',
          style: TextStyle(
            color: dojoGrey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _summary(double average) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
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
          childAspectRatio: columns == 1 ? 3.2 : 2.4,
          children: [
            _SummaryCard(
              title: 'Average Rating',
              value: average.toStringAsFixed(1),
              icon: Icons.star_outline,
              color: dojoOrange,
            ),
            _SummaryCard(
              title: 'Total Reviews',
              value: '${reviews.length}',
              icon: Icons.rate_review_outlined,
              color: dojoBlue,
            ),
            const _SummaryCard(
              title: '5 Star Reviews',
              value: '2',
              icon: Icons.star,
              color: dojoGreen,
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
        runSpacing: 5,
        children: [
          _filterButton('All'),
          _filterButton('5'),
          _filterButton('4'),
          _filterButton('3'),
          _filterButton('2'),
          _filterButton('1'),
        ],
      ),
    );
  }

  Widget _filterButton(String value) {
    final selected = selectedFilter == value;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() {
          selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected ? dojoOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != 'All') ...[
              Icon(
                Icons.star,
                size: 14,
                color: selected ? Colors.white : dojoOrange,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              value == 'All' ? 'All' : '$value Star',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : dojoBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewList() {
    final list = filteredReviews;

    if (list.isEmpty) {
      return _emptyState();
    }

    return Column(
      children: list.map((review) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _reviewCard(review),
        );
      }).toList(),
    );
  }

  Widget _reviewCard(ReviewData review) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 500) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _people(review),
                    const SizedBox(height: 10),
                    _rating(review.rating),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _people(review)),
                  _rating(review.rating),
                ],
              );
            },
          ),
          const SizedBox(height: 15),
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: dojoBlack,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            review.date,
            style: const TextStyle(
              fontSize: 11,
              color: dojoGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _people(ReviewData review) {
    return Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFFFFEEE9),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.person_outline,
            color: dojoOrange,
          ),
        ),
        const SizedBox(width: 11),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.owner,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Walker: ${review.walker}',
                style: const TextStyle(
                  fontSize: 11,
                  color: dojoGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _rating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: 19,
          color: dojoOrange,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      height: 280,
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
              Icons.rate_review_outlined,
              size: 50,
              color: dojoGrey,
            ),
            SizedBox(height: 12),
            Text(
              'No reviews found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Reviews will appear here.',
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

class ReviewData {
  final String owner;
  final String walker;
  final int rating;
  final String comment;
  final String date;

  const ReviewData({
    required this.owner,
    required this.walker,
    required this.rating,
    required this.comment,
    required this.date,
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
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
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
