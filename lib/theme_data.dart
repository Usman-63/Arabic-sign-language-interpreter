import 'package:flutter/material.dart';

final elevatedButtonTheme = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF7E22CE),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);

final cardThemeData = CardTheme(
  elevation: 8,
  shadowColor: const Color(0xFF7E22CE),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
);
