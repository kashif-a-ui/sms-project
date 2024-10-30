import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/master.dart';
import 'teachers.dart';

class AddTeacher extends StatefulWidget {
  const AddTeacher({
    Key? key,
  }) : super(key: key);

  @override
  State<AddTeacher> createState() => _AddTeacherState();
}

class _AddTeacherState extends State<AddTeacher> {
  final nameCont = TextEditingController();
  final fNameCont = TextEditingController();
  final qualificationCont = TextEditingController();
  final classCont = TextEditingController();
  final emailCont = TextEditingController();
  final passCont = TextEditingController();
  String? _chosenClass;
  List<String> drops = ['1', '2', '3', '4', '5'];
  final _formKey = GlobalKey<FormState>();
  bool loading = false, incharge = false;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Teacher'),
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
                  const Text('Teacher Name'),
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
                  const Text('Teacher Email'),
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
                  const Text('Teacher Password'),
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
                  const Text('Teacher Class'),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.black38)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: DropdownButton(
                        underline: const SizedBox(),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: drops.map<DropdownMenuItem<String>>((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              'Class $value',
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              maxLines: 2,
                            ),
                          );
                        }).toList(),
                        value: _chosenClass,
                        style: const TextStyle(color: black),
                        hint: const Text(
                          "Select Class",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                        onChanged: (String? value) {
                          _chosenClass = value;
                          log('_chosenClass: $_chosenClass');

                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: getHeight(context) * .02),
                  SwitchListTile(
                      value: incharge,
                      activeColor: pColor,
                      onChanged: (value) {
                        incharge = value;
                        setState(() {});
                      },
                      title: const Text('Make Class Incharge')),
                  SizedBox(height: getHeight(context) * .02),
                  const Text('Qualification'),
                  CreateCustomField(
                    text: 'Qualification',
                    controller: qualificationCont,
                    keyBoardType: TextInputType.text,
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
                          if (_chosenClass != null) {
                            uploadTeacher();
                          } else {
                            displayToast('Please Select Class');
                          }
                        }
                      }),
                ],
              ),
            ),
    );
  }

  void uploadTeacher() async {
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
      'email': emailCont.text,
      'password': passCont.text,
      'class': _chosenClass!,
      'qualification': qualificationCont.text,
      'id': token
    };
    log('saving in Teachers');
    await fireStore.collection('Teachers').doc(emailCont.text).set(data);
    log('saving in Classes');

    if (incharge) {
      await fireStore
          .collection('Classes')
          .doc('Class$_chosenClass')
          .set({"teacher": emailCont.text}).whenComplete(() async {
        log("Updated the incharge");
      }).catchError((e) => log(e));
    }

    log('Teacher info is added');

    setState(() => loading = false);
    Get.back();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Teachers()));
  }
}
