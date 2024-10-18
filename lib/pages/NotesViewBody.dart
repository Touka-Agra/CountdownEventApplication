import 'package:countdown_event/Customs/MyAppBar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../provider/NotesProvider.dart';

class NotesViewBody extends StatefulWidget {
  const NotesViewBody({super.key});

  @override
  _NotesViewBodyState createState() => _NotesViewBodyState();
}

class _NotesViewBodyState extends State<NotesViewBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  DateTime? selectedDateTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    // notesProvider.fetchNotes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _editNoteAt(BuildContext context, int index) {
    final provider = Provider.of<NotesProvider>(context, listen: false);
    _titleController.text = provider.activeNotes[index]['title'];
    _subtitleController.text = provider.activeNotes[index]['subtitle'];
    selectedDateTime = provider.activeNotes[index]['time'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Use StatefulBuilder to manage the dialog's internal state
            return AlertDialog(
              backgroundColor: const Color(0xFF1C1C1C),
              title: const Text('Edit Note',
                  style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    cursorColor: Colors.blue,
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  TextField(
                    cursorColor: Colors.blue,
                    controller: _subtitleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Subtitle',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      selectedDateTime != null
                          ? DateFormat('MMM d, y - hh:mm a')
                              .format(selectedDateTime!)
                          : 'Select Date & Time',
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: IconButton(
                      icon:
                          const Icon(Icons.calendar_today, color: Colors.white),
                      onPressed: () async {
                        await _pickDateTime(context);
                        setState(
                            () {}); // Ensure the dialog is rebuilt when the date is changed
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    provider.editNoteAt(
                      index,
                      _titleController.text,
                      _subtitleController.text,
                      selectedDateTime ?? provider.activeNotes[index]['time'],
                    );
                    _titleController.clear();
                    _subtitleController.clear();
                    selectedDateTime = null;
                    Navigator.pop(context);
                  },
                  child: const Text('Update',
                      style: TextStyle(color: Colors.blue)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: getAppBar(
        context: context,
        title: "My Notes",
        tabBar: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Active Tasks'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active Tasks Tab
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: (notesProvider.activeNotes.isEmpty)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //lottie
                      Text("You Have No Tasks Yet",
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Click Add",
                              style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          Icon(
                            Icons.add,
                            color: Colors.grey[500],
                            size: 25,
                          )
                        ],
                      )
                    ],
                  )
                : ListView.builder(
                    itemCount: notesProvider.activeNotes.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onDoubleTap: () => _editNoteAt(context, index),
                        child: Dismissible(
                          direction: DismissDirection.endToStart,
                          background: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  colors: [Colors.redAccent, Colors.red[800]!],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.amber,
                                      blurRadius: 10,
                                      offset: Offset(0, 3)),
                                ]),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.delete,
                                      color: Colors.white, size: 28),
                                  SizedBox(width: 8),
                                  Text(
                                    "Delete",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          key: Key(index.toString()),
                          onDismissed: (direction) {
                            notesProvider.deleteNoteAt(index);

                            // Optionally show a snackbar or some confirmation here
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius:
                                    30, // Reduced radius for a smaller avatar
                                backgroundColor:
                                    Color.fromARGB(255, 123, 147, 180),
                                child: Text(
                                  "${DateFormat('hh:mm a').format((notesProvider.activeNotes[index]['time'] as DateTime) // Ensure it's a DateTime
                                      )}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10, // Reduced font size for time
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 123, 176, 180),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color:
                                            Color.fromARGB(255, 123, 176, 180)),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8.0, right: 12),
                                        child: Text(
                                          DateFormat('MMM d, y').format(
                                              notesProvider.activeNotes[index]
                                                  ['time']),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white70,
                                              fontSize: 12,
                                              shadows: [
                                                Shadow(
                                                    color: Colors.white54,
                                                    offset: Offset(0.5, 0.5))
                                              ]
                                              //fontSize: 8,
                                              ),
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                          notesProvider.activeNotes[index]
                                              ['title'],
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                    color: Colors.white54,
                                                    offset: Offset(0.5, 0.5))
                                              ]),
                                        ),
                                        subtitle: Text(
                                          notesProvider.activeNotes[index]
                                              ['subtitle'],
                                          style: const TextStyle(
                                              color: Colors.white70),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.check,
                                            color: Color.fromARGB(
                                                255, 249, 250, 249),
                                          ),
                                          onPressed: () {
                                            notesProvider
                                                .toggleCompletion(index);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // History Tab
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: (notesProvider.historyNotes.isEmpty)
                ? Center(
                    child: Text("Empty History",
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 20,
                            fontWeight: FontWeight.bold)))
                : ListView.builder(
                    itemCount: notesProvider.historyNotes.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        background: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [Colors.redAccent, Colors.red[800]!],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.amber,
                                    blurRadius: 10,
                                    offset: Offset(0, 3)),
                              ]),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.delete,
                                    color: Colors.white, size: 28),
                                SizedBox(width: 8),
                                Text(
                                  "Delete",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        key: Key(index.toString()),
                        onDismissed: (direction) {
                          notesProvider.deleteHistoryNoteAt(index);
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30, // Reduced radius for a smaller avatar
                              backgroundColor:
                                  Color.fromARGB(255, 123, 147, 180),
                              child: Text(
                                DateFormat('hh:mm a').format(
                                    notesProvider.historyNotes[index]['time']),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10, // Reduced font size for time
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 180, 180, 180),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color:
                                          Color.fromARGB(255, 180, 180, 180)),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0, right: 12),
                                      child: Text(
                                        DateFormat('MMM d, y').format(
                                            notesProvider.historyNotes[index]
                                                ['time']),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white70,
                                            fontSize: 12,
                                            shadows: [
                                              Shadow(
                                                  color: Colors.white54,
                                                  offset: Offset(0.5, 0.5))
                                            ]
                                            //fontSize: 8,
                                            ),
                                      ),
                                    ),
                                    ListTile(
                                      title: Text(
                                          notesProvider.historyNotes[index]
                                              ['title'],
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                    color: Colors.white54,
                                                    offset: Offset(0.5, 0.5))
                                              ])),
                                      subtitle: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                              color: Colors.white70),
                                          children: [
                                            TextSpan(
                                              text: notesProvider
                                                  .historyNotes[index]
                                                      ['subtitle']
                                                  .split(RegExp(
                                                      r"   (Not yet|Done)"))[0],
                                            ),
                                            if (notesProvider
                                                .historyNotes[index]['subtitle']
                                                .contains("Not yet"))
                                              const TextSpan(
                                                text: "   Not yet",
                                                style: TextStyle(
                                                    color: Colors
                                                        .red), // Color for "Not yet"
                                              )
                                            else if (notesProvider
                                                .historyNotes[index]['subtitle']
                                                .contains("Done"))
                                              TextSpan(
                                                text: "   Done",
                                                style: const TextStyle(
                                                    color: Color.fromARGB(
                                                        255,
                                                        2,
                                                        248,
                                                        10)), // Color for "Done"
                                              ),
                                          ],
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.restore,
                                          color: Color.fromARGB(
                                              255, 249, 250, 249),
                                        ),
                                        onPressed: () =>
                                            notesProvider.restoreNoteAt(index),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
