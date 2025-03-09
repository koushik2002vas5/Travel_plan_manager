import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // For date formatting

void main() {
  runApp(PlanManagerApp());
}

class Plan {
  String name;
  String description;
  DateTime date;
  String priority;
  bool isCompleted;
  String status; // Added status field

  Plan({
    required this.name,
    required this.description,
    required this.date,
    required this.priority,
    this.isCompleted = false,
    this.status = 'pending', // Default status
  });
}

class PlanManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark, // Set the app to dark theme
        scaffoldBackgroundColor:
            Colors.black, // Set scaffold background to black
        cardColor: Color(0xFF1E1E1E), // Dark cards
        dialogBackgroundColor: Color(0xFF121212), // Dark dialogs
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF121212), // Dark app bar
          elevation: 0,
        ),
      ),
      home: PlanManagerScreen(),
    );
  }
}
