// import 'package:calendar_app/pages/event_editing_page.dart';
// import 'package:calendar_app/widgets/calendar_widget.dart';
// import 'package:flutter/material.dart';

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Calendar"),
//         centerTitle: true,
//       ),
//       body: CalendarWidget(),
//       floatingActionButton: FloatingActionButton(
//           child: Icon(
//             Icons.add,
//             color: Colors.white,
//           ),
//           backgroundColor: Colors.cyan,
//           onPressed: () => Navigator.of(context).push(
//                 MaterialPageRoute(builder: (context) => EventEditingPage()),
//               )),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../Customs/MyAppBar.dart';
import '../widgets/calendar_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(title: "TimeVesta", context: context),
      //bottomNavigationBar: const BottomNavBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 144, 198, 209), 
              Color.fromARGB(255, 126, 216, 223), 
              Color.fromARGB(255, 65, 153, 177),
            ],
          ),
        ),
        child: CalendarWidget(), // Your calendar widget
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(
      //     Icons.add,
      //     color: Colors.white,
      //   ),
      //   backgroundColor: Colors.cyan,
      //   onPressed: () => Navigator.of(context).push(
      //     MaterialPageRoute(builder: (context) => EventEditingPage()),
      //   ),
      // ),
    );
  }
}
