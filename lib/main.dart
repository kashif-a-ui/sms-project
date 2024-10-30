import 'dart:async';
import 'dart:developer';

import 'package:calendar_view/calendar_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sms/screens/admin/admin_home.dart';
import 'package:animate_do/animate_do.dart';
import 'master.dart';
import 'screens/login/login.dart';
import 'screens/student/student_home.dart';
import 'screens/teacher/teacher_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(CalendarControllerProvider(
    controller: EventController(),
    child: GetMaterialApp(
      theme: ThemeData(
          scaffoldBackgroundColor: bColor,
          floatingActionButtonTheme:
              const FloatingActionButtonThemeData(backgroundColor: pColor),
          primaryColor: pColor,
          appBarTheme: const AppBarTheme(
              color: pColor,
              systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: pColor)),
          iconTheme: const IconThemeData(color: pColor)),
      home: const MyApp(),
      debugShowCheckedModeBanner: false,
    ),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    Timer(const Duration(milliseconds: 2200), checkFirst);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Center(
              child: SpinPerfect(
                  duration: const Duration(milliseconds: 1700),
                  child: Image.asset('assets/logo.png')))),
    );
  }

  checkFirst() async {
    int userType = await getUserType();
    log('userType: $userType');
    if (userType != -1) {
      if (userType == 1) {
        Get.off(() => const AdminHome());
      } else if (userType == 2) {
        Get.off(() => const TeacherHome());
      } else {
        Get.off(() => const StudentHome());
      }
    } else {
      Get.off(() => const LoginPage());
    }
  }
}
