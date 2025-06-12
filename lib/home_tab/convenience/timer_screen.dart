import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class CountdownTimerScreen extends StatefulWidget {
  const CountdownTimerScreen({super.key});

  @override
  State<CountdownTimerScreen> createState() => _CountdownTimerScreenState();
}

class _CountdownTimerScreenState extends State<CountdownTimerScreen> with WidgetsBindingObserver {
  int _totalSeconds = 0;
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _isRunning = false;
  DateTime? _pauseTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTimerState();
  }

  Future<void> _loadTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTotal = prefs.getInt('totalSeconds') ?? 0;
    final savedRemaining = prefs.getInt('remainingSeconds') ?? 0;
    final lastPaused = prefs.getInt('pauseTimestamp');
    final wasRunning = prefs.getBool('isRunning') ?? false;

    if (lastPaused != null && wasRunning) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = ((now - lastPaused) / 1000).floor();
      final adjustedRemaining = max(0, savedRemaining - elapsed);
      setState(() {
        _totalSeconds = savedTotal;
        _remainingSeconds = adjustedRemaining;
        _isRunning = adjustedRemaining > 0;
      });
      if (_isRunning) _startTimer();
    } else {
      setState(() {
        _totalSeconds = savedTotal;
        _remainingSeconds = savedRemaining;
        _isRunning = false;
      });
    }
  }

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalSeconds', _totalSeconds);
    await prefs.setInt('remainingSeconds', _remainingSeconds);
    await prefs.setBool('isRunning', _isRunning);
    if (_isRunning) {
      await prefs.setInt('pauseTimestamp', DateTime.now().millisecondsSinceEpoch);
    }
  }

  void _startTimer() {
    if (_remainingSeconds <= 0) return;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
        setState(() => _isRunning = false);
      } else {
        setState(() => _remainingSeconds--);
        _saveTimerState();
      }
    });
    setState(() => _isRunning = true);
    _saveTimerState();
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
    _saveTimerState();
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _totalSeconds;
      _isRunning = false;
    });
    _saveTimerState();
  }

  void _adjustTimeFromDrag(double delta) {
    if (_isRunning) return;
    final deltaMinutes = (delta / -10).round();
    final newMinutes = ((_totalSeconds / 60).round() + deltaMinutes).clamp(0, 999);
    final newSeconds = newMinutes * 60;
    setState(() {
      _totalSeconds = newSeconds;
      _remainingSeconds = newSeconds;
    });
    _saveTimerState();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double _progress() => _totalSeconds == 0 ? 0 : _remainingSeconds / _totalSeconds;

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _saveTimerState();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _isRunning) {
      _saveTimerState();
    } else if (state == AppLifecycleState.resumed) {
      _loadTimerState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('타이머'),
        centerTitle: true,
        backgroundColor: Colors.brown,
      ),
      backgroundColor: const Color(0xFFFFF8E1),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onVerticalDragUpdate: (details) => _adjustTimeFromDrag(details.delta.dy),
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFFFFF3E0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: CustomPaint(
                  painter: _TimerPainter(_progress()),
                  child: Center(
                    child: Text(
                      _formatTime(_remainingSeconds),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                        shadows: [
                          Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 2)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? null : _startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('시작'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isRunning ? _stopTimer : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('중지'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _resetTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('초기화'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _TimerPainter extends CustomPainter {
  final double progress;
  _TimerPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = min(size.width / 2, size.height / 2) - 6;

    final backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;

    final foregroundPaint = Paint()
      ..shader = SweepGradient(
        colors: [Colors.green, Colors.lightGreenAccent, Colors.green],
        startAngle: 0.0,
        endAngle: 2 * pi,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
