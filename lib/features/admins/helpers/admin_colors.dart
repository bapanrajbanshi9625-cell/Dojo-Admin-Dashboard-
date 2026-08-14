import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoRed = Color(0xFFC94A4A);
const Color dojoBlack = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);

Color roleColor(String role) {
  switch (role.toLowerCase()) {
    case 'super admin':
      return dojoOrange;
    case 'support':
      return dojoBlue;
    case 'manager':
      return dojoGreen;
    case 'admin':
    default:
      return dojoBlack;
  }
}
