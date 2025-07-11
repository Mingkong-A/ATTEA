import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'common_dialog.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String name;
  final String description;
  final String? subtitle;
  final DocumentReference recipeRef;

  const RecipeDetailScreen({
    super.key,
    required this.name,
    required this.description,
    this.subtitle,
    required this.recipeRef,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadAdminStatus();
  }

  Future<void> _loadAdminStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isAdmin = prefs.getBool('isAdmin') ?? false;
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  Future<void> _deleteRecipe() async {
    final confirm = await showConfirmDialog(
      context: context,
      title: '레시피 삭제',
      content: '정말 이 레시피를 삭제하시겠습니까?',
      confirmText: '삭제',
    );

    if (confirm == true) {
      await widget.recipeRef.delete();
      Navigator.pop(context); // 삭제 후 이전 화면으로
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          '레시피 보기',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: '레시피 삭제',
              onPressed: _deleteRecipe,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                widget.subtitle!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              widget.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.8,
                letterSpacing: 0.2,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
