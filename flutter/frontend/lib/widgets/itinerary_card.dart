import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../models/travel_state.dart';

class ItineraryCard extends StatelessWidget {
  final Itinerary itinerary;

  const ItineraryCard({super.key, required this.itinerary});

  @override
  Widget build(BuildContext context) {
    final totalStops =
        itinerary.days.fold<int>(0, (n, d) => n + d.pois.length);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: SeoulPalette.hanNavy.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: SeoulPalette.persimmon.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(days: itinerary.days.length, stops: totalStops),
          if (itinerary.summary.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
              child: Text(
                itinerary.summary,
                style: TextStyle(
                  fontSize: 13.5,
                  color: SeoulPalette.hanNavy.withValues(alpha: 0.78),
                  height: 1.45,
                ),
              ),
            ),
          const SizedBox(height: 6),
          ...itinerary.days.map((d) => _DaySection(day: d)),
          if (itinerary.sources.isNotEmpty)
            _SourcesSection(sources: itinerary.sources),
          _DownloadButton(itinerary: itinerary),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int days;
  final int stops;

  const _Header({required this.days, required this.stops});

  @override
  Widget build(BuildContext context) {
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
              child: Text('🗺️', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Seoul Itinerary',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$days ${days == 1 ? "day" : "days"} · $stops ${stops == 1 ? "stop" : "stops"}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12.5,
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

class _DaySection extends StatelessWidget {
  final ItineraryDay day;

  const _DaySection({required this.day});

  @override
  Widget build(BuildContext context) {
    return Theme(
      // Strip default ExpansionTile divider.
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: day.day == 1,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        iconColor: SeoulPalette.persimmon,
        collapsedIconColor: SeoulPalette.hanNavy.withValues(alpha: 0.4),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    SeoulPalette.persimmon.withValues(alpha: 0.85),
                    SeoulPalette.gold.withValues(alpha: 0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'D${day.day}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                day.theme.isEmpty ? 'Day ${day.day}' : day.theme,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: SeoulPalette.hanNavy,
                ),
              ),
            ),
          ],
        ),
        subtitle: day.estimatedCost.isEmpty
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: 44, top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.payments_outlined,
                        size: 14, color: SeoulPalette.gold),
                    const SizedBox(width: 4),
                    Text(
                      day.estimatedCost,
                      style: TextStyle(
                        color: SeoulPalette.hanNavy.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
        children: [
          for (var i = 0; i < day.pois.length; i++)
            _PoiTile(poi: day.pois[i], isLast: i == day.pois.length - 1),
        ],
      ),
    );
  }
}

class _PoiTile extends StatelessWidget {
  final Poi poi;
  final bool isLast;

  const _PoiTile({required this.poi, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                const SizedBox(height: 6),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: SeoulPalette.persimmon,
                      width: 2.5,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: SeoulPalette.persimmon.withValues(alpha: 0.25),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SeoulPalette.cream,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: SeoulPalette.persimmon.withValues(alpha: 0.10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          poi.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                            color: SeoulPalette.hanNavy,
                          ),
                        ),
                      ),
                      if (poi.stayMinutes > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: SeoulPalette.persimmon.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${poi.stayMinutes} min',
                            style: const TextStyle(
                              color: SeoulPalette.persimmon,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (poi.type.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: SeoulPalette.gold.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          poi.type,
                          style: const TextStyle(
                            color: Color(0xFFB45309),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (poi.address.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: SeoulPalette.hanNavy.withValues(alpha: 0.55),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              poi.address,
                              style: TextStyle(
                                color: SeoulPalette.hanNavy
                                    .withValues(alpha: 0.65),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (poi.notes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        poi.notes,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: SeoulPalette.hanNavy,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourcesSection extends StatelessWidget {
  final List<ItinerarySource> sources;

  const _SourcesSection({required this.sources});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 16),
          Row(
            children: [
              const Icon(Icons.bookmark_outline,
                  size: 16, color: SeoulPalette.hanNavy),
              const SizedBox(width: 6),
              Text(
                'Sources',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: SeoulPalette.hanNavy,
                  fontSize: 13,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final s in sources)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _SourceRow(source: s),
            ),
        ],
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  final ItinerarySource source;

  const _SourceRow({required this.source});

  Future<void> _open(BuildContext context) async {
    final url = source.sourceUrl.trim();
    if (url.isEmpty) return;

    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUrl = source.sourceUrl.trim().isNotEmpty;
    final label =
        '${source.source.isEmpty ? '' : '[${source.source}] '}${source.courseTitle}';

    final titleStyle = TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      color: hasUrl
          ? SeoulPalette.persimmon
          : SeoulPalette.hanNavy.withValues(alpha: 0.75),
      decoration: hasUrl ? TextDecoration.underline : TextDecoration.none,
      decorationColor: SeoulPalette.persimmon.withValues(alpha: 0.6),
      height: 1.4,
    );

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: titleStyle)),
        if (hasUrl) ...[
          const SizedBox(width: 6),
          Icon(
            Icons.open_in_new,
            size: 14,
            color: SeoulPalette.persimmon.withValues(alpha: 0.8),
          ),
        ],
      ],
    );

    if (!hasUrl) return row;

    return InkWell(
      onTap: () => _open(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: row,
      ),
    );
  }
}

class _DownloadButton extends StatefulWidget {
  final Itinerary itinerary;

  const _DownloadButton({required this.itinerary});

  @override
  State<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton> {
  bool _saving = false;

  Future<void> _download() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final payload = widget.itinerary.raw.isNotEmpty
          ? widget.itinerary.raw
          : <String, dynamic>{
              'summary': widget.itinerary.summary,
            };

      final encoded = const JsonEncoder.withIndent('  ').convert(payload);
      final bytes = Uint8List.fromList(utf8.encode(encoded));
      final stamp = DateTime.now().toIso8601String().split('T').first;

      await FileSaver.instance.saveFile(
        name: 'seoul_itinerary_$stamp',
        bytes: bytes,
        ext: 'json',
        mimeType: MimeType.json,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Itinerary downloaded as JSON')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _saving ? null : _download,
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_outlined, size: 18),
          label: Text(_saving ? 'Saving…' : 'Download itinerary (JSON)'),
          style: OutlinedButton.styleFrom(
            foregroundColor: SeoulPalette.hanNavy,
            side: BorderSide(
              color: SeoulPalette.persimmon.withValues(alpha: 0.35),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
