import 'package:flutter/material.dart';

import '../../main.dart';

/// "Verified by Seoul Open Data" / "Based on general knowledge" banner.
/// Jade gradient mirrors the chat-side _ConfirmedBanner when verified;
/// soft gold/cream tones when unverified.
class LensVerificationBanner extends StatelessWidget {
  final bool dataVerified;
  final String dataSource;

  const LensVerificationBanner({
    super.key,
    required this.dataVerified,
    required this.dataSource,
  });

  @override
  Widget build(BuildContext context) {
    return dataVerified ? const _Verified() : _Unverified(dataSource: dataSource);
  }
}

class _Verified extends StatelessWidget {
  const _Verified();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SeoulPalette.jade, Color(0xFF52B788)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: SeoulPalette.jade.withValues(alpha: 0.20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.verified, color: Colors.white, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verified by Seoul Open Data',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Sourced from korean.visitseoul.net',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Unverified extends StatelessWidget {
  final String dataSource;
  const _Unverified({required this.dataSource});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: SeoulPalette.creamDeep,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SeoulPalette.gold.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: SeoulPalette.gold.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.info_outline,
              size: 16,
              color: Color(0xFFB45309),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Based on general knowledge',
                  style: TextStyle(
                    color: SeoulPalette.hanNavy,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'No Seoul Open Data match — facts not independently verified.',
                  style: TextStyle(
                    color: Color(0xFFB45309),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
