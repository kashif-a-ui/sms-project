import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/master.dart';
import '../students/student_model.dart';
import 'class_models.dart';
import 'mark_attendance.dart';

class ClassAttendance extends StatefulWidget {
  final String className;
  final List<StudentModel> students;

  const ClassAttendance(
      {Key? key, required this.className, required this.students})
      : super(key: key);

  @override
  State<ClassAttendance> createState() => _ClassAttendanceState();
}

class _ClassAttendanceState extends State<ClassAttendance> {
  bool loading = false;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  List<AttendanceModel> attendance = [];
  List<AttendanceSheet> dataModel = [];

  @override
  void initState() {
    // fetchData();
    fetchAttendanceSheet();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Class ${widget.className} Attendance'),
      ),
      floatingActionButton: loading
          ? const SizedBox()
          : FloatingActionButton(
              onPressed: () {
                Get.off(() => MarkAttendance(
                    className: widget.className, students: widget.students));
              },
              child: const Icon(Icons.add)),
      body: loading
          ? const Loader()
          : ListView(
              padding: EdgeInsets.symmetric(
                  horizontal: getWidth(context) * .04,
                  vertical: getHeight(context) * .02),
              children: [
                /*ListView.builder(
                  itemCount: attendance.length,
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = attendance[index];
                    return ListTile(
                      leading: Text(item.rollNo),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.name),
                          Text(item.date),
                        ],
                      ),
                      trailing: Container(
                        height: 40,
                        width: 40,
                        color: item.present ? green : red,
                        child: Center(
                            child: Text(item.present ? 'P' : 'A',
                                style: const TextStyle(color: white))),
                      ),
                    );
                  },
                ),*/

                dataModel.isNotEmpty
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: [
                            const DataColumn(label: Text('Roll No')),
                            const DataColumn(label: Text('Name')),
                            DataColumn(
                                label: Container(
                              height: 35,
                              width: 35,
                              color: green,
                              child: const Center(
                                  child: Text('P',
                                      style: TextStyle(color: white))),
                            )),
                            DataColumn(
                                label: Container(
                              height: 35,
                              width: 35,
                              color: red,
                              child: const Center(
                                  child: Text('A',
                                      style: TextStyle(color: white))),
                            )),
                            const DataColumn(label: Text('Presence')),
                          ],
                          rows: dataModel
                              .map((e) => DataRow(
                                      color: e.percentage < 50
                                          ? WidgetStateProperty.all<Color>(
                                              Colors.red.shade100)
                                          : null,
                                      cells: [
                                        DataCell(Text(e.rollNo)),
                                        DataCell(Text(e.name)),
                                        DataCell(Text(e.present.toString())),
                                        DataCell(Text(e.absent.toString())),
                                        DataCell(Text(
                                            '${e.percentage.toStringAsFixed(2)}%')),
                                      ]))
                              .toList(),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
    );
  }

/*  void fetchData() async {
    attendance.clear();
    setState(() => loading = true);

    final className = widget.className;

    for (int i = 0; i < widget.students.length; i++) {
      num p = 0, a = 0, t = 0;
      await fireStore
          .collection(
              'Classes/Class$className/Attendance/${widget.students[i].rollNo}/Dec-2022')
          .get()
          .then((value) {
        for (var attendanceData in value.docs) {
          log("attendanceData = ${attendanceData.data()}");

          final attendanceModel =
              AttendanceModel.fromJson(attendanceData.data());
          attendance.add(attendanceModel);

          if (attendanceModel.present) {
            log('present ++');
            p = p + 1;
          } else {
            log('absent ++');
            a = a + 1;
          }
        }

        log('p = $p');
        log('a = $a');
        log('t = ${a + p}');
        dataModel.add(AttendanceSheet(
            name: widget.students[i].name,
            rollNo: widget.students[i].rollNo,
            present: p,
            absent: a,
            total: p + a,
            percentage: (p / t) * 100));
      });
      setState(() => loading = false);
    }
  }*/

  fetchAttendanceSheet() async {
    dataModel.clear();
    setState(() => loading = true);
    final className = widget.className;

    for (int i = 0; i < widget.students.length; i++) {
      try {
        var collection =
            fireStore.collection('Classes/Class$className/Attendance');
        var docSnapshot = await collection.doc(widget.students[i].rollNo).get();
        if (docSnapshot.exists) {
          Map<String, dynamic>? data = docSnapshot.data();
          if (data != null) {
            log(data.toString());
            AttendanceSheet sheet = AttendanceSheet.fromJson(data);

            sheet.total = sheet.present + sheet.absent;
            sheet.percentage = (sheet.present / sheet.total) * 100;

            dataModel.add(sheet);
          }
        }
      } on Exception catch (e) {
        log(e.toString());
      }
      setState(() => loading = false);
    }
  }
}
