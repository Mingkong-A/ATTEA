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
  final TextEditingController _adminPwController = TextEditingController();
  bool _saveEmail = false;
  bool _autoLogin = false;
  bool _isAdminLogin = false; //운영진 로그인
  String? _errorMessage;

  Future<void> _login() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // 운영진 비밀번호 검증
      if (_isAdminLogin) {
        if (_adminPwController.text.trim() != 'admin1234') {
          setState(() {
            _errorMessage = '운영진 비밀번호가 틀렸습니다.';
          });
          return;
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('saveEmail', _saveEmail);
      await prefs.setBool('autoLogin', _autoLogin);
      await prefs.setBool('isAdmin', _isAdminLogin);
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
      print('로그인 실패 코드: ${e.code}'); // 추가
      setState(() {
        if (e.code == 'wrong-password' || e.code == 'invalid-credential' || e.code == 'user-not-found') {
          _errorMessage = '이메일 또는 비밀번호가 올바르지 않습니다.';
        } else {
          _errorMessage = e.message ?? '로그인 실패';
        }
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
      backgroundColor: const Color(0xFFFFF8E1), // 크림색 배경
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/ATTEA.png',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
              const SizedBox(height: 16),
              const Text(
                'ATTEA',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'e-mail',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

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
              Row(
                children: [
                  Checkbox(
                    value: _isAdminLogin,
                    onChanged: (value) {
                      setState(() {
                        _isAdminLogin = value ?? false;
                      });
                    },
                  ),
                  const Text('운영진으로 로그인'),
                ],
              ),
              if (_isAdminLogin)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _adminPwController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '운영진 비밀번호',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.brown, width: 2),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),

              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: Colors.white,
                ),
                child: const Text('로그인', style: TextStyle(fontSize: 18)),
              ),
              if (_errorMessage?.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black, // 텍스트 색상
                ),
                child: const Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
