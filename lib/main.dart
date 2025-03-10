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

  // Show dialog for creating or editing a plan
  void _showCreatePlanDialog({int? index, DateTime? date}) {
    String name = index != null ? plans[index].name : '';
    String description = index != null ? plans[index].description : '';
    DateTime selectedPlanDate =
        date ?? (index != null ? plans[index].date : selectedDate);
    String selectedPriority = index != null ? plans[index].priority : 'Medium';
    String selectedStatus = index != null ? plans[index].status : 'pending';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              index == null ? "Create Plan" : "Edit Plan",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFF1E1E1E), // Dark dialog background
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Plan Name",
                      labelStyle: TextStyle(color: Colors.blue[200]),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue[200]!),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    controller: TextEditingController(text: name),
                    onChanged: (value) => name = value,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Description",
                      labelStyle: TextStyle(color: Colors.blue[200]),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue[200]!),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    controller: TextEditingController(text: description),
                    onChanged: (value) => description = value,
                    maxLines: 3,
                  ),
                  SizedBox(height: 15),

                  // Date display (no calendar popup in dialog)
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade700),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Plan Date:",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[200],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          DateFormat('yyyy-MM-dd').format(selectedPlanDate),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "(Date is set to your calendar selection)",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        "Priority: ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue[200],
                        ),
                      ),
                      SizedBox(width: 10),
                      DropdownButton<String>(
                        value: selectedPriority,
                        dropdownColor: Color(0xFF2C2C2C),
                        style: TextStyle(color: Colors.white),
                        items: ['High', 'Medium', 'Low'].map((priority) {
                          return DropdownMenuItem(
                            value: priority,
                            child: Text(
                              priority,
                              style: TextStyle(
                                color: _getPriorityTextColor(priority),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedPriority = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Text(
                        "Status: ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue[200],
                        ),
                      ),
                      SizedBox(width: 10),
                      DropdownButton<String>(
                        value: selectedStatus,
                        dropdownColor: Color(0xFF2C2C2C),
                        style: TextStyle(color: Colors.white),
                        items: ['pending', 'completed'].map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(
                              status.capitalize(),
                              style: TextStyle(
                                color: status == 'completed'
                                    ? Colors.green[300]
                                    : Colors.orange[300],
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedStatus = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (name.isNotEmpty) {
                    if (index == null) {
                      _addPlan(name, description, selectedPlanDate,
                          selectedPriority, selectedStatus);
                    } else {
                      _updatePlan(index, name, description, selectedPlanDate,
                          selectedPriority, selectedStatus);
                    }
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                ),
                child: Text(
                  index == null ? "Add" : "Update",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  // Get color based on plan status and priority
  Color _getPlanColor(Plan plan) {
    if (plan.isCompleted || plan.status == 'completed') {
      return Color(0xFF1B3D2F); // Dark green for completed
    } else {
      switch (plan.priority) {
        case 'High':
          return Color(0xFF3D1B1B); // Dark red for high priority
        case 'Medium':
          return Color(0xFF3D2B1B); // Dark orange for medium priority
        case 'Low':
          return Color(0xFF1B2D3D); // Dark blue for low priority
        default:
          return Color(0xFF2D2D2D); // Dark grey for default
      }
    }
  }

  // Helper method to get priority text color
  Color _getPriorityTextColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red[300]!;
      case 'Medium':
        return Colors.orange[300]!;
      case 'Low':
        return Colors.blue[300]!;
      default:
        return Colors.grey[300]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Travel Plan Manager",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.sort,
              color: Colors.white,
            ),
            onPressed: _sortPlans,
            tooltip: "Sort by priority",
          ),
        ],
      ),
      body: Container(
        color: Colors.black, // Black background
        child: Column(
          children: [
            // Calendar with DragTarget
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF121212), // Dark surface for calendar
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              margin: EdgeInsets.all(8),
              child: DragTarget<Plan>(
                onAccept: (plan) {
                  // Update the plan's date when dropped on calendar
                  setState(() {
                    int planIndex = plans.indexOf(plan);
                    plans[planIndex].date = selectedDate;
                    _sortPlans();
                  });
                },
                onWillAccept: (plan) => plan != null,
                builder: (context, candidateData, rejectedData) {
                  return TableCalendar(
                    focusedDay: selectedDate,
                    firstDay: DateTime(2000),
                    lastDay: DateTime(2100),
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        selectedDate = selectedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.blue[800],
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      outsideDaysVisible: false,
                      defaultTextStyle: TextStyle(color: Colors.white),
                      weekendTextStyle: TextStyle(color: Colors.red[200]),
                      holidayTextStyle: TextStyle(color: Colors.orange[200]),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonTextStyle: TextStyle(color: Colors.white),
                      titleTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                      formatButtonDecoration: BoxDecoration(
                        color: Colors.blue[700],
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: Colors.grey[300]),
                      weekendStyle: TextStyle(color: Colors.red[200]),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        // Mark days that have plans
                        final hasPlans = plans.any((plan) =>
                            plan.date.year == date.year &&
                            plan.date.month == date.month &&
                            plan.date.day == date.day);

                        if (hasPlans) {
                          return Positioned(
                            right: 1,
                            bottom: 1,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue[400],
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                  );
                },
              ),
            ),

            // New plan drag target area
            DragTarget<String>(
              onAccept: (data) {
                if (data == 'new_plan') {
                  _showCreatePlanDialog(date: selectedDate);
                }
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  padding: EdgeInsets.all(10.0),
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: candidateData.isNotEmpty
                          ? Colors.blue[700]!
                          : Colors.grey[800]!,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                    color: Color(0xFF1A1A1A),
                  ),
                  child: Center(
                    child: Text(
                      "Drop here to add a new plan for ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                      style: TextStyle(
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Create Plan button (replacing floating action button)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton.icon(
                onPressed: () => _showCreatePlanDialog(date: selectedDate),
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                label: Text(
                  "Create Plan",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            // Label for plans on selected date - FIXED to match the selected date
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Plans for ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue[200],
                ),
              ),
            ),

            // Draggable new plan option
            Draggable<String>(
              data: 'new_plan',
              feedback: Material(
                elevation: 4.0,
                color: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Color(0xFF1A344D),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    "New Plan",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              childWhenDragging: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  "Drag to create",
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
              child: Container(
                padding: EdgeInsets.all(10.0),
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Color(0xFF1A344D),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.drag_indicator,
                      color: Colors.blue[200],
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      "Drag to add a new plan",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            // List of plans for the selected date
            Expanded(
              child: Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF121212),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _filteredPlans.isEmpty
                    ? Center(
                        child: Text(
                          "No plans for this date",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredPlans.length,
                        itemBuilder: (context, index) {
                          final plan = _filteredPlans[index];
                          final planIndex = plans.indexOf(plan);

                          // Make each plan item draggable
                          return LongPressDraggable<Plan>(
                            data: plan,
                            feedback: Material(
                              elevation: 4.0,
                              color: Colors.transparent,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: _getPlanColor(plan),
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: Colors.grey[800]!,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  plan.name,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            child: Dismissible(
                              key: Key(
                                  "plan_${planIndex}_${DateTime.now().millisecondsSinceEpoch}"),
                              onDismissed: (direction) {
                                // Handle the dismissal without removing from list yet
                                _toggleCompletion(planIndex, direction);

                                // Re-render the item
                                setState(() {});
                              },
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.endToStart) {
                                  if (!plan.isCompleted) {
                                    setState(() {
                                      plans[planIndex].isCompleted = true;
                                      plans[planIndex].status = 'completed';
                                    });
                                  }
                                } else if (direction ==
                                    DismissDirection.startToEnd) {
                                  if (plan.isCompleted) {
                                    setState(() {
                                      plans[planIndex].isCompleted = false;
                                      plans[planIndex].status = 'pending';
                                    });
                                  }
                                }
                                // Return false to prevent actual dismissal
                                return false;
                              },
                              background: Container(
                                color: Color(0xFF1B3D2F), // Dark green
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 20),
                                child:
                                    Icon(Icons.undo, color: Colors.green[300]),
                              ),
                              secondaryBackground: Container(
                                color: Color(0xFF1B2D3D), // Dark blue
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(right: 20),
                                child:
                                    Icon(Icons.check, color: Colors.blue[300]),
                              ),
                              child: GestureDetector(
                                onDoubleTap: () {
                                  // Show confirmation dialog before deletion
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: Color(0xFF1E1E1E),
                                      title: Text(
                                        "Delete Plan",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      content: Text(
                                        "Are you sure you want to delete '${plan.name}'?",
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(
                                                color: Colors.grey[400]),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _deletePlan(planIndex);
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "Delete",
                                            style: TextStyle(
                                                color: Colors.red[300]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onLongPress: () {
                                  _showCreatePlanDialog(index: planIndex);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _getPlanColor(plan),
                                    borderRadius: BorderRadius.circular(8.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 2.0,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.grey[800]!,
                                      width: 1,
                                    ),
                                  ),
                                  margin: EdgeInsets.symmetric(
                                      vertical: 4.0, horizontal: 8.0),
                                  child: ListTile(
                                    title: Text(
                                      plan.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        decoration: plan.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          plan.description,
                                          style: TextStyle(
                                              color: Colors.grey[400]),
                                        ),
                                        SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _getPriorityColor(
                                                        plan.priority)
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: _getPriorityColor(
                                                      plan.priority),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                plan.priority,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: _getPriorityTextColor(
                                                      plan.priority),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: (plan.status ==
                                                            'completed'
                                                        ? Colors.green[900]
                                                        : Colors.orange[900])!
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color:
                                                      plan.status == 'completed'
                                                          ? Colors.green[700]!
                                                          : Colors.orange[700]!,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                plan.status.capitalize(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      plan.status == 'completed'
                                                          ? Colors.green[300]
                                                          : Colors.orange[300],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: Icon(
                                      plan.isCompleted
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      color: plan.isCompleted
                                          ? Colors.green[300]
                                          : Colors.grey[400],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get priority color
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red[700]!;
      case 'Medium':
        return Colors.orange[700]!;
      case 'Low':
        return Colors.blue[700]!;
      default:
        return Colors.grey[700]!;
    }
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
