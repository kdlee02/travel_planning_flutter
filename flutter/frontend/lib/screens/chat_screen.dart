import 'package:flutter/material.dart';
import '../main.dart';
import '../models/travel_state.dart';
import '../services/api_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/info_drawer.dart';
import '../widgets/itinerary_card.dart';

class _Message {
  final String? text;
  final BubbleRole? role;
  final Itinerary? itinerary;

  _Message.text(String this.text, BubbleRole this.role) : itinerary = null;
  _Message.itinerary(Itinerary this.itinerary)
      : text = null,
        role = null;

  bool get isItinerary => itinerary != null;
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _api = ApiService();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  final List<_Message> _messages = [];
  TravelState? _state;
  bool _loading = false;
  bool _itineraryShown = false;

  static const _suggestions = <String>[
    '3-day Seoul food tour',
    'Hanok village + palaces',
    'Budget trip under \$500',
    'K-pop & shopping in Hongdae',
    'Vegetarian-friendly route',
  ];

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  Future<void> _init() async {
    setState(() => _loading = true);
    try {
      final state = await _api.chat(null); // null → triggers greeting
      _applyState(state);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _controller.clear();

    setState(() {
      _messages.add(_Message.text(text, BubbleRole.user));
      _loading = true;
    });
    _scrollToBottom();

    try {
      final state = await _api.chat(text);
      _applyState(state);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  Future<void> _reset() async {
    await _api.reset();
    setState(() {
      _messages.clear();
      _state = null;
      _itineraryShown = false;
    });
    _init();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _applyState(TravelState state) {
    setState(() => _state = state);
    if (state.reply != null) {
      setState(() => _messages.add(
            _Message.text(state.reply!, BubbleRole.assistant),
          ));
    }
    if (state.itinerary != null && !_itineraryShown) {
      setState(() {
        _messages.add(_Message.itinerary(state.itinerary!));
        _itineraryShown = true;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $msg'),
        backgroundColor: SeoulPalette.persimmon,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final confirmed = _state?.confirmed ?? false;
    // Show suggestion chips only before the user has sent anything.
    final showSuggestions =
        !_messages.any((m) => m.role == BubbleRole.user) && !confirmed;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      endDrawer: InfoDrawer(state: _state, onReset: _reset),
      body: Stack(
        children: [
          const _BackgroundDecor(),
          Column(
            children: [
              const SizedBox(height: kToolbarHeight + 12),
              if (confirmed) const _ConfirmedBanner(),
              Expanded(
                child: _messages.isEmpty && _loading
                    ? const _GreetingLoader()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: _messages.length + (_loading ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i == _messages.length) {
                            return const _TypingIndicator();
                          }
                          final m = _messages[i];
                          if (m.isItinerary) {
                            return ItineraryCard(itinerary: m.itinerary!);
                          }
                          return ChatBubble(text: m.text!, role: m.role!);
                        },
                      ),
              ),
              if (showSuggestions) _SuggestionStrip(
                suggestions: _suggestions,
                onTap: _loading ? null : _send,
              ),
              _InputBar(
                controller: _controller,
                enabled: !confirmed && !_loading,
                onSend: _send,
                hint: confirmed
                    ? 'Trip confirmed — 즐거운 여행 되세요! 🎒'
                    : 'Ask anything about Seoul…',
              ),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      titleSpacing: 16,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [SeoulPalette.persimmon, SeoulPalette.gold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: SeoulPalette.persimmon.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text('🗼', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Seoul Travel Buddy',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: SeoulPalette.hanNavy,
                ),
              ),
              Text(
                '안녕하세요 · Plan your trip',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: SeoulPalette.hanNavy.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Builder(
          builder: (ctx) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.menu_book_outlined),
              tooltip: 'Trip details',
              color: SeoulPalette.hanNavy,
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ────────────────────────────────────────────────────────────────────────────

class _BackgroundDecor extends StatelessWidget {
  const _BackgroundDecor();

  @override
  Widget build(BuildContext context) {
    // Soft persimmon glow at the top, fades into cream.
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                SeoulPalette.creamDeep,
                SeoulPalette.cream,
                SeoulPalette.cream,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmedBanner extends StatelessWidget {
  const _ConfirmedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SeoulPalette.jade, Color(0xFF52B788)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: SeoulPalette.jade.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Trip confirmed! Have a wonderful time in Seoul.',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text('🎉', style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}

class _GreetingLoader extends StatelessWidget {
  const _GreetingLoader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🇰🇷', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'Saying hello…',
            style: TextStyle(
              color: SeoulPalette.hanNavy.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: SeoulPalette.persimmon,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: SeoulPalette.persimmon.withValues(alpha: 0.15),
            child: const Text('🗼', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: SeoulPalette.persimmon.withValues(alpha: 0.12),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: SeoulPalette.persimmon,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Buddy is thinking…',
                  style: TextStyle(
                    color: SeoulPalette.hanNavy,
                    fontSize: 13,
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

class _SuggestionStrip extends StatelessWidget {
  final List<String> suggestions;
  final void Function(String)? onTap;

  const _SuggestionStrip({required this.suggestions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Try one to get started ✨',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: SeoulPalette.hanNavy.withValues(alpha: 0.65),
              ),
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => ActionChip(
                label: Text(suggestions[i]),
                onPressed: onTap == null ? null : () => onTap!(suggestions[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final void Function(String) onSend;
  final String hint;

  const _InputBar({
    required this.controller,
    required this.enabled,
    required this.onSend,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          border: Border(
            top: BorderSide(
              color: SeoulPalette.persimmon.withValues(alpha: 0.08),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                textInputAction: TextInputAction.send,
                onSubmitted: enabled ? onSend : null,
                decoration: InputDecoration(hintText: hint),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: enabled
                  ? SeoulPalette.persimmon
                  : SeoulPalette.persimmon.withValues(alpha: 0.3),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: enabled ? () => onSend(controller.text) : null,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
