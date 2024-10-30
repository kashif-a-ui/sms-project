import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '/master.dart';
import 'feedback_model.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  bool loading = false;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  List<FeedbackModel> dataModel = [];
  final titleCont = TextEditingController();

  @override
  void initState() {
    fetchData();
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
          : dataModel.isNotEmpty
              ? ListView(
                  children: [
                    Card(child: Image.asset('assets/feedback_top.png', height: getHeight(context)*.25)),
                    ListView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: getWidth(context) * .04,
                          vertical: getHeight(context) * .02),
                      itemCount: dataModel.length,
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      itemBuilder: (context, index) {
                        final item = dataModel[index];
                        return Card(
                          color: Colors.green.shade50,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          margin: const EdgeInsets.only(bottom: 15),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Text('form: ',
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic)),
                                    Text(item.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20)),
                                  ],
                                ),
                                SizedBox(height: getHeight(context) * .01),
                                Text(
                                  item.feedback,
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
                  ],
                )
              : const Center(child: Text('No feedback.')),
    );
  }

  void fetchData() async {
    dataModel.clear();
    setState(() => loading = true);

    await fireStore.collection('Feedback').get().then((value) {
      for (var feedbackData in value.docs) {
        log("feedbackData = ${feedbackData.data()}");

        final noticeModel = FeedbackModel.fromJson(feedbackData.data());
        dataModel.add(noticeModel);
      }
    });
    setState(() => loading = false);
  }
}
