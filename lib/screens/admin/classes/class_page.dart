import 'dart:developer';
import 'dart:math' hide log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:sms/screens/admin/students/students.dart';

import '/master.dart';
import '../students/student_model.dart';
import '../teachers/teacher_model.dart';
import 'assignments_page.dart';
import 'attendance_page.dart';
import 'results_page.dart';
import 'subjects_page.dart';
import 'timetable_page.dart';

class ClassPage extends StatefulWidget {
  const ClassPage({Key? key}) : super(key: key);

  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  String? _chosenClass;
  List<String> drops = ['1', '2', '3', '4', '5'];
  bool loading = false;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  String teacherName = '';
  int total = 0;
  List<StudentModel> students = [];
  List<DataModel> dataModel = [];
  final List<double> tileHeight = [150, 200];

  @override
  void initState() {
    _chosenClass = '1';

    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final random = Random();
    return SafeArea(
      child: classPage(random)
      /*CollapsibleSidebar(
        isCollapsed: getWidth(context) <= 800,
        items: [
          CollapsibleItem(
            text: 'Class 1',
            icon: Icons.looks_one_rounded,
            onPressed: () {
              _chosenClass = '1';
              fetchData();
              //Get.off(() => const ClassPage());
            },
            isSelected: _chosenClass!.contains('1'),
          ),
          CollapsibleItem(
              text: 'Class 2',
              icon: Icons.looks_two_rounded,
              onPressed: () {
                _chosenClass = '2';
                fetchData();
              }),
          CollapsibleItem(
              text: 'Class 3',
              icon: Icons.looks_3_rounded,
              onPressed: () {
                _chosenClass = '3';
                fetchData();
              }),
          CollapsibleItem(
              text: 'Class 4',
              icon: Icons.looks_4_rounded,
              onPressed: () {
                _chosenClass = '4';
                fetchData();
              }),
          CollapsibleItem(
              text: 'Class 5',
              icon: Icons.looks_5_rounded,
              onPressed: () {
                _chosenClass = '5';
                fetchData();
              }),
        ],
        fitItemsToBottom: true,
        title: 'Admin',
        body: classPage(random),
        backgroundColor: shimmerColor,
        selectedTextColor: pColor,
        iconSize: 35,
        selectedIconColor: pColor,
        selectedIconBox: white,
        textStyle:
            const TextStyle(fontSize: 18, decoration: TextDecoration.none),
        titleStyle: const TextStyle(
            fontSize: 20,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none),
        toggleTitleStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none),
        sidebarBoxShadow: const [
          BoxShadow(
            color: pColor,
            blurRadius: 10,
            spreadRadius: 0.01,
            offset: Offset(3, 3),
          ),
          BoxShadow(
            color: Colors.green,
            blurRadius: 10,
            spreadRadius: 0.01,
            offset: Offset(3, 3),
          ),
        ],
      )*/,
    );
  }

  void fetchData() async {
    setState(() => loading = true);
    students.clear();

    await fireStore
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
    });

    var collection = fireStore.collection('Classes');
    var docSnapshot = await collection.doc('Class$_chosenClass').get();

    if (docSnapshot.exists) {
      // setState(() => loading = false);
      Map<String, dynamic>? mData = docSnapshot.data();
      if (mData != null) {
        log(mData.toString());

        String inchargeId = mData['teacher'] ?? '';

        var tCollection = fireStore.collection('Teachers');
        var tDocSnapshot = await tCollection.doc(inchargeId).get();

        if (tDocSnapshot.exists) {
          Map<String, dynamic>? tData = tDocSnapshot.data();

          TeacherModel model = TeacherModel.fromJson(tData!);

          teacherName = model.name;


        }else{

          displayToast('Class incharge not found');
        }
        setState(() => loading = false);
      }
    }

    dataModel = [
      DataModel(
          text: 'Attendance',
          onTap: () => Get.to(() =>
              ClassAttendance(className: _chosenClass!, students: students)),
          image: 'assets/attendence.png',
          color: Colors.indigo.shade700),
      DataModel(
          text: 'Assignments',
          onTap: () => Get.to(() => AssignmentPage(className: _chosenClass!)),
          image: 'assets/assignment.png',
          color: Colors.grey.shade400),
      DataModel(
          text: 'Timetable',
          onTap: () => Get.to(() => TimeTablePage(className: _chosenClass!)),
          image: 'assets/timetable.png',
          color: Colors.purpleAccent.shade400),
      DataModel(
          text: 'Subjects',
          onTap: () => Get.to(() => SubjectPage(className: _chosenClass!)),
          image: 'assets/subject.png',
          color: Colors.yellow.shade800),
      DataModel(
          text: 'Results',
          onTap: () => Get.to(
              () => ResultPage(students: students, className: _chosenClass!)),
          image: 'assets/result.png',
          color: pColor),
      DataModel(
          text: 'Students',
          onTap: () => Get.to(() => const Students()),
          image: 'assets/student.png',
          color: Colors.red.shade500),
    ];
  }

  Widget classPage(Random random) {
    return Scaffold(
      backgroundColor: bColor,
      body: loading
          ? const Loader()
          : ListView(
              padding: EdgeInsets.symmetric(
                  horizontal: getWidth(context) * .04,
                  vertical: getHeight(context) * .02),
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: FloatingActionButton.small(
                      onPressed: () {
                        Get.back();
                      },
                      backgroundColor: white,
                      child: const Icon(Icons.arrow_back_ios,
                          size: 20, color: black)),
                ),
                Text('Class $_chosenClass Info',
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center),
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
                      },
                    ),
                  ),
                ),
                SizedBox(height: getHeight(context) * .02),
                ListTile(
                  tileColor: Colors.black12,
                  dense: true,
                  leading: const Text('Class Incharge'),
                  trailing: Text(teacherName),
                ),
                SizedBox(height: getHeight(context) * .01),
                ListTile(
                  onTap: () => Get.to(() => Students(cName: _chosenClass)),
                  tileColor: pColor,
                  textColor: white,
                  dense: true,
                  leading: const Text('Class Students'),
                  trailing: Text(total.toString()),
                ),
                SizedBox(height: getHeight(context) * .02),
                /* Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Get.to(() => ClassAttendance(
                            className: _chosenClass!, students: students)),
                        child: Container(
                            decoration: BoxDecoration(
                                color: green,
                                borderRadius: BorderRadius.circular(10)),
                            height: getHeight(context) * .2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Image.asset('assets/attendence.png',
                                    height: 70),
                                Text('Attandance',
                                    style:
                                        TextStyle(color: white, fontSize: 18))
                              ],
                            )),
                      ),
                    ),
                    SizedBox(width: getWidth(context) * .05),
                    Expanded(
                      child: InkWell(
                        onTap: () => Get.to(
                            () => AssignmentPage(className: _chosenClass!)),
                        child: Container(
                            decoration: BoxDecoration(
                                color: grey,
                                borderRadius: BorderRadius.circular(10)),
                            height: getHeight(context) * .15,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Image.asset('assets/assignment.png',
                                    height: 70),
                                Text('Assignments',
                                    style:
                                        TextStyle(color: white, fontSize: 18))
                              ],
                            )),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Get.to(
                            () => TimeTablePage(className: _chosenClass!)),
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.indigo.shade700,
                                borderRadius: BorderRadius.circular(10)),
                            height: getHeight(context) * .15,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Image.asset('assets/timetable.png', height: 70),
                                Text('Timetable',
                                    style:
                                        TextStyle(color: white, fontSize: 18))
                              ],
                            )),
                      ),
                    ),
                    SizedBox(width: getWidth(context) * .05),
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            Get.to(() => SubjectPage(className: _chosenClass!)),
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.cyan,
                                borderRadius: BorderRadius.circular(10)),
                            height: getHeight(context) * .2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Image.asset('assets/subject.png', height: 70),
                                Text('Subjects',
                                    style:
                                        TextStyle(color: white, fontSize: 18))
                              ],
                            )),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Get.to(() => ResultPage(
                            students: students, className: _chosenClass!)),
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.brown.shade400,
                                borderRadius: BorderRadius.circular(10)),
                            height: getHeight(context) * .2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Image.asset('assets/result.png', height: 70),
                                Text('Results',
                                    style:
                                        TextStyle(color: white, fontSize: 18))
                              ],
                            )),
                      ),
                    ),
                    SizedBox(width: getWidth(context) * .05),
                    Expanded(
                      child: InkWell(
                        onTap: () => Get.to(() => const Students()),
                        child: Container(
                            decoration: BoxDecoration(
                                color: red,
                                borderRadius: BorderRadius.circular(10)),
                            height: getHeight(context) * .15,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Image.asset('assets/student.png', height: 70),
                                Text('Students',
                                    style:
                                        TextStyle(color: white, fontSize: 18))
                              ],
                            )),
                      ),
                    ),
                  ],
                ),*/
                MasonryGridView.count(
                    padding: EdgeInsets.symmetric(
                        horizontal: getWidth(context) * .03,
                        vertical: getHeight(context) * .02),
                    physics: const BouncingScrollPhysics(),
                    itemCount: dataModel.length,
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 16,
                    itemBuilder: (context, index) {
                      final item = dataModel[index];
                      return InkWell(
                          onTap: item.onTap,
                          child: Container(
                              decoration: BoxDecoration(
                                  color: item.color,
                                  borderRadius: BorderRadius.circular(10)),
                              height:
                                  tileHeight[random.nextInt(tileHeight.length)],
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image.asset(item.image, height: 70),
                                  Text(item.text,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: white, fontSize: 18))
                                ],
                              )));
                    }),
              ],
            ),
    );
  }
}
