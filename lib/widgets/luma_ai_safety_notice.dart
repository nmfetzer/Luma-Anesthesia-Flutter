import 'package:flutter/material.dart';

/// Safety acknowledgement only, not consent to send data to an AI provider.
/// Live chat must separately enforce server-side scope, privacy and cost controls.
class LumaAiSafetyNotice extends StatefulWidget {
  const LumaAiSafetyNotice({super.key, required this.onAcknowledged});
  final VoidCallback onAcknowledged;

  static const version = '2026-09-25';
  static const disclaimer =
      'Luma AI is intended for professional education and general reference only. '
      'AI can make mistakes, omit important information, and provide outdated '
      'or fabricated answers and references. Independently verify all information '
      'against current, authoritative clinical references before use.\n\n'
      'Do not use Luma AI for patient-specific diagnosis, treatment decisions, '
      'medication dosing, infusion-rate calculations, or other patient-specific '
      'clinical calculations. Use validated tools and approved clinical resources '
      'for these tasks.\n\n'
      'Luma AI does not replace your clinical judgment, institutional policies '
      'and protocols, or consultation with an appropriate physician or qualified '
      'clinician before medical decisions. Resolve discrepancies through your '
      'institution’s clinical escalation process. Do not use Luma AI for emergencies '
      'or delay necessary care.\n\n'
      'Do not enter patient names, dates of birth, medical record numbers, '
      'identifiable case details, or other personal or protected health information.';

  @override
  State<LumaAiSafetyNotice> createState() => _LumaAiSafetyNoticeState();
}

class _LumaAiSafetyNoticeState extends State<LumaAiSafetyNotice> {
  bool _acknowledged = false;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Before using Luma AI',
              style: TextStyle(fontFamily: 'Fraunces', fontSize: 26)),
          const SizedBox(height: 16),
          const Text(LumaAiSafetyNotice.disclaimer,
              style: TextStyle(fontSize: 15, height: 1.5)),
          const SizedBox(height: 16),
          const Text(
              'Preview only: no prompts are being collected or sent to an AI '
              'provider. Before live chat is enabled, we will identify the '
              'provider, explain what is shared and how it is handled, and '
              'request separate permission. This acknowledgement is not '
              'permission to share data.',
              style: TextStyle(fontSize: 13, height: 1.5)),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('I understand these limitations and will '
                  'independently verify AI responses.'),
              value: _acknowledged,
              onChanged: (value) =>
                  setState(() => _acknowledged = value ?? false),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _acknowledged ? widget.onAcknowledged : null,
            child: const Text('Continue to AI preview'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context)
                .pushNamedAndRemoveUntil('/home', (_) => false),
            child: const Text('Not now, return home'),
          ),
        ],
      );
}
