import 'dart:developer';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sms/screens/admin/calender/calender_page.dart';
import 'package:sms/screens/rules_regulations/rules_regulations.dart';

import '/master.dart';
import '../../widgets/notice_page.dart';
import '../about_us/about_us.dart';
import '../admin/classes/attendance_page.dart';
import '../admin/classes/results_page.dart';
import '../admin/notice_board/notice_model.dart';
import '../admin/students/student_model.dart';
import '../login/login.dart';
import 'profile/profile_page.dart';
import 'teacher_class_page.dart';

class TeacherHome extends StatefulWidget {
  const TeacherHome({Key? key}) : super(key: key);

  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  DateTime timeBackPressed = DateTime.now();
  List<NoticeModel> dataModel = [];
  bool loading = false;
  String tClass = '';

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
        backgroundColor: Colors.green.shade50,
        appBar: AppBar(
          title: const Text('Teacher Home'),
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
              horizontal: getWidth(context) * .05,
              vertical: getHeight(context) * .02),
          children: [
            /*dataModel.isNotEmpty
                ? SizedBox(
                    height: getHeight(context) * .3,
                    child: Swiper(
                      itemCount: dataModel.length,
                      itemWidth: getWidth(context),
                      itemHeight: getHeight(context) * .3,
                      layout: SwiperLayout.DEFAULT,
                      autoplayDisableOnInteraction: true,
                      pagination: const SwiperPagination(
                          builder: DotSwiperPaginationBuilder(
                              color: Colors.black, activeColor: Colors.white)),
                      indicatorLayout: PageIndicatorLayout.SCALE,
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
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20)),
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
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.network(item.image,
                                                height:
                                                    getHeight(context) * .12,
                                                fit: BoxFit.fitWidth),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                                SizedBox(height: getHeight(context) * .01),
                                Text(
                                  item.description,
                                  style: const TextStyle(fontSize: 17),
                                ),
                                SizedBox(height: getHeight(context) * .01),
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
                : SizedBox(
                    height: getHeight(context) * .3,
                    child: const SpinKitHourGlass(color: pColor),
                  ),*/
            SizedBox(height: getHeight(context) * .02),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Get.to(() => const TeacherClass()),
                    child: Container(
                        decoration: BoxDecoration(
                            color: blueGrey,
                            borderRadius: BorderRadius.circular(10)),
                        height: getHeight(context) * .15,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Image.asset('assets/classes.png', height: 65),
                            const Text('My Class',
                                style: TextStyle(color: white, fontSize: 18))
                          ],
                        )),
                  ),
                ),
                SizedBox(width: getWidth(context) * .15),
                Expanded(
                  child: InkWell(
                    onTap: () => Get.to(() => const ProfilePage()),
                    child: Container(
                        decoration: BoxDecoration(
                            color: blue,
                            borderRadius: BorderRadius.circular(10)),
                        height: getHeight(context) * .15,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(Icons.person, size: 60, color: white),
                            Text('My Profile',
                                style: TextStyle(color: white, fontSize: 18))
                          ],
                        )),
                  ),
                ),
              ],
            ),
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
            SizedBox(height: getHeight(context) * .07),
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset('assets/feedback.png', height: 55),
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset('assets/calendar.png', height: 55),
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
    tClass = await getTeacherClass();
    dataModel.clear();
    setState(() => loading = true);

    await fireStore.collection('NoticeBoard').get().then((value) {
      for (var noticeData in value.docs) {
        log("noticeData = ${noticeData.data()}");

        final noticeModel = NoticeModel.fromJson(noticeData.data());
        if (noticeModel.active) {
          dataModel.add(noticeModel);
        }
      }
    });

    setState(() => loading = false);
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
//6279262
