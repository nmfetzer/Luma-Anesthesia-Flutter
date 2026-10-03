import 'package:flutter/material.dart';

import '../widgets/premium_access_gate.dart';
import 'diagnostics_screen.dart';
import 'abg_screen.dart';
import 'clinical_module_screen.dart';
import 'clinical_modules.dart';

/// The release app always checks its existing clinical subscription entitlement.
/// Review access is supplied only by the separate private preview entry point.
class DiagnosticsFeature extends StatelessWidget {
  const DiagnosticsFeature({
    super.key,
    this.reviewPreview = false,
    this.initialSection,
    this.checkAccess,
    this.accessChanges,
  });
  final bool reviewPreview;
  final String? initialSection;
  final Future<bool> Function()? checkAccess;
  final Stream<void>? accessChanges;

  @override
  Widget build(BuildContext context) {
    final scope = DiagnosticsAccessScope(
      reviewPreview: reviewPreview,
      checkAccess: checkAccess,
      accessChanges: accessChanges,
      child: switch (initialSection) {
        'labs' => LabValuesScreen(
          showClinicalDraft: reviewPreview,
          clinicalRelease: !reviewPreview,
        ),
        'abg' => AbgReferenceScreen(
          showClinicalDraft: reviewPreview,
          clinicalRelease: !reviewPreview,
        ),
        final id? when clinicalModules.any((m) => m.id == id) =>
          ClinicalModuleScreen(
            module: clinicalModules.firstWhere((m) => m.id == id),
            showClinicalDraft: reviewPreview,
            clinicalRelease: !reviewPreview,
          ),
        _ => DiagnosticsScreen(
          showClinicalDraft: reviewPreview,
          clinicalRelease: !reviewPreview,
        ),
      },
    );
    return scope.protect(scope);
  }
}

class DiagnosticsAccessScope extends InheritedWidget {
  const DiagnosticsAccessScope({
    super.key,
    required super.child,
    required this.reviewPreview,
    this.checkAccess,
    this.accessChanges,
  });
  final bool reviewPreview;
  final Future<bool> Function()? checkAccess;
  final Stream<void>? accessChanges;

  static DiagnosticsAccessScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DiagnosticsAccessScope>();

  Widget protect(Widget page) => reviewPreview
      ? page
      : PremiumAccessGate(
          checkAccess: checkAccess,
          accessChanges: accessChanges,
          builder: (_) => page,
        );

  @override
  bool updateShouldNotify(DiagnosticsAccessScope oldWidget) =>
      oldWidget.reviewPreview != reviewPreview ||
      oldWidget.checkAccess != checkAccess ||
      oldWidget.accessChanges != accessChanges;
}
