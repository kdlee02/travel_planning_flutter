import 'package:flutter/material.dart';
import '../main.dart';

enum BubbleRole { user, assistant }

class ChatBubble extends StatelessWidget {
  final String text;
  final BubbleRole role;

  const ChatBubble({super.key, required this.text, required this.role});

  @override
  Widget build(BuildContext context) {
    final isUser = role == BubbleRole.user;

    final bubble = Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      decoration: BoxDecoration(
        gradient: isUser
            ? const LinearGradient(
                colors: [SeoulPalette.persimmon, Color(0xFFEF6B7C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isUser ? null : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isUser ? 20 : 6),
          bottomRight: Radius.circular(isUser ? 6 : 20),
        ),
        border: isUser
            ? null
            : Border.all(
                color: SeoulPalette.persimmon.withValues(alpha: 0.10),
              ),
        boxShadow: [
          BoxShadow(
            color: (isUser ? SeoulPalette.persimmon : SeoulPalette.hanNavy)
                .withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isUser ? Colors.white : SeoulPalette.hanNavy,
          fontSize: 14.5,
          height: 1.45,
        ),
      ),
    );

    final avatar = CircleAvatar(
      radius: 16,
      backgroundColor: isUser
          ? SeoulPalette.hanNavy.withValues(alpha: 0.10)
          : SeoulPalette.persimmon.withValues(alpha: 0.15),
      child: Text(
        isUser ? '🧳' : '🗼',
        style: const TextStyle(fontSize: 15),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: isUser
            ? [
                Flexible(child: bubble),
                const SizedBox(width: 8),
                avatar,
              ]
            : [
                avatar,
                const SizedBox(width: 8),
                Flexible(child: bubble),
              ],
      ),
    );
  }
}
