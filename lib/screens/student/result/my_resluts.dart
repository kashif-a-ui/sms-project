import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sms/screens/admin/classes/class_models.dart';

import '/master.dart';

class ResultPage extends StatefulWidget {
  final String className;

  const ResultPage({
    Key? key,
    required this.className,
  }) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool loading = false;
  List<SubjectSheet> dataModel = [];

  List<String> drops = [
    '1st Term Results',
    '2nd Term Results',
    'Annual Results'
  ];
  String? _chosenType, _chosenStu;

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
        title: const Text('My Results'),
      ),
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
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DataTable(
                        headingRowColor: WidgetStateProperty.all<Color>(
                            Colors.green.shade100),
                        columns: const [
                          DataColumn(label: Text('Subject')),
                          DataColumn(label: Text('Obt. Marks')),
                          DataColumn(label: Text('Total Marks')),
                        ],
                        rows: dataModel
                            .map((e) => DataRow(
                                    color: e.subject.contains('Total')
                                        ? WidgetStateProperty.all<Color>(
                                            Colors.green.shade100)
                                        : null,
                                    cells: [
                                      DataCell(Text(
                                        e.subject,
                                        style: TextStyle(
                                            fontWeight:
                                                e.subject.contains('Total')
                                                    ? FontWeight.bold
                                                    : null,
                                            color: pColor),
                                      )),
                                      DataCell(Text(
                                        e.obtained,
                                        style: TextStyle(
                                            fontWeight:
                                                e.subject.contains('Total')
                                                    ? FontWeight.bold
                                                    : null),
                                      )),
                                      DataCell(Text(
                                        e.total,
                                        style: TextStyle(
                                            fontWeight:
                                                e.subject.contains('Total')
                                                    ? FontWeight.bold
                                                    : null),
                                      )),
                                    ]))
                            .toList(),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }

  void fetchData() async {
    dataModel.clear();
    setState(() => loading = true);

    String rollNo = await getStudentRoll();

    await fireStore
        .collection(
            'Classes/Class${widget.className}/Results/$rollNo/$_chosenType')
        .get()
        .then((value) {
      for (var resultData in value.docs) {
        log("resultData = ${resultData.data()}");

        final result = SubjectSheet.fromJson(resultData.data());

        dataModel.add(result);
      }
    });

    dataModel.add(SubjectSheet(
      subject: 'Total',
      total: calculateTotal(subjectsMarks: dataModel).toString(),
      obtained: calculateObtained(subjectsMarks: dataModel).toString(),
    ));

    setState(() => loading = false);
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
