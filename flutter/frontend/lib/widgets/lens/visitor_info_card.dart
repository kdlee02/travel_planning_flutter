import 'package:flutter/material.dart';

import '../../main.dart';

/// Visitor information rendered with the same accent-dot tile style used
/// in info_drawer.dart on the chat side — jade accent for filled fields.
class LensVisitorInfoCard extends StatelessWidget {
  /// Raw Korean fields from seoul.json.
  final Map<String, String> info;

  /// Translated English fields. Empty values fall back to Korean per-field.
  final Map<String, String> infoEn;

  const LensVisitorInfoCard({
    super.key,
    required this.info,
    required this.infoEn,
  });

  static const _fields = <_Field>[
    _Field('address', 'Address', Icons.location_on_outlined),
    _Field('hours', 'Hours', Icons.access_time),
    _Field('open_days', 'Open', Icons.event_available_outlined),
    _Field('closed_days', 'Closed', Icons.event_busy_outlined),
    _Field('subway', 'Subway', Icons.directions_subway_outlined),
    _Field('phone', 'Phone', Icons.phone_outlined),
    _Field('website', 'Website', Icons.link),
    _Field('tags', 'Tags', Icons.tag),
  ];

  String _displayValue(_Field f) {
    final en = (infoEn[f.key] ?? '').trim();
    if (en.isNotEmpty) return en;
    return (info[f.key] ?? '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final rows =
        _fields.where((f) => _displayValue(f).isNotEmpty).toList();
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
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
                  color: SeoulPalette.jade.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.place_outlined,
                  size: 16,
                  color: SeoulPalette.jade,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Visitor info',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: SeoulPalette.hanNavy,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...rows.map((f) => _InfoTile(field: f, value: _displayValue(f))),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final _Field field;
  final String value;

  const _InfoTile({required this.field, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SeoulPalette.jade.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: SeoulPalette.jade,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            field.icon,
            size: 16,
            color: SeoulPalette.hanNavy.withValues(alpha: 0.55),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              field.label,
              style: const TextStyle(
                color: SeoulPalette.hanNavy,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                color: SeoulPalette.hanNavy.withValues(alpha: 0.85),
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field {
  const _Field(this.key, this.label, this.icon);
  final String key;
  final String label;
  final IconData icon;
}
