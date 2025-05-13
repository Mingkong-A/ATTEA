import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _errorMessage = '';

  Future<void> _signup() async {
    final name = _nameController.text.trim();
    final id = _idController.text.trim();
    final email = _emailController.text.trim();
    final pw = _passwordController.text.trim();
    final pwCheck = _confirmPasswordController.text.trim();

    if (pw != pwCheck) {
      setState(() {
        _errorMessage = '비밀번호가 일치하지 않습니다.';
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('members')
          .doc(name)
          .get();

      if (!doc.exists || doc['id'] != id) {
        setState(() {
          _errorMessage = '동아리원 정보가 없거나 식별자가 틀렸습니다.';
        });
        return;
      }

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pw);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': name,
        'email': email,
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? '회원가입 실패';
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon) : null,
          labelText: label,
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.brown, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text('회원가입'),
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
        ClipOval(
        child: Image.asset(
        'assets/images/ATTEA.png',
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _nameController,
              label: '이름',
              icon: Icons.person,
            ),
            _buildTextField(
              controller: _idController,
              label: '개인 식별자',
              icon: Icons.badge,
            ),
            _buildTextField(
              controller: _emailController,
              label: '이메일',
              icon: Icons.email,
            ),
            _buildTextField(
              controller: _passwordController,
              label: '비밀번호',
              icon: Icons.lock,
              obscure: true,
            ),
            _buildTextField(
              controller: _confirmPasswordController,
              label: '비밀번호 확인',
              icon: Icons.lock_outline,
              obscure: true,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _signup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                minimumSize: const Size.fromHeight(48),
                foregroundColor: Colors.white,
              ),
              child: const Text('가입하기'),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
