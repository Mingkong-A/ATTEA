import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

DateTime _normalizeDate(DateTime date) {
  return DateTime.utc(date.year, date.month, date.day);
}

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<String>> _events = {
    DateTime.utc(2025, 5, 14): ['베이킹 기획 회의'],
    DateTime.utc(2025, 5, 17): ['정기 베이킹 3회차'],
  };

  List<String> _getEventsForDay(DateTime day) {
    return _events[_normalizeDate(day)] ?? [];
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
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          eventLoader: _getEventsForDay,
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.brown,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.brown,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: _getEventsForDay(_selectedDay ?? _focusedDay)
                .map((event) => ListTile(
              title: Text(event),
              leading: const Icon(Icons.event_note),
            ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
