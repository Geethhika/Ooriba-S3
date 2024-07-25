import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ooriba/services/HR/LeaveTypes.dart';
import 'package:table_calendar/table_calendar.dart';
import 'services/leave_service.dart'; // Import the leave service

class LeavePage extends StatefulWidget {
  final String? employeeId;

  const LeavePage({super.key, required this.employeeId});
  @override
  _LeavePageState createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  final _formKey = GlobalKey<FormState>();
  late String empid;
  final LeaveService _leaveService =
      LeaveService(); // Instantiate the leave service
  final LeaveTypesService _leaveTypesService = LeaveTypesService();

  List<String> leaveTypes = [];
  String selectedLeaveType = 'Sick Leave'; // Default value

  TextEditingController employeeIdController = TextEditingController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  TextEditingController leaveReasonController = TextEditingController();
  TextEditingController numberOfDaysController = TextEditingController();

  DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  Map<String, Map<String, int>> leaveTypeDetails = {};

  @override
  void initState() {
    super.initState();
    numberOfDaysController.text = '0';
    _fetchEmployeeLeaveDates();
    _fetchLeaveTypes();
  }

  Future<void> _fetchLeaveTypes() async {
    List<String> types = await _leaveTypesService.fetchLeaveTypes();
    setState(() {
      leaveTypes = types;
      if (leaveTypes.isNotEmpty) {
        selectedLeaveType = leaveTypes[0]; // Set default to first leave type
      }
    });
  }

  void calculateDays() {
    if (fromDateController.text.isNotEmpty &&
        toDateController.text.isNotEmpty) {
      DateTime from = dateFormat.parse(fromDateController.text);
      DateTime to = dateFormat.parse(toDateController.text);
      int days = to.difference(from).inDays + 1; // Including the start date
      setState(() {
        numberOfDaysController.text = days.toString();
      });
    }
  }

  Future<void> _applyLeave() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        double numberOfDays = double.parse(numberOfDaysController.text);

        await _leaveService.applyLeave(
          employeeId: widget.employeeId!,
          leaveType: selectedLeaveType,
          fromDate: dateFormat.parse(fromDateController.text),
          toDate: dateFormat.parse(toDateController.text),
          numberOfDays: numberOfDays,
          leaveReason: leaveReasonController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Leave applied successfully')),
        );

        // Fetch leave dates again to update the calendar
        await _fetchEmployeeLeaveDates();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Insufficient leave balance')),
        );
      }
    }
  }

  void _showLeaveDetails(DateTime selectedDay) async {
    final leaveDetails = await _leaveService.fetchLeaveDetailsByDate(
        widget.employeeId!, selectedDay);
    if (leaveDetails != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Leave Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Leave Type: ${leaveDetails['leaveType']}'),
                Text(
                    'From Date: ${DateFormat('dd-MM-yyyy').format((leaveDetails['fromDate'] as Timestamp).toDate())}'),
                Text(
                    'To Date: ${DateFormat('dd-MM-yyyy').format((leaveDetails['toDate'] as Timestamp).toDate())}'),
                Text('Number of Days: ${leaveDetails['numberOfDays']}'),
                Text('Leave Reason: ${leaveDetails['leaveReason']}'),
                Text('Approved: ${leaveDetails['isApproved'] ? 'Yes' : 'No'}'),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('No leave details found for the selected date.')),
      );
    }
  }

  Widget _buildLabelWithStar(String label) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(color: Colors.black),
        children: [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filteredLeaveRequests = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Set<DateTime> _employeeLeaveDates = {};
  Map<DateTime, Map<String, dynamic>> _leaveDetailsMap = {};

  Future<void> _fetchEmployeeLeaveDates() async {
    try {
      List<Map<String, dynamic>> leaveRequests =
          await _leaveService.fetchLeaveRequests(
        employeeId: widget.employeeId!,
      );

      Set<DateTime> leaveDates = {};
      for (var request in leaveRequests) {
        DateTime fromDate = (request['fromDate'] as Timestamp).toDate();
        DateTime toDate = (request['toDate'] as Timestamp).toDate();
        for (DateTime date = fromDate;
            date.isBefore(toDate) || date.isAtSameMomentAs(toDate);
            date = date.add(Duration(days: 1))) {
          leaveDates.add(date);
          _leaveDetailsMap[date] = request;
        }
      }

      print('Leave Dates: $leaveDates'); // Debug statement

      setState(() {
        _employeeLeaveDates = leaveDates;
      });
    } catch (e) {
      print('Error fetching leave dates: $e');
    }
  }

  Map<String, dynamic>? _selectedLeaveDetails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Leave Application'),
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(16.0), // Reduced padding
            child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    Container(
                      padding: EdgeInsets.all(
                          16.0), // Add padding inside the container
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey), // Border color
                        borderRadius:
                            BorderRadius.circular(8.0), // Rounded corners
                        color: Colors.white, // Background color
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          TextFormField(
                            controller:
                                TextEditingController(text: widget.employeeId),
                            decoration: InputDecoration(
                                label: _buildLabelWithStar('Employee ID')),
                            enabled: false,
                          ),
                          SizedBox(height: 12.0), // Reduced spacing
                          DropdownButtonFormField(
                            value: selectedLeaveType,
                            items: leaveTypes.map((String type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedLeaveType = value.toString();
                                numberOfDaysController.text = '0';
                              });
                            },
                            decoration: InputDecoration(
                                label: _buildLabelWithStar('Leave Type')),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a leave type';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 12.0), // Reduced spacing
                          TextFormField(
                            controller: fromDateController,
                            decoration: InputDecoration(
                                label: _buildLabelWithStar('From Date')),
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now()
                                    .subtract(Duration(days: 365)),
                                lastDate:
                                    DateTime.now().add(Duration(days: 365)),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  fromDateController.text =
                                      dateFormat.format(pickedDate);
                                  calculateDays();
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a from date';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 12.0), // Reduced spacing
                          TextFormField(
                            controller: toDateController,
                            decoration: InputDecoration(
                                label: _buildLabelWithStar('To Date')),
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now()
                                    .subtract(Duration(days: 365)),
                                lastDate:
                                    DateTime.now().add(Duration(days: 365)),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  toDateController.text =
                                      dateFormat.format(pickedDate);
                                  calculateDays();
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a to date';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 12.0), // Reduced spacing
                          TextFormField(
                            controller: numberOfDaysController,
                            decoration:
                                InputDecoration(labelText: 'Number of Days'),
                            readOnly: true,
                          ),
                          SizedBox(height: 12.0), // Reduced spacing
                          TextFormField(
                            controller: leaveReasonController,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration:
                                InputDecoration(labelText: 'Leave Reason'),
                          ),
                          SizedBox(height: 12.0),
                          Center(
                            child: ElevatedButton(
                              onPressed: _applyLeave,
                              child: Text('Apply'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(120, 40),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      padding: EdgeInsets.all(
                          16.0), // Add padding inside the container
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey), // Border color
                        borderRadius:
                            BorderRadius.circular(8.0), // Rounded corners
                        color: Colors.white, // Background color
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TableCalendar(
                            focusedDay: _focusedDay,
                            firstDay: DateTime(2000),
                            lastDay: DateTime(2100),
                            selectedDayPredicate: (day) {
                              return isSameDay(_selectedDay, day);
                            },
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                                _showLeaveDetails(
                                    selectedDay); // Show leave details for the selected day
                              });
                            },
                            calendarStyle: CalendarStyle(
                              todayDecoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, day, focusedDay) {
                                bool isOnLeave = _employeeLeaveDates.any(
                                    (leaveDate) =>
                                        leaveDate.year == day.year &&
                                        leaveDate.month == day.month &&
                                        leaveDate.day == day.day);
                                if (isOnLeave) {
                                  return Container(
                                    margin: const EdgeInsets.all(6.0),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${day.day}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }
                                return null;
                              },
                              markerBuilder: (context, date, events) {
                                if (_employeeLeaveDates.contains(date)) {
                                  return Positioned(
                                    bottom: 1,
                                    child: Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  );
                                }
                                return null;
                              },
                            ),
                            headerStyle: HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                              formatButtonShowsNext: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
            )));
  }

  void main() => runApp(MaterialApp(
        home: LeavePage(employeeId: widget.employeeId),
      ));
}