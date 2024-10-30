import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '/master.dart';
import '../admin/admin_home.dart';
import '../admin/admin_model.dart';
import '../admin/students/student_model.dart';
import '../admin/teachers/teacher_model.dart';
import '../student/student_home.dart';
import '../teacher/teacher_home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCont = TextEditingController();
  final passCont = TextEditingController();
  String? _chosenRole;
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  DateTime timeBackPressed = DateTime.now();
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final diff = DateTime.now().difference(timeBackPressed);
        final exitWarning = diff >= const Duration(seconds: 2);

        timeBackPressed = DateTime.now();

        if (exitWarning) {
          displayToast('Press back again to exit!');
          return false;
        } else {
          Fluttertoast.cancel();
          closeApp();
          return false;
        }
      },
      child: Scaffold(
        body: loading
            ? const Loader()
            : Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.symmetric(
                      horizontal: getWidth(context) * .04,
                      vertical: getHeight(context) * .02),
                  children: [
                    InkWell(
                        onTap: () {
                          //Get.to(() => AdminHome());
                        },
                        child: Image.asset('assets/login.png')),
                    SizedBox(height: getHeight(context) * .02),
                    const Text('Login',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                            color: pColor)),
                    const Text(
                      'Hello Sir, Welcome Back',
                      style: TextStyle(fontSize: 25),
                    ),
                    SizedBox(height: getHeight(context) * .02),
                    _chosenRole != null
                        ? const Text('Select Your Role',
                            style: TextStyle(fontWeight: FontWeight.w500))
                        : const SizedBox(),
                    Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom:
                                  BorderSide(width: 2, color: Colors.black))),
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: DropdownButton(
                        underline: const SizedBox(),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: drops.map<DropdownMenuItem<String>>((value) {
                          return DropdownMenuItem<String>(
                            value: value.id.toString(),
                            child: Text(
                              value.name,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              maxLines: 2,
                            ),
                          );
                        }).toList(),
                        value: _chosenRole,
                        style: const TextStyle(color: black),
                        hint: const Text(
                          "Select your Role",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                        onChanged: (String? value) {
                          setState(() {
                            _chosenRole = value;
                            log('_chosenRole: $_chosenRole');
                          });
                        },
                      ),
                    ),
                    SizedBox(height: getHeight(context) * .02),
                    Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom:
                                  BorderSide(width: 2, color: Colors.black))),
                      child: CreateCustomField(
                          controller: emailCont,
                          text: 'Email',
                          border: InputBorder.none,
                          keyBoardType: TextInputType.emailAddress,
                          validator: (value) {
                            Pattern pattern =
                                r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                                r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                                r"{0,253}[a-zA-Z0-9])?)*$";
                            RegExp regex = RegExp(pattern.toString());
                            if (value == null) {
                              return 'Enter an Email Address!';
                            } else if (!regex.hasMatch(value)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          }),
                    ),
                    SizedBox(height: getHeight(context) * .02),
                    Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom:
                                  BorderSide(width: 2, color: Colors.black))),
                      child: CreatePasswordField(
                        controller: passCont,
                        border: InputBorder.none,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Password';
                          } else if (value.length < 6) {
                            return 'Password must be 6 characters long';
                          }
                          return null;
                        },
                        onSubmit: (v) {
                          if (_formKey.currentState!.validate() &&
                              _chosenRole != null) {
                            doLogin();
                          }
                        },
                      ),
                    ),
                    SizedBox(height: getHeight(context) * .02),
                    CreateCustomButton(
                        text: 'Login',
                        onTap: () {
                          if (_formKey.currentState!.validate() &&
                              _chosenRole != null) {
                            doLogin();
                          }
                        })
                  ],
                ),
              ),
      ),
    );
  }

  // loading == true ? abc : xyz;

  doLogin() async {
    setState(() => loading = true);
    if (_chosenRole!.contains('1')) {
      adminLogin();
    } else if (_chosenRole!.contains('2')) {
      teacherLogin();
    } else {
      studentLogin();
    }
  }

  adminLogin() async {
    var collection = fireStore.collection('Admin');
    var docSnapshot = await collection.doc(emailCont.text).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      if (data != null) {
        log('Collection Found: ${data.toString()}');
        AdminModel model = AdminModel.fromJson(data);

        try {
          UserCredential result = await auth.signInWithEmailAndPassword(
              email: emailCont.text.trim(), password: passCont.text.trim());
          final User user = result.user!;
          setState(() => loading = false);
          if (result.user != null) {
            setUserDetails(
                token: user.uid,
                name: model.name,
                email: model.email,
                userType: _chosenRole!);
            Get.off(() => const AdminHome(), transition: Transition.size);
          } else {
            displayToast('invalid password is entered');
          }
        } on Exception catch (e) {
          setState(() => loading = false);
          log(e.toString());
          displayToast(e.toString().split(']').last);
        }
      } else {
        displayToast('does\'nt found user......');
      }
    } else {
      setState(() => loading = false);
      displayToast('invalid email address is entered');
    }
  }

  teacherLogin() async {
    var collection = fireStore.collection('Teachers');
    var docSnapshot = await collection.doc(emailCont.text).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      if (data != null) {
        log('Collection Found: ${data.toString()}');
        TeacherModel model = TeacherModel.fromJson(data);

        try {
          UserCredential result = await auth.signInWithEmailAndPassword(
              email: emailCont.text.trim(), password: passCont.text.trim());
          final User user = result.user!;
          setState(() => loading = false);
          if (result.user != null) {
            setUserDetails(
                token: user.uid,
                name: model.name,
                email: model.email,
                userType: _chosenRole!);
            setTeacherClass(tecClass: model.mClass);
            Get.off(() => const TeacherHome(), transition: Transition.size);
          } else {
            displayToast('invalid password is entered');
          }
        } on Exception catch (e) {
          setState(() => loading = false);
          log(e.toString());
          displayToast(e.toString().split(']').last);
        }
      } else {
        setState(() => loading = false);
        displayToast('does\'nt found user......');
      }
    } else {
      setState(() => loading = false);
      displayToast('invalid email address is entered');
    }
  }

  studentLogin() async {
    try {
      UserCredential result = await auth.signInWithEmailAndPassword(
          email: emailCont.text.trim(), password: passCont.text.trim());

      if (result.user != null) {
        final User user = result.user!;
        var collection = fireStore.collection('Students');
        var docSnapshot = await collection.doc(user.uid).get();
        if (docSnapshot.exists) {
          Map<String, dynamic>? data = docSnapshot.data();
          if (data != null) {
            log('Collection Found: ${data.toString()}');
            StudentModel model = StudentModel.fromJson(data);
            setUserDetails(
                token: user.uid,
                name: model.name,
                email: model.email,
                userType: _chosenRole!);
            setStudentClass(stuClass: model.studentClass);
            setStudentRoll(roll: model.rollNo);
            Get.off(() => const StudentHome(), transition: Transition.size);
          } else {
            setState(() => loading = false);
            displayToast('does\'nt found user......');
          }
        }
      } else {
        setState(() => loading = false);
        displayToast('invalid password is entered');
      }
    } on Exception catch (e) {
      setState(() => loading = false);
      log(e.toString());
      displayToast(e.toString().split(']').last);
    }
  }
}

class DropClass {
  final String name;
  final int id;

  DropClass({required this.name, required this.id});
}

List<DropClass> drops = [
  DropClass(name: 'Admin', id: 1),
  DropClass(name: 'Teacher', id: 2),
  DropClass(name: 'Student', id: 3)
];
