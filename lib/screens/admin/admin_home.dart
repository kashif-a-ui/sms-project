import 'dart:math' hide log;

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '/master.dart' hide FeedbackPage;
import '../about_us/about_us.dart';
import '../login/login.dart';
import '../rules_regulations/rules_regulations.dart';
import 'calender/calender_page.dart';
import 'classes/class_page.dart';
import 'feedback/feedback.dart';
import 'notice_board/notice_board.dart';
import 'teachers/teachers.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  DateTime timeBackPressed = DateTime.now();
  bool loading = false;
  String name = 'MR ADMIN';
  final List<double> tileHeight = [150, 200];

  @override
  void initState() {
    fetchInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final random = Random();

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
        backgroundColor: bColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Admin Home'),
          actions: [
            IconButton(
                onPressed: () {
                  removePrefs();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()));
                },
                icon: Image.asset('assets/logout.png')),
          ],
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(
              horizontal: getWidth(context) * .04,
              vertical: getHeight(context) * .02),
          children: [
            /*SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  InkWell(
                    onTap: () {},
                    child: Container(
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: pColor),
                        height: getHeight(context) * .2,
                        width: getWidth(context) * .45,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(Icons.ac_unit, color: white),
                            Text('About Us',
                                style: TextStyle(color: white, fontSize: 18))
                          ],
                        )),
                  ),
                  //SizedBox(width: getWidth(context) * .05),
                  InkWell(
                    onTap: () => Get.to(() => const NoticeBoard()),
                    child: Container(
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: pColor),
                        height: getHeight(context) * .2,
                        width: getWidth(context) * .45,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(Icons.ac_unit, color: white),
                            Text('Notice Board',
                                style: TextStyle(color: white, fontSize: 18))
                          ],
                        )),
                  ),
                  InkWell(
                    onTap: () => Get.to(() => const FeedbackPage()),
                    child: Container(
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: pColor),
                        height: getHeight(context) * .2,
                        width: getWidth(context) * .45,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(Icons.ac_unit, color: white),
                            Text('Feedback',
                                style: TextStyle(color: white, fontSize: 18))
                          ],
                        )),
                  ),
                  InkWell(
                    onTap: () => Get.to(() => const CalenderPage()),
                    child: Container(
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: pColor),
                        height: getHeight(context) * .2,
                        width: getWidth(context) * .5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(Icons.ac_unit, color: white),
                            Text('Calender',
                                style: TextStyle(color: white, fontSize: 18))
                          ],
                        )),
                  ),
                ],
              ),
            ),*/
            Card(
              color: Colors.black54,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.only(topLeft: Radius.circular(10))),
                      color: pColor,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Text('Admin',
                            style: TextStyle(
                                color: white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17)),
                      ),
                    ),
                  ),
                  /*CircleAvatar(
                    minRadius: 40,
                    child: SizedBox(
                      height: 80,
                      child: Icon(Icons.person, size: 40),
                    ),
                  ),*/
                  CircleAvatar(
                    minRadius: 52,
                    backgroundColor: pColor,
                    child: CircleAvatar(
                      backgroundColor: Colors.green.shade50,
                      minRadius: 50,
                      child: Text(getInitials(name),
                          style: GoogleFonts.rubikMoonrocks(
                              fontSize: 35,
                              fontWeight: FontWeight.w500,
                              color: pColor)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 8.0, bottom: getHeight(context) * .02),
                    child: Text(name,
                        style: const TextStyle(fontSize: 20, color: white)),
                  ),
                ],
              ),
            ),
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
                          height: tileHeight[random.nextInt(tileHeight.length)],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Image.asset(item.image, height: 70),
                              Text(item.text,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: white, fontSize: 18))
                            ],
                          )));
                }),
            /*Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Get.to(() => const ClassPage()),
                    child: Container(
                        decoration: BoxDecoration(
                            color: green,
                            borderRadius: BorderRadius.circular(10)),
                        height: getHeight(context) * .15,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(Icons.ac_unit, color: white),
                            Text('Classes',
                                style: TextStyle(color: white, fontSize: 18))
                          ],
                        )),
                  ),
                ),
                SizedBox(width: getWidth(context) * .15),
                Expanded(
                  child: InkWell(
                    onTap: () => Get.to(() => const Teachers()),
                    child: Container(
                        decoration: BoxDecoration(
                            color: blue,
                            borderRadius: BorderRadius.circular(10)),
                        height: getHeight(context) * .15,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(Icons.ac_unit, color: white),
                            Text('Teachers',
                                style: TextStyle(color: white, fontSize: 18))
                          ],
                        )),
                  ),
                ),
              ],
            ),
            SizedBox(height: getHeight(context) * .1),*/
            /* Container(
              alignment: Alignment.centerLeft,
              height: getHeight(context) * .4,
              //width: getWidth(context) * .2,
              child: ListWheelScrollView(
                physics: const ScrollPhysics(),
                offAxisFraction: 1,
                itemExtent: getHeight(context) * .15,
                onSelectedItemChanged: (a) {
                  print(a);
                  setState(() {});
                },
                // renderChildrenOutsideViewport: true,

                children: [
                  InkWell(
                    onTap: () {},
                    child: Container(
                        decoration: BoxDecoration(
                            color: pColor,
                            borderRadius: BorderRadius.circular(10)),
                        height: getHeight(context) * .15,
                        width: getWidth(context) * .4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(Icons.ac_unit, color: white),
                            Text('About Us',
                                style: TextStyle(color: white, fontSize: 18))
                          ],
                        )),
                  ),
                  InkWell(
                    onTap: () => Get.to(() => const NoticeBoard()),
                    child: Container(
                        decoration: BoxDecoration(
                            color: pColor,
                            borderRadius: BorderRadius.circular(10)),
                        height: getHeight(context) * .15,
                        width: getWidth(context) * .4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(Icons.ac_unit, color: white),
                            Text('Notice Board',
                                style: TextStyle(color: white, fontSize: 18))
                          ],
                        )),
                  ),
                  InkWell(
                    onTap: () => Get.to(() => const FeedbackPage()),
                    child: Container(
                        decoration: BoxDecoration(
                            color: pColor,
                            borderRadius: BorderRadius.circular(10)),
                        height: getHeight(context) * .15,
                        width: getWidth(context) * .4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(Icons.ac_unit, color: white),
                            Text('Feedback',
                                style: TextStyle(color: white, fontSize: 18))
                          ],
                        )),
                  ),
                  InkWell(
                    onTap: () => Get.to(() => const CalenderPage()),
                    child: Container(
                        decoration: BoxDecoration(
                            color: pColor,
                            borderRadius: BorderRadius.circular(10)),
                        height: getHeight(context) * .15,
                        width: getWidth(context) * .4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(Icons.ac_unit, color: white),
                            Text('Calender',
                                style: TextStyle(color: white, fontSize: 18))
                          ],
                        )),
                  ),
                ],
              ),
            ),*/
            /*SizedBox(
              height: getHeight(context) * .4,
              child: ListWheelScrollView.useDelegate(
                  itemExtent: getHeight(context) * .2,
                  perspective: 0.002,
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      final item = dataModel[index];
                      return InkWell(
                        onTap: item.onTap,
                        child: Container(
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: pColor),
                            height: getHeight(context) * .2,
                            width: getWidth(context) * .45,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Icon(Icons.ac_unit, color: white),
                                Text(item.text,
                                    style:
                                        TextStyle(color: white, fontSize: 18))
                              ],
                            )),
                      );
                    },
                    childCount: dataModel.length,
                  )),
            )*/
            /*  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {},
                  child: Container(
                      decoration: BoxDecoration(
                          color: pColor,
                          // borderRadius: BorderRadius.circular(10)
                          shape: BoxShape.circle),
                      height: getHeight(context) * .2,
                      width: getWidth(context) * .4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(Icons.ac_unit, color: white),
                          Text('About Us',
                              style: TextStyle(color: white, fontSize: 18))
                        ],
                      )),
                ),
                InkWell(
                  onTap: () => Get.to(() => const NoticeBoard()),
                  child: Container(
                      decoration:
                          BoxDecoration(color: pColor, shape: BoxShape.circle),
                      height: getHeight(context) * .2,
                      width: getWidth(context) * .4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(Icons.ac_unit, color: white),
                          Text('Notice Board',
                              style: TextStyle(color: white, fontSize: 18))
                        ],
                      )),
                ),
              ],
            ),
            SizedBox(height: getHeight(context) * .02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => Get.to(() => const FeedbackPage()),
                  child: Container(
                      decoration:
                          BoxDecoration(color: pColor, shape: BoxShape.circle),
                      height: getHeight(context) * .2,
                      width: getWidth(context) * .4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(Icons.ac_unit, color: white),
                          Text('Feedback',
                              style: TextStyle(color: white, fontSize: 18))
                        ],
                      )),
                ),
                InkWell(
                  onTap: () => Get.to(() => const CalenderPage()),
                  child: Container(
                      decoration:
                          BoxDecoration(color: pColor, shape: BoxShape.circle),
                      height: getHeight(context) * .2,
                      width: getWidth(context) * .4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(Icons.ac_unit, color: white),
                          Text('Calender',
                              style: TextStyle(color: white, fontSize: 18))
                        ],
                      )),
                ),
              ],
            ),*/
          ],
        ),
      ),
    );
  }

  void fetchInfo() async {
    name = await getUsername();
    setState(() {});
  }

  List<DataModel> dataModel = [
    DataModel(
        text: 'Classes',
        onTap: () => Get.to(() => const ClassPage()),
        image: 'assets/classes.png',
        color: Colors.indigo.shade700),
    DataModel(
        text: 'Teachers',
        onTap: () => Get.to(() => const Teachers()),
        image: 'assets/teacher.png',
        color: Colors.cyanAccent.shade400),
    DataModel(
        text: 'About Us',
        onTap: () => Get.to(() => const AboutUsPage()),
        image: 'assets/about.png',
        color: Colors.purpleAccent.shade400),
    DataModel(
        text: 'Notice Board',
        onTap: () => Get.to(() => const NoticeBoard()),
        image: 'assets/notice.png',
        color: Colors.yellow.shade600),
    DataModel(
        text: 'Feedback',
        onTap: () => Get.to(() => const FeedbackPage()),
        image: 'assets/feedback.png',
        color: pColor),
    DataModel(
        text: 'Calendar',
        onTap: () => Get.to(() => const CalenderPage()),
        image: 'assets/calendar.png',
        color: Colors.red.shade500),
    DataModel(
        text: 'Rules & Regulations',
        onTap: () => Get.to(() => const RulesPage(admin: true)),
        image: 'assets/about.png',
        color: Colors.brown.shade400),
  ];
}
