import 'package:flutter/material.dart';
import '../welcome/luma_theme.dart' as brand;
import '../welcome/welcome_background.dart';
import '../widgets/luma_home_button.dart';

/// Honest visual preview: no model calls, invented balance, or purchase flow.
class LumaAssistantScreen extends StatelessWidget {
  const LumaAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: brand.LumaColors.navyDeep,
        appBar: AppBar(
          title: const Text('Meet Luma'),
          actions: const [LumaHomeButton()],
        ),
        body: Stack(children: [
          const WelcomeBackground(heroHaloOpacity: 0),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset('assets/branding/luma_assistant.png',
                        width: 280,
                        semanticLabel: 'Luma, a glowing golden character with a halo'),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: brand.LumaColors.cream,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Your learning companion.',
                            style: brand.LumaText.title(
                                size: 28, color: brand.LumaColors.navy)),
                        const SizedBox(height: 12),
                        const Text('Luma AI is in development. The assistant is '
                            'not connected yet, and no credits can be purchased or used.'),
                        const SizedBox(height: 20),
                        const Text('Planned credit options',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        const Text('An included allowance with eligible plans, '
                            'plus optional credit packs when you need more. '
                            'Amounts and prices are still being finalized.'),
                        const SizedBox(height: 12),
                        const Text('No automatic top-ups. Purchased credits will '
                            'not expire. Complimentary CE app access will include '
                            'the same AI-credit allowance as a subscription.'),
                        const SizedBox(height: 20),
                        const FilledButton(
                            onPressed: null, child: Text('Chat coming soon')),
                        const SizedBox(height: 16),
                        const Text('For learning and reference, not patient-specific '
                            'orders or emergencies. Do not share patient-identifying '
                            'information. AI responses will require independent verification.',
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      );
}
