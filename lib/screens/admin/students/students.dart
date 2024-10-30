import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/master.dart';
import '../teachers/teacher_model.dart';
import 'add_student.dart';
import 'student_model.dart';

class Students extends StatefulWidget {
  final String? cName;

  const Students({Key? key, this.cName}) : super(key: key);

  @override
  State<Students> createState() => _StudentsState();
}

class _StudentsState extends State<Students> {
  String? _chosenClass;
  List<String> drops = ['1', '2', '3', '4', '5'];
  bool loading = false;
  List<StudentModel> students = [];
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  int total = 0;
  String teacherName = '';

  final nameCont = TextEditingController();
  final emailCont = TextEditingController();
  final qualifyCont = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _chosenClass = widget.cName ?? '1';

    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
      ),
      floatingActionButton: widget.cName != null
          ? const SizedBox()
          : FloatingActionButton(
              onPressed: () => Get.to(() =>
                  AddStudent(className: _chosenClass!, classTotal: total)),
              child: const Text('Add'),
            ),
      body: loading
          ? const Loader()
          : ListView(
              padding: EdgeInsets.symmetric(
                  horizontal: getWidth(context) * .04,
                  vertical: getHeight(context) * .02),
              children: [
                widget.cName != null
                    ? const SizedBox()
                    : Card(
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
                              "Select Student Class",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                            onChanged: (String? value) {
                              if (_chosenClass != null &&
                                  !_chosenClass!.contains(value!)) {
                                _chosenClass = value;
                                log('_chosenClass: $_chosenClass');
                                fetchData();
                              }

                              // setState(() {});
                            },
                          ),
                        ),
                      ),
                SizedBox(height: getHeight(context) * .02),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  color: const Color(0xff36ecec),
                  margin: EdgeInsets.only(bottom: getHeight(context) * .02),
                  child: Column(
                    children: [
                      SizedBox(height: getHeight(context) * .03),
                      Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          'Class $_chosenClass Information',
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w500,
                              color: white),
                        ),
                      ),
                      SizedBox(height: getHeight(context) * .01),
                      ListTile(
                        dense: true,
                        title: const Text('Class Incharge',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, color: white)),
                        trailing: Text(teacherName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, color: white)),
                      ),
                      ListTile(
                        dense: true,
                        title: const Text('Class Students',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, color: white)),
                        trailing: Text(students.length.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, color: white)),
                      ),
                    ],
                  ),
                ),
                if (students.isNotEmpty)
                  ListView.builder(
                    itemBuilder: (context, index) => Card(
                      color: pColor,
                      child: Card(
                        margin: const EdgeInsets.all(1),
                        child: ExpansionTile(
                          title: Text(students[index].name,
                              style: const TextStyle(
                                  color: pColor, fontWeight: FontWeight.w500)),
                          subtitle: Text(students[index].email,
                              style: const TextStyle(color: black)),
                          trailing: Text(students[index].rollNo,
                              style: const TextStyle(
                                  color: pColor, fontWeight: FontWeight.w500)),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  MaterialButton(
                                    onPressed: () {
                                      createBottomSheet(context,
                                          model: students[index]);
                                    },
                                    minWidth: getWidth(context) * .35,
                                    color: blue,
                                    shape: const BeveledRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12))),
                                    child: const Text('Edit '),
                                  ),
                                  MaterialButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Warning!!'),
                                          content: const Text(
                                              'The Student record will be deleted permanently'),
                                          actions: [
                                            CreateCustomButton(
                                                text: 'Cancel',
                                                onTap: () => Get.back()),
                                            CreateCustomButton(
                                                text: 'Delete',
                                                onTap: () => deleteData(
                                                    id: students[index].id),
                                                buttonColor: red)
                                          ],
                                        ),
                                      );
                                    },
                                    minWidth: getWidth(context) * .35,
                                    color: red,
                                    shape: const BeveledRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12))),
                                    child: const Text('Delete '),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    itemCount: students.length,
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                  )
                else
                  const Text('No Student data found')
              ],
            ),
    );
  }

  void fetchData() async {
    students.clear();
    teacherName = '';
    setState(() => loading = true);
    fireStore
        .collection("Classes/Class$_chosenClass/Students")
        .orderBy('roll_no')
        .get()
        .then((value) {
      for (var studentData in value.docs) {
        log("studentData = ${studentData.data()}");

        students.add(StudentModel.fromJson(studentData.data()));
      }
      total = students.length;
      log('total Students: $total');
      setState(() => loading = false);
    });
    var collection = fireStore.collection('Classes');
    var docSnapshot = await collection.doc('Class$_chosenClass').get();

    if (docSnapshot.exists) {
      Map<String, dynamic>? mData = docSnapshot.data();
      if (mData != null) {
        log(mData.toString());

        String inchargeId = mData['teacher'];

        var tCollection = fireStore.collection('Teachers');
        var tDocSnapshot = await tCollection.doc(inchargeId).get();

        if (tDocSnapshot.exists) {
          Map<String, dynamic>? tData = tDocSnapshot.data();

          TeacherModel model = TeacherModel.fromJson(tData!);

          teacherName = model.name;

          setState(() {});
        }
      }
    }
  }

  void addData({required String id}) async {
    setState(() => loading = true);

    var doc = fireStore.collection('Students').doc(id);
    var cDoc =
        fireStore.collection('Classes/Class$_chosenClass/Students').doc(id);

    final data = {'name': nameCont.text};

    await doc.update(data);
    await cDoc.update(data);

    nameCont.clear();
    emailCont.clear();

    setState(() => loading = false);
    showSuccessToast(
        context: context, text: 'Student Info Updated Successfully');

    fetchData();
  }

  void deleteData({required String id}) async {
    setState(() => loading = true);

    var doc = fireStore.collection('Students').doc(id);

    await doc.delete();

    setState(() => loading = false);

    showDeleteToast(context: context);

    fetchData();
  }

  createBottomSheet(BuildContext context, {required StudentModel model}) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return StatefulBuilder(builder: (context, setBottomState) {
            return Card(
              color: shimmerColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
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
                      const Text('Edit Student Info',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500)),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CreateCustomField(
                          text: 'Name',
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
                      /*Padding(
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
                      ),*/
                      CreateCustomButton(
                          width: getWidth(context) * .9,
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              Get.back();
                              addData(id: model.id);
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
          });
        });
  }
}
