import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ooriba/services/admin/event_service.dart';
import 'package:table_calendar/table_calendar.dart';

class UpcomingEventsPage extends StatefulWidget {
  @override
  _UpcomingEventsPageState createState() => _UpcomingEventsPageState();
}

class _UpcomingEventsPageState extends State<UpcomingEventsPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  Map<DateTime, List<Map<String, dynamic>>> _holidays = {};

  final EventService _eventService = EventService();

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _loadHolidays();
  }

  Future<void> _loadEvents() async {
    Map<DateTime, List<Map<String, dynamic>>> events =
        await _eventService.loadEvents();
    setState(() {
      _events = events;
    });
  }

  Future<void> _loadHolidays() async {
    Map<DateTime, List<Map<String, dynamic>>> holidays =
        await _eventService.loadHolidays();
    setState(() {
      _holidays = holidays;
    });
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    DateTime dayWithoutTime = DateTime(day.year, day.month, day.day);
    List<Map<String, dynamic>> events = _events[dayWithoutTime] ?? [];
    List<Map<String, dynamic>> holidays = _holidays[dayWithoutTime] ?? [];
    return [...events, ...holidays];
  }

  Future<void> _addEvent(String event) async {
    if (_selectedDay != null) {
      DocumentReference docRef =
          await _eventService.addEvent(_selectedDay!, event);
      setState(() {
        DateTime selectedDayWithoutTime = DateTime(
            _selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
        if (_events[selectedDayWithoutTime] == null) {
          _events[selectedDayWithoutTime] = [];
        }
        _events[selectedDayWithoutTime]!.add({
          'id': docRef.id,
          'event': event,
        });
      });
    }
  }

  Future<void> _addHoliday(String holiday) async {
    if (_selectedDay != null) {
      DocumentReference docRef =
          await _eventService.addHoliday(_selectedDay!, holiday);
      setState(() {
        DateTime selectedDayWithoutTime = DateTime(
            _selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
        if (_holidays[selectedDayWithoutTime] == null) {
          _holidays[selectedDayWithoutTime] = [];
        }
        _holidays[selectedDayWithoutTime]!.add({
          'id': docRef.id,
          'holiday': holiday,
        });
      });
    }
  }

  Future<void> _deleteEvent(String eventId, DateTime date) async {
    await _eventService.deleteEvent(eventId);
    setState(() {
      DateTime dateWithoutTime = DateTime(date.year, date.month, date.day);
      _events[dateWithoutTime]!.removeWhere((event) => event['id'] == eventId);
      if (_events[dateWithoutTime]!.isEmpty) {
        _events.remove(dateWithoutTime);
      }
    });
  }

  Future<void> _deleteHoliday(String holidayId, DateTime date) async {
    await _eventService.deleteHoliday(holidayId);
    setState(() {
      DateTime dateWithoutTime = DateTime(date.year, date.month, date.day);
      _holidays[dateWithoutTime]!
          .removeWhere((holiday) => holiday['id'] == holidayId);
      if (_holidays[dateWithoutTime]!.isEmpty) {
        _holidays.remove(dateWithoutTime);
      }
    });
  }

  void _showAddEventDialog() {
    final TextEditingController _eventController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Event'),
          content: TextField(
            controller: _eventController,
            decoration: const InputDecoration(labelText: 'Event'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _addEvent(_eventController.text);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAddHolidayDialog() {
    final TextEditingController _holidayController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Holiday'),
          content: TextField(
            controller: _holidayController,
            decoration: const InputDecoration(labelText: 'Holiday'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _addHoliday(_holidayController.text);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Events'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getEventsForDay,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: events.map((event) {
                      Map<String, dynamic> eventMap =
                          event as Map<String, dynamic>;
                      bool isHoliday = eventMap.containsKey('holiday');
                      return Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isHoliday ? Colors.red : Colors.blue,
                        ),
                      );
                    }).toList(),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: _showAddEventDialog,
            child: const Text('Add Event'),
          ),
          ElevatedButton(
            onPressed: _showAddHolidayDialog,
            child: const Text('Add Holiday'),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView(
              children:
                  _getEventsForDay(_selectedDay ?? _focusedDay).map((event) {
                Map<String, dynamic> eventMap = event as Map<String, dynamic>;
                return ListTile(
                  title: Text(eventMap['event'] ?? eventMap['holiday']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      if (eventMap.containsKey('event')) {
                        _deleteEvent(
                            eventMap['id'], _selectedDay ?? _focusedDay);
                      } else {
                        _deleteHoliday(
                            eventMap['id'], _selectedDay ?? _focusedDay);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
