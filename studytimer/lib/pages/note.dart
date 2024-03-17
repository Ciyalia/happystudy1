import 'package:flutter/material.dart';

void main() {
  runApp(NotesApp());
}

class NotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> notes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              _onBackButtonPressed(context);
            },
          ),
          title: Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Text(
              'Notes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                color: const Color.fromARGB(255, 62, 78, 47),
              ),
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/Logo.png', // Path to your image
                    width: 130,
                    height: 130,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Your note is still empty, try clicking',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: const Color.fromARGB(255, 62, 78, 47),
                    ),
                  ),
                  Text(
                    'the "+" to add your note.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: const Color.fromARGB(255, 62, 78, 47),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding:
                  EdgeInsets.only(top: 20.0), // Menambahkan jarak dari atas
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey),
                      bottom: BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      notes[index].title,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      notes[index].formattedDate(),
                      style: TextStyle(fontSize: 14.0, color: Colors.grey),
                    ),
                    onTap: () {
                      _navigateToNoteDetail(context, notes[index]);
                    },
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 19.0), // Padding from both sides
                  ),
                );
              },
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30.0, right: 10.0),
        child: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 62, 78, 47),
          onPressed: () {
            _navigateToAddNoteScreen(context);
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          shape: CircleBorder(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _navigateToAddNoteScreen(BuildContext context) async {
    final newNote = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteEditPage()),
    );
    if (newNote != null) {
      setState(() {
        notes.add(newNote);
      });
    }
  }

  void _navigateToNoteDetail(BuildContext context, Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteDetailPage(note: note)),
    );

    if (result != null && result is Note) {
      int index = notes.indexWhere((element) => element.id == result.id);
      if (index != -1) {
        setState(() {
          notes[index] = result;
        });
      }
    }
  }

  void _onBackButtonPressed(BuildContext context) {
    Navigator.pop(context);
  }
}

class Note {
  int id;
  String title;
  String text;
  DateTime dateCreated;

  Note({
    required this.id,
    required this.title,
    required this.text,
    required this.dateCreated,
  });

  String formattedDate() {
    return '${_getWeekDay(dateCreated.weekday)} ${dateCreated.day} ${_getMonth(dateCreated.month)}';
  }

  String _getWeekDay(int weekday) {
    switch (weekday) {
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

  String _getMonth(int month) {
    switch (month) {
      case DateTime.january:
        return 'January';
      case DateTime.february:
        return 'February';
      case DateTime.march:
        return 'March';
      case DateTime.april:
        return 'April';
      case DateTime.may:
        return 'May';
      case DateTime.june:
        return 'June';
      case DateTime.july:
        return 'July';
      case DateTime.august:
        return 'August';
      case DateTime.september:
        return 'September';
      case DateTime.october:
        return 'October';
      case DateTime.november:
        return 'November';
      case DateTime.december:
        return 'December';
      default:
        return '';
    }
  }
}

class NoteEditPage extends StatefulWidget {
  @override
  _NoteEditPageState createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          // Mengganti tombol checklist dengan tombol Save
          TextButton(
            onPressed: () {
              _saveNote();
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          // Menambahkan tombol Cancel
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Kembali ke halaman sebelumnya
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _textController,
              maxLines: null, // Allows multiple lines
              decoration: InputDecoration(
                labelText: 'Description',
                border: InputBorder.none, // Removes the bottom line
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveNote() {
    final title = _titleController.text;
    final text = _textController.text;
    if (title.isNotEmpty) {
      final newNote = Note(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        text: text,
        dateCreated: DateTime.now(),
      );
      Navigator.pop(context, newNote);
    } else {
      // Handle empty fields
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please enter a title.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }
}

class NoteDetailPage extends StatefulWidget {
  final Note note;

  NoteDetailPage({required this.note});

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _textController = TextEditingController(text: widget.note.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              _saveNote();
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteNote();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _textController,
              maxLines: null, // Allows multiple lines
              decoration: InputDecoration(
                labelText: 'Description',
                border: InputBorder.none, // Removes the bottom line
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveNote() {
    final title = _titleController.text;
    final text = _textController.text;
    if (title.isNotEmpty) {
      final updatedNote = widget.note.copyWith(
        title: title,
        text: text,
      );
      Navigator.pop(context, updatedNote);
    } else {
      // Handle empty fields
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please enter a title.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _deleteNote() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Note'),
          content: Text('Are you sure you want to delete this note?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }
}

extension CopyWithExtension on Note {
  Note copyWith({
    int? id,
    String? title,
    String? text,
    DateTime? dateCreated,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      dateCreated: dateCreated ?? this.dateCreated,
    );
  }
}
