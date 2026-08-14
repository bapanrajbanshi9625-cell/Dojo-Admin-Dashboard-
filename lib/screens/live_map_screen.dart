import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoDark = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({
    super.key,
  });

  @override
  State<LiveMapScreen> createState() =>
      _LiveMapScreenState();
}

class _LiveMapScreenState
    extends State<LiveMapScreen> {
  int selectedWalk = -1;

  final List<LiveWalkData> walks = const [
    LiveWalkData(
      walkId: 'WALK-001',
      ownerName: 'Owner 01',
      walkerName: 'Walker 01',
      petName: 'Buddy',
      status: 'Live',
    ),
    LiveWalkData(
      walkId: 'WALK-002',
      ownerName: 'Owner 02',
      walkerName: 'Walker 02',
      petName: 'Max',
      status: 'Live',
    ),
    LiveWalkData(
      walkId: 'WALK-003',
      ownerName: 'Owner 03',
      walkerName: 'Walker 03',
      petName: 'Rocky',
      status: 'Live',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _header(),

        const SizedBox(height: 20),

        _summaryCards(),

        const SizedBox(height: 18),

        LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            if (constraints.maxWidth < 900) {
              return Column(
                children: [
                  _mapContainer(),

                  const SizedBox(height: 18),

                  _activeWalksPanel(),
                ],
              );
            }

            return Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: _mapContainer(),
                ),

                const SizedBox(width: 18),

                Expanded(
                  flex: 3,
                  child:
                      _activeWalksPanel(),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _header() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: const [
        Text(
          'Live Map',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            color: dojoDark,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Monitor every active walk in real time',
          style: TextStyle(
            color: dojoGrey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // SUMMARY
  // ==========================================================

  Widget _summaryCards() {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final int columns =
            constraints.maxWidth >= 900
                ? 3
                : constraints.maxWidth >= 550
                    ? 2
                    : 1;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio:
              columns == 1 ? 3.2 : 2.5,
          children: const [
            _SummaryCard(
              title: 'Active Walks',
              value: '0',
              icon:
                  Icons.directions_walk_outlined,
              color: dojoOrange,
            ),
            _SummaryCard(
              title: 'Walkers Online',
              value: '0',
              icon: Icons.badge_outlined,
              color: dojoGreen,
            ),
            _SummaryCard(
              title: 'Live Locations',
              value: '0',
              icon: Icons.location_on_outlined,
              color: dojoBlue,
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // MAP
  // ==========================================================

  Widget _mapContainer() {
    return Container(
      height: 560,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2F0),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: LiveMapPainter(),
              ),
            ),

            Positioned(
              top: 15,
              left: 15,
              child: _liveStatus(),
            ),

            const Positioned(
              left: 80,
              top: 130,
              child: _MapMarker(
                title: 'WALK-001',
                color: dojoOrange,
              ),
            ),

            const Positioned(
              right: 110,
              top: 210,
              child: _MapMarker(
                title: 'WALK-002',
                color: dojoBlue,
              ),
            ),

            const Positioned(
              left: 190,
              bottom: 120,
              child: _MapMarker(
                title: 'WALK-003',
                color: dojoGreen,
              ),
            ),

            Positioned(
              right: 15,
              top: 15,
              child: _mapControls(),
            ),

            Positioned(
              right: 15,
              bottom: 15,
              child: _locationButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _liveStatus() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(11),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.08),
            blurRadius: 12,
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(
            Icons.circle,
            color: dojoGreen,
            size: 10,
          ),
          SizedBox(width: 7),
          Text(
            'LIVE',
            style: TextStyle(
              color: dojoGreen,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(11),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.08),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          IconButton(
            tooltip: 'Zoom in',
            onPressed: () {},
            icon: const Icon(
              Icons.add,
              size: 20,
            ),
          ),

          const Divider(
            height: 1,
          ),

          IconButton(
            tooltip: 'Zoom out',
            onPressed: () {},
            icon: const Icon(
              Icons.remove,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationButton() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.08),
            blurRadius: 12,
          ),
        ],
      ),
      child: IconButton(
        tooltip: 'My location',
        onPressed: () {},
        icon: const Icon(
          Icons.my_location,
          color: dojoOrange,
        ),
      ),
    );
  }

  // ==========================================================
  // ACTIVE WALKS PANEL
  // ==========================================================

  Widget _activeWalksPanel() {
    return Container(
      constraints:
          const BoxConstraints(
        minHeight: 560,
      ),
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.directions_walk_outlined,
                color: dojoOrange,
                size: 21,
              ),

              const SizedBox(width: 8),

              const Expanded(
                child: Text(
                  'Active Walks',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w800,
                    color: dojoDark,
                  ),
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFEAF6EF,
                  ),
                  borderRadius:
                      BorderRadius.circular(8),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color: dojoGreen,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (walks.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No active walks',
                  style: TextStyle(
                    color: dojoGrey,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: walks.length,
                separatorBuilder: (
                  context,
                  index,
                ) =>
                    const SizedBox(
                  height: 10,
                ),
                itemBuilder: (
                  context,
                  index,
                ) {
                  return _walkTile(
                    walks[index],
                    index,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _walkTile(
    LiveWalkData walk,
    int index,
  ) {
    final bool selected =
        selectedWalk == index;

    return InkWell(
      borderRadius:
          BorderRadius.circular(13),
      onTap: () {
        setState(() {
          selectedWalk =
              selected ? -1 : index;
        });
      },
      child: Container(
        padding:
            const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFFEEE9)
              : const Color(0xFFF8F9FA),
          borderRadius:
              BorderRadius.circular(13),
          border: Border.all(
            color: selected
                ? dojoOrange
                : dojoBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? dojoOrange
                    : const Color(
                        0xFFFFEEE9,
                      ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pets,
                size: 19,
                color: selected
                    ? Colors.white
                    : dojoOrange,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    walk.walkId,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    '${walk.walkerName} • ${walk.petName}',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: dojoGrey,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.circle,
              color: dojoGreen,
              size: 9,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DATA MODEL
// ============================================================

class LiveWalkData {
  final String walkId;
  final String ownerName;
  final String walkerName;
  final String petName;
  final String status;

  const LiveWalkData({
    required this.walkId,
    required this.ownerName,
    required this.walkerName,
    required this.petName,
    required this.status,
  });
}

// ============================================================
// SUMMARY CARD
// ============================================================

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
      padding:
          const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color:
                  color.withOpacity(.10),
              borderRadius:
                  BorderRadius.circular(13),
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
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: dojoGrey,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight:
                        FontWeight.w900,
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

// ============================================================
// MAP MARKER
// ============================================================

class _MapMarker extends StatelessWidget {
  final String title;
  final Color color;

  const _MapMarker({
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(7),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(.10),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ),

        const SizedBox(height: 4),

        Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color:
                    color.withOpacity(.25),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.pets,
            color: Colors.white,
            size: 17,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// MAP PAINTER
// ============================================================

class LiveMapPainter
    extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final gridPaint = Paint()
      ..color =
          const Color(0xFFDDE3DF)
      ..strokeWidth = 1.5;

    for (
      double x = 0;
      x < size.width;
      x += 55
    ) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(
          x + 80,
          size.height,
        ),
        gridPaint,
      );
    }

    for (
      double y = 20;
      y < size.height;
      y += 65
    ) {
      canvas.drawLine(
        Offset(0, y),
        Offset(
          size.width,
          y - 25,
        ),
        gridPaint,
      );
    }

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 11
      ..style =
          PaintingStyle.stroke;

    final road = Path()
      ..moveTo(
        0,
        size.height * .72,
      )
      ..quadraticBezierTo(
        size.width * .32,
        size.height * .20,
        size.width,
        size.height * .55,
      );

    canvas.drawPath(
      road,
      roadPaint,
    );

    final secondRoad =
        Path()
          ..moveTo(
            size.width * .10,
            0,
          )
          ..quadraticBezierTo(
            size.width * .55,
            size.height * .45,
            size.width * .85,
            size.height,
          );

    canvas.drawPath(
      secondRoad,
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}
