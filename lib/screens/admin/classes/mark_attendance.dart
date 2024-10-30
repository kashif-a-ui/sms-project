import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '/master.dart';
import '../students/student_model.dart';
import 'attendance_page.dart';

class MarkAttendance extends StatefulWidget {
  final String className;
  final List<StudentModel> students;

  const MarkAttendance(
      {Key? key, required this.className, required this.students})
      : super(key: key);

  @override
  State<MarkAttendance> createState() => _MarkAttendanceState();
}

class _MarkAttendanceState extends State<MarkAttendance> {
  bool loading = false;
  List<StudentModel> students = [];
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  List<bool> presents = [];
  String? _date, _month, _year;

  @override
  void initState() {
    DateTime d = DateTime.now();

    _date = dates[d.day - 1];
    _month = monthsList[d.month];
    _year = d.year.toString();

    fetchStudents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: getWidth(context) * .1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButton(
                    isExpanded: false,
                    //style: const TextStyle(color: white),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: dates.map<DropdownMenuItem<String>>((value) {
                      return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              value,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              maxLines: 2,
                            ),
                          ));
                    }).toList(),
                    value: _date,
                    onChanged: (String? value) {
                      setState(() {
                        _date = value;
                      });
                      setState(() {});
                    },
                    hint: const Text('Day'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButton(
                    isExpanded: false,
                    //style: const TextStyle(color: white),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: monthsList.map<DropdownMenuItem<String>>((value) {
                      return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              value,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              maxLines: 2,
                            ),
                          ));
                    }).toList(),
                    value: _month,
                    onChanged: (String? value) {
                      setState(() {
                        _month = value;
                      });
                      setState(() {});
                    },
                    hint: const Text('Month'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButton(
                    isExpanded: false,
                    //style: const TextStyle(color: white),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: years.map<DropdownMenuItem<String>>((value) {
                      return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              value,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              maxLines: 2,
                            ),
                          ));
                    }).toList(),
                    value: _year,
                    onChanged: (String? value) {
                      setState(() {
                        _year = value;
                      });
                      setState(() {});
                    },
                    hint: const Text('Year'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: pColor,
        child: MaterialButton(
          textColor: white,
          onPressed: () {
            saveAttendance();
          },
          child: const Text('Save Attendance'),
        ),
      ),
      body: loading
          ? const Loader()
          : ListView(
              children: [
                const ListTile(
                  leading: Text('Roll No.'),
                  title: Text('Student Name'),
                  trailing: Text('Present'),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final item = students[index];
                    return SwitchListTile(
                        secondary: Text(item.rollNo),
                        title: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(item.name),
                        ),
                        value: presents[index],
                        onChanged: (value) {
                          presents[index] = value;
                          setState(() {});
                        });
                  },
                )
              ],
            ),
    );
  }

  void fetchStudents() async {
    students.clear();
    presents.clear();
    setState(() => loading = true);
    String className = widget.className;
    fireStore
        .collection("Classes/Class$className/Students")
        .orderBy('roll_no')
        .get()
        .then((value) {
      for (var studentData in value.docs) {
        log("studentData = ${studentData.data()}");

        students.add(StudentModel.fromJson(studentData.data()));
        presents.add(false);
      }
      setState(() => loading = false);
    });
  }

  void saveAttendance() async {
    setState(() => loading = true);

    final className = widget.className;
    //final date = DateTime.now();

    //final mainNode = '$_month-$_year';

    final subNode = '$_date-$_month-$_year';

    for (int i = 0; i < students.length; i++) {
      num p = 0, a = 0;
      // final data = {
      //   'name': students[i].name,
      //   'roll_no': students[i].rollNo,
      //   'date': subNode,
      //   'present': presents[i]
      // };
      var collection =
          fireStore.collection('Classes/Class$className/Attendance');
      var docSnapshot = await collection.doc(students[i].rollNo).get();

      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();

        if (data != null) {
          p = data['present'];
          a = data['absent'];

          if (data['last_updated'].contains(subNode)) {
            setState(() => loading = false);

            showErrorToast(context: context, text: 'Attendance marked already');
            return;
          }
        }
      }
      if (presents[i]) {
        p = p + 1;
      } else {
        a = a + 1;
      }
      collection.doc(students[i].rollNo).set({
        'present': p,
        'absent': a,
        'name': students[i].name,
        'roll_no': students[i].rollNo,
        'last_updated': subNode,
      });

      // fireStore
      //     .collection(
      //         'Classes/Class$className/Attendance/${students[i].rollNo}/$mainNode')
      //     .doc(subNode)
      //     .set(data);
      setState(() => loading = false);
    }
    displayToast('Attendance marked');
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ClassAttendance(
                className: widget.className, students: widget.students)));
  }
}
