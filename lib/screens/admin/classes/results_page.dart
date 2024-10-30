import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/master.dart';
import '../students/student_model.dart';
import 'class_models.dart';

class ResultPage extends StatefulWidget {
  final String className;
  final bool student;
  final List<StudentModel> students;

  const ResultPage(
      {Key? key,
      required this.className,
      this.student = false,
      required this.students})
      : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool loading = false;
  List<ResultModel> dataModel = [];

  List<String> drops = [
    '1st Term Results',
    '2nd Term Results',
    'Annual Results'
  ];
  String? _chosenType, _chosenStu;
  final titleCont = TextEditingController();
  final descCont = TextEditingController();
  final dateCont = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _chosenType = '1st Term Results';
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Class ${widget.className} Results'),
      ),
      floatingActionButton: loading
          ? const SizedBox()
          : FloatingActionButton(
              onPressed: fetchSubjects, child: const Icon(Icons.add)),
      body: loading
          ? const Loader()
          : ListView(
              padding: EdgeInsets.symmetric(
                  horizontal: getWidth(context) * .04,
                  vertical: getHeight(context) * .02),
              children: [
                Card(
                  color: Colors.green.shade100,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.black38)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: DropdownButton(
                      underline: const SizedBox(),
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: drops.map<DropdownMenuItem<String>>((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 2,
                          ),
                        );
                      }).toList(),
                      value: _chosenType,
                      style: const TextStyle(color: black),
                      hint: const Text(
                        "Select Result Type",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                      onChanged: (String? value) {
                        if (_chosenType != null &&
                            !_chosenType!.contains(value!)) {
                          _chosenType = value;
                          log('_chosenType: $_chosenType');

                          fetchData();
                        }

                        // setState(() {});
                      },
                    ),
                  ),
                ),
                SizedBox(height: getHeight(context) * .02),
                dataModel.isNotEmpty
                    ? ListView.builder(
                        itemCount: dataModel.length,
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemBuilder: (context, index) {
                          final item = dataModel[index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ExpansionTile(
                              collapsedBackgroundColor: pColor,
                              collapsedTextColor: white,
                              collapsedIconColor: white,
                              textColor: pColor,
                              leading: Text(item.rollNo,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              title: Text(item.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: item.subjectsMarks.length,
                                  itemBuilder: (context, index) {
                                    final sub = item.subjectsMarks[index];
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(sub.subject,
                                              style: const TextStyle(
                                                  color: pColor,
                                                  fontWeight: FontWeight.w500)),
                                          Text(
                                              '${sub.obtained} / ${sub.total}'),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const Divider(),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Total',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          calculateTotal(
                                                  subjectsMarks:
                                                      item.subjectsMarks)
                                              .toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Obtained',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          calculateObtained(
                                                  subjectsMarks:
                                                      item.subjectsMarks)
                                              .toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : SizedBox(
                        height: getHeight(context) * .6,
                        child: Center(
                          child: Text('No Data for $_chosenType'),
                        ),
                      )
              ],
            ),
    );
  }

  void fetchData() async {
    dataModel.clear();
    setState(() => loading = true);

    for (StudentModel model in widget.students) {
      List<SubjectSheet> subData = [];

      await fireStore
          .collection(
              'Classes/Class${widget.className}/Results/${model.rollNo}/$_chosenType')
          .get()
          .then((value) {
        for (var resultData in value.docs) {
          log("resultData = ${resultData.data()}");

          final result = SubjectSheet.fromJson(resultData.data());

          subData.add(result);
        }
      });
      dataModel.add(ResultModel(
          name: model.name, rollNo: model.rollNo, subjectsMarks: subData));
      if (subData.isEmpty) {
        dataModel.clear();
      }
    }

    setState(() => loading = false);
  }

  void fetchSubjects() async {
    setState(() => loading = true);

    List<SubjectModel> subjects = [];
    await fireStore
        .collection('Classes/Class${widget.className}/Subjects')
        .get()
        .then((value) {
      for (var subjectData in value.docs) {
        log("subjectData = ${subjectData.data()}");

        final s = SubjectModel.fromJson(subjectData.data());
        subjects.add(s);
      }
    });
    setState(() => loading = false);
    Get.to(() => AddStudentResult(
        students: widget.students,
        subjects: subjects,
        className: widget.className));
  }

  calculateTotal({required List<SubjectSheet> subjectsMarks}) {
    num total = 0.0;
    for (final model in subjectsMarks) {
      total = total + num.parse(model.total);
    }
    return total;
  }

  calculateObtained({required List<SubjectSheet> subjectsMarks}) {
    num obtained = 0.0;
    for (final model in subjectsMarks) {
      obtained = obtained + num.parse(model.obtained);
    }
    return obtained;
  }
}

class AddStudentResult extends StatefulWidget {
  final List<StudentModel> students;
  final List<SubjectModel> subjects;
  final String className;

  const AddStudentResult(
      {Key? key,
      required this.students,
      required this.subjects,
      required this.className})
      : super(key: key);

  @override
  State<AddStudentResult> createState() => _AddStudentResultState();
}

class _AddStudentResultState extends State<AddStudentResult> {
  String? _chosenStu, _subject, _type;

  final totalCOnt = TextEditingController();
  final obtCont = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  List<SubjectSheet> dataModel = [];
  List<String> drops = [
    '1st Term Results',
    '2nd Term Results',
    'Annual Results'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Student Result')),
      body: loading
          ? const Loader()
          : ListView(
              padding: EdgeInsets.symmetric(
                  horizontal: getWidth(context) * .05,
                  vertical: getHeight(context) * .02),
              children: [
                Card(
                  color: Colors.green.shade100,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.black38)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: DropdownButton(
                      underline: const SizedBox(),
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: drops.map<DropdownMenuItem<String>>((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 2,
                          ),
                        );
                      }).toList(),
                      value: _type,
                      style: const TextStyle(color: black),
                      hint: const Text(
                        "Select Result Type",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                      onChanged: (String? value) {
                        _type = value;
                        setState(() {});
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Card(
                  color: Colors.green.shade100,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.black38)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: DropdownButton(
                      underline: const SizedBox(),
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: widget.students
                          .map<DropdownMenuItem<String>>((value) {
                        return DropdownMenuItem<String>(
                          value: value.rollNo,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(value.name,
                                  overflow: TextOverflow.ellipsis, maxLines: 1),
                              Text(value.rollNo),
                            ],
                          ),
                        );
                      }).toList(),
                      value: _chosenStu,
                      style: const TextStyle(color: black),
                      hint: const Text(
                        "Select Student",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                      onChanged: (String? value) {
                        _chosenStu = value;
                        setState(() {});
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                dataModel.length == widget.subjects.length
                    ? const SizedBox()
                    : Align(
                        alignment: Alignment.topRight,
                        child: CreateCustomButton(
                            onTap: () => createBottomSheet(context),
                            text: 'Add Marks'),
                      ),
                dataModel.isNotEmpty
                    ? ListView.builder(
                        itemCount: dataModel.length,
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemBuilder: (context, index) {
                          final item = dataModel[index];
                          return ListTile(
                              leading: Text(item.subject),
                              trailing:
                                  Text('${item.obtained} / ${item.total}'));
                        },
                      )
                    : const SizedBox(),
                dataModel.length == widget.subjects.length
                    ? CreateCustomButton(
                        text: 'Upload Marks', onTap: addData, isRound: true)
                    : const SizedBox()
              ],
            ),
    );
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
                      const Text('Add Result',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500)),
                      Card(
                        color: Colors.green.shade100,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Colors.black38)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: DropdownButton(
                            underline: const SizedBox(),
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: widget.subjects
                                .map<DropdownMenuItem<String>>((value) {
                              return DropdownMenuItem<String>(
                                value: value.subject,
                                child: Text(value.subject,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1),
                              );
                            }).toList(),
                            value: _subject,
                            style: const TextStyle(color: black),
                            hint: const Text(
                              "Select Subject",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                            onChanged: (String? value) {
                              _subject = value;
                              setState(() {});
                              setBottomState(() {});
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CreateCustomField(
                          text: 'Total',
                          controller: totalCOnt,
                          autoFocus: true,
                          keyBoardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the total';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CreateCustomField(
                          text: 'Obtained',
                          controller: obtCont,
                          autoFocus: true,
                          keyBoardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the obtained';
                            }
                            return null;
                          },
                        ),
                      ),
                      CreateCustomButton(
                          width: getWidth(context) * .9,
                          onTap: () async {
                            if (_formKey.currentState!.validate() &&
                                _subject != null) {
                              Get.back();

                              dataModel.add(SubjectSheet(
                                  subject: _subject!,
                                  total: totalCOnt.text,
                                  obtained: obtCont.text));
                              _subject = null;
                              totalCOnt.clear();
                              obtCont.clear();
                              setState(() {});
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

    for (SubjectSheet item in dataModel) {
      final data = {
        'subject': item.subject,
        'total': item.total,
        'obtained': item.obtained,
      };
      await fireStore
          .collection(
              'Classes/Class${widget.className}/Results/$_chosenStu/$_type/')
          .doc(item.subject)
          .set(data);
    }

    dataModel.clear();
    _chosenStu = null;
    _type = null;

    showSuccessToast(context: context, text: 'Student Result Added');

    setState(() => loading = false);
  }
}
