import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/master.dart';
import '../../admin/teachers/teacher_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool loading = false;
  TeacherModel? teacherInfo;
  String name = '';
  String email = '';

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: pColor,
          centerTitle: true),
      body: teacherInfo != null
          ? ListView(
              padding: EdgeInsets.symmetric(
                  horizontal: getWidth(context) * .05,
                  vertical: getHeight(context) * .02),
              children: [
                Padding(
                  padding: EdgeInsets.only(top: getHeight(context) * .075),
                  child: Center(
                    child: CircleAvatar(
                      minRadius: 52,
                      backgroundColor: pColor,
                      child: CircleAvatar(
                        backgroundColor: Colors.green.shade50,
                        minRadius: 50,
                        child: Text(getInitials(teacherInfo!.name),
                            style: GoogleFonts.rubikMoonrocks(
                                fontSize: 35,
                                fontWeight: FontWeight.w500,
                                color: pColor)),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: getHeight(context) * .15,
                ),
                Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: getWidth(context) * .05),
                  child: Card(
                    child: ListTile(
                      leading:
                          const Text('Name', style: TextStyle(color: pColor)),
                      title: Text(teacherInfo!.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: getWidth(context) * .05),
                  child: Card(
                    child: ListTile(
                      leading:
                          const Text('Email', style: TextStyle(color: pColor)),
                      title: Text(teacherInfo!.email,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
                Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: getWidth(context) * .05),
                  child: Card(
                    child: ListTile(
                      leading:
                          const Text('Class', style: TextStyle(color: pColor)),
                      title: Text(teacherInfo!.mClass,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
                Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: getWidth(context) * .05),
                  child: Card(
                    child: ListTile(
                      leading: const Text('Qualification',
                          style: TextStyle(color: pColor)),
                      title: Text(teacherInfo!.qualification,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
              ],
            )
          : const Loader(),
    );
  }

  void fetchData() async {
    String email = await getUserEmail();
    var collection = fireStore.collection('Teachers');
    var docSnapshot = await collection.doc(email).get();

    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      if (data != null) {
        log(data.toString());
        teacherInfo = TeacherModel.fromJson(data);
        setState(() {});
      } else {
        showErrorToast(context: context, text: 'Profile details not found');
      }
    } else {
      showErrorToast(context: context, text: 'Profile details not found');
    }
  }
}
