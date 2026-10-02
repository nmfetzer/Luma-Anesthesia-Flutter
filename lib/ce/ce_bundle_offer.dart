import 'package:flutter/material.dart';

import '../theme/luma_theme.dart';

const ceBundleOfferSeenKey = 'ce_bundle_offer_seen_v1';
const _navy = Color(0xFF0B1437);
const _gold = Color(0xFFE6CF9C);

class CeBundleOfferCard extends StatelessWidget {
  const CeBundleOfferCard({super.key, required this.onExplore});
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 24),
    color: _navy,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THE THREE-COURSE BUNDLE',
            style: lumaBody(size: 12, color: _gold, weight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            'Your CE, all together.',
            style: lumaDisplay(size: 25, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            '3 courses · 60 total MAC Ed CE credits\n'
            'Includes up to 3 complimentary months of Luma Premium.',
            style: lumaBody(color: Colors.white),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const ValueKey('ce-bundle-offer-explore'),
            style: FilledButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: _navy,
              minimumSize: const Size(48, 48),
            ),
            onPressed: onExplore,
            child: const Text('Explore the bundle'),
          ),
        ],
      ),
    ),
  );
}

/// Informational offer only. Returning true opens the existing store paywall;
/// this dialog never starts checkout, sets a price, or grants an entitlement.
class CeBundleOfferDialog extends StatelessWidget {
  const CeBundleOfferDialog({super.key});

  @override
  Widget build(BuildContext context) => AlertDialog(
    key: const ValueKey('ce-bundle-offer-dialog'),
    backgroundColor: LumaColors.cream,
    scrollable: true,
    insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    title: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            'Three courses.\nOne bundle.',
            style: lumaDisplay(size: 27, color: _navy),
          ),
        ),
        IconButton(
          tooltip: 'Close bundle offer',
          onPressed: () => Navigator.of(context).pop(false),
          icon: const Icon(Icons.close),
        ),
      ],
    ),
    content: SizedBox(
      width: 440,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '60 total MAC Ed CE credits',
            style: lumaBody(size: 19, weight: FontWeight.w600, color: _navy),
          ),
          const SizedBox(height: 16),
          for (final title in const [
            'A Medication Review for the Experienced CRNA',
            'Uncommon but Catastrophic Anesthesia Events',
            'Legal Essentials for the CRNA',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text('• $title', style: lumaBody()),
            ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _navy,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Includes 3 complimentary months of Luma Premium',
              style: lumaBody(color: _gold, weight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'One-time course purchase. No app subscription required.\n\n'
            'Maximum 3 complimentary months per account. If a prior course '
            'purchase already awarded 1 month, the bundle adds 2 months. '
            'No automatic subscription enrollment.\n\n'
            'CE credit requires completion of each course’s requirements. '
            'View the current price and purchase details on the next screen.',
            style: lumaBody(size: 13, color: LumaColors.inkMuted),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: const Text('Not now'),
      ),
      FilledButton(
        key: const ValueKey('ce-bundle-offer-view'),
        style: FilledButton.styleFrom(
          backgroundColor: _navy,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48),
        ),
        onPressed: () => Navigator.of(context).pop(true),
        child: const Text('View bundle & price'),
      ),
    ],
  );
}
