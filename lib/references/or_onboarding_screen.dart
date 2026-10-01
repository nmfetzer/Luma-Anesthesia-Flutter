import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ce/ce_pdf_viewer.dart';
import '../widgets/luma_home_button.dart';

/// A bundled, standalone reference. This is not a CE enrollment, purchase,
/// certificate award, or promotion-redemption flow.
class OrOnboardingScreen extends StatefulWidget {
  const OrOnboardingScreen({super.key, this.loadBytes, this.viewerBuilder});

  static const route = '/first-days-in-or';
  static const title = 'The First Days in the OR';
  static const asset = 'assets/references/first_days_in_the_or.pdf';

  final Future<Uint8List> Function()? loadBytes;
  final Widget Function(Uint8List)? viewerBuilder;

  @override
  State<OrOnboardingScreen> createState() => _OrOnboardingScreenState();
}

class _OrOnboardingScreenState extends State<OrOnboardingScreen> {
  late Future<Uint8List> document = load();

  Future<Uint8List> load() async {
    if (widget.loadBytes != null) return widget.loadBytes!();
    final data = await rootBundle.load(OrOnboardingScreen.asset);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  void retry() => setState(() {
    document = load();
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      toolbarHeight: 64 * MediaQuery.textScalerOf(context).scale(16) / 16,
      title: const Text(
        'OR Guide',
        style: TextStyle(fontSize: 16, height: 1.3),
      ),
      actions: [
        IconButton(
          tooltip: 'Reload PDF',
          onPressed: retry,
          icon: const Icon(Icons.refresh),
        ),
        const LumaHomeButton(),
      ],
    ),
    body: SafeArea(
      child: FutureBuilder<Uint8List>(
        future: document,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'The onboarding PDF could not be opened. Please try again.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: retry, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                semanticsLabel: 'Opening onboarding PDF',
              ),
            );
          }
          return widget.viewerBuilder?.call(snapshot.data!) ??
              CePdfViewer(
                bytes: snapshot.data!,
                title: OrOnboardingScreen.title,
                errorMessage:
                    'Unable to display this PDF. Use Reload PDF to try again.',
              );
        },
      ),
    ),
  );
}
