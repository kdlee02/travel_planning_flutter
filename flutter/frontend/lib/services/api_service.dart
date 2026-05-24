import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/travel_state.dart';

class ApiService {
  /// Base URL for the backend.
  ///
  /// - In local dev, defaults to `http://localhost:8000` so `flutter run`
  ///   works without flags.
  /// - In production, the build is run with
  ///   `--dart-define=API_BASE_URL=https://<backend-host>` and points at
  ///   the deployed FastAPI service.
  /// - If the value is an empty string we treat it as "same origin" — this
  ///   is what Render Static Site builds use when set to "" so the app
  ///   talks to whichever host served it.
  static const String _baseRaw = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  /// Empty string → same-origin; otherwise the literal value (no trailing slash).
  static String get _base {
    if (_baseRaw.isEmpty) return '';
    return _baseRaw.endsWith('/')
        ? _baseRaw.substring(0, _baseRaw.length - 1)
        : _baseRaw;
  }

  /// Per-instance thread id. With auth=none we don't want every visitor
  /// landing on the same shared LangGraph thread (they'd see each other's
  /// trip details), so each ApiService instance gets a fresh random id.
  ///
  /// Override via `ApiService(threadId: '...')` for tests or when you want
  /// to resume a specific conversation.
  final String threadId;

  ApiService({String? threadId}) : threadId = threadId ?? _newThreadId();

  static String _newThreadId() {
    // Compact, URL-safe, sufficiently unique for a session: time-prefix +
    // random suffix. Avoids pulling in the `uuid` package for one call site.
    final ts = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final rand = Random.secure();
    final tail = List.generate(
      8,
      (_) => 'abcdefghijklmnopqrstuvwxyz0123456789'[rand.nextInt(36)],
    ).join();
    return 'trip-$ts-$tail';
  }

  /// Sends a user message (or null for the initial greeting) and returns
  /// the updated [TravelState] including the latest AI reply.
  Future<TravelState> chat(String? message) async {
    final body = jsonEncode({
      'thread_id': threadId,
      'message': message,
    });

    final response = await http.post(
      Uri.parse('$_base/chat'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final json =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return TravelState.fromJson(json);
    } else {
      throw Exception('Backend error ${response.statusCode}: ${response.body}');
    }
  }

  /// Resets the conversation on the backend.
  Future<void> reset() async {
    await http.post(Uri.parse('$_base/reset?thread_id=$threadId'));
  }
}
