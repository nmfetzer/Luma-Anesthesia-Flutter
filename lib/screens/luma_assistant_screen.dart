import 'package:flutter/material.dart';
import '../welcome/luma_theme.dart' as brand;
import '../welcome/welcome_background.dart';
import '../widgets/luma_home_button.dart';
import '../widgets/luma_ai_safety_notice.dart';
import '../ai/luma_ai_catalog.dart';

/// Honest visual preview: no model calls, invented balance, or purchase flow.
class LumaAssistantScreen extends StatefulWidget {
  const LumaAssistantScreen({super.key});

  @override
  State<LumaAssistantScreen> createState() => _LumaAssistantScreenState();
}

class _LumaAssistantScreenState extends State<LumaAssistantScreen> {
  bool _safetyAcknowledged = false;

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
                    child: Image.asset(LumaAiCatalog.mascotAsset,
                        width: 280,
                        semanticLabel:
                            'Luma, a glowing golden character with a halo'),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: brand.LumaColors.cream,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: !_safetyAcknowledged
                        ? LumaAiSafetyNotice(
                            onAcknowledged: () =>
                                setState(() => _safetyAcknowledged = true))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('Your learning companion.',
                                  style: brand.LumaText.title(
                                      size: 28, color: brand.LumaColors.navy)),
                              const SizedBox(height: 12),
                              const Text(
                                  'Luma AI is in development. The assistant is '
                                  'not connected yet, and no credits can be purchased or used.'),
                              const SizedBox(height: 20),
                              const Text('Credit pack preview',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Text('${LumaAiCatalog.creditsPerPack} credits',
                                  style: brand.LumaText.title(
                                      size: 28, color: brand.LumaColors.navy)),
                              const SizedBox(height: 8),
                              const Text(
                                  '${LumaAiCatalog.usPreviewPrice} · One-time purchase',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 12),
                              const Text(
                                  'One credit covers one completed text response. '
                                  'Each follow-up uses another credit. Failed or '
                                  'safety-blocked requests use no credits.'),
                              const SizedBox(height: 12),
                              const Text(
                                  'U.S. preview price only. Local pricing will '
                                  'come from the app store when purchases are available.',
                                  style: TextStyle(fontSize: 12)),
                              const SizedBox(height: 16),
                              const FilledButton(
                                  key: Key('luma-credit-purchase-disabled'),
                                  onPressed: null,
                                  child: Text('Credit purchases coming soon')),
                              const SizedBox(height: 12),
                              const Text(
                                  'No automatic top-ups. Purchased credits will '
                                  'not expire. The included monthly allowance is still '
                                  'being finalized. Complimentary CE app access will '
                                  'include the same allowance as a subscription.'),
                              const SizedBox(height: 20),
                              const FilledButton(
                                  onPressed: null,
                                  child: Text('Chat coming soon')),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () =>
                                    setState(() => _safetyAcknowledged = false),
                                child: const Text('Review AI safety notice'),
                              ),
                              const Text(
                                  'For learning and reference, not patient-specific '
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
