import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms/screens/rules_regulations/rules_model.dart';

import '/master.dart';

class RulesPage extends StatefulWidget {
  final bool admin;

  const RulesPage({Key? key, this.admin = false}) : super(key: key);

  @override
  State<RulesPage> createState() => _RulesPageState();
}

class _RulesPageState extends State<RulesPage> {
  bool loading = false;
  List<RuleModel> stuData = [], tecData = [];
  final ruleCont = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String selectedRole = 'student';

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rules & Regulations')),
      floatingActionButton: loading || !widget.admin
          ? const SizedBox()
          : FloatingActionButton(
              onPressed: () => createBottomSheet(context),
              child: const Icon(Icons.add)),
      body: loading
          ? const Loader()
          : ListView(
              padding: EdgeInsets.symmetric(
                  horizontal: getWidth(context) * .05,
                  vertical: getHeight(context) * .02),
              children: [
                const Text('For Students',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: pColor)),
                SizedBox(height: getHeight(context) * .02),
                stuData.isNotEmpty
                    ? ListView.builder(
                        itemCount: stuData.length,
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemBuilder: (context, index) {
                          final item = stuData[index];
                          return ListTile(
                              leading: const Text('\u2B24',
                                  style: TextStyle(color: pColor)),
                              title: Text(item.rule));
                        },
                      )
                    : const SizedBox(),
                SizedBox(height: getHeight(context) * .02),
                const Text('For Teachers',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: pColor)),
                SizedBox(height: getHeight(context) * .02),
                tecData.isNotEmpty
                    ? ListView.builder(
                        itemCount: tecData.length,
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemBuilder: (context, index) {
                          final item = tecData[index];
                          return ListTile(
                              leading: const Text('\u2B24',
                                  style: TextStyle(color: pColor)),
                              title: Text(item.rule));
                        },
                      )
                    : const SizedBox(),
                const ListTile(
                  title: Text(
                    'Broadly speaking, the function of teachers is to help students learn by imparting knowledge to them and by setting up a situation in which students can & will learn effectively.',
                    style: TextStyle(),
                  ),
                )
              ],
            ),
    );
  }

  void fetchData() async {
    stuData.clear();
    tecData.clear();
    setState(() => loading = true);

    await fireStore.collection('Stu Rules').get().then((value) {
      for (var studentData in value.docs) {
        log("studentData = ${studentData.data()}");
        stuData.add(RuleModel.fromJson(studentData.data()));
      }
    });
    await fireStore.collection('Tec Rules').get().then((value) {
      for (var teacherData in value.docs) {
        log("teacherData = ${teacherData.data()}");
        tecData.add(RuleModel.fromJson(teacherData.data()));
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
                      const Text('Add Rule',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          Expanded(
                              child: RadioListTile(
                                onChanged: (value) {
                                  setBottomState(() => selectedRole = value!);
                                },
                                value: 'student',
                                title: const Text('Student'),
                                groupValue: selectedRole,
                              )),
                          Expanded(
                              child: RadioListTile(
                                  onChanged: (value) {
                                    setBottomState(() => selectedRole = value!);
                                  },
                                  value: 'teacher',
                                  groupValue: selectedRole,
                                  title: const Text('Teacher'))),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CreateCustomField(
                          text: 'Rule',
                          controller: ruleCont,
                          autoFocus: true,
                          keyBoardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the rule';
                            }
                            return null;
                          },
                        ),
                      ),

                      CreateCustomButton(
                          width: getWidth(context) * .9,
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              Get.back();
                              addData();
                            }
                          },
                          text: 'Save'),
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

    String coll = selectedRole.contains('student') ? 'Stu Rules' : 'Tec Rules';
    var doc = fireStore.collection(coll).doc();

    final data = {'rule': ruleCont.text, "id": doc.id};

    await doc.set(data);

    ruleCont.clear();

    setState(() => loading = false);
    showSuccessToast(context: context, text: 'Rule added successfully');

    fetchData();
  }
}
