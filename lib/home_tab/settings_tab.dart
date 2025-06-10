import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'popup/common_dialog.dart';
import 'setting/Account_Info_screen.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "알 수 없음";

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    child: Icon(Icons.person, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('로그인 계정', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(email, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text('계정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.manage_accounts),
            title: const Text('계정 정보'),
            onTap: () {
              Navigator.pushNamed(context, '/account-info');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('로그아웃'),
              onTap: () async {
                final shouldLogout = await showConfirmDialog(
                  context: context,
                  title: '로그아웃',
                  content: '정말 로그아웃 하시겠습니까?',
                  confirmText: '로그아웃',
                );

                if (shouldLogout == true) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/');
                }
              }
          ),
          const SizedBox(height: 32),
          const Text('앱 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('버전 정보'),
            subtitle: const Text('1.0.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: '나의 앱',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 Jeon jin',
              );
            },
          ),
        ],
      ),
    );
  }
}
