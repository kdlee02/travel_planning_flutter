/// Coerce `jsonDecode` output into `Map<String, dynamic>`. Nested maps from
/// `jsonDecode` are `Map<String, dynamic>` on Dart VM but can come back as
/// `Map<dynamic, dynamic>` on web — `is Map<String, dynamic>` fails in the
/// latter case and silently drops the field. Going through `Map.from` works
/// on both.
Map<String, dynamic>? _asJsonMap(Object? raw) {
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return null;
}

List<Map<String, dynamic>> _asJsonList(Object? raw) {
  if (raw is! List) return const [];
  return [
    for (final item in raw)
      if (item is Map) Map<String, dynamic>.from(item),
  ];
}

/// Mirrors the StateResponse Pydantic model from the FastAPI backend.
class TravelState {
  final String? duration;
  final String? location;
  final String? budget;
  final String? dietary;
  final String? purpose;
  final String currentStep;
  final bool confirmed;
  final String? reply;
  final Itinerary? itinerary;

  const TravelState({
    this.duration,
    this.location,
    this.budget,
    this.dietary,
    this.purpose,
    this.currentStep = 'start',
    this.confirmed = false,
    this.reply,
    this.itinerary,
  });

  factory TravelState.fromJson(Map<String, dynamic> json) {
    final itineraryJson = _asJsonMap(json['itinerary']);
    return TravelState(
      duration: json['duration'] as String?,
      location: json['location'] as String?,
      budget: json['budget'] as String?,
      dietary: json['dietary'] as String?,
      purpose: json['purpose'] as String?,
      currentStep: (json['current_step'] as String?) ?? 'start',
      confirmed: (json['confirmed'] as bool?) ?? false,
      reply: json['reply'] as String?,
      itinerary:
          itineraryJson != null ? Itinerary.fromJson(itineraryJson) : null,
    );
  }

  /// Human-readable label → value pairs for the info drawer.
  Map<String, String?> get fields => {
        '📅 Trip Duration': duration,
        '📍 Destination': location,
        '💰 Budget': budget,
        '🥗 Dietary Restrictions': dietary,
        '🎯 Travel Purpose': purpose,
      };
}

class Itinerary {
  final String summary;
  final List<ItineraryDay> days;
  final List<ItinerarySource> sources;

  /// The original JSON payload from the backend. Kept verbatim so users can
  /// download a file that includes fields the typed model doesn't surface
  /// (critic_report, repair_log, area_coverage, requested_areas, …).
  final Map<String, dynamic> raw;

  const Itinerary({
    required this.summary,
    required this.days,
    required this.sources,
    this.raw = const {},
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) => Itinerary(
        summary: json['summary'] as String? ?? '',
        days: _asJsonList(json['days']).map(ItineraryDay.fromJson).toList(),
        sources: _asJsonList(json['sources'])
            .map(ItinerarySource.fromJson)
            .toList(),
        raw: json,
      );
}

class ItineraryDay {
  final int day;
  final String theme;
  final List<Poi> pois;
  final String estimatedCost;

  const ItineraryDay({
    required this.day,
    required this.theme,
    required this.pois,
    required this.estimatedCost,
  });

  factory ItineraryDay.fromJson(Map<String, dynamic> json) => ItineraryDay(
        day: (json['day'] as num?)?.toInt() ?? 0,
        theme: json['theme'] as String? ?? '',
        pois: _asJsonList(json['pois']).map(Poi.fromJson).toList(),
        estimatedCost: json['estimated_cost']?.toString() ?? '',
      );
}

class Poi {
  final String name;
  final String type;
  final String address;
  final double? lat;
  final double? lng;
  final int stayMinutes;
  final String notes;

  const Poi({
    required this.name,
    required this.type,
    required this.address,
    this.lat,
    this.lng,
    required this.stayMinutes,
    required this.notes,
  });

  factory Poi.fromJson(Map<String, dynamic> json) => Poi(
        name: json['name'] as String? ?? '',
        type: json['type'] as String? ?? '',
        address: json['address'] as String? ?? '',
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        stayMinutes: (json['stay_minutes'] as num?)?.toInt() ?? 0,
        notes: json['notes'] as String? ?? '',
      );
}

class ItinerarySource {
  final String courseId;
  final String courseTitle;
  final String source;
  final String sourceUrl;

  const ItinerarySource({
    required this.courseId,
    required this.courseTitle,
    required this.source,
    required this.sourceUrl,
  });

  factory ItinerarySource.fromJson(Map<String, dynamic> json) =>
      ItinerarySource(
        courseId: json['course_id']?.toString() ?? '',
        courseTitle: json['course_title'] as String? ?? '',
        source: json['source'] as String? ?? '',
        sourceUrl: json['source_url'] as String? ?? '',
      );
}
