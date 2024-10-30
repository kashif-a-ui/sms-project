import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '/master.dart';
import '../teachers/teacher_model.dart';
import 'add_teacher.dart';

class Teachers extends StatefulWidget {
  const Teachers({Key? key}) : super(key: key);

  @override
  State<Teachers> createState() => _TeachersState();
}

class _TeachersState extends State<Teachers> {
  bool loading = false;
  List<TeacherModel> teachers = [];
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  int total = 0;
  String teacherName = '';

  final nameCont = TextEditingController();
  final emailCont = TextEditingController();
  final qualifyCont = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teachers'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddTeacher()),
        child: const Text('Add'),
      ),
      body: loading
          ? const Loader()
          : ListView(
              padding: EdgeInsets.symmetric(
                  horizontal: getWidth(context) * .04,
                  vertical: getHeight(context) * .02),
              children: [
                SizedBox(height: getHeight(context) * .02),
                teachers.isNotEmpty
                    ? ListView.builder(
                        itemBuilder: (context, index) {
                          final item = teachers[index];
                          return Card(
                            color: pColor,
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Card(
                                margin:
                                    const EdgeInsets.only(left: 8, bottom: 1),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        item.incharge
                                            ? const Card(
                                                margin: EdgeInsets.zero,
                                                color: pColor,
                                                child: Padding(
                                                  padding: EdgeInsets.all(12),
                                                  child: Text('Incharge',
                                                      style: TextStyle(
                                                          color: white,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                              )
                                            : const SizedBox(),
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: PopupMenuButton(
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                textStyle:
                                                    TextStyle(color: blue),
                                                child: Text('Edit'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                textStyle:
                                                    TextStyle(color: red),
                                                child: Text('Delete'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'classIncharge',
                                                textStyle:
                                                    TextStyle(color: pColor),
                                                child: Text('Class Incharge'),
                                              ),
                                            ],
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  context: context,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  builder: (BuildContext bc) {
                                                    return StatefulBuilder(
                                                        builder: (context,
                                                            setBottomState) {
                                                      return createBottomSheet(
                                                          model: item);
                                                    });
                                                  },
                                                );
                                              } else if (value == 'delete') {
                                                // Handle delete action
                                                showConfirmationDialog(context,
                                                    teacher: item);
                                              } else if (value ==
                                                  'classIncharge') {
                                                // Handle Class Incharge action
                                                showConfirmationDialog(context,
                                                    teacher: item,
                                                    deleting: false);
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: getHeight(context) * .02),
                                      child: Center(
                                        child: CircleAvatar(
                                          minRadius: 52,
                                          backgroundColor: pColor,
                                          child: CircleAvatar(
                                            backgroundColor:
                                                Colors.green.shade50,
                                            minRadius: 50,
                                            child: Text(
                                                getInitials(
                                                    teachers[index].name),
                                                style:
                                                    GoogleFonts.rubikMoonrocks(
                                                        fontSize: 35,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: pColor)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      dense: true,
                                      leading: const Text('Name:'),
                                      trailing: Text(teachers[index].name,
                                          style: const TextStyle(
                                              color: pColor,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    ListTile(
                                      dense: true,
                                      leading: const Text('Email:'),
                                      trailing: Text(teachers[index].email,
                                          style: const TextStyle(
                                              color: pColor,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    ListTile(
                                      dense: true,
                                      leading: const Text('Qualification:'),
                                      trailing: Text(
                                          teachers[index].qualification,
                                          style: const TextStyle(
                                              color: pColor,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    ListTile(
                                      dense: true,
                                      leading: const Text('Class In-charge:'),
                                      trailing: Text(teachers[index].mClass,
                                          style: const TextStyle(
                                              color: pColor,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  ],
                                )),
                          );
                        },
                        itemCount: teachers.length,
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                      )
                    : const Text('No Teachers data found')
              ],
            ),
    );
  }

  void showConfirmationDialog(BuildContext context,
      {required TeacherModel teacher, bool deleting = true}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(deleting ? 'Delete Teacher' : 'Make Class Incharge'),
          content: Text(deleting
              ? 'Are you sure you want to delete teacher ${teacher.name}?'
              : 'Are you sure you want to make ${teacher.name} class Incharge?'),
          actions: [
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(color: deleting ? pColor : red)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text(deleting ? 'Delete' : 'Confirm',
                  style: TextStyle(color: deleting ? red : pColor)),
              onPressed: () {
                deleting ? deleteTeacher(teacher) : makeIncharge(teacher);
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void fetchData() async {
    teachers.clear();
    teacherName = '';
    setState(() => loading = true);
    fireStore.collection("Teachers").orderBy('class').get().then((value) {
      for (var teacherData in value.docs) {
        log("teacherData = ${teacherData.data()}");

        teachers.add(TeacherModel.fromJson(teacherData.data()));
      }
      total = teachers.length;
      log('total teachers: $total');
      setState(() => loading = false);
    });
  }

  void addData() async {
    setState(() => loading = true);

    var doc = fireStore.collection('Teachers').doc(emailCont.text);

    final data = {
      'name': nameCont.text,
      "qualification": qualifyCont.text,
    };

    await doc.update(data);

    nameCont.clear();
    emailCont.clear();
    qualifyCont.clear();

    setState(() => loading = false);
    showSuccessToast(
        context: context, text: 'Teacher Info Updated Successfully');

    fetchData();
  }

  createBottomSheet({required TeacherModel model}) {
    return Card(
      color: shimmerColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Form(
        key: _formKey,
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Text('Edit Teacher Info',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CreateCustomField(
                  text: 'Title',
                  controller: nameCont,
                  label: model.name,
                  autoFocus: true,
                  keyBoardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the Name';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CreateCustomField(
                  text: 'Email',
                  controller: emailCont,
                  label: model.email,
                  enabled: false,
                  keyBoardType: TextInputType.text,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CreateCustomField(
                  text: 'Qualification',
                  controller: qualifyCont,
                  label: model.qualification,
                  keyBoardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the Qualification';
                    }
                    return null;
                  },
                ),
              ),
              CreateCustomButton(
                  width: getWidth(context) * .9,
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      Get.back();
                      addData();
                    }
                  },
                  text: 'Update',
                  buttonColor: pColor),
              SizedBox(height: getHeight(context) * .02)
            ],
          ),
        ),
      ),
    );
  }

  void deleteTeacher(TeacherModel teacher) async {
    setState(() => loading = true);

    var collection = fireStore.collection('Classes');
    var docSnapshot = await collection.doc('Class${teacher.mClass}').get();

    if (docSnapshot.exists) {
      Map<String, dynamic>? mData = docSnapshot.data();
      if (mData != null) {
        log(mData.toString());

        String inchargeId = mData['teacher'] ?? '';

        if (inchargeId.contains(teacher.email)) {
          setState(() => loading = false);
          showErrorToast(
              context: context, text: 'You cannot delete Class incharge!!');
          return;
        } else {
          var tCollection = fireStore.collection('Teachers');
          await tCollection.doc(teacher.email).delete();

          displayToast('Teacher deleted successfully!!');
          setState(() => loading = false);
          fetchData();
        }
      }
    }
  }

  void makeIncharge(TeacherModel teacher) async {
    setState(() => loading = true);
    await fireStore
        .collection('Classes')
        .doc('Class${teacher.mClass}')
        .set({"teacher": teacher.email}).whenComplete(() async {
      await fireStore
          .collection('Teachers')
          .doc(teacher.email)
          .update({"incharge": true}).whenComplete(() async {
        log("made the incharge");
      }).catchError((e) => log(e));
      log("Updated the incharge");
    }).catchError((e) => log(e));

    //previous incharge is no mera class incharge
    for (final item in teachers) {
      if ((item.mClass == teacher.mClass) && (item.incharge)) {
        await fireStore
            .collection('Teachers')
            .doc(item.email)
            .update({"incharge": false}).whenComplete(() async {
          log("made the incharge");
        }).catchError((e) => log(e));
        log("Updated the incharge");
      }
    }
    setState(() => loading = false);
    showSuccessToast(
        context: context, text: '${teacher.name} is Class Incharge now');

    fetchData();
  }
}
