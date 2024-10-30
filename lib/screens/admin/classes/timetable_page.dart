import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/master.dart';
import 'class_models.dart';

class TimeTablePage extends StatefulWidget {
  final String className;
  final bool student;

  const TimeTablePage({Key? key, required this.className, this.student = false})
      : super(key: key);

  @override
  State<TimeTablePage> createState() => _TimeTablePageState();
}

class _TimeTablePageState extends State<TimeTablePage> {
  bool loading = false;
  List<SubjectModel> subjects = [];
  List<TimetableModel> dataModel = [];
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
        title: Text('Class ${widget.className} Timetable'),
      ),
      floatingActionButton: loading //|| dataModel.isNotEmpty
          ? const SizedBox()
          : FloatingActionButton(
              onPressed: () {
                Get.off(() => AddTimetable(
                    className: widget.className, dataModel: dataModel));
                //createBottomSheet(context);
              },
              child: const Icon(Icons.add)),
      body: loading
          ? const Loader()
          : dataModel.isNotEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      margin: EdgeInsets.symmetric(
                          horizontal: getWidth(context) * .05),
                      child: DataTable(
                          headingRowColor: WidgetStateProperty.all<Color>(
                              Colors.green.shade100),
                          //border: TableBorder.all(),
                          columns: const [
                            DataColumn(label: Text('Time')),
                            DataColumn(label: Text('Subject')),
                          ],
                          rows: dataModel
                              .map((e) => DataRow(cells: [
                                    DataCell(Text(e.time)),
                                    DataCell(Text(e.subject)),
                                  ]))
                              .toList()),
                    ),
                  ],
                )
              : const Center(child: Text('No Timetable found.')),
    );
  }

  void fetchData() async {
    subjects.clear();
    setState(() => loading = true);

    // await fireStore
    //     .collection('Classes/Class${widget.className}/Subjects')
    //     .orderBy('subject')
    //     .get()
    //     .then((value) {
    //   for (var subjectData in value.docs) {
    //     log("subjectData = ${subjectData.data()}");
    //
    //     final assignment = SubjectModel.fromJson(subjectData.data());
    //     subjects.add(assignment);
    //   }
    // });

    await fireStore
        .collection('Classes/Class${widget.className}/Timetable')
        .orderBy('time')
        .get()
        .then((value) {
      for (var timeData in value.docs) {
        log("timeData = ${timeData.data()}");

        final time = TimetableModel.fromJson(timeData.data());
        dataModel.add(time);
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

class AddTimetable extends StatefulWidget {
  final String className;
  final List<TimetableModel> dataModel;

  const AddTimetable(
      {Key? key, required this.className, required this.dataModel})
      : super(key: key);

  @override
  State<AddTimetable> createState() => _AddTimetableState();
}

class _AddTimetableState extends State<AddTimetable> {
  final subjectCont = TextEditingController();
  final timeCont = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  List<TimetableModel> dataModel = [];
  String from = '', to = '';
  String? id;

  @override
  void initState() {
    dataModel = widget.dataModel;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Timetable Management')),
        body: ListView(
          padding: EdgeInsets.symmetric(
              horizontal: getWidth(context) * .05,
              vertical: getHeight(context) * .02),
          children: [
            loading
                ? SizedBox(
                    height: getHeight(context) * .35, child: const Loader())
                : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CreateCustomButton(
                            text: 'From',
                            width: getWidth(context) * .4,
                            onTap: () async {
                              TimeOfDay? time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                  initialEntryMode:
                                      TimePickerEntryMode.dialOnly);
                              if (time != null) {
                                from = (time.toString().split('(').last)
                                    .split(')')
                                    .first;
                                log('from: $from');

                                setState(() {});
                              }
                            },
                          ),
                          CreateCustomButton(
                            text: 'To',
                            width: getWidth(context) * .4,
                            onTap: () async {
                              TimeOfDay? time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                  initialEntryMode:
                                      TimePickerEntryMode.dialOnly);
                              if (time != null) {
                                to = (time.toString().split('(').last)
                                    .split(')')
                                    .first;
                                log('to: $to');

                                setState(() {});
                              }
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(from.isNotEmpty ? from : '--'),
                          Text(to.isNotEmpty ? to : '--'),
                        ],
                      ),
                      Form(
                        key: _formKey,
                        child: CreateCustomField(
                            text: 'Subject',
                            controller: subjectCont,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter subject';
                              }
                              return null;
                            }),
                      ),
                      CreateCustomButton(
                          text: 'Save',
                          width: getWidth(context) * .7,
                          onTap: () {
                            if (_formKey.currentState!.validate() &&
                                (from.isNotEmpty && to.isNotEmpty)) {
                              addData();
                            }
                          }),
                      SizedBox(height: getHeight(context) * .1),
                    ],
                  ),
            const Divider(thickness: 5),
            dataModel.isNotEmpty
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                        border: TableBorder.all(),
                        columns: const [
                          DataColumn(label: Text('Time')),
                          DataColumn(label: Text('Subject')),
                          DataColumn(label: Text('Action')),
                        ],
                        rows: dataModel
                            .map((e) => DataRow(cells: [
                                  DataCell(Text(e.time)),
                                  DataCell(Text(e.subject)),
                                  DataCell(Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                          onTap: () {
                                            from = e.time.split(' ').first;
                                            to = e.time.split('to ').last;
                                            subjectCont.text = e.subject;
                                            id = e.id;

                                            dataModel.remove(e);
                                            setState(() {});
                                          },
                                          child: const Icon(Icons.edit,
                                              color: blue)),
                                      InkWell(
                                          onTap: () {
                                            deleteData(deleteId: e.id);
                                            dataModel.remove(e);
                                          },
                                          child: const Icon(Icons.delete,
                                              color: red)),
                                    ],
                                  )),
                                ]))
                            .toList()),
                  )
                : const Text('--'),
          ],
        ));
  }

  void addData() async {
    setState(() => loading = true);

    var doc = fireStore
        .collection('Classes/Class${widget.className}/Timetable')
        .doc(id);

    final model = TimetableModel(
        subject: subjectCont.text, id: doc.id, time: '$from to $to');

    final data = model.toJson();

    id != null ? await doc.update(data) : await doc.set(data);

    dataModel.add(model);
    from = '';
    to = '';
    subjectCont.clear();

    setState(() => loading = false);
    showSuccessToast(context: context, text: 'Entry added successfully');
  }

  void deleteData({required String deleteId}) async {
    setState(() => loading = true);

    await fireStore
        .collection('Classes/Class${widget.className}/Timetable')
        .doc(deleteId)
        .delete();

    setState(() => loading = false);
    showDeleteToast(context: context);
  }
}
