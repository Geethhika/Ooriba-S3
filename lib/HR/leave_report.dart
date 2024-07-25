//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
//import 'package:ooriba/services/employee_location_service.dart';
//import 'package:ooriba/services/retrieveDataByEmployeeId.dart';
//import 'package:permission_handler/permission_handler.dart';
//import 'package:path_provider/path_provider.dart';
//import 'dart:io';
//
//class LeaveReportPage extends StatefulWidget {
//  const LeaveReportPage({super.key});
//
//  @override
//  _LeaveReportPageState createState() => _LeaveReportPageState();
//}
//
//class _LeaveReportPageState extends State<LeaveReportPage> {
//  DateTime? _selectedDate;
//  Map<String, Map<String, String>> _data = {};
//  List<Map<String, dynamic>> _allEmployees = [];
//  bool _sortOrder = true;
//  String _selectedLocation = 'Berhampur';
//  final List<String> _locations = [];
//
//  String? selectedMonth;
//  List<String> months = [];
//  Map<String, int> employeeWorkingDays = {};
//
//  @override
//  void initState() {
//    super.initState();
//    _selectedDate = DateTime.now();
//    _initializeMonths();
//    _fetchAllEmployees();
//    _fetchData(DateFormat('yyyy-MM-dd').format(_selectedDate!));
//  }
//
//  void _initializeMonths() {
//    DateTime now = DateTime.now();
//    for (int i = 1; i <= now.month; i++) {
//      months.add(DateFormat.MMMM().format(DateTime(0, i)));
//    }
//  }
//
//  void _fetchAllEmployees() async {
//    FirestoreService firestoreService = FirestoreService();
//    _allEmployees = await firestoreService.getAllEmployees();
//    _locations.addAll(_allEmployees.map((e) => e['location'] ?? '').toSet().cast<String>());
//    _locations.removeWhere((element) => element == '');
//    setState(() {
//      _sortEmployees();
//    });
//  }
//
//  void _fetchData(String formattedDate) async {
//    // Fetch data based on the selected date
//    // Update _data variable
//  }
//
//  void _sortEmployees() {
//    _allEmployees.sort((a, b) {
//      int comparison = a['location'].compareTo(b['location']);
//      return _sortOrder ? comparison : -comparison;
//    });
//  }
//
//  List<Map<String, dynamic>> _filterEmployeesByLocation() {
//    return _allEmployees.where((employee) {
//      return employee['location'] == _selectedLocation;
//    }).toList();
//  }
//
//  Future<void> _downloadCsv() async {
//    await _calculateWorkingDays();
//    List<Map<String, dynamic>> filteredEmployees = _filterEmployeesByLocation();
//    StringBuffer csvContent = StringBuffer();
//    csvContent.writeln("EmployeeId,Name,Location,Phone No,Working Days");
//
//    for (var employee in filteredEmployees) {
//      String empId = employee['employeeId'] ?? 'Null';
//      String name = '${employee['firstName']} ${employee['lastName']}' ?? 'Null';
//      String location = employee['location'] ?? '';
//      String phoneNo = employee['phoneNo'] ?? 'Null';
//      int workingDays = employeeWorkingDays[empId] ?? 0;
//
//      csvContent.writeln('$empId,$name,$location,$phoneNo,$workingDays');
//    }
//
//    if (await Permission.storage.request().isGranted ||
//        await Permission.manageExternalStorage.request().isGranted) {
//      Directory? directory = await getExternalStorageDirectory();
//      String? downloadPath = Platform.isAndroid ? '/storage/emulated/0/Download' : directory?.path;
//
//      if (downloadPath != null) {
//        String path = '$downloadPath/attendance_${selectedMonth}_${DateTime.now().year}.csv';
//        File file = File(path);
//        await file.writeAsString(csvContent.toString());
//        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('CSV saved to $path')));
//      } else {
//        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to access storage directory')));
//      }
//    } else if (await Permission.storage.isDenied ||
//        await Permission.manageExternalStorage.isDenied) {
//      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Storage permission denied')));
//    } else if (await Permission.storage.isPermanentlyDenied ||
//        await Permission.manageExternalStorage.isPermanentlyDenied) {
//      openAppSettings();
//    }
//  }
//
//  Future<void> _calculateWorkingDays() async {
//    if (selectedMonth == null) return;
//
//    DateTime now = DateTime.now();
//    int monthIndex = months.indexOf(selectedMonth!) + 1;
//    DateTime firstDayOfMonth = DateTime(now.year, monthIndex, 1);
//    DateTime lastDayOfMonth = DateTime(now.year, monthIndex + 1, 0);
//
//    QuerySnapshot snapshot = await FirebaseFirestore.instance
//        .collection('employee_locations')
//        .where('timestamp', isGreaterThanOrEqualTo: firstDayOfMonth)
//        .where('timestamp', isLessThanOrEqualTo: lastDayOfMonth)
//        .get();
//
//    Map<String, Set<String>> employeeCheckInDays = {};
//
//    for (var doc in snapshot.docs) {
//      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//      data.forEach((employeeId, checkIns) {
//        if (employeeId != 'timestamp') {
//          for (var checkIn in checkIns) {
//            DateTime checkInDate = (checkIn['timestamp'] as Timestamp).toDate();
//            String dateKey = DateFormat('yyyy-MM-dd').format(checkInDate);
//            employeeCheckInDays.putIfAbsent(employeeId, () => {}).add(dateKey);
//          }
//        }
//      });
//    }
//
//    employeeCheckInDays.forEach((employeeId, days) {
//      employeeWorkingDays[employeeId] = days.length;
//    });
//
//    setState(() {});
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('Monthly Report'),
//      ),
//      body: Padding(
//        padding: const EdgeInsets.all(16.0),
//        child: Column(
//          children: [
//            DropdownButton<String>(
//              hint: Text('Select Month'),
//              value: selectedMonth,
//              items: months.map((String month) {
//                return DropdownMenuItem<String>(
//                  value: month,
//                  child: Text(month),
//                );
//              }).toList(),
//              onChanged: (String? newValue) {
//                setState(() {
//                  selectedMonth = newValue;
//                });
//              },
//            ),
//            SizedBox(height: 20),
//            if (selectedMonth != null)
//              IconButton(
//                icon: Icon(Icons.download),
//                onPressed: _downloadCsv,
//              ),
//          ],
//        ),
//      ),
//    );
//  }
//}
//