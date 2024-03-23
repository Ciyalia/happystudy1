import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScreenCalendar(
        onEventAdded: (String title, DateTime date, String targetTime) {},
        onEventClicked: (String title, DateTime date, String targetTime) {},
      ),
    );
  }
}

class ScreenCalendar extends StatefulWidget {
  final void Function(String title, DateTime date, String targetTime)
      onEventAdded;
  final void Function(String title, DateTime date, String targetTime)
      onEventClicked;

  const ScreenCalendar({
    Key? key,
    required this.onEventAdded,
    required this.onEventClicked,
  }) : super(key: key);

  @override
  ScreenCalendarState createState() => ScreenCalendarState();
}

class ScreenCalendarState extends State<ScreenCalendar> {
  late DateTime _selectedDate;
  final List<Map<String, dynamic>> _events = [];
  late Timer _timer;
  late int _targetSeconds;
  Map<DateTime, double> dailyTimerData = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Timer logic
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _addEvent(String title, DateTime date, String targetTime) {
    setState(() {
      _events.add({
        'title': title,
        'date': date,
        'targetTime': targetTime,
      });
    });
  }

  void _deleteEvent(int index) {
    setState(() {
      _events.removeAt(index);
    });
  }

  void _startTimer(String title, DateTime date, String targetTime) {
    _targetSeconds = _calculateSeconds(targetTime);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimerPage(targetSeconds: _targetSeconds),
      ),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_targetSeconds <= 0) {
          timer.cancel();
        } else {
          _targetSeconds--;
        }
      });
    });
  }

  int _calculateSeconds(String targetTime) {
    final parts = targetTime.split(' ');
    final hours = int.parse(parts[0].replaceAll('h', ''));
    final minutes = int.parse(parts[1].replaceAll('m', ''));
    final seconds = int.parse(parts[2].replaceAll('s', ''));
    return (hours * 3600) + (minutes * 60) + seconds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: CalendarPage(
                  selectedDate: _selectedDate,
                  events: _events,
                  onDateSelected: (DateTime date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),
              )
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Container(
                margin: const EdgeInsets.only(top: 490),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Task',
                        style: GoogleFonts.lato(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _events.isEmpty ? 1 : _events.length,
                        itemBuilder: (context, index) {
                          if (_events.isEmpty) {
                            return Center(
                              child: Column(
                                children: [
                                  const SizedBox(height: 2),
                                  Image.asset(
                                    'assets/images/Logo.png',
                                    width: 65,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  const Text(
                                    'Your task is still empty, try clicking',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  const Text('the "+" to add your task.'),
                                ],
                              ),
                            );
                          } else {
                            final event = _events[index];
                            if (_selectedDate.year == event['date'].year &&
                                _selectedDate.month == event['date'].month &&
                                _selectedDate.day == event['date'].day) {
                              return EventItem(
                                event: event,
                                onDelete: () => _deleteEvent(index),
                                onStart: () => _startTimer(event['title'],
                                    event['date'], event['targetTime']),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0, bottom: 20),
              child: MyCustomButton(
                onEventAdded: _addEvent,
                selectedDate: _selectedDate,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EventItem extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onDelete;
  final VoidCallback onStart;

  const EventItem({
    Key? key,
    required this.event,
    required this.onDelete,
    required this.onStart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String targetTime = event['targetTime'];

    return GestureDetector(
      onTap: onStart,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.black),
            bottom: BorderSide(color: Colors.black),
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              event['title'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ' $targetTime',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: onDelete,
              iconSize: 25,
            ),
          ],
        ),
      ),
    );
  }
}

class MyCustomButton extends StatelessWidget {
  final Function(String, DateTime, String) onEventAdded;
  final DateTime selectedDate;

  const MyCustomButton({
    Key? key,
    required this.onEventAdded,
    required this.selectedDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 48, 64, 41),
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.all(0.5),
      child: IconButton(
        icon: const Icon(
          Icons.add,
          color: Color.fromARGB(255, 255, 255, 255),
          size: 36,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewEventPage(
                onEventAdded: onEventAdded,
                selectedDate: selectedDate,
              ),
            ),
          );
        },
      ),
    );
  }
}

class CalendarPage extends StatelessWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>> events;
  final ValueChanged<DateTime> onDateSelected;

  const CalendarPage({
    Key? key,
    required this.selectedDate,
    required this.events,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 5, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 1),
            child: TableCalendar(
              focusedDay: selectedDate,
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              calendarFormat: CalendarFormat.month,
              onFormatChanged: (format) {},
              startingDayOfWeek: StartingDayOfWeek.sunday,
              daysOfWeekVisible: true,
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: Color.fromARGB(255, 62, 78, 47),
                  shape: BoxShape.rectangle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.rectangle,
                  border: Border.all(
                    color: const Color.fromARGB(255, 62, 78, 47),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                todayTextStyle:
                    const TextStyle(color: Color.fromARGB(255, 62, 78, 47)),
              ),
              selectedDayPredicate: (day) {
                return isSameDay(selectedDate, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                onDateSelected(selectedDay);
              },
              eventLoader: (day) {
                return events
                    .where((event) => isSameDay(event['date'], day))
                    .toList();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NewEventPage extends StatefulWidget {
  final Function(String, DateTime, String) onEventAdded;
  final DateTime selectedDate;

  const NewEventPage({
    Key? key,
    required this.onEventAdded,
    required this.selectedDate,
  }) : super(key: key);

  @override
  NewEventPageState createState() => NewEventPageState();
}

class NewEventPageState extends State<NewEventPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  late DateTime _date;
  TimeOfDay _startTime = TimeOfDay.now();
  Duration _targetTime = const Duration();

  @override
  void initState() {
    super.initState();
    _date = widget.selectedDate;
  }

  Future<void> _scheduleNotification(DateTime scheduledDateTime) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      '2',
      'Scheduled notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    final location = tz.getLocation('Asia/Jakarta');
    final scheduledTime = tz.TZDateTime.from(scheduledDateTime, location);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Scheduled',
      'Time to complete your task',
      scheduledTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'customData',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              onSaved: (value) {
                _title = value ?? '';
              },
            ),
            ListTile(
              title: const Text('Date'),
              trailing: Text('${_date.day}/${_date.month}/${_date.year}'),
            ),
            ListTile(
              title: const Text('Start Time'),
              trailing: Text(_startTime.format(context)),
              onTap: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: _startTime,
                );
                if (pickedTime != null && pickedTime != _startTime) {
                  setState(() {
                    _startTime = pickedTime;
                  });
                }
              },
            ),
            ListTile(
              title: const Text('Target Time'),
              subtitle: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Hours'),
                      onChanged: (value) {
                        final hours = int.tryParse(value) ?? 0;
                        setState(() {
                          _targetTime = Duration(hours: hours);
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Minutes'),
                      onChanged: (value) {
                        final minutes = int.tryParse(value) ?? 0;
                        setState(() {
                          _targetTime =
                              _targetTime + Duration(minutes: minutes);
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Seconds'),
                      onChanged: (value) {
                        final seconds = int.tryParse(value) ?? 0;
                        setState(() {
                          _targetTime =
                              _targetTime + Duration(seconds: seconds);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final targetHours = _targetTime.inHours;
                  final targetMinutes = (_targetTime.inMinutes % 60);
                  final targetSeconds = (_targetTime.inSeconds % 60);
                  final targetTimeString =
                      '${targetHours}h ${targetMinutes}m ${targetSeconds}s';
                  widget.onEventAdded(_title, _date, targetTimeString);
                  final scheduledDateTime = DateTime(
                    _date.year,
                    _date.month,
                    _date.day,
                    _startTime.hour,
                    _startTime.minute,
                  );
                  _scheduleNotification(scheduledDateTime);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class TimerPage extends StatefulWidget {
  final int targetSeconds;

  const TimerPage({Key? key, required this.targetSeconds}) : super(key: key);

  @override
  TimerPageState createState() => TimerPageState();
}

class TimerPageState extends State<TimerPage> {
  late int _elapsedSeconds;
  late String _timerDisplay;
  late double _progressValue;
  late int hours;
  late int minutes;
  late int seconds;
  late Timer _timer;
  late bool _isPlaying;

  @override
  void initState() {
    super.initState();
    _elapsedSeconds = 0;
    _timerDisplay = _formatTime(_elapsedSeconds);
    _progressValue = 0.0;
    hours = widget.targetSeconds ~/ 3600;
    minutes = (widget.targetSeconds % 3600) ~/ 60;
    seconds = widget.targetSeconds % 60;
    _isPlaying = false;

    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    const oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(oneSecond, (timer) {
      setState(() {
        if (_elapsedSeconds < widget.targetSeconds) {
          _elapsedSeconds++;
          _timerDisplay = _formatTime(_elapsedSeconds);
          _progressValue = _elapsedSeconds / widget.targetSeconds;
          hours = (widget.targetSeconds - _elapsedSeconds) ~/ 3600;
          minutes = ((widget.targetSeconds - _elapsedSeconds) % 3600) ~/ 60;
          seconds = (widget.targetSeconds - _elapsedSeconds) % 60;
        } else {
          timer.cancel();

          // Tampilkan dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Times Up"),
                content: const Text("Congratulation!"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        }
      });
    });
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(remainingSeconds)}';
  }

  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  void _toggleTimer() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        if (!_timer.isActive) {
          _startTimer();
        }
      } else {
        _timer.cancel();
      }
    });
  }

  void _restartTimer() {
    setState(() {
      _elapsedSeconds = 0;
      _timerDisplay = _formatTime(_elapsedSeconds);
      _progressValue = 0.0;
      hours = widget.targetSeconds ~/ 3600;
      minutes = (widget.targetSeconds % 3600) ~/ 60;
      seconds = widget.targetSeconds % 60;
    });
    _timer.cancel();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 300,
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 1,
                    child: SizedBox(
                      width: 250,
                      height: 250,
                      child: CustomPaint(
                        painter: CirclePainter(),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 1,
                    child: SizedBox(
                      width: 250,
                      height: 250,
                      child: CustomPaint(
                        painter: ProgressPainter(_progressValue),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _timerDisplay,
                              style: const TextStyle(
                                  fontSize: 40, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _toggleTimer,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                      backgroundColor: const Color.fromARGB(255, 62, 78, 47),
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 60,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _restartTimer,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                      backgroundColor: const Color.fromARGB(255, 134, 149, 123),
                    ),
                    child: const Icon(
                      Icons.restart_alt,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressPainter extends CustomPainter {
  final double progress;

  ProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color.fromARGB(255, 62, 78, 47)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    const double startAngle = -pi / 2;
    final double sweepAngle = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color.fromARGB(255, 224, 224, 224)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
