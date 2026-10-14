// Local design review only. The normal lib/main.dart never imports this.
// flutter run -t lib/academy_review_main.dart
import 'package:flutter/material.dart';

import 'academy/academy_review_screen.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF153247)),
    ),
    home: const AcademyReviewScreen(),
  ),
);
