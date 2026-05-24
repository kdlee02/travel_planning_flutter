import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/landmark_analysis.dart';
import 'verification_banner.dart';
import 'visitor_info_card.dart';

/// Full result panel rendered after a successful landmark analysis.
/// Visually mirrors the ItineraryCard: gradient header (persimmon→gold),
/// white body, soft han-navy shadow.
class LensResultCard extends StatelessWidget {
  final LandmarkAnalysis result;

  const LensResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final lowConfidence = result.confidence > 0 && result.confidence < 60;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: SeoulPalette.persimmon.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: SeoulPalette.hanNavy.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(result: result),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Chips(result: result),
                const SizedBox(height: 14),
                LensVerificationBanner(
                  dataVerified: result.dataVerified,
                  dataSource: result.dataSource,
                ),
                if (lowConfidence) ...[
                  const SizedBox(height: 10),
                  _LowConfidenceBanner(confidence: result.confidence),
                ],
                if (result.dataVerified && result.publicInfo.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  LensVisitorInfoCard(
                    info: result.publicInfo,
                    infoEn: result.publicInfoEn,
                  ),
                ],
                const SizedBox(height: 14),
                _StoryBlock(text: result.description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final LandmarkAnalysis result;
  const _Header({required this.result});

  @override
  Widget build(BuildContext context) {
    final showKorean = result.nameKorean.isNotEmpty &&
        result.nameKorean != result.nameEnglish;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [SeoulPalette.persimmon, SeoulPalette.gold],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('📸', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.nameEnglish,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                if (showKorean) ...[
                  const SizedBox(height: 2),
                  Text(
                    result.nameKorean,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chips extends StatelessWidget {
  final LandmarkAnalysis result;
  const _Chips({required this.result});

  @override
  Widget build(BuildContext context) {
    final highConf = result.confidence >= 75;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _SoftChip(
          icon: Icons.label_outline,
          label: result.category,
          accent: SeoulPalette.gold,
        ),
        _SoftChip(
          icon: highConf ? Icons.check_circle_outline : Icons.help_outline,
          label: 'Confidence: ${result.confidence}%',
          accent: highConf ? SeoulPalette.jade : SeoulPalette.gold,
        ),
      ],
    );
  }
}

class _SoftChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;

  const _SoftChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: SeoulPalette.hanNavy,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LowConfidenceBanner extends StatelessWidget {
  final int confidence;
  const _LowConfidenceBanner({required this.confidence});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: SeoulPalette.gold.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: SeoulPalette.gold.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFB45309),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Buddy wasn't very confident ($confidence%). "
              'The identification might be off — try another photo?',
              style: const TextStyle(
                color: Color(0xFFB45309),
                fontSize: 12.5,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryBlock extends StatelessWidget {
  final String text;
  const _StoryBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SeoulPalette.cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SeoulPalette.persimmon.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: SeoulPalette.persimmon.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_stories_outlined,
                  size: 16,
                  color: SeoulPalette.persimmon,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Story',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: SeoulPalette.hanNavy,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SelectableText(
            text,
            style: const TextStyle(
              color: SeoulPalette.hanNavy,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
