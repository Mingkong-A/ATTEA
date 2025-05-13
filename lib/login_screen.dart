import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _saveEmail = false;
  bool _autoLogin = false;
  String? _errorMessage;

  Future<void> _login() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('saveEmail', _saveEmail);
      await prefs.setBool('autoLogin', _autoLogin);
      if (_saveEmail) {
        await prefs.setString('savedEmail', email);
      } else {
        await prefs.remove('savedEmail');
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? '로그인 실패';
      });
    }
  }
  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _checkAutoLogin();
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _saveEmail = prefs.getBool('saveEmail') ?? false;
      _autoLogin = prefs.getBool('autoLogin') ?? false;
      if (_saveEmail) {
        _emailController.text = prefs.getString('savedEmail') ?? '';
      }
    });
  }

  void _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final auto = prefs.getBool('autoLogin') ?? false;
    final user = FirebaseAuth.instance.currentUser;

    if (auto && user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: '이메일'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            Row(
              children: [
                Checkbox(
                  value: _saveEmail,
                  onChanged: (value) {
                    setState(() {
                      _saveEmail = value ?? false;
                    });
                  },
                ),
                const Text('아이디 저장'),
                const SizedBox(width: 20),
                Checkbox(
                  value: _autoLogin,
                  onChanged: (value) {
                    setState(() {
                      _autoLogin = value ?? false;
                    });
                  },
                ),
                const Text('자동 로그인'),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _login,
              child: const Text('로그인'),
            ),
            if (_errorMessage?.isNotEmpty ?? false)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: const Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}
