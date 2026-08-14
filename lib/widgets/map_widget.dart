import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);

class DojoMapWidget extends StatelessWidget {
  final double height;
  final bool showHeader;
  final bool showControls;
  final VoidCallback? onTap;

  const DojoMapWidget({
    super.key,
    this.height = 320,
    this.showHeader = true,
    this.showControls = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: height,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF2F0),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: dojoBorder),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: DojoMapPainter(),
                ),
              ),

              if (showHeader)
                Positioned(
                  top: 14,
                  left: 14,
                  child: _liveBadge(),
                ),

              const Positioned(
                left: 75,
                top: 82,
                child: DojoMapMarker(
                  label: 'Walk 01',
                  color: dojoOrange,
                ),
              ),

              const Positioned(
                right: 90,
                top: 145,
                child: DojoMapMarker(
                  label: 'Walk 02',
                  color: dojoBlue,
                ),
              ),

              const Positioned(
                left: 175,
                bottom: 62,
                child: DojoMapMarker(
                  label: 'Walk 03',
                  color: dojoGreen,
                ),
              ),

              if (showControls)
                Positioned(
                  right: 14,
                  bottom: 14,
                  child: _locationButton(),
                ),

              Positioned(
                right: 14,
                top: 14,
                child: _mapInfo(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _liveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 12,
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            color: dojoGreen,
            size: 9,
          ),
          SizedBox(width: 7),
          Text(
            'Live Map',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.directions_walk_outlined,
            size: 15,
            color: dojoOrange,
          ),
          SizedBox(width: 5),
          Text(
            '3 Active',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationButton() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.10),
            blurRadius: 10,
          ),
        ],
      ),
      child: const Icon(
        Icons.my_location,
        color: dojoOrange,
        size: 20,
      ),
    );
  }
}

class DojoMapMarker extends StatelessWidget {
  final String label;
  final Color color;

  const DojoMapMarker({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.10),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
          child: const Icon(
            Icons.pets,
            color: Colors.white,
            size: 15,
          ),
        ),
      ],
    );
  }
}

class DojoMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFDCE3DF)
      ..strokeWidth = 1.4;

    for (double x = -size.height;
        x < size.width;
        x += 55) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        gridPaint,
      );
    }

    for (double y = 0;
        y < size.height + 80;
        y += 58) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y - 35),
        gridPaint,
      );
    }

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final road = Path()
      ..moveTo(-20, size.height * .78)
      ..cubicTo(
        size.width * .22,
        size.height * .30,
        size.width * .55,
        size.height * .80,
        size.width + 20,
        size.height * .42,
      );

    canvas.drawPath(road, roadPaint);

    final roadLinePaint = Paint()
      ..color = const Color(0xFFD4DBD7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(road, roadLinePaint);
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}
