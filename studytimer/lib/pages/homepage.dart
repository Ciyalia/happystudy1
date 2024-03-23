import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:studytimer/pages/calenderpage.dart';
import 'package:studytimer/pages/happy.dart';
import 'package:studytimer/pages/note.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Map<String, dynamic>> _events = [];

  late Timer _timer;
  int _start = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), _updateTimer);
  }

  void _updateTimer(Timer timer) {
    if (_isPlaying && _start > 0) {
      setState(() {
        _start--;
      });
    } else if (_isPlaying && _start == 0) {
      _timer.cancel();
      _isPlaying = false;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Timer Finished'),
            content:
                const Text('Congratulations! You have completed your task.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _startTimer(int targetSeconds) {
    setState(() {
      _start = targetSeconds;
      _isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    String greeting = _getGreeting();
    Duration duration = Duration(seconds: _start);
    int hours = duration.inHours.remainder(24);
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);
    double progress = _start / 60.0;

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: [
              _buildHomeScreen(_events, progress, hours, minutes, seconds),
              ScreenCalendar(
                onEventAdded: (title, date, targetTime) => _addEvent(title,
                    date, targetTime as TimeOfDay, targetTime as TimeOfDay),
                onEventClicked: (title, date, endTime) {},
              ),
              const ThankYouPage(),
            ],
          ),
          Positioned(
            bottom: 10,
            left: MediaQuery.of(context).size.width / 2 - 80,
            child: Visibility(
              visible: _selectedIndex == 0,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isPlaying = !_isPlaying;
                        if (_isPlaying) {
                          _timer = Timer.periodic(
                            const Duration(seconds: 1),
                            _updateTimer,
                          );
                        } else {
                          _timer.cancel();
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(15),
                      backgroundColor: const Color.fromARGB(255, 62, 78, 47),
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      _showTimerDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(15),
                      backgroundColor: const Color.fromARGB(255, 62, 78, 47),
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 20,
            child: Visibility(
              visible: _selectedIndex == 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 62, 78, 47)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ready to be productive?',
                    style: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 128, 149, 102)),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 65,
            right: 16,
            child: Visibility(
              visible: _selectedIndex == 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 50,
                  height: 50,
                  color: const Color.fromARGB(255, 62, 78, 47),
                  child: IconButton(
                    icon: const Icon(Icons.assignment_outlined),
                    iconSize: 30,
                    color: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotesPage()),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
        child: GNav(
          color: const Color.fromARGB(255, 62, 78, 47),
          activeColor: const Color.fromARGB(255, 62, 78, 47),
          tabBackgroundColor: const Color.fromARGB(255, 206, 222, 189),
          gap: 8,
          padding: const EdgeInsets.all(16),
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          tabs: const [
            GButton(
              icon: Icons.home_filled,
              text: 'Home',
            ),
            GButton(
              icon: Icons.edit_calendar,
              text: 'Calendar',
            ),
            GButton(
              icon: Icons.logout,
              text: 'Logout',
            ),
          ],
        ),
      ),
    );
  }

  void _showTimerDialog(BuildContext context) {
    int hours = 0;
    int minutes = 0;
    int seconds = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Set Timer"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  hours = int.tryParse(value) ?? 0;
                },
                decoration: const InputDecoration(
                  labelText: "Hours",
                ),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  minutes = int.tryParse(value) ?? 0;
                },
                decoration: const InputDecoration(
                  labelText: "Minutes",
                ),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  seconds = int.tryParse(value) ?? 0;
                },
                decoration: const InputDecoration(
                  labelText: "Seconds",
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _startTimer(hours * 3600 + minutes * 60 + seconds);
                Navigator.of(context).pop();
              },
              child: const Text("Start"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _addEvent(
    String title,
    DateTime date,
    TimeOfDay startTime,
    TimeOfDay endTime,
  ) {
    setState(() {
      _events.add({
        'title': title,
        'date': date,
        'startTime': '${startTime.hour}:${startTime.minute}',
        'endTime': '${endTime.hour}:${endTime.minute}',
      });
    });
  }

  Widget _buildHomeScreen(List<Map<String, dynamic>> events, double progress,
      int hours, int minutes, int seconds) {
    String dateString = _getDateString(DateTime.now());

    return Center(
      child: SizedBox(
        width: 300,
        height: 300,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Lingkaran border
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
            // Lingkaran progres
            Positioned(
              top: 1,
              child: SizedBox(
                width: 250,
                height: 250,
                child: CustomPaint(
                  painter: ProgressPainter(progress),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                            fontSize: 40, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        dateString,
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
    );
  }

  String _getDateString(DateTime date) {
    String day = _getDayString(date.weekday);
    String dayOfMonth = date.day.toString();
    String month = _getMonthString(date.month);
    return '$day $dayOfMonth $month';
  }

  String _getDayString(int dayIndex) {
    switch (dayIndex) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  String _getMonthString(int monthIndex) {
    switch (monthIndex) {
      case DateTime.january:
        return 'Jan';
      case DateTime.february:
        return 'Feb';
      case DateTime.march:
        return 'Mar';
      case DateTime.april:
        return 'Apr';
      case DateTime.may:
        return 'May';
      case DateTime.june:
        return 'Jun';
      case DateTime.july:
        return 'Jul';
      case DateTime.august:
        return 'Aug';
      case DateTime.september:
        return 'Sep';
      case DateTime.october:
        return 'Oct';
      case DateTime.november:
        return 'Nov';
      case DateTime.december:
        return 'Dec';
      default:
        return '';
    }
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning!';
    } else if (hour < 17) {
      return 'Good afternoon!';
    } else {
      return 'Good evening!';
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

class CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 128, 149, 102)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class ProgressPainter extends CustomPainter {
  final double progress;

  ProgressPainter(this.progress); // Hapus named parameter dan required keyword

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 6;
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double arcAngle = 2 * progress * math.pi;

    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 62, 78, 47)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      arcAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
