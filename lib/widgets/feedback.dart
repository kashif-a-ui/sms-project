import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '/master.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  bool loading = false;
  final nameCont = TextEditingController();
  final emailCont = TextEditingController();
  final feedbackCont = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    fetchUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: loading
          ? const Loader()
          : ListView(
              padding: EdgeInsets.symmetric(
                  horizontal: getWidth(context) * .04,
                  vertical: getHeight(context) * .02),
              children: [
                CreateCustomField(
                    text: 'Name', controller: nameCont, enabled: false),
                SizedBox(height: getHeight(context) * .02),
                CreateCustomField(
                    text: 'Email', controller: emailCont, enabled: false),
                SizedBox(height: getHeight(context) * .02),
                Form(
                  key: _formKey,
                  child: CreateCustomField(
                    text: 'Feedback',
                    controller: feedbackCont,
                    minLines: 15,
                    lines: 15,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter feedback';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: getHeight(context) * .02),
                MaterialButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        sendFeedback();
                      }
                    },
                    shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    color: green,
                    textColor: white,
                    child: const Text('Upload'))
              ],
            ),
    );
  }

  void fetchUserDetails() async {
    String email = await getUserEmail();
    String name = await getUsername();

    nameCont.text = name;
    emailCont.text = email;
    setState(() {});
  }

  sendFeedback() async {
    setState(() => loading = true);
    String uid = await getUserToken();

    var doc = fireStore.collection('Feedback').doc(uid);

    String date = DateFormat("MMMM dd, yyyy").format(DateTime.now());

    final data = {
      'email': nameCont.text,
      'name': emailCont.text,
      'feedback': feedbackCont.text,
      'date': date,
      'id': uid
    };

    await doc.set(data);

    showSuccessToast(context: context, text: 'Your feedback is received.');

    Get.back();
  }
}
