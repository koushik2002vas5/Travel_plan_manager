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
class PlanManagerScreen extends StatefulWidget {
  @override
  _PlanManagerScreenState createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<Plan> plans = [];
  DateTime selectedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Plan? _draggedPlan; // For storing the plan being dragged

  // Filter plans for the selected date
  List<Plan> get _filteredPlans {
    return plans
        .where((plan) =>
            plan.date.year == selectedDate.year &&
            plan.date.month == selectedDate.month &&
            plan.date.day == selectedDate.day)
        .toList();
  }

  // Add a new plan
  void _addPlan(String name, String description, DateTime date, String priority,
      String status) {
    setState(() {
      plans.add(Plan(
          name: name,
          description: description,
          date: date,
          priority: priority,
          status: status));
      _sortPlans();
    });
  }

  // Update an existing plan
  void _updatePlan(int index, String name, String description, DateTime date,
      String priority, String status) {
    setState(() {
      Plan updatedPlan = plans[index];
      updatedPlan.name = name;
      updatedPlan.description = description;
      updatedPlan.date = date;
      updatedPlan.priority = priority;
      updatedPlan.status = status;
      _sortPlans();
    });
  }

  // Toggle plan completion based on swipe direction
  void _toggleCompletion(int index, DismissDirection direction) {
    setState(() {
      if (direction == DismissDirection.endToStart) {
        plans[index].isCompleted = true;
        plans[index].status = 'completed';
      } else if (direction == DismissDirection.startToEnd) {
        plans[index].isCompleted = false;
        plans[index].status = 'pending';
      }
    });
  }

  // Delete a plan
  void _deletePlan(int index) {
    setState(() {
      plans.removeAt(index);
    });
  }

  // Sort plans by priority and date
  void _sortPlans() {
    setState(() {
      plans.sort((a, b) {
        const priorityOrder = {'High': 0, 'Medium': 1, 'Low': 2};
        int priorityComparison =
            priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
        return priorityComparison != 0
            ? priorityComparison
            : a.date.compareTo(b.date);
      });
    });
  }

