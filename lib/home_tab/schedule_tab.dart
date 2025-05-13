import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final _auth = FirebaseAuth.instance;
  Set<String> _participatingScheduleIds = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadParticipations();
  }

  Future<void> _loadParticipations() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final schedules = await FirebaseFirestore.instance.collection('schedules').get();
    final participatingIds = <String>{};

    for (var doc in schedules.docs) {
      final participant = await doc.reference.collection('participants').doc(uid).get();
      if (participant.exists && participant['participating'] == true) {
        participatingIds.add(doc.id);
      }
    }

    setState(() {
      _participatingScheduleIds = participatingIds;
    });
  }

  Future<void> _showAddEventDialog(DateTime date) async {
    final controller = TextEditingController();
    bool isRegular = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('${date.toLocal().toString().split(" ")[0]} 일정 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: '일정 내용'),
              ),
              CheckboxListTile(
                title: const Text('정기 베이킹 일정'),
                value: isRegular,
                onChanged: (val) {
                  setState(() => isRegular = val ?? false);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                final event = controller.text.trim();
                if (event.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('schedules').add({
                    'date': date.toIso8601String().split("T")[0],
                    'event': event,
                    'isRegular': isRegular,
                    'createdAt': Timestamp.now(),
                  });
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('등록'),
            ),
          ],
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _eventStream(DateTime date) {
    final dayString = date.toIso8601String().split("T")[0];
    return FirebaseFirestore.instance
        .collection('schedules')
        .where('date', isEqualTo: dayString)
        .snapshots();
  }

  Future<bool> _isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isAdmin') ?? false;
  }

  Future<void> _showParticipationDialog(String scheduleId, bool current) async {
    final uid = _auth.currentUser?.uid;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final name = userDoc.data()?['name'] ?? _auth.currentUser?.email ?? '익명';
    if (uid == null) return;

    if (current) {
      await FirebaseFirestore.instance
          .collection('schedules')
          .doc(scheduleId)
          .collection('participants')
          .doc(uid)
          .delete();
    } else {
      await FirebaseFirestore.instance
          .collection('schedules')
          .doc(scheduleId)
          .collection('participants')
          .doc(uid)
          .set({
        'name': name,
        'participating': true,
        'timestamp': Timestamp.now(),
      });
    }

    await _loadParticipations();
  }

  Future<void> _showDetailOverlay(String event, String date, String scheduleId) async {
    final isAdmin = await _isAdmin();
    if (!isAdmin) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('schedules')
        .doc(scheduleId)
        .collection('participants')
        .where('participating', isEqualTo: true)
        .get();

    final participants = snapshot.docs;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('일정 세부정보'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('일정: $event'),
              const SizedBox(height: 8),
              Text('날짜: $date'),
              const SizedBox(height: 16),
              const Text('참여자 명단:'),
              ...participants.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final time = (data['timestamp'] as Timestamp).toDate();
                final formatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(time);
                return Text('${data['name']} - $formatted');
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          )
        ],
      ),
    );
  }

  void _handleRegularScheduleClick(String docId) async {
    final current = _participatingScheduleIds.contains(docId);
    await _showParticipationDialog(docId, current);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) async {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });

            if (await _isAdmin()) {
              _showAddEventDialog(selectedDay);
            }
          },
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.brown,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.deepOrange,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _selectedDay == null
              ? const Center(child: Text('날짜를 선택하세요.'))
              : StreamBuilder<QuerySnapshot>(
            stream: _eventStream(_selectedDay!),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('오류 발생'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(child: Text('일정이 없습니다.'));
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final docId = docs[index].id;
                  final isRegular = data['isRegular'] ?? false;
                  final isParticipating = _participatingScheduleIds.contains(docId);

                  return ListTile(
                    title: Text(data['event'] ?? '내용 없음'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['date'] ?? ''),
                        if (isRegular && isParticipating)
                          const Text(
                            '참여 중 ✅',
                            style: TextStyle(color: Colors.green),
                          ),
                      ],
                    ),
                    leading: const Icon(Icons.event_note),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isRegular)
                          IconButton(
                            icon: const Icon(Icons.how_to_reg),
                            onPressed: () => _handleRegularScheduleClick(docId),
                          ),
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () => _showDetailOverlay(data['event'], data['date'], docId),
                        ),
                      ],
                    ),
                    onTap: null,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
