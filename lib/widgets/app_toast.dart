import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoRed = Color(0xFFC94A4A);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoBlack = Color(0xFF263238);

class DojoToast {
  static void success(
    BuildContext context,
    String message,
  ) {
    _show(
      context,
      message,
      Icons.check_circle_outline,
      dojoGreen,
    );
  }

  static void error(
    BuildContext context,
    String message,
  ) {
    _show(
      context,
      message,
      Icons.error_outline,
      dojoRed,
    );
  }

  static void info(
    BuildContext context,
    String message,
  ) {
    _show(
      context,
      message,
      Icons.info_outline,
      dojoBlue,
    );
  }

  static void warning(
    BuildContext context,
    String message,
  ) {
    _show(
      context,
      message,
      Icons.warning_amber_outlined,
      dojoOrange,
    );
  }

  static void _show(
    BuildContext context,
    String message,
    IconData icon,
    Color color,
  ) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.white,
          elevation: 4,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: dojoBlack,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
