import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  bool isAdmin = false;
  final adminPwController = TextEditingController();
  final currentPwController = TextEditingController();
  final newPwController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAdminStatus();
  }

  Future<void> _loadAdminStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAdmin = prefs.getBool('isAdmin') ?? false;
    });
  }

  Future<void> _toggleAdminLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (isAdmin) {
      await prefs.setBool('isAdmin', false);
      setState(() => isAdmin = false);
    } else {
      if (adminPwController.text.trim() == 'admin1234') {
        await prefs.setBool('isAdmin', true);
        setState(() => isAdmin = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('운영진 로그인 성공')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호가 틀렸습니다')),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    final currentPw = currentPwController.text.trim();
    final newPw = newPwController.text.trim();

    if (user == null || user.email == null) return;

    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPw,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPw);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 변경되었습니다')),
      );
      currentPwController.clear();
      newPwController.clear();
    } on FirebaseAuthException catch (e) {
      String msg = '오류 발생';
      if (e.code == 'wrong-password') {
        msg = '현재 비밀번호가 올바르지 않습니다';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '알 수 없음';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8E1),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '계정 정보',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.brown),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('로그인 계정: $email',
              style: const TextStyle(fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 24),

          const Text('비밀번호 변경',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),

          TextField(
            controller: currentPwController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: '현재 비밀번호',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: newPwController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: '새 비밀번호',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: _changePassword,
            icon: const Icon(Icons.password, color: Colors.black),
            label: const Text(
              '비밀번호 변경',
              style: TextStyle(color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown[100],
              minimumSize: const Size.fromHeight(48),
            ),
          ),

          const SizedBox(height: 32),
          const Divider(),
          Text('운영진 로그인 상태: ${isAdmin ? '활성화됨' : '비활성화됨'}',
              style: const TextStyle(fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 12),

          if (!isAdmin)
            TextField(
              controller: adminPwController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '운영진 비밀번호',
                border: OutlineInputBorder(),
              ),
            ),

          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _toggleAdminLogin,
            icon: Icon(isAdmin ? Icons.lock_open : Icons.verified_user,
                color: Colors.black),
            label: Text(
              isAdmin ? '운영진 로그인 해제' : '운영진 로그인',
              style: const TextStyle(color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown[100],
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }
}
