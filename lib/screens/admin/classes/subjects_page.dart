import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/master.dart';
import 'class_models.dart';

class SubjectPage extends StatefulWidget {
  final String className;
  final bool student;

  const SubjectPage({Key? key, required this.className, this.student = false})
      : super(key: key);

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  bool loading = false;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  List<SubjectModel> dataModel = [];
  final subjectCont = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Class ${widget.className} Subjects'),
      ),
      floatingActionButton: loading
          ? const SizedBox()
          : FloatingActionButton(
              onPressed: () => createBottomSheet(context),
              child: const Icon(Icons.add)),
      body: loading
          ? const Loader()
          : dataModel.isNotEmpty
              ? GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 80,
                      crossAxisSpacing: 25,
                      mainAxisSpacing: 20),
                  padding: EdgeInsets.symmetric(
                      horizontal: getWidth(context) * .04,
                      vertical: getHeight(context) * .02),
                  itemCount: dataModel.length,
                  itemBuilder: (context, index) {
                    final item = dataModel[index];
                    return Card(
                      color: shimmerColor,
                      child: Card(
                        child: Center(
                            child: Text(
                          item.subject,
                          style: const TextStyle(
                              color: pColor, fontWeight: FontWeight.w500),
                        )),
                      ),
                    );
                  },
                )
              : const Center(child: Text('No Subjects found.')),
    );
  }

  void fetchData() async {
    dataModel.clear();
    setState(() => loading = true);

    await fireStore
        .collection('Classes/Class${widget.className}/Subjects')
        .orderBy('subject')
        .get()
        .then((value) {
      for (var subjectData in value.docs) {
        log("subjectData = ${subjectData.data()}");

        final assignment = SubjectModel.fromJson(subjectData.data());
        dataModel.add(assignment);
      }
    });
    setState(() => loading = false);
  }

  createBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return StatefulBuilder(builder: (context, setBottomState) {
            return Card(
              //color: shimmerColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Text('Add Subject',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500)),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CreateCustomField(
                          text: 'Subject',
                          controller: subjectCont,
                          autoFocus: true,
                          keyBoardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the Subject';
                            }
                            return null;
                          },
                        ),
                      ),
                      CreateCustomButton(
                          width: getWidth(context) * .9,
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              Get.back();
                              addData();
                            }
                          },
                          text: 'Save',
                          buttonColor: pColor),
                      SizedBox(height: getHeight(context) * .02)
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  void addData() async {
    setState(() => loading = true);

    var doc =
        fireStore.collection('Classes/Class${widget.className}/Subjects').doc();

    final data = {
      'subject': subjectCont.text,
      "id": doc.id,
    };

    await doc.set(data);

    subjectCont.clear();

    setState(() => loading = false);
    showSuccessToast(context: context, text: 'Subject added successfully');

    fetchData();
  }
}
