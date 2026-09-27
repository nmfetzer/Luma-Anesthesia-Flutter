import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const storeId = 'com.base6a35a143e93e5ed18ad346be.app';

  test('Android application ID matches the existing RevenueCat store app', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    expect(
      RegExp(r'applicationId\s*=\s*"([^"]+)"').firstMatch(gradle)?.group(1),
      storeId,
    );
    // The source namespace is independent of the public store application ID.
    expect(gradle, contains('namespace = "com.example.luma_anesthesia"'));
  });

  test(
    'all iOS app and test configurations use the existing store identity',
    () {
      final project = File('ios/Runner.xcodeproj/project.pbxproj')
          .readAsStringSync();
      final identifiers = RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);')
          .allMatches(project)
          .map((match) => match.group(1))
          .toList();
      expect(identifiers.where((id) => id == storeId), hasLength(3));
      expect(
        identifiers.where((id) => id == '$storeId.RunnerTests'),
        hasLength(3),
      );
      expect(identifiers, hasLength(6));
    },
  );

  test(
    'existing OAuth callback scheme remains independent of store identity',
    () {
      final manifest = File('android/app/src/main/AndroidManifest.xml')
          .readAsStringSync();
      final plist = File('ios/Runner/Info.plist').readAsStringSync();
      expect(manifest, contains('android:scheme="com.luma.anesthesia"'));
      expect(plist, contains('<string>com.luma.anesthesia</string>'));
    },
  );
}
