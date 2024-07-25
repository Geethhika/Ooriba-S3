import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ooriba/services/HR/LeaveTypes.dart';

class ApplyLeavePage extends StatefulWidget {
  @override
  _ApplyLeavePageState createState() => _ApplyLeavePageState();
}

class _ApplyLeavePageState extends State<ApplyLeavePage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LeaveTypesService _leaveTypesService = LeaveTypesService();

  List<String> leaveTypes = [];
  String selectedLeaveType = 'Sick Leave'; // Default value

  TextEditingController employeeIdSearchController = TextEditingController();
  TextEditingController employeeIdController = TextEditingController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  TextEditingController leaveReasonController = TextEditingController();
  TextEditingController numberOfDaysController = TextEditingController();

  Map<String, dynamic>? leaveDetails;

  DateFormat dateFormat = DateFormat('dd-MM-yyyy');

  List<Map<String, dynamic>> searchResults = [];
  bool showSearchResults = false;

  @override
  void initState() {
    super.initState();
    _fetchLeaveTypes();
    numberOfDaysController.text = '0';
    employeeIdSearchController.addListener(() {
      _formatSearchText(employeeIdSearchController);
    });
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

  void _formatSearchText(TextEditingController controller) {
    String text = controller.text;
    if (text.isNotEmpty) {
      // Split text into words
      List<String> words = text.split(' ');
      for (int i = 0; i < words.length; i++) {
        if (words[i].isNotEmpty) {
          words[i] =
              words[i][0].toUpperCase() + words[i].substring(1).toLowerCase();
        }
      }
      String formattedText = words.join(' ');

      // Check if the text is an employee ID and fully capitalize it
      if (RegExp(r'^[a-zA-Z]+\d+$').hasMatch(formattedText)) {
        formattedText = formattedText.toUpperCase();
      }

      controller.value = controller.value.copyWith(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
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

  Future<Map<String, dynamic>?> getEmployeeById(String employeeId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Regemp')
          .where('employeeId', isEqualTo: employeeId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  int calculateEarnedLeaveDays(DateTime joiningDate) {
    DateTime currentDate = DateTime.now();

    // Adjust joining date if not in the current year
    if (joiningDate.year != currentDate.year) {
      joiningDate = DateTime(currentDate.year, 1, 1);
    }

    int monthsWorked = ((currentDate.year - joiningDate.year) * 12 +
            currentDate.month -
            joiningDate.month)
        .clamp(0, double.infinity)
        .toInt();
    return monthsWorked;
  }

  Future<void> applyLeave({
    required String employeeId,
    required String leaveType,
    required DateTime? fromDate,
    required DateTime? toDate,
    required double numberOfDays,
    required String? leaveReason,
  }) async {
    try {
      String fromDateStr =
          fromDate != null ? fromDate.toIso8601String().split('T').first : '';
      String currentYear = DateTime.now().year.toString();

      if (leaveType == 'Sick Leave') {
        DocumentSnapshot leaveTypeDoc = await _firestore
            .collection('LeaveTypes')
            .doc('Sick Leave')
            .collection(currentYear)
            .doc(employeeId)
            .get();

        double maxLeave = 4.0; // Default max leave for sick leave
        Map<String, dynamic>? leaveData =
            leaveTypeDoc.data() as Map<String, dynamic>?;

        if (leaveData != null && leaveData.containsKey('maxLeave')) {
          maxLeave = leaveData['maxLeave'];
        }

        if (numberOfDays > maxLeave) {
          throw Exception('Insufficient sick leave balance');
        }

        // Subtract the number of days from max leave
        maxLeave -= numberOfDays;

        await _firestore
            .collection('LeaveTypes')
            .doc('Sick Leave')
            .collection(currentYear)
            .doc(employeeId)
            .set({
          'maxLeave': maxLeave,
          'leaveTaken': FieldValue.increment(numberOfDays),
        }, SetOptions(merge: true));
      } else if (leaveType == 'Earned Leave') {
        Map<String, dynamic>? employeeData = await getEmployeeById(employeeId);
        if (employeeData == null) {
          throw Exception('Employee not found');
        }

        DateFormat dateFormat = DateFormat('dd/MM/yyyy');
        DateTime joiningDate = dateFormat.parse(employeeData['joiningDate']);
        int earnedLeaveDays = calculateEarnedLeaveDays(joiningDate);

        DocumentSnapshot leaveTypeDoc = await _firestore
            .collection('LeaveTypes')
            .doc('Earned Leave')
            .collection(currentYear)
            .doc(employeeId)
            .get();

        double leavesTaken = 0.0;
        Map<String, dynamic>? leaveData =
            leaveTypeDoc.data() as Map<String, dynamic>?;

        if (leaveData != null && leaveData.containsKey('leavesTaken')) {
          leavesTaken = leaveData['leavesTaken'];
        }

        if ((earnedLeaveDays - leavesTaken) < numberOfDays) {
          throw Exception('Insufficient earned leave balance');
        }

        await _firestore
            .collection('LeaveTypes')
            .doc('Earned Leave')
            .collection(currentYear)
            .doc(employeeId)
            .set({
          'leavesTaken': FieldValue.increment(numberOfDays),
        }, SetOptions(merge: true));
      }

      await _firestore
          .collection('leave')
          .doc('accept')
          .collection(employeeId)
          .doc(fromDateStr)
          .set({
        'employeeId': employeeId,
        'leaveType': leaveType,
        'fromDate': fromDate,
        'toDate': toDate,
        'numberOfDays': numberOfDays,
        'leaveReason': leaveReason,
        'isApproved': true, // Set isApproved to true as required
        'count': FieldValue.increment(1), // Increment the leave count
      });

      await _firestore.collection('LeaveCount').doc(employeeId).set({
        'fromDate': fromDate,
        'count': FieldValue.increment(1), // Increment count
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error applying leave: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> searchEmployees(String query) async {
    try {
      // First, split the query into parts to handle both first and last name search
      List<String> parts = query.split(' ');

      List<Map<String, dynamic>> employees = [];

      // Search by employee ID first
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('Regemp')
          .where('employeeId', isEqualTo: query)
          .get();

      employees = querySnapshot.docs.map((doc) => doc.data()).toList();

      // If no results, search by firstName
      if (employees.isEmpty) {
        querySnapshot = await _firestore
            .collection('Regemp')
            .where('firstName', isEqualTo: parts[0])
            .get();

        employees = querySnapshot.docs.map((doc) => doc.data()).toList();
      }

      // If still no results, search by lastName
      if (employees.isEmpty) {
        querySnapshot = await _firestore
            .collection('Regemp')
            .where('lastName', isEqualTo: parts[0])
            .get();

        employees = querySnapshot.docs.map((doc) => doc.data()).toList();
      }

      // If still no results, try searching by full name
      if (employees.isEmpty && parts.length > 1) {
        String fullNameQuery = '${parts[0]} ${parts[1]}';
        querySnapshot = await _firestore
            .collection('Regemp')
            .where('fullName', isEqualTo: fullNameQuery)
            .get();

        employees = querySnapshot.docs.map((doc) => doc.data()).toList();
      }

      return employees;
    } catch (e) {
      print('Error searching employees: $e');
      throw e;
    }
  }

  Future<void> _showLeaveDetails() async {
  String employeeId = employeeIdController.text;
  String fromDateStr = fromDateController.text;
  String toDateStr = toDateController.text;

  if (employeeId.isNotEmpty &&
      fromDateStr.isNotEmpty &&
      toDateStr.isNotEmpty) {
    try {
      DateTime fromDate = dateFormat.parse(fromDateStr);
      DateTime toDate = dateFormat.parse(toDateStr);

      String fromDateFormatted = dateFormat.format(fromDate);
      String toDateFormatted = dateFormat.format(toDate);

      List<Map<String, dynamic>>? details = await _leaveTypesService
          .fetchLeaveByDate(employeeId, fromDateFormatted, toDateFormatted);

      if (details != null && details.isNotEmpty) {
        setState(() {
          leaveDetails = details as Map<String, dynamic>?;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('No leave details found for the specified dates.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching leave details: $e')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Please enter employee ID, from date, and to date.')),
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

  Widget _buildSearchResults() {
    if (!showSearchResults) return Container();

    return Column(
      children: searchResults.map((result) {
        String fullName = '${result['firstName']} ${result['lastName']}';
        String employeeId = result['employeeId'];

        return ListTile(
          title: Text(fullName),
          subtitle: Text(employeeId),
          onTap: () {
            setState(() {
              employeeIdController.text = employeeId;
              showSearchResults = false;
              searchResults = [];
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Leave Application'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TextFormField(
              controller: employeeIdSearchController,
              decoration: InputDecoration(
                labelText: 'Search Employee ID or Name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    if (employeeIdSearchController.text.isNotEmpty) {
                      try {
                        List<Map<String, dynamic>> results =
                            await searchEmployees(
                                employeeIdSearchController.text);
                        setState(() {
                          searchResults = results;
                          showSearchResults = true;
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text('Failed to fetch search results: $e')));
                      }
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20.0),
            _buildSearchResults(),
            if (!showSearchResults) ...[
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: employeeIdController,
                      decoration: InputDecoration(
                          label: _buildLabelWithStar('Employee ID')),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an employee ID';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.0),
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
                          if (selectedLeaveType == 'Partial Leave') {
                            numberOfDaysController.text = '0.5';
                            fromDateController.text = '';
                            toDateController.text = '';
                          } else {
                            numberOfDaysController.text = '0';
                          }
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
                    SizedBox(height: 12.0),
                    TextFormField(
                      controller: fromDateController,
                      decoration: InputDecoration(
                        label: _buildLabelWithStar('From Date'),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                fromDateController.text =
                                    dateFormat.format(pickedDate);
                                calculateDays();
                              });
                            }
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a from date';
                        }
                        return null;
                      },
                      readOnly: true,
                    ),
                    SizedBox(height: 12.0),
                    if (selectedLeaveType != 'Partial Leave')
                      TextFormField(
                        controller: toDateController,
                        decoration: InputDecoration(
                          label: _buildLabelWithStar('To Date'),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  toDateController.text =
                                      dateFormat.format(pickedDate);
                                  calculateDays();
                                });
                              }
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a to date';
                          }
                          return null;
                        },
                        readOnly: true,
                      ),
                    SizedBox(height: 12.0),
                    TextFormField(
                      controller: numberOfDaysController,
                      decoration: InputDecoration(
                        label: _buildLabelWithStar('Number of Days'),
                        suffixIcon: Icon(Icons.event_note),
                      ),
                      readOnly: true,
                    ),
                    SizedBox(height: 12.0),
                    TextFormField(
                      controller: leaveReasonController,
                      decoration: InputDecoration(label: Text('Leave Reason')),
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            DateTime fromDate =
                                dateFormat.parse(fromDateController.text);
                            DateTime? toDate;
                            if (toDateController.text.isNotEmpty) {
                              toDate = dateFormat.parse(toDateController.text);
                            }

                            await applyLeave(
                              employeeId: employeeIdController.text,
                              leaveType: selectedLeaveType,
                              fromDate: fromDate,
                              toDate: toDate,
                              numberOfDays:
                                  double.parse(numberOfDaysController.text),
                              leaveReason: leaveReasonController.text,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Leave applied successfully')));

                            // Clear form fields
                            employeeIdController.clear();
                            fromDateController.clear();
                            toDateController.clear();
                            leaveReasonController.clear();
                            numberOfDaysController.text = '0';

                            setState(() {
                              leaveDetails =
                                  null; // Clear previous leave details
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Failed to apply leave: $e')));
                          }
                        }
                      },
                      child: Text('Apply Leave'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _showLeaveDetails,
                      child: Text('Details'),
                    ),
                    if (leaveDetails != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Leave Details:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Employee ID: ${leaveDetails!['employeeId']}'),
                            Text('Leave Type: ${leaveDetails!['leaveType']}'),
                            Text(
                                'From Date: ${dateFormat.format((leaveDetails!['fromDate'] as Timestamp).toDate())}'),
                            Text(
                                'To Date: ${dateFormat.format((leaveDetails!['toDate'] as Timestamp).toDate())}'),
                            Text(
                                'Number of Days: ${leaveDetails!['numberOfDays']}'),
                            Text('Reason: ${leaveDetails!['leaveReason']}'),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ]
          ]),
        ));
  }
}