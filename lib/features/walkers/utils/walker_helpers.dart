import 'package:flutter/material.dart';

const Color dojoOrange =
    Color(0xFFD35435);

const Color dojoBlue =
    Color(0xFF3F6FA5);

const Color dojoGreen =
    Color(0xFF3F8F68);

const Color dojoDark =
    Color(0xFF263238);

const Color dojoGrey =
    Color(0xFF6B7280);

const Color dojoBorder =
    Color(0xFFE7E9ED);

const Color pendingColor =
    Color(0xFFD99000);

const Color rejectedColor =
    Color(0xFFC62828);

Color walkerStatusColor(
  String status,
) {
  switch (status) {
    case 'approved':
      return dojoGreen;

    case 'rejected':
      return rejectedColor;

    default:
      return pendingColor;
  }
}

String walkerStatusLabel(
  String status,
) {
  switch (status) {
    case 'approved':
      return 'Approved';

    case 'rejected':
      return 'Rejected';

    default:
      return 'Pending';
  }
}
