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
        builder: (context) => const CountdownTimerScreen(),
      ),
      _FeatureItem(title: '재고정리', icon: Icons.inventory, builder: null),
    ];

    final double spacing = 16.0;
    final double itemWidth =
        (MediaQuery.of(context).size.width - (3 * spacing)) / 2;

    return Container(
      color: const Color(0xFFFCF5FD),
      padding: EdgeInsets.all(spacing),
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: features.map((feature) {
          return _AnimatedFeatureBox(
            title: feature.title,
            icon: feature.icon,
            width: itemWidth,
            height: itemWidth,
            onTap: feature.builder != null
                ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: feature.builder!),
              );
            }
                : null,
          );
        }).toList(),
      ),
    );
  }
}

class _FeatureItem {
  final String title;
  final IconData icon;
  final WidgetBuilder? builder;

  _FeatureItem({required this.title, required this.icon, required this.builder});
}

class _AnimatedFeatureBox extends StatefulWidget {
  final String title;
  final IconData icon;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const _AnimatedFeatureBox({
    super.key,
    required this.title,
    required this.icon,
    required this.width,
    required this.height,
    this.onTap,
  });

  @override
  State<_AnimatedFeatureBox> createState() => _AnimatedFeatureBoxState();
}

class _AnimatedFeatureBoxState extends State<_AnimatedFeatureBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 0.2, // 움직임을 더 크게
    );
    _animation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    if (widget.onTap != null) widget.onTap!();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.width,
          height: widget.height,
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
              Icon(widget.icon, size: 48, color: Colors.brown[900]),
              const SizedBox(height: 12),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
