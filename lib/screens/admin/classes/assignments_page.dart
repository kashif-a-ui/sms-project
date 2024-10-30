import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '/master.dart';
import 'class_models.dart';

class AssignmentPage extends StatefulWidget {
  final String className;
  final bool student;

  const AssignmentPage(
      {Key? key, required this.className, this.student = false})
      : super(key: key);

  @override
  State<AssignmentPage> createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  bool loading = false, isStudent = false;
  List<AssignmentModel> dataModel = [];
  final titleCont = TextEditingController();
  final descCont = TextEditingController();

  final subjectCont = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? dueDate;

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Class ${widget.className} Assignments'),
      ),
      floatingActionButton: loading || isStudent
          ? const SizedBox()
          : FloatingActionButton(
              onPressed: () => createBottomSheet(context),
              child: const Icon(Icons.add)),
      body: loading
          ? const Loader()
          : dataModel.isNotEmpty
              ? ListView.builder(
                  padding: EdgeInsets.symmetric(
                      horizontal: getWidth(context) * .04,
                      vertical: getHeight(context) * .02),
                  itemCount: dataModel.length,
                  itemBuilder: (context, index) {
                    final item = dataModel[index];
                    return Card(
                      color: Colors.green.shade100,
                      child: Card(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Subject:'),
                                  Text(item.subject)
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Topic:'),
                                  Text(item.title)
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: SingleChildScrollView(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Description:'),
                                    Text(item.description)
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Due Date:'),
                                  Text(item.dueDate)
                                  // Text(DateFormat("MMMM dd, yyyy")
                                  //     .format(DateTime.parse(item.dueDate)))
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                color: Colors.green.shade100,
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  item.date,
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                )
              : const Center(child: Text('No Assignments.')),
    );
  }

  void fetchData() async {
    dataModel.clear();
    setState(() => loading = true);

    int id = await getUserType();

    isStudent = id == 3;

    await fireStore
        .collection('Classes/Class${widget.className}/Assignments')
        .get()
        .then((value) {
      for (var assignmentData in value.docs) {
        log("assignmentData = ${assignmentData.data()}");

        final assignment = AssignmentModel.fromJson(assignmentData.data());
        dataModel.add(assignment);
      }
    });
    setState(() => loading = false);
  }

  void addData() async {
    setState(() => loading = true);

    String date = DateFormat("MMMM dd, yyyy").format(DateTime.now());
    String dDate = DateFormat("MMMM dd, yyyy").format(dueDate!);

    var doc = fireStore
        .collection('Classes/Class${widget.className}/Assignments')
        .doc();

    final data = {
      'subject': subjectCont.text,
      'title': titleCont.text,
      "description": descCont.text,
      "id": doc.id,
      "date": date,
      "due_date": dDate,
    };

    await doc.set(data);

    titleCont.clear();
    descCont.clear();
    subjectCont.clear();
    dueDate = null;

    setState(() => loading = false);
    showSuccessToast(
        context: context, text: 'New Assignment added successfully');

    fetchData();
  }

  createBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return StatefulBuilder(builder: (context, setBottomState) {
            return Card(
              color: shimmerColor,
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
                      const Text('Add Assignment',
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CreateCustomField(
                          text: 'Topic',
                          controller: titleCont,
                          autoFocus: true,
                          keyBoardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the Title';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CreateCustomField(
                            text: 'Description',
                            controller: descCont,
                            keyBoardType: TextInputType.text,
                            minLines: 5,
                            lines: 5),
                      ),
                      dueDate != null
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Due Date',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                    dueDate.toString().split(' ').first,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            )
                          : CreateCustomButton(
                              text: 'Select Due Date',
                              buttonColor: Colors.lightGreen,
                              onTap: () async {
                                dueDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2025));
                                setBottomState(() {});
                              }),
                      CreateCustomButton(
                          width: getWidth(context) * .9,
                          onTap: () async {
                            if (_formKey.currentState!.validate() &&
                                dueDate != null) {
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
}
