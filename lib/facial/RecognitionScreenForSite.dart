import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:ooriba/facial/ML/Recognition.dart';
import 'package:ooriba/facial/ML/Recognizer.dart';
import 'package:ooriba/services/employee_location_service.dart';
import 'package:ooriba/services/geo_service.dart';
import 'package:ooriba/services/retrieveDataByEmployeeId.dart';
import 'package:ooriba/services/user.dart';
import 'package:ooriba/siteManager/siteManagerDashboard.dart';

class RecognitionScreen extends StatefulWidget {
  final String phoneNumber;
  final Map<String, dynamic> userDetails;
  const RecognitionScreen(
      {super.key, required this.phoneNumber, required this.userDetails});

  @override
  State<RecognitionScreen> createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends State<RecognitionScreen> {
  late ImagePicker imagePicker;
  File? _image;
  bool isLoading = false; // Loading state
  Map<String, dynamic> Employee = {};
  late FaceDetector faceDetector;
  late Recognizer recognizer;
  final UserFirestoreService firestoreService = UserFirestoreService();
  DateTime? checkInTime;
  DateTime? checkOutTime;
  final EmployeeLocationService employeeLocationService =
      EmployeeLocationService();
  final GeoService geoService = GeoService();

  List<Recognition> recognitions = [];

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    final options = FaceDetectorOptions();
    faceDetector = FaceDetector(options: options);
    recognizer = Recognizer();
    _imgFromCamera(); // Call the camera function immediately when the screen loads
  }

  _imgFromCamera() async {
    setState(() {
      isLoading = true;
    });

    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await doFaceDetection();
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> uploadImageToFirebase(File image, String employeeId) async {
    // final FirestoreService firestoreService = FirestoreService();
    // Map<String, dynamic>? employeeData = await firestoreService.getEmployeeByEmailOrPhoneNo("9315690342","Regemp");
    // String id=employeeData?["employeeId"];
    try {
      String imagePath = 'authImage/$employeeId.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(imagePath);
      await storageRef.putFile(image);
    } catch (e) {
      print("Error uploading image to Firebase Storage: $e");
    }
  }

  Future<void> _toggleCheckInCheckOut(String employeeId) async {
    DateTime now = DateTime.now();
    await firestoreService.toggleCheckInCheckOut(employeeId, now);

    final checkInOutData =
        await firestoreService.getCheckInOutDataByEmployeeId(employeeId, now);
    setState(() {
      checkInTime = checkInOutData['checkIn'];
      checkOutTime = checkInOutData['checkOut'];
    });

    Position position = await geoService.determinePosition();
    await employeeLocationService.saveEmployeeLocation(
        employeeId!, position, now, 'check-in'); // Save location
  }

  List<Face> faces = [];
  doFaceDetection() async {
    recognitions.clear();
    _image = await removeRotation(_image!);

    image = await _image?.readAsBytes();
    image = await decodeImageFromList(image);

    InputImage inputImage = InputImage.fromFile(_image!);
    faces = await faceDetector.processImage(inputImage);
    for (Face face in faces) {
      Rect faceRect = face.boundingBox;
      num left = faceRect.left < 0 ? 0 : faceRect.left;
      num top = faceRect.top < 0 ? 0 : faceRect.top;
      num right =
          faceRect.right > image.width ? image.width - 1 : faceRect.right;
      num bottom =
          faceRect.bottom > image.height ? image.height - 1 : faceRect.bottom;
      num width = right - left;
      num height = bottom - top;

      final bytes = _image!.readAsBytesSync();
      img.Image? faceImg = img.decodeImage(bytes);
      img.Image faceImg2 = img.copyCrop(faceImg!,
          x: left.toInt(),
          y: top.toInt(),
          width: width.toInt(),
          height: height.toInt());

      Recognition recognition = recognizer.recognize(faceImg2, faceRect);
      recognitions.add(recognition);
    }
    await drawRectangleAroundFaces();
  }

  removeRotation(File inputImage) async {
    final img.Image? capturedImage =
        img.decodeImage(await File(inputImage.path).readAsBytes());
    final img.Image orientedImage = img.bakeOrientation(capturedImage!);
    return await File(_image!.path).writeAsBytes(img.encodeJpg(orientedImage));
  }

  var image;
  drawRectangleAroundFaces() async {
    image = await _image?.readAsBytes();
    image = await decodeImageFromList(image);
    setState(() {
      recognitions;
      image;
      faces;
    });

    if (_image != null && isFaceRecognized()) {
      // Automatically trigger the arrow button's action
      // await uploadImageToFirebase(_image!, widget.phoneNumber);
      // Navigator.pop(context, true);
    }
  }

  bool isFaceRecognized() {
    return recognitions.any((recognition) => recognition.distance < 1);
  }

  void goback() async {
    setState(() {
      isLoading = true;
    });
    if (_image != null && isFaceRecognized()) {
      String employeeId =
          recognitions.first.name; // Assuming only one face is recognized
      await uploadImageToFirebase(_image!, employeeId);
      await _toggleCheckInCheckOut(employeeId);
    }
    setState(() {
      isLoading = false;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Sitemanagerdashboard(
            phoneNumber: widget.phoneNumber, userDetails: {}),
      ),
    );
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          image != null
              ? Container(
                  margin: const EdgeInsets.only(
                      top: 60, left: 30, right: 30, bottom: 0),
                  child: FittedBox(
                    child: SizedBox(
                      width: image.width.toDouble(),
                      height: image.width.toDouble(),
                      child: CustomPaint(
                        painter: FacePainter(
                            facesList: recognitions, imageFile: image),
                      ),
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(top: 100),
                  child: Image.asset(
                    "assets/images/logo.png",
                    width: screenWidth - 100,
                    height: screenWidth - 100,
                  ),
                ),
          if (isLoading) // Show loading icon while processing
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: const CircularProgressIndicator(),
            ),
          if (!isLoading && _image != null && !isFaceRecognized())
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "No face recognized. Please try again.",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          Container(
            margin: const EdgeInsets.only(bottom: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Card(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(200))),
                  child: InkWell(
                    onTap: () async {
                      await _imgFromCamera();
                    },
                    child: SizedBox(
                      width: screenWidth / 2 - 70,
                      height: screenWidth / 2 - 70,
                      child: Icon(Icons.camera,
                          color: const Color.fromARGB(255, 243, 33, 33),
                          size: screenWidth / 7),
                    ),
                  ),
                ),
                Card(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(200))),
                  child: InkWell(
                    onTap: () async {
                      goback(); // Add your action here
                    },
                    child: SizedBox(
                      width: screenWidth / 2 - 70,
                      height: screenWidth / 2 - 70,
                      child: Icon(Icons.arrow_forward,
                          color: const Color.fromARGB(255, 33, 243, 33),
                          size: screenWidth / 7),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class FacePainter extends CustomPainter {
  List<Recognition> facesList;
  dynamic imageFile;
  FacePainter({required this.facesList, @required this.imageFile});

  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      canvas.drawImage(imageFile, Offset.zero, Paint());
    }

    Paint p = Paint();
    p.color = Colors.red;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 3;

    for (Recognition rectangle in facesList) {
      canvas.drawRect(rectangle.location, p);
      TextSpan span = TextSpan(
          style: const TextStyle(
              color: Colors.black, fontSize: 100, fontWeight: FontWeight.bold),
          text: "${rectangle.name}  ${rectangle.distance.toStringAsFixed(2)}");
      TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(rectangle.location.left, rectangle.location.top));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
