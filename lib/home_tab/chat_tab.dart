import 'package:flutter/material.dart';
import 'chat/global_chat_page.dart';
import 'chat/private_chat_list_page.dart';

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: const TabBar(
          tabs: [
            Tab(text: '전체 채팅'),
            Tab(text: '개인 채팅'),
          ],
          labelColor: Colors.brown,
          unselectedLabelColor: Colors.black45,
        ),
        body: const TabBarView(
          children: [
            GlobalChatPage(),
            PrivateChatListPage(),
          ],
        ),
      ),
    );
  }
}
