import 'package:flutter/material.dart';
import 'convenience/timer_screen.dart';

class ConvenienceTab extends StatelessWidget {
  const ConvenienceTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_FeatureItem> features = [
      _FeatureItem(
        title: '타이머',
        icon: Icons.timer,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CountdownTimerScreen()),
          );
        },
      ),

      _FeatureItem(title: '재고정리', icon: Icons.inventory, onTap: () {}),
    ];

    final double spacing = 16.0;
    final double itemWidth = (MediaQuery.of(context).size.width - (3 * spacing)) / 2;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(spacing),
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: features.map((feature) {
          return GestureDetector(
            onTap: feature.onTap,
            child: Container(
              width: itemWidth,
              height: itemWidth,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.brown.shade100, Colors.brown.shade200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.shade100,
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(feature.icon, size: 48, color: Colors.brown[900]),
                  const SizedBox(height: 12),
                  Text(
                    feature.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FeatureItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  _FeatureItem({required this.title, required this.icon, required this.onTap});
}
