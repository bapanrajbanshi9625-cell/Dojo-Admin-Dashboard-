import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoGrey = Color(0xFF6B7280);

class LoadingView extends StatelessWidget {
  final String message;

  const LoadingView({
    super.key,
    this.message = 'Loading...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: dojoOrange,
            ),
          ),
          const SizedBox(height: 13),
          Text(
            message,
            style: const TextStyle(
              color: dojoGrey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
