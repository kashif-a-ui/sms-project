import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms/screens/admin/students/students.dart';

import '/master.dart';
import '../admin/classes/assignments_page.dart';
import '../admin/classes/attendance_page.dart';
import '../admin/classes/results_page.dart';
import '../admin/classes/timetable_page.dart';
import '../admin/students/student_model.dart';

class TeacherClass extends StatefulWidget {
  const TeacherClass({Key? key}) : super(key: key);

  @override
  State<TeacherClass> createState() => _TeacherClassState();
}

class _TeacherClassState extends State<TeacherClass> {
  bool loading = false;
  String tClass = '';

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Class'),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
            horizontal: getWidth(context) * .05,
            vertical: getHeight(context) * .02),
        children: [
          InkWell(
            onTap: () => Get.to(() => Students(cName: tClass)),
            child: Container(
                decoration: BoxDecoration(
                    color: blueGrey, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: Image.asset('assets/student.png',
                            height: getHeight(context) * .2)),
                    SizedBox(
                        height: getHeight(context) * .18,
                        child: const Row(children: [
                          VerticalDivider(thickness: 2, color: white),
                          VerticalDivider(thickness: 2, color: white)
                        ])),
                    const Expanded(
                      child: Text('Students',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500)),
                    )
                  ],
                )),
          ),
          SizedBox(height: getHeight(context) * .02),
          InkWell(
            onTap: () => Get.to(() => TimeTablePage(className: tClass)),
            child: Container(
                decoration: BoxDecoration(
                    color: orangeDeep, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: Image.asset('assets/timetable.png',
                            height: getHeight(context) * .2)),
                    SizedBox(
                        height: getHeight(context) * .18,
                        child: const Row(children: [
                          VerticalDivider(thickness: 2, color: white),
                          VerticalDivider(thickness: 2, color: white)
                        ])),
                    const Expanded(
                      child: Text('Timetable',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500)),
                    )
                  ],
                )),
          ),
          SizedBox(height: getHeight(context) * .02),
          InkWell(
            onTap: () => fetchStudents(result: true),
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.lime.shade600,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: Image.asset('assets/result.png',
                            height: getHeight(context) * .2)),
                    SizedBox(
                        height: getHeight(context) * .18,
                        child: const Row(children: [
                          VerticalDivider(thickness: 2, color: white),
                          VerticalDivider(thickness: 2, color: white)
                        ])),
                    const Expanded(
                      child: Text('Results',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500)),
                    )
                  ],
                )),
          ),
          SizedBox(height: getHeight(context) * .02),
          InkWell(
            onTap: () => Get.to(() => AssignmentPage(className: tClass)),
            child: Container(
                decoration: BoxDecoration(
                    color: orange, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: Image.asset('assets/assignment.png',
                            height: getHeight(context) * .2)),
                    SizedBox(
                        height: getHeight(context) * .18,
                        child: const Row(children: [
                          VerticalDivider(thickness: 2, color: white),
                          VerticalDivider(thickness: 2, color: white)
                        ])),
                    const Expanded(
                      child: Text('Assignment',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500)),
                    )
                  ],
                )),
          ),
          SizedBox(height: getHeight(context) * .02),
          InkWell(
            onTap: fetchStudents,
            child: Container(
                decoration: BoxDecoration(
                    color: red, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: Image.asset('assets/attendence.png',
                            height: getHeight(context) * .2)),
                    SizedBox(
                        height: getHeight(context) * .18,
                        child: const Row(children: [
                          VerticalDivider(thickness: 2, color: white),
                          VerticalDivider(thickness: 2, color: white)
                        ])),
                    const Expanded(
                      child: Text('Attendance',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500)),
                    )
                  ],
                )),
          ),
        ],
      ),
    );
  }

  void fetchData() async {
    tClass = await getTeacherClass();
    setState(() {});
  }

  void fetchStudents({bool result = false}) async {
    setState(() => loading = true);
    List<StudentModel> students = [];
    await fireStore
        .collection('Classes/Class$tClass/Students')
        .orderBy('roll_no')
        .get()
        .then((value) {
      for (var stuData in value.docs) {
        log("stuData = ${stuData.data()}");

        students.add(StudentModel.fromJson(stuData.data()));
      }
    });
    result
        ? Get.to(() => ResultPage(students: students, className: tClass))
        : Get.to(() => ClassAttendance(students: students, className: tClass));
  }
}
