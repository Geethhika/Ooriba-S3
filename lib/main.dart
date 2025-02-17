import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ooriba/HR/hr_dashboard_page.dart';
import 'package:ooriba/firebase_options.dart';
import 'package:ooriba/post_login_page.dart';

import 'package:ooriba/services/auth_service.dart';
import 'package:ooriba/services/dark_mode.dart';
import 'package:ooriba/services/forgot_pass_service.dart';
import 'package:ooriba/signup_page.dart';
import 'package:ooriba/siteManager/siteManagerDashboard.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'Admin/admin_dashboard_page.dart'; // Import the admin.dart file
import 'services/admin/logo_service.dart';
import 'services/company_name_service.dart';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('Handling a background message: ${message.messageId}');
// }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _requestPermissions();
  final AuthService authService = AuthService();
  final String? email = await authService.getUserSession();
  final String? role = await authService.getUserRole();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(OoribaApp(isLoggedIn: email != null, email: email, userRole: role));
}

Future<void> _requestPermissions() async {
  PermissionStatus status = await Permission.storage.request();
  if (status.isGranted) {
    print('Storage permission granted');
  } else if (status.isDenied) {
    print('Storage permission denied');
  } else if (status.isPermanentlyDenied) {
    print('Storage permission permanently denied');
    openAppSettings();
  }
}

class OoribaApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? userRole;
  final String? email;

  const OoribaApp({
    Key? key,
    required this.isLoggedIn,
    required this.email,
    required this.userRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DarkModeService()),
        ChangeNotifierProvider(create: (_) => CompanyNameService()),
        ChangeNotifierProvider(create: (_) => LogoService()),
      ],
      child: Consumer3<DarkModeService, CompanyNameService, LogoService>(
        builder:
            (context, darkModeService, companyNameService, logoService, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: companyNameService.companyName,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.dark,
            ),
            themeMode:
                darkModeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: _getInitialPage(isLoggedIn, email, userRole),
          );
        },
      ),
    );
  }

  Widget _getInitialPage(bool isLoggedIn, String? email, String? role) {
    if (!isLoggedIn) {
      return LoginPage();
    } else if (role == 'HR') {
      return const HRDashboardPage();
    } else if (role == 'SiteManager') {
      return Sitemanagerdashboard(phoneNumber: email ?? '', userDetails: {});
    } else if (role == 'Standard') {
      return PostLoginPage(phoneNumber: email ?? '', userDetails: {});
    } else if (role == 'Admin') {
      return AdminDashboardPage();
    } else {
      return LoginPage();
    }
  }
}

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  Widget build(BuildContext context) {
    final darkModeService =
        Provider.of<DarkModeService>(context, listen: false);
    final companyNameService = Provider.of<CompanyNameService>(context);
    final logoService = Provider.of<LogoService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(companyNameService.companyName),
        actions: [
          IconButton(
            icon: Icon(darkModeService.isDarkMode
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () {
              darkModeService.toggleDarkMode();
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 400, // Limit the width for larger screens
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Welcome To ${companyNameService.companyName}',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            logoService.logo != null
                                ? Image.file(
                                    logoService.logo!,
                                    width: 200,
                                    height: 190,
                                  )
                                : logoService.logoUrl != null
                                    ? Image.network(
                                        logoService.logoUrl!,
                                        width: 200,
                                        height: 190,
                                      )
                                    : Image.asset(
                                        'assets/images/companyLogo.png',
                                        width: 200,
                                        height: 190,
                                      ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _identifierController,
                          decoration: const InputDecoration(
                            filled: true,
                            labelText: 'Email ID or Phone Number',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              _showForgotPasswordDialog(context);
                            },
                            child: const Text('Forgot Password'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            bool success = await AuthService().signin(
                              identifier: _identifierController.text,
                              password: _passwordController.text,
                              context: context,
                            );
                            if (success) {
                              // Navigation is handled within AuthService
                            }
                          },
                          child: const Text('Sign In'),
                        ),
                        const SizedBox(height: 20),
                        RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color),
                            children: [
                              TextSpan(
                                text: 'Sign Up here',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SignUpPage()),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // ElevatedButton(
                        //   onPressed: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => AdminDashboardPage(),
                        //       ),
                        //     );
                        //   },
                        //   child: const Text('Admin'),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Enter your email',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text;
                if (email.isNotEmpty) {
                  await ForgetPassService()
                      .sendPasswordResetEmail(email, context);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter an email address'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Reset Password'),
            ),
          ],
        );
      },
    );
  }
}





// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:ooriba_s3/HR/hr_dashboard_page.dart';
// import 'package:ooriba_s3/firebase_options.dart';
// import 'package:ooriba_s3/post_login_page.dart';
// import 'package:ooriba_s3/services/auth_service.dart';
// import 'package:ooriba_s3/services/dark_mode.dart';
// import 'package:ooriba_s3/services/forgot_pass_service.dart';
// import 'package:ooriba_s3/signup_page.dart';
// import 'package:ooriba_s3/siteManager/siteManagerDashboard.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
// import 'Admin/admin_dashboard_page.dart'; // Import the admin.dart file
// import 'services/company_name_service.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   await _requestPermissions();
//   final AuthService authService = AuthService();
//   final String? email = await authService.getUserSession();
//   final String? role = await authService.getUserRole();

//   runApp(OoribaApp(isLoggedIn: email != null, email: email, userRole: role));
// }

// Future<void> _requestPermissions() async {
//   PermissionStatus status = await Permission.storage.request();
//   if (status.isGranted) {
//     print('Storage permission granted');
//   } else if (status.isDenied) {
//     print('Storage permission denied');
//   } else if (status.isPermanentlyDenied) {
//     print('Storage permission permanently denied');
//     openAppSettings();
//   }
// }

// class OoribaApp extends StatelessWidget {
//   final bool isLoggedIn;
//   final String? userRole;
//   final String? email;

//   const OoribaApp({
//     Key? key,
//     required this.isLoggedIn,
//     required this.email,
//     required this.userRole,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => DarkModeService()),
//         ChangeNotifierProvider(create: (_) => CompanyNameService()),
//       ],
//       child: Consumer2<DarkModeService, CompanyNameService>(
//         builder: (context, darkModeService, companyNameService, _) {
//           return MaterialApp(
//             debugShowCheckedModeBanner: false,
//             title: companyNameService.companyName,
//             theme: ThemeData(
//               primarySwatch: Colors.blue,
//               brightness: Brightness.light,
//             ),
//             darkTheme: ThemeData(
//               primarySwatch: Colors.blue,
//               brightness: Brightness.dark,
//             ),
//             themeMode:
//                 darkModeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
//             home: _getInitialPage(isLoggedIn, email, userRole),
//           );
//         },
//       ),
//     );
//   }

//   Widget _getInitialPage(bool isLoggedIn, String? email, String? role) {
//     if (!isLoggedIn) {
//       return LoginPage();
//     } else if (role == 'HR') {
//       return const HRDashboardPage();
//     } else if (role == 'SiteManager') {
//       return Sitemanagerdashboard(phoneNumber: email ?? '', userDetails: {});
//     } else {
//       return PostLoginPage(phoneNumber: email ?? '', userDetails: {});
//     }
//   }
// }

// class LoginPage extends StatelessWidget {
//   LoginPage({super.key});

//   final TextEditingController _identifierController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final darkModeService =
//         Provider.of<DarkModeService>(context, listen: false);
//     final companyNameService = Provider.of<CompanyNameService>(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(companyNameService.companyName),
//         actions: [
//           IconButton(
//             icon: Icon(darkModeService.isDarkMode
//                 ? Icons.light_mode
//                 : Icons.dark_mode),
//             onPressed: () {
//               darkModeService.toggleDarkMode();
//             },
//           ),
//         ],
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Center(
//                 child: ConstrainedBox(
//                   constraints: const BoxConstraints(
//                     maxWidth: 400, // Limit the width for larger screens
//                   ),
//                   child: Container(
//                     padding: const EdgeInsets.all(16.0),
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).colorScheme.surface,
//                       borderRadius: BorderRadius.circular(10),
//                       boxShadow: const [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 10,
//                           offset: Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         Text(
//                           'Welcome To ${companyNameService.companyName}',
//                           style: const TextStyle(
//                               fontSize: 24, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: <Widget>[
//                             Image.asset(
//                               'assets/images/companyLogo.png',
//                               width: 200,
//                               height: 190,
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         TextField(
//                           controller: _identifierController,
//                           decoration: const InputDecoration(
//                             filled: true,
//                             labelText: 'Email ID or Phone Number',
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         TextField(
//                           controller: _passwordController,
//                           decoration: const InputDecoration(
//                             labelText: 'Password',
//                             border: OutlineInputBorder(),
//                           ),
//                           obscureText: true,
//                         ),
//                         const SizedBox(height: 10),
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: TextButton(
//                             onPressed: () {
//                               _showForgotPasswordDialog(context);
//                             },
//                             child: const Text('Forgot Password'),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         ElevatedButton(
//                           onPressed: () async {
//                             bool success = await AuthService().signin(
//                               identifier: _identifierController.text,
//                               password: _passwordController.text,
//                               context: context,
//                             );
//                             if (success) {
//                               // Navigation is handled within AuthService
//                             }
//                           },
//                           child: const Text('Sign In'),
//                         ),
//                         const SizedBox(height: 20),
//                         RichText(
//                           text: TextSpan(
//                             text: "Don't have an account? ",
//                             style: TextStyle(
//                                 color: Theme.of(context)
//                                     .textTheme
//                                     .bodyLarge!
//                                     .color),
//                             children: [
//                               TextSpan(
//                                 text: 'Sign Up here',
//                                 style: const TextStyle(
//                                   color: Colors.blue,
//                                   decoration: TextDecoration.underline,
//                                 ),
//                                 recognizer: TapGestureRecognizer()
//                                   ..onTap = () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) =>
//                                               const SignUpPage()),
//                                     );
//                                   },
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         ElevatedButton(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => AdminDashboardPage(),
//                               ),
//                             );
//                           },
//                           child: const Text('Admin'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   void _showForgotPasswordDialog(BuildContext context) {
//     final TextEditingController emailController = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Reset Password'),
//           content: TextField(
//             controller: emailController,
//             decoration: const InputDecoration(
//               labelText: 'Enter your email',
//               border: OutlineInputBorder(),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 final email = emailController.text;
//                 if (email.isNotEmpty) {
//                   await ForgetPassService()
//                       .sendPasswordResetEmail(email, context);
//                   Navigator.of(context).pop();
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Please enter an email address'),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                 }
//               },
//               child: const Text('Reset Password'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }