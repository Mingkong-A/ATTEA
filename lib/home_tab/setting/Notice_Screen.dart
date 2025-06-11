import 'package:flutter/material.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            '📢 공지사항',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            '- ATTEA 에 오신걸 환영합니다!\n\n'
                '- 향후 점검 일정 및 업데이트 사항은 이곳에 공지됩니다.\n\n'
                '- 건의사항은 settings > 계정 정보에서 전달해주세요.\n\n',
            style: TextStyle(fontSize: 16),ㅈ
          ),
        ],
      ),
    );
  }
}
