import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart' as g;
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'widgets/custom_buttons.dart';
export 'widgets/custom_text_field.dart';
export 'widgets/detail_screen.dart';
export 'widgets/feedback.dart';

const black = Colors.black;
const white = Colors.white;
const red = Colors.red;
const blue = Colors.blue;
const blueGrey = Colors.blueGrey;
const yellow = Colors.yellow;
const orange = Colors.orange;
const orangeDeep = Colors.deepOrange;
const grey = Colors.grey;
const green = Colors.green;

const shimmerColor = Color(0xFFE7FBE7);
const pColor = Color(0xff2ECB70);
const bColor = Color(0xFFF5F5F5);
const appVersion = '1.0.0';

FirebaseFirestore fireStore = FirebaseFirestore.instance;

bool isEmailValid(String text) {
  Pattern pattern =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9])?)*$";
  RegExp regex = RegExp(pattern.toString());

  return !regex.hasMatch(text);
}

alertDialogueWithLoader({required BuildContext context}) {
  log("alertDialogueWithLoader fired");
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 300,
        color: Colors.transparent,
        child: Center(
            child: SizedBox(
          height: 70,
          width: 70,
          child: SpinKitFadingCircle(
            color: Colors.blue[200],
            size: 50.0,
          ),
        )),
      );
    },
  );
}

const String apiHeader = '';

double getWidth(BuildContext context) => MediaQuery.of(context).size.width;

double getHeight(BuildContext context) => MediaQuery.of(context).size.height;

Future<void> setUserDetails(
    {required String token,
    required String name,
    required String email,
    required String userType}) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  log("setting user token : $token");
  preferences.setString("token", token);
  log("setting user name : $name");
  preferences.setString("name", name);
  log("setting user email : $email");
  preferences.setString("email", email);
  log("setting user type : $userType");
  preferences.setInt("userType", int.parse(userType));
}

void closeApp() {
  if (Platform.isAndroid) {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  } else {
    exit(0);
  }
}

userCheckedIn() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setBool('checkedIn', true);
  log('user is checked in');
}

isCheckedIn() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.getBool('checkedIn') == null) {
    log('Checked In : false');
    return false;
  } else {
    log('Checked In : true');
    return true;
  }
}

Future<String> getUserToken() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.getString("token") == null) {
    log("null user token");
    return "";
  }
  log('getting token: Successfully');
  return preferences.getString("token").toString();
}

Future<String> getUsername() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.getString("name") == null) {
    log("null user name");
    return "";
  }
  log('getting name: Successfully');
  return preferences.getString("name").toString();
}

Future<String> getUserEmail() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.getString("email") == null) {
    log("null user email");
    return "";
  }
  log('getting email: Successfully');
  return preferences.getString("email").toString();
}

Future<String> getUserPhone() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.getString("phone") == null) {
    log("null user phone");
    return "";
  }
  log('getting phone: Successfully');
  return preferences.getString("phone").toString();
}

void showErrorToast({required BuildContext context, required String text}) {
  MotionToast.error(
    title: const Text(
      'Oops',
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    description: Text(text),
    animationType: AnimationType.fromBottom,
    position: MotionToastPosition.bottom,
  ).show(context);
}

void showDeleteToast({required BuildContext context}) {
  MotionToast.delete(
    title: const Text(
      'Success',
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    description: const Text('Item deleted successfully!'),
    animationType: AnimationType.fromBottom,
    position: MotionToastPosition.bottom,
  ).show(context);
}

void showSuccessToast({required BuildContext context, required String text}) {
  MotionToast.success(
    title: const Text(
      'Success',
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    description: Text(text),
    animationType: AnimationType.fromBottom,
    position: MotionToastPosition.bottom,
  ).show(context);
}

void showInfoToast({required BuildContext context, required String text}) {
  MotionToast(
    title: const Text('Description',
        style: TextStyle(fontWeight: FontWeight.bold)),
    description: Text(text),
    barrierColor: Colors.grey.shade200.withOpacity(0.6),
    animationType: AnimationType.fromBottom,
    position: MotionToastPosition.center,
    toastDuration: const Duration(seconds: 5),
    primaryColor: pColor,
    backgroundType: BackgroundType.lighter,
    icon: Icons.info,
  ).show(context);
}

removePrefs() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.remove('token');
  preferences.remove('userId');
  preferences.remove('name');
  preferences.remove('email');
  preferences.remove('userType');
  preferences.remove('roll');
  preferences.remove('stuClass');
  preferences.remove('tecClass');

  log('token and userId removed from prefs');
}

setStudentClass({required String stuClass}) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  log("setting student class : $stuClass");
  preferences.setString("stuClass", stuClass);
}

setStudentRoll({required String roll}) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  log("setting student roll : $roll");
  preferences.setString("roll", roll);
}

Future getStudentClass() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.getString("stuClass") == null) {
    log("null stuClass");
    return "";
  }
  return preferences.getString("stuClass");
}

Future getStudentRoll() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.getString("roll") == null) {
    log("null roll");
    return "";
  }
  return preferences.getString("roll");
}

setTeacherClass({required String tecClass}) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  log("setting teacher class : $tecClass");
  preferences.setString("tecClass", tecClass);
}

Future getTeacherClass() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.getString("tecClass") == null) {
    log("null tecClass");
    return "";
  }
  return preferences.getString("tecClass");
}

Future<int> getUserType() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.getInt("userType") == null) {
    log("null user type");
    return -1;
  }
  return preferences.getInt("userType")!;
}

Future<bool?> displayToast(String m, {bool top = false, bool error = false}) {
  return Fluttertoast.showToast(
    msg: m,
    toastLength: Toast.LENGTH_SHORT,
    gravity: top ? ToastGravity.TOP : ToastGravity.BOTTOM,
    backgroundColor: error ? red : white,
    textColor: error ? white : black,
  );
}

showSnackBar({required String title, required String msg, bool top = false}) {
  g.Get.snackbar(title, msg,
      snackPosition: top ? g.SnackPosition.TOP : g.SnackPosition.BOTTOM,
      backgroundColor: shimmerColor);
}

showSnackAction(
    {required String title,
    required String msg,
    required String bText,
    required GestureTapCallback onTap}) {
  g.Get.snackbar(title, msg,
      mainButton: TextButton(onPressed: onTap, child: Text(bText)),
      snackPosition: g.SnackPosition.BOTTOM,
      backgroundColor: shimmerColor);
}

const List monthsList = [
  'months',
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
];
const List years = [
  '2020',
  '2021',
  '2022',
  '2023',
  '2024',
  '2025',
  '2026',
  '2027',
  '2028',
  '2029',
  '2030',
  '2031',
  '2032',
  '2033',
  '2034',
  '2035',
  '2036',
  '2037',
  '2038',
  '2039',
  '2040',
];

const List months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];

const List dates = [
  '01',
  '02',
  '03',
  '04',
  '05',
  '06',
  '07',
  '08',
  '09',
  '10',
  '11',
  '12',
  '13',
  '14',
  '15',
  '16',
  '17',
  '18',
  '19',
  '20',
  '21',
  '22',
  '23',
  '24',
  '25',
  '26',
  '27',
  '28',
  '29',
  '30',
  '31',
];

class Loader extends StatelessWidget {
  const Loader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SpinKitSpinningLines(color: pColor),
        Text('Please Wait..', style: TextStyle(color: black))
      ],
    );
  }
}

String convertDate({required DateTime mDate}) =>
    '${mDate.day} ${monthsList[mDate.month]}, ${mDate.year}';

String getInitials(String name) => name.isNotEmpty
    ? name.trim().split(RegExp(' +')).map((s) => s[0]).take(2).join()
    : '';

class DataModel {
  final String text, image;
  final GestureTapCallback onTap;
  final Color color;

  DataModel(
      {required this.text,
      this.image = '',
      required this.onTap,
      this.color = pColor});
}
