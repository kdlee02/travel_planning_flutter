import 'package:flutter/material.dart';
import '../main.dart';
import '../models/travel_state.dart';

class InfoDrawer extends StatelessWidget {
  final TravelState? state;
  final VoidCallback onReset;

  const InfoDrawer({super.key, required this.state, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: SeoulPalette.cream,
      child: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, left: 4),
                    child: Text(
                      'Your trip details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: SeoulPalette.hanNavy.withValues(alpha: 0.6),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  if (state == null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'No data yet — start chatting on the left.',
                        style: TextStyle(color: SeoulPalette.hanNavy),
                      ),
                    )
                  else
                    ...state!.fields.entries.map((e) => _FieldTile(
                          label: e.key,
                          value: e.value,
                        )),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: SeoulPalette.persimmon.withValues(alpha: 0.15),
                ),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: SeoulPalette.persimmon.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.restart_alt_rounded,
                    color: SeoulPalette.persimmon,
                  ),
                ),
                title: const Text(
                  'Plan a new trip',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: SeoulPalette.hanNavy,
                  ),
                ),
                subtitle: Text(
                  'Reset and start over',
                  style: TextStyle(
                    color: SeoulPalette.hanNavy.withValues(alpha: 0.55),
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onReset();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [SeoulPalette.persimmon, SeoulPalette.gold],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('🎒', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Trip Notebook',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '여행 정보 · everything we know so far',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldTile extends StatelessWidget {
  final String label;
  final String? value;

  const _FieldTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final filled = value != null && value!.isNotEmpty;
    final accent = filled ? SeoulPalette.jade : SeoulPalette.gold;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: SeoulPalette.hanNavy,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  filled ? value! : 'Not provided yet',
                  style: TextStyle(
                    color: filled
                        ? SeoulPalette.hanNavy.withValues(alpha: 0.75)
                        : SeoulPalette.hanNavy.withValues(alpha: 0.4),
                    fontSize: 12.5,
                    fontStyle: filled ? FontStyle.normal : FontStyle.italic,
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
