// global_chat_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_bubble.dart';

class GlobalChatPage extends StatefulWidget {
  const GlobalChatPage({super.key});

  @override
  State<GlobalChatPage> createState() => _GlobalChatPageState();
}

class _GlobalChatPageState extends State<GlobalChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  final _auth = FirebaseAuth.instance;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final uid = _auth.currentUser?.uid;
    await FirebaseFirestore.instance.collection('global_messages').add({
      'text': text,
      'timestamp': Timestamp.now(),
      'senderId': uid,
    });

    _controller.clear();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic, // 💡 여기서 스크롤 부드러움 조정
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('global_messages')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;
              final reversedDocs = docs.reversed.toList(); // 최신순 → 오래된 순

              /// 🔥 핵심: Stream 데이터가 업데이트되었을 때 스크롤을 아래로 이동
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });

              return ListView.builder(
                controller: _scrollController,
                itemCount: reversedDocs.length,
                itemBuilder: (context, index) {
                  final data = reversedDocs[index].data() as Map<String, dynamic>;
                  final message = data['text'] ?? '';
                  final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                  final senderId = data['senderId'] ?? '';
                  final isMe = senderId == uid;

                  final showName = index == 0 ||
                      (reversedDocs[index - 1].data() as Map<String, dynamic>)['senderId'] != senderId;

                  return Column(
                    crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      if (showName)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 4, bottom: 2),
                          child: Text(
                            isMe ? '나' : '익명',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                        ),
                      ChatBubble(
                        message: message,
                        timestamp: timestamp,
                        isMe: isMe,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration:
                  const InputDecoration(hintText: '메시지를 입력하세요...'),
                  onSubmitted: (_) async {
                    await _sendMessage();
                    _scrollToBottom();
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () async {
                  await _sendMessage();
                  _scrollToBottom();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
