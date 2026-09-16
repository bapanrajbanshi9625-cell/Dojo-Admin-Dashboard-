import 'package:flutter/material.dart';

class AvailabilityTabs extends StatelessWidget {
  const AvailabilityTabs({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  static const Color primaryOrange = Color(0xFFD35435);
  static const Color secondaryBlue = Color(0xFF3F6FA5);

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _Tab(
              title: 'Insta Walk',
              icon: Icons.flash_on_rounded,
              selected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
            const SizedBox(width: 4),
            _Tab(
              title: 'Daily Walk',
              icon: Icons.schedule_rounded,
              selected: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  static const Color primaryOrange = Color(0xFFD35435);
  static const Color secondaryBlue = Color(0xFF3F6FA5);

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.fromLTRB(
            15,
            12,
            15,
            10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFFFF6F2)
                : Colors.transparent,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
            border: Border(
              bottom: BorderSide(
                color: selected
                    ? primaryOrange
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
                    ? primaryOrange
                    : secondaryBlue,
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
                      ? primaryOrange
                      : const Color(0xFF4B5563),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
