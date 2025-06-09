// chat_bubble.dart
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final DateTime? timestamp;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.message,
    required this.timestamp,
    this.isMe = false,
  });

  @override
  Widget build(BuildContext context) {
    final timeText = timestamp != null
        ? Text(
      '${timestamp!.hour.toString().padLeft(2, '0')}:${timestamp!.minute
          .toString().padLeft(2, '0')}',
      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
    )
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: isMe
            ? [
          if (timeText != null)
            Padding(padding: const EdgeInsets.only(bottom: 6, right: 4),
                child: timeText),
          Flexible(
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: Text(
                message,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                softWrap: true,
              ),
            ),
          ),
        ]
            : [
          Flexible(
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Text(
                message,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                softWrap: true,
              ),
            ),
          ),
          if (timeText != null)
            Padding(padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: timeText),
        ],
      ),
    );
  }
}
