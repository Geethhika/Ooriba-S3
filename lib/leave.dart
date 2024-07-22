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
    _fetchDetailedLeaveTypes();
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

  Future<void> _fetchDetailedLeaveTypes() async {
    Map<String, Map<String, int>> typesDetails =
        await _leaveTypesService.fetchDetailedLeaveTypes();
    setState(() {
      leaveTypeDetails = typesDetails;
    });
  }

  Future<DocumentSnapshot> fetchSickLeaveData() async {
    return await FirebaseFirestore.instance
        .collection('LeaveTypes')
        .doc('Sick Leave')
        .get();
  }

  Future<bool> canRequestSickLeave(String employeeId) async {
    try {
      DocumentSnapshot snapshot = await fetchSickLeaveData();

      int maxSickLeaveDays = 4; // Default max sick leave days
      if (snapshot.exists) {
        maxSickLeaveDays =
            (snapshot.data() as Map<String, dynamic>?)?['maxDays'] ?? 4;
      }

      // Fetch the total number of sick leave days already taken by the employee
      List<Map<String, dynamic>> leaveRequests =
          await _leaveService.fetchLeaveRequests(employeeId: employeeId);

      // Calculate the total sick leave days taken by the employee
      int totalSickLeaveDays = leaveRequests
          .where((request) => request['leaveType'] == 'Sick Leave')
          .fold(0, (sum, request) {
        DateTime fromDate = (request['fromDate'] as Timestamp).toDate();
        DateTime toDate = (request['toDate'] as Timestamp).toDate();
        return sum + toDate.difference(fromDate).inDays + 1;
      });

      // Allow the request if the total sick leave days taken is less than the maximum allowed
      return totalSickLeaveDays < maxSickLeaveDays;
    } catch (e) {
      print('Error checking sick leave request: $e');
      return false;
    }
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

        // Check if the leave type is "Sick Leave" and the number of days is more than 4
        if (selectedLeaveType == 'Sick Leave' && numberOfDays > 4) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Cannot request more than 4 days of sick leave.')),
          );
          return;
        }

        bool canRequest = true;
        // If leave type is "Sick Leave," check if the employee can request more sick leave
        if (selectedLeaveType == 'Sick Leave') {
          canRequest = await canRequestSickLeave(widget.employeeId!);
        }

        // Check for eligible earned leave days
        if (selectedLeaveType == 'Earned Leave') {
          int eligibleLeaveDays = await _leaveTypesService
              .calculateEligibleEarnedLeave(widget.employeeId!);
          if (numberOfDays > eligibleLeaveDays) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Cannot request more than $eligibleLeaveDays days of earned leave.')),
            );
            return;
          }
        }

        if (canRequest) {
          await _leaveService.applyLeave(
            employeeId: widget.employeeId!,
            leaveType: selectedLeaveType,
            fromDate: dateFormat.parse(fromDateController.text),
            toDate: dateFormat.parse(toDateController.text),
            numberOfDays: numberOfDays,
            leaveReason: leaveReasonController.text,
          );
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Leave applied successfully')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cannot request more sick leave.')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to apply leave: $e')));
      }
    }
  }

  // Future<void> searchLeaveRequests() async {
  //   try {
  //     DateTime? fromDate = fromDateController.text.isNotEmpty
  //         ? dateFormat.parse(fromDateController.text)
  //         : null;
  //     DateTime? toDate = toDateController.text.isNotEmpty
  //         ? dateFormat.parse(toDateController.text)
  //         : null;

  //     // Fetch leave requests for the specific employeeId within the date range
  //     List<Map<String, dynamic>> leaveRequests =
  //         await _leaveService.fetchLeaveRequests(
  //       employeeId: widget.employeeId!,
  //       fromDate: fromDate,
  //       toDate: toDate,
  //     );

  //     // Display the filtered leave requests in debug console
  //     print('Filtered Leave Requests: $leaveRequests');

  //     // Optionally, you can display the leave requests in UI as needed
  //     // For simplicity, let's print them in the debug console
  //     setState(() {
  //       _filteredLeaveRequests = leaveRequests;
  //     });
  //   } catch (e) {
  //     print('Error fetching leave requests: $e');
  //     // Handle error as needed
  //   }
  // }
  void _showLeaveDetails(DateTime selectedDay) {
    final leaveDetails = _leaveDetailsMap[selectedDay];
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
                Text(
                    'Approved At: ${leaveDetails['approvedAt'] != null ? DateFormat('dd-MM-yyyy').format((leaveDetails['approvedAt'] as Timestamp).toDate()) : 'N/A'}'),
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
              // SizedBox(height: 1.0),
              // if (leaveTypeDetails.isNotEmpty)
              //   ...leaveTypeDetails.entries.map((entry) {
              //     String leaveType = entry.key;
              //     Map<String, int> employeeData = entry.value;
              //     // Get the max number of days allowed for this leave type
              //     int maxDays =
              //         leaveType == 'Sick Leave' ? 4 : 12; // Adjust as needed

              //     return Padding(
              //       padding: const EdgeInsets.symmetric(vertical: 8.0),
              //       child: Card(
              //         margin: EdgeInsets.symmetric(vertical: 8.0),
              //         child: Padding(
              //           padding: EdgeInsets.all(8.0),
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: <Widget>[
              //               Text(
              //                 'Leave Type: $leaveType',
              //                 style: TextStyle(fontWeight: FontWeight.bold),
              //               ),
              //               Padding(
              //                 padding:
              //                     const EdgeInsets.symmetric(vertical: 4.0),
              //                 child: Row(
              //                   mainAxisAlignment:
              //                       MainAxisAlignment.spaceBetween,
              //                   children: [
              //                     Text(
              //                       'Taken Leaves: ${employeeData.values.fold(0, (sum, leaves) => sum + leaves)}',
              //                       style: TextStyle(fontSize: 12.0),
              //                     ),
              //                     Text(
              //                       'Balance: ${maxDays - employeeData.values.fold(0, (sum, leaves) => sum + leaves)}',
              //                       style: TextStyle(fontSize: 12.0),
              //                     ),
              //                   ],
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),
              //     );
              //   }).toList()
              // else
              //   Padding(
              //     padding: const EdgeInsets.symmetric(vertical: 20.0),
              //     child: Center(
              //       child: Text(
              //         'No leave type details available',
              //         style: TextStyle(fontSize: 16.0),
              //       ),
              //     ),
              //   ),
              SizedBox(height: 20.0),
              Container(
                padding:
                    EdgeInsets.all(16.0), // Add padding inside the container
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey), // Border color
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
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
                          firstDate:
                              DateTime.now().subtract(Duration(days: 365)),
                          lastDate: DateTime.now().add(Duration(days: 365)),
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
                          firstDate:
                              DateTime.now().subtract(Duration(days: 365)),
                          lastDate: DateTime.now().add(Duration(days: 365)),
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
                      decoration: InputDecoration(labelText: 'Number of Days'),
                      readOnly: true,
                    ),
                    SizedBox(height: 12.0), // Reduced spacing
                    TextFormField(
                      controller: leaveReasonController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(labelText: 'Leave Reason'),
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
                    bool isOnLeave = _employeeLeaveDates.any((leaveDate) =>
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
      ),
    );
  }

  void main() => runApp(MaterialApp(
        home: LeavePage(employeeId: widget.employeeId),
      ));
}
