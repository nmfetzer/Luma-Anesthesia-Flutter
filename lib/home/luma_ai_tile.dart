import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../ai/luma_ai_catalog.dart';

/// Shared tile across phone, tablet and desktop. Opens the safety-gated preview.
class LumaAiTile extends StatelessWidget {
  const LumaAiTile({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: 'Luma AI. Your learning companion. Opens AI preview.',
        excludeSemantics: true,
        child: Material(
          color: const Color(0xFF0B1834),
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/luma-ai'),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE6CF9C), width: 0.7),
              ),
              child: LayoutBuilder(builder: (context, constraints) {
                final imageSize =
                    math.min(96.0, constraints.maxHeight).clamp(32.0, 96.0);
                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        LumaAiCatalog.mascotAsset,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                        excludeFromSemantics: true,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Luma AI',
                              style: TextStyle(
                                  fontFamily: 'Fraunces',
                                  fontSize: 24,
                                  height: 1.1,
                                  color: Color(0xFFF7F1E6))),
                          SizedBox(height: 5),
                          Text('Your learning companion',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  height: 1.3,
                                  color: Color(0xFFE6CF9C))),
                          SizedBox(height: 4),
                          Text('AI preview',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: Color(0xFFD3D9E6))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Color(0xFFE6CF9C), size: 20),
                  ],
                );
              }),
            ),
          ),
        ),
      );
}
