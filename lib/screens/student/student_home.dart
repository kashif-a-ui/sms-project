import 'dart:developer';

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sms/screens/admin/classes/timetable_page.dart';

import '/master.dart';
import '../../widgets/notice_page.dart';
import '../about_us/about_us.dart';
import '../admin/calender/calender_page.dart';
import '../admin/classes/assignments_page.dart';
import '../admin/classes/class_models.dart';
import '../login/login.dart';
import '../rules_regulations/rules_regulations.dart';
import 'profile/profile_page.dart';
import 'result/my_resluts.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({Key? key}) : super(key: key);

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  DateTime timeBackPressed = DateTime.now();
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  bool loading = false;
  String stuClass = '';
  num present = 0, absent = 0, per = 0;
  List<DataModel> dataModel = [];

  //List<NoticeModel> dataModel = [];
  AttendanceSheet? attendance;

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        appBar: AppBar(
          title: const Text('Student Home'),
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
        body: loading
            ? const Loader()
            : ListView(
                padding: EdgeInsets.symmetric(
                    horizontal: getWidth(context) * .05,
                    vertical: getHeight(context) * .02),
                children: [
                  /*    dataModel.isNotEmpty
                      ? SizedBox(
                          height: getHeight(context) * .3,
                          child: Swiper(
                            itemCount: dataModel.length,
                            pagination: const SwiperPagination(),
                            autoplay: dataModel.isNotEmpty,
                            duration: 2000,
                            autoplayDelay: 3000,
                            itemBuilder: (context, index) {
                              final item = dataModel[index];
                              return Card(
                                color: Colors.green.shade100,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(item.title,
                                          style: GoogleFonts.rubikMoonrocks(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: pColor)),
                                      item.image.isNotEmpty
                                          ? InkWell(
                                              onTap: () {
                                                Get.to(() => DetailScreen(
                                                    image: item.image,
                                                    tag: 'image$index'));
                                              },
                                              child: Hero(
                                                tag: 'image$index',
                                                child: Container(
                                                  width: getWidth(context),
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Image.network(
                                                      item.image,
                                                      height:
                                                          getHeight(context) *
                                                              .12,
                                                      fit: BoxFit.fitWidth,
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          const Icon(
                                                              Icons.image,
                                                              size: 100)),
                                                ),
                                              ),
                                            )
                                          : const SizedBox(),
                                      SizedBox(
                                          height: getHeight(context) * .01),
                                      Text(
                                        item.description,
                                        style: GoogleFonts.kanit(fontSize: 17),
                                      ),
                                      SizedBox(
                                          height: getHeight(context) * .01),
                                      Align(
                                          alignment: Alignment.topRight,
                                          child: Text(
                                            item.date,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500),
                                          )),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : const SizedBox(),*/
                  const Text('My Attendance'),
                  Pulse(
                    child: Card(
                      color: Colors.green.shade100,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                height: 35,
                                width: 35,
                                color: green,
                                child: const Center(
                                    child: Text('P',
                                        style: TextStyle(color: white))),
                              ),
                              Text('$present'),
                              const SizedBox(
                                  height: 30,
                                  child: VerticalDivider(thickness: 4)),
                              Container(
                                height: 35,
                                width: 35,
                                color: red,
                                child: const Center(
                                    child: Text('A',
                                        style: TextStyle(color: white))),
                              ),
                              Text('$absent'),
                              const SizedBox(
                                  height: 30,
                                  child: VerticalDivider(thickness: 4)),
                              Container(
                                height: 35,
                                width: 35,
                                color: blue,
                                child: const Center(
                                    child: Text('%',
                                        style: TextStyle(color: white))),
                              ),
                              Text('${per.toStringAsFixed(2)}%'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: getHeight(context) * .02),
                  ElasticIn(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => Get.to(() => AssignmentPage(
                              student: true, className: stuClass)),
                          child: Card(
                            color: Colors.indigo.shade600,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: Image.asset(
                                    'assets/assignment.png',
                                    height: getHeight(context) * .2,
                                  ),
                                ),
                                SizedBox(
                                    height: getHeight(context) * .18,
                                    child: const Row(children: [
                                      VerticalDivider(
                                          thickness: 2, color: white),
                                      VerticalDivider(
                                          thickness: 2, color: white)
                                    ])),
                                Expanded(
                                  child: Text('Assignments',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.permanentMarker(
                                          color: white, fontSize: 20)),
                                )
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () =>
                              Get.to(() => ResultPage(className: stuClass)),
                          child: Card(
                            color: blueGrey,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: Image.asset(
                                    'assets/result.png',
                                    height: getHeight(context) * .2,
                                  ),
                                ),
                                SizedBox(
                                    height: getHeight(context) * .18,
                                    child: const Row(children: [
                                      VerticalDivider(
                                          thickness: 2, color: white),
                                      VerticalDivider(
                                          thickness: 2, color: white)
                                    ])),
                                Expanded(
                                  child: Text('My Results',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.permanentMarker(
                                          color: white, fontSize: 20)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  /* Bounce(
                    child: Row(
                      children: [
                        Expanded(
                          child: HomeTile(
                              image: 'assets/assignment.png',
                              text: 'Assignments',
                              tileColor: blueGrey,
                              onTap: () => Get.to(() => AssignmentPage(
                                  student: true, className: stuClass))),
                        ),
                        SizedBox(width: getWidth(context) * .15),
                        Expanded(
                          child: HomeTile(
                            onTap: () =>
                                Get.to(() => ResultPage(className: stuClass)),
                            text: 'Results',
                            tileColor: Colors.deepOrange,
                            image: 'assets/result.png',
                          ),
                        ),
                      ],
                    ),
                  ),*/
                  SizedBox(height: getHeight(context) * .02),
                  ElasticIn(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => Get.to(() => TimeTablePage(
                              className: stuClass, student: true)),
                          child: Card(
                            color: Colors.purple.shade600,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: Image.asset(
                                    'assets/timetable.png',
                                    height: getHeight(context) * .2,
                                  ),
                                ),
                                SizedBox(
                                    height: getHeight(context) * .18,
                                    child: const Row(children: [
                                      VerticalDivider(
                                          thickness: 2, color: white),
                                      VerticalDivider(
                                          thickness: 2, color: white)
                                    ])),
                                Expanded(
                                  child: Text('MY Timetable',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.permanentMarker(
                                          color: white, fontSize: 20)),
                                )
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => Get.to(() => const ProfilePage()),
                          child: Card(
                            color: red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: Image.asset(
                                    'assets/student.png',
                                    height: getHeight(context) * .2,
                                  ),
                                ),
                                SizedBox(
                                    height: getHeight(context) * .18,
                                    child: const Row(children: [
                                      VerticalDivider(
                                          thickness: 2, color: white),
                                      VerticalDivider(
                                          thickness: 2, color: white)
                                    ])),
                                Expanded(
                                  child: Text('My Profile',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.permanentMarker(
                                          color: white, fontSize: 20)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bounce(
                  //   child: Row(
                  //     children: [
                  //       Expanded(
                  //         child: HomeTile(
                  //             onTap: () => Get.to(() => TimeTablePage(
                  //                 className: stuClass, student: true)),
                  //             text: 'Timetable',
                  //             image: 'assets/timetable.png',
                  //             tileColor: blue),
                  //       ),
                  //       SizedBox(width: getWidth(context) * .15),
                  //       Expanded(
                  //         child: HomeTile(
                  //             onTap: () => Get.to(() => const ProfilePage()),
                  //             text: 'Profile',
                  //             tileColor: orange,
                  //             image: 'assets/student.png'),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  SizedBox(height: getHeight(context) * .03),
                  InkWell(
                    onTap: () => Get.to(() => const RulesPage()),
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.brown,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                                child: Image.asset('assets/about.png',
                                    height: getHeight(context) * .15)),
                            SizedBox(
                                height: getHeight(context) * .13,
                                child: const Row(children: [
                                  VerticalDivider(thickness: 2, color: white),
                                  VerticalDivider(thickness: 2, color: white)
                                ])),
                            const Expanded(
                              child: Text('Rules & Regulations',
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
                  /*Row(
                    children: [
                      Expanded(
                        child: HomeTile(
                            onTap: () =>
                                Get.to(() => const CalenderPage(student: true)),
                            tileColor: red,
                            image: '',
                            text: 'Calender'),
                      ),
                      SizedBox(width: getWidth(context) * .15),
                      Expanded(
                          child: HomeTile(
                              onTap: () => Get.to(() => const FeedbackPage()),
                              text: 'Feedback',
                              image: '',
                              tileColor: Colors.brown.shade500)),
                    ],
                  ),*/
                  FlipInX(
                    duration: const Duration(milliseconds: 3000),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => Get.to(() => const FeedbackPage()),
                          child: Container(
                              decoration: const BoxDecoration(
                                  color: pColor, shape: BoxShape.circle),
                              height: getHeight(context) * .2,
                              width: getWidth(context) * .4,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image.asset('assets/feedback.png',
                                      height: 55),
                                  Text('Feedback',
                                      style: GoogleFonts.permanentMarker(
                                          color: white, fontSize: 18))
                                ],
                              )),
                        ),
                        InkWell(
                          onTap: () => Get.to(() => const CalenderPage()),
                          child: Container(
                              decoration: const BoxDecoration(
                                  color: pColor, shape: BoxShape.circle),
                              height: getHeight(context) * .2,
                              width: getWidth(context) * .4,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image.asset('assets/calendar.png',
                                      height: 55),
                                  Text('Calender',
                                      style: GoogleFonts.permanentMarker(
                                          color: white, fontSize: 18))
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: getHeight(context) * .04),
                  FlipInX(
                    duration: const Duration(milliseconds: 3000),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => Get.to(() => const AboutUsPage()),
                          child: Container(
                              decoration: const BoxDecoration(
                                  color: pColor,
                                  // borderRadius: BorderRadius.circular(10)
                                  shape: BoxShape.circle),
                              height: getHeight(context) * .2,
                              width: getWidth(context) * .4,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image.asset('assets/about.png', height: 55),
                                  Text('About Us',
                                      style: GoogleFonts.permanentMarker(
                                          color: white, fontSize: 18))
                                ],
                              )),
                        ),
                        InkWell(
                          onTap: () => Get.to(() => const NoticePage()),
                          child: Container(
                              decoration: const BoxDecoration(
                                  color: pColor, shape: BoxShape.circle),
                              height: getHeight(context) * .2,
                              width: getWidth(context) * .4,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image.asset('assets/notice.png', height: 55),
                                  Text('Notice Board',
                                      maxLines: 2,
                                      softWrap: true,
                                      style: GoogleFonts.permanentMarker(
                                          color: white, fontSize: 16))
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void fetchData() async {
    stuClass = await getStudentClass();

    String roll = await getStudentRoll();
    dataModel.clear();
    setState(() => loading = true);

    final date = DateTime.now();

    /*  if (date.day <= 5) {
      String d = DateFormat("MMMM dd, yyyy").format(DateTime.now());

      String m = DateFormat("MMMM").format(DateTime.now());

      final notice = NoticeModel(
          active: true,
          date: d,
          title: 'Fee Notice',
          description:
              'Please Submit your monthly fee until 5th $m. Otherwise Rs.100 will be charged per day after due date',
          id: '',
          image: '');

      dataModel.add(notice);
    }*/

    try {
      /*await fireStore.collection('NoticeBoard').get().then((value) {
        for (var noticeData in value.docs) {
          log("noticeData = ${noticeData.data()}");

          final noticeModel = NoticeModel.fromJson(noticeData.data());
          if (noticeModel.active) {
            dataModel.add(noticeModel);
          }
        }
      });*/

      var coll = fireStore.collection('Classes/Class$stuClass/Attendance');
      var docSnapshot = await coll.doc(roll).get();

      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();

        if (data != null) {
          log('attendance : ${data.toString()}');
          present = data['present'];
          absent = data['absent'];
          per = (present / (present + absent)) * 100;
        }
      }
    } on Exception catch (e) {
      log(e.toString());
      showErrorToast(context: context, text: 'Something went wrong');
    } finally {
      setState(() => loading = false);
    }

    dataModel = [
      DataModel(
          text: 'Assignments',
          onTap: () => Get.to(() => AssignmentPage(className: stuClass)),
          image: 'assets/assignment.png',
          color: Colors.indigo.shade700),
      DataModel(
          text: 'Results',
          onTap: () => Get.to(() => ResultPage(className: stuClass)),
          image: 'assets/result.png',
          color: Colors.cyanAccent.shade700),
      DataModel(
          text: 'Timetable',
          onTap: () =>
              Get.to(() => TimeTablePage(className: stuClass, student: true)),
          image: 'assets/timetable.png',
          color: Colors.purpleAccent.shade400),
      DataModel(
          text: 'Profile',
          onTap: () => Get.to(() => const ProfilePage()),
          image: 'assets/student.png',
          color: Colors.yellow.shade600),
      // DataModel(
      //     text: 'Feedback',
      //     onTap: () => Get.to(() => const FeedbackPage()),
      //     image: 'assets/feedback.png',
      //     color: pColor),
      // DataModel(
      //     text: 'Calendar',
      //     onTap: () => Get.to(() => const CalenderPage()),
      //     image: 'assets/calendar.png',
      //     color: Colors.red.shade500),
      // DataModel(
      //     text: 'Rules & Regulations',
      //     onTap: () {},
      //     image: 'assets/about.png',
      //     color: Colors.brown.shade400),
    ];
  }
}

class HomeTile extends StatelessWidget {
  const HomeTile({
    Key? key,
    required this.image,
    required this.text,
    required this.tileColor,
    required this.onTap,
  }) : super(key: key);

  final String image, text;
  final Color tileColor;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
          decoration: BoxDecoration(
              color: tileColor, borderRadius: BorderRadius.circular(10)),
          height: getHeight(context) * .15,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset(image, height: 60),
              Text(text,
                  style:
                      GoogleFonts.permanentMarker(color: white, fontSize: 18))
            ],
          )),
    );
  }
}
