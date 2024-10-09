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
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1C),
          title: const Text('Edit Note', style: TextStyle(color: Colors.white)),
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
                      ? DateFormat('yyyy-MM-dd – HH:mm')
                          .format(selectedDateTime!)
                      : 'Select Date & Time',
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  onPressed: () => _pickDateTime(context),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
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
              child: const Text('Update', style: TextStyle(color: Colors.blue)),
            ),
          ],
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
          ListView.builder(
            itemCount: notesProvider.activeNotes.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onDoubleTap: () => _editNoteAt(context, index),
                child: Dismissible(
                  key: Key(notesProvider.activeNotes[index]['title']),
                  onDismissed: (direction) {
                    notesProvider.deleteNoteAt(index);
                    // Optionally show a snackbar or some confirmation here
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 123, 176, 180),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Color.fromARGB(255, 123, 176, 180)),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25, // Reduced radius for a smaller avatar
                        backgroundColor: Color.fromARGB(255, 123, 147, 180),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('HH:mm').format(
                                  notesProvider.activeNotes[index]['time']),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10, // Reduced font size for time
                              ),
                            ),
                            Text(
                              DateFormat('yyyy-MM-dd').format(
                                  notesProvider.activeNotes[index]['time']),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 8, // Reduced font size for date
                              ),
                            ),
                          ],
                        ),
                      ),
                      title: Text(
                        notesProvider.activeNotes[index]['title'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        notesProvider.activeNotes[index]['subtitle'],
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.check,
                          color: Color.fromARGB(255, 249, 250, 249),
                        ),
                        onPressed: () {
                          notesProvider.toggleCompletion(index);
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // History Tab
          ListView.builder(
            itemCount: notesProvider.historyNotes.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 180, 180, 180),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color.fromARGB(255, 180, 180, 180)),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 25, // Reduced radius for a smaller avatar
                    backgroundColor: Color.fromARGB(255, 123, 147, 180),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(
                              notesProvider.historyNotes[index]['time']),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10, // Reduced font size for time
                          ),
                        ),
                        Text(
                          DateFormat('yyyy-MM-dd').format(
                              notesProvider.historyNotes[index]['time']),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 8, // Reduced font size for date
                          ),
                        ),
                      ],
                    ),
                  ),
                  title: Text(
                    notesProvider.historyNotes[index]['title'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.white70),
                      children: [
                        TextSpan(
                          text: notesProvider.historyNotes[index]['subtitle']
                              .split(RegExp(r"   (Not yet|Done)"))[0],
                        ),
                        if (notesProvider.historyNotes[index]['subtitle']
                            .contains("Not yet"))
                          TextSpan(
                            text: "   Not yet",
                            style: const TextStyle(
                                color: Colors.red), // Color for "Not yet"
                          )
                        else if (notesProvider.historyNotes[index]['subtitle']
                            .contains("Done"))
                          TextSpan(
                            text: "   Done",
                            style: const TextStyle(
                                color: Color.fromARGB(
                                    255, 2, 248, 10)), // Color for "Done"
                          ),
                      ],
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.restore,
                      color: Color.fromARGB(255, 249, 250, 249),
                    ),
                    onPressed: () => notesProvider.restoreNoteAt(index),
                  ),
                ),
              );
            },
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Color.fromARGB(255, 123, 147, 180),
      //   onPressed: () {
      //     showDialog(
      //       context: context,
      //       builder: (context) {
      //         return AlertDialog(
      //           backgroundColor: const Color(0xFF1C1C1C),
      //           title: const Text('New Note',
      //               style: TextStyle(color: Colors.white)),
      //           content: Column(
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               TextField(
      //                 controller: _titleController,
      //                 cursorColor: Colors.blue,
      //                 style: const TextStyle(color: Colors.white),
      //                 decoration: const InputDecoration(
      //                   labelText: 'Title',
      //                   labelStyle: TextStyle(color: Colors.white70),
      //                   enabledBorder: UnderlineInputBorder(
      //                     borderSide: BorderSide(color: Colors.blue),
      //                   ),
      //                   focusedBorder: UnderlineInputBorder(
      //                     borderSide: BorderSide(color: Colors.blue),
      //                   ),
      //                 ),
      //               ),
      //               TextField(
      //                 controller: _subtitleController,
      //                 cursorColor: Colors.blue,
      //                 style: const TextStyle(color: Colors.white),
      //                 decoration: const InputDecoration(
      //                   labelText: 'Subtitle',
      //                   labelStyle: TextStyle(color: Colors.white70),
      //                   enabledBorder: UnderlineInputBorder(
      //                     borderSide: BorderSide(color: Colors.blue),
      //                   ),
      //                   focusedBorder: UnderlineInputBorder(
      //                     borderSide: BorderSide(color: Colors.blue),
      //                   ),
      //                 ),
      //               ),
      //               ListTile(
      //                 title: Text(
      //                   selectedDateTime != null
      //                       ? DateFormat('yyyy-MM-dd – HH:mm')
      //                           .format(selectedDateTime!)
      //                       : 'Select Date & Time',
      //                   style: const TextStyle(color: Colors.white),
      //                 ),
      //                 trailing: IconButton(
      //                   icon: const Icon(Icons.calendar_today,
      //                       color: Colors.white),
      //                   onPressed: () => _pickDateTime(context),
      //                 ),
      //               ),
      //             ],
      //           ),
      //           actions: [
      //             TextButton(
      //               onPressed: () {
      //                 Navigator.pop(context);
      //               },
      //               child: const Text('Cancel',
      //                   style: TextStyle(color: Colors.white)),
      //             ),
      //             TextButton(
      //               onPressed: () {
      //                 _createNote();
      //                 Navigator.pop(context);
      //               },
      //               child: const Text('Create',
      //                   style: TextStyle(color: Colors.blue)),
      //             ),
      //           ],
      //         );
      //       },
      //     );
      //   },
      //   child: const Icon(
      //     Icons.add,
      //     color: Colors.white, // Set the foreground (icon) color
      //   ),
      // ),
    );
  }
}
