// Owner-only review entry. Never import this from the production entry point.
// The private build preparation step supplies assets/academy_review/bundle.json.
import 'package:flutter/widgets.dart';

import 'academy/academy_package_review_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AcademyPrivateBundleApp());
}
