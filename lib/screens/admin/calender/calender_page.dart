import 'dart:developer';

import 'package:calendar_view/calendar_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '/master.dart';
import 'calender_model.dart';

class CalenderPage extends StatefulWidget {
  final bool student;

  const CalenderPage({Key? key, this.student = false}) : super(key: key);

  @override
  State<CalenderPage> createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  bool loading = false;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  List<CalenderModel> dataModel = [];
  final titleCont = TextEditingController();
  final descCont = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _date;

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: const Text('Annual Calender'),
      ),
      floatingActionButton: loading || widget.student
          ? const SizedBox()
          : FloatingActionButton(
              onPressed: () {
                createBottomSheet(context);
              },
              child: const Icon(Icons.add)),
      body: loading
          ? const Loader()
          : dataModel.isNotEmpty
              ? ListView(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(10),
                        height: getHeight(context) * .48,
                        child: MonthView(
                          cellAspectRatio: 1.2,
                          borderColor: grey,
                          headerStyle: const HeaderStyle(
                            decoration: BoxDecoration(color: pColor),
                            headerTextStyle: TextStyle(
                                color: white, fontWeight: FontWeight.bold),
                            leftIcon:
                                Icon(Icons.arrow_circle_left, color: white),
                            rightIcon:
                                Icon(Icons.arrow_circle_right, color: white),
                          ),
                          cellBuilder: (date, event, isToday, isInMonth) {
                            bool isEvent = event.isNotEmpty &&
                                event[0].date.compareWithoutTime(date);
                            return Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.zero,
                              color: isInMonth
                                  ? isToday
                                      ? blue
                                      : isEvent
                                          ? pColor
                                          : white
                                  : Colors.grey.shade300,
                              child: Text(date.day.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: isToday || isEvent
                                          ? FontWeight.bold
                                          : null,
                                      color:
                                          isToday || isEvent ? white : black)),
                            );
                          },
                          onCellTap: (events, date) {
                            if (events.isNotEmpty) {
                              showInfoToast(
                                  context: context,
                                  text: events[0].description);
                            }
                          },
                          // onEventTap: (event, date) => showInfoToast(
                          //     context: context, text: event.description),
                        )),
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
                          margin: const EdgeInsets.only(bottom: 25),
                          child: ExpansionTile(
                            leading: Text(item.date),
                            title: Text(item.event),
                            children: [
                              Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Description:',
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.bold)),
                                    Text(item.description,
                                        style: const TextStyle(fontSize: 18)),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                )
              : const Center(child: Text('No Event available')),
    );
  }

  void addData() async {
    setState(() => loading = true);

    String date = DateFormat("MMMM dd").format(_date!);

    var doc = fireStore.collection('Calender').doc();

    final data = {
      'event': titleCont.text,
      "id": doc.id,
      "date": date,
      "c_date": _date.toString().split(' ').first,
      "description": descCont.text,
      'month': (_date!.month * 100) + _date!.day
    };

    await doc.set(data);

    titleCont.clear();
    descCont.clear();
    _date = null;

    setState(() => loading = false);
    showSuccessToast(context: context, text: 'Event added successfully');

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
                      const Text('Add Notice',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500)),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CreateCustomField(
                          text: 'Title',
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
                      SizedBox(
                        height: 200,
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime: DateTime(2023, 1, 1),
                          onDateTimeChanged: (DateTime newDateTime) {
                            setState(() {});
                            setBottomState(() {
                              _date = newDateTime;
                            });
                          },
                        ),
                      ),
                      CreateCustomButton(
                          width: getWidth(context) * .9,
                          onTap: () async {
                            log(_date.toString());
                            if (_formKey.currentState!.validate() &&
                                _date != null) {
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

  void fetchData() async {
    dataModel.clear();
    setState(() => loading = true);

    await fireStore
        .collection('Calender')
        .orderBy('month', descending: false)
        .get()
        .then((value) {
      for (var calenderData in value.docs) {
        log("calenderData = ${calenderData.data()}");

        final model = CalenderModel.fromJson(calenderData.data());
        dataModel.add(model);
      }
    });
    addEntries(data: dataModel);
  }

  addEntries({required List<CalenderModel> data}) {
    for (CalenderModel model in data) {
      DateTime d = DateTime.parse(model.cDate);
      final event = CalendarEventData(
        date: DateTime(DateTime.now().year, d.month, d.day),
        description: model.description,
        title: model.event,
      );
      CalendarControllerProvider.of(context).controller.add(event);
    }

    setState(() => loading = false);
  }
}
