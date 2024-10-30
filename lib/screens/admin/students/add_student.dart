import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms/screens/admin/students/students.dart';

import '/master.dart';

class AddStudent extends StatefulWidget {
  final String className;
  final int classTotal;

  const AddStudent(
      {Key? key, required this.className, required this.classTotal})
      : super(key: key);

  @override
  State<AddStudent> createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
  final nameCont = TextEditingController();
  final fNameCont = TextEditingController();
  final rollCont = TextEditingController();
  final classCont = TextEditingController();
  final emailCont = TextEditingController();
  final passCont = TextEditingController();
  String? _chosenClass;
  List<String> drops = ['1', '2', '3', '4', '5'];
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  int roll = 0;

  @override
  void initState() {
    int serial = 100 * int.parse(widget.className);
    roll = serial + widget.classTotal + 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Student'),
      ),
      body: loading
          ? const Loader()
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(
                    horizontal: getWidth(context) * .04,
                    vertical: getHeight(context) * .02),
                children: [
                  const Text('Student Name'),
                  CreateCustomField(
                    text: 'Name',
                    controller: nameCont,
                    keyBoardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter student name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: getHeight(context) * .02),
                  const Text('Father Name'),
                  CreateCustomField(
                    text: 'Father Name',
                    controller: fNameCont,
                    keyBoardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter father name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: getHeight(context) * .02),
                  const Text('Student Email'),
                  CreateCustomField(
                    text: 'Email',
                    controller: emailCont,
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
                    },
                  ),
                  SizedBox(height: getHeight(context) * .02),
                  const Text('Student Password'),
                  CreatePasswordField(
                      controller: passCont,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Password';
                        } else if (value.length < 6) {
                          return 'Password must be 6 characters long';
                        }
                        return null;
                      }),
                  SizedBox(height: getHeight(context) * .02),
                  const Text('Student Class'),
                  CreateCustomField(
                    text: 'Class',
                    controller: classCont,
                    keyBoardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    enabled: false,
                    label: widget.className,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter class';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: getHeight(context) * .02),
                  const Text('Roll No'),
                  CreateCustomField(
                    text: 'Roll No',
                    controller: rollCont,
                    label: '$roll',
                    enabled: false,
                    keyBoardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter roll no';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: getHeight(context) * .02),
                  CreateCustomButton(
                      text: 'Save',
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          log('email: ${emailCont.text}');
                          log('password: ${passCont.text}');
                          uploadStudent();
                        }
                      }),
                ],
              ),
            ),
    );
  }

  void uploadStudent() async {
    setState(() => loading = true);
    String token = '';
    try {
      FirebaseAuth auth = FirebaseAuth.instance;

      UserCredential result = await auth.createUserWithEmailAndPassword(
          email: emailCont.text, password: passCont.text);

      token = result.user!.uid;

      log('new User: $token');
    } catch (e) {
      setState(() => loading = false);
      displayToast(e.toString());
      return;
    }

    final data = {
      'name': nameCont.text,
      'father_name': fNameCont.text,
      'email': emailCont.text,
      'password': passCont.text,
      'class': classCont.text,
      'roll_no': rollCont.text,
      'id': token
    };
    log('saving in Students');
    await fireStore.collection('Students').doc(token).set(data);
    log('saving in Classes');
    await fireStore
        .collection('Classes/Class${widget.className}/Students')
        .doc(token)
        .set(data);

    log('student info is added');

    setState(() => loading = false);
    Get.back();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Students()));
  }
}
