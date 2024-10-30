import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sms/master.dart';
import 'package:sms/screens/about_us/about_us_model.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  bool loading = false;
  List<AboutUsModel> aboutData = [];
  final titleCont = TextEditingController();
  final descCont = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isAdmin = false;

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      floatingActionButton: loading || !isAdmin
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
                const Text('Meezan Institute of Science and Technology',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(height: getHeight(context) * .02),
                CircleAvatar(
                  minRadius: 60,
                  backgroundColor: pColor,
                  child: CircleAvatar(
                    backgroundColor: Colors.green.shade50,
                    minRadius: 58,
                    child: Text('MIST',
                        style: GoogleFonts.rubikMoonrocks(
                            fontSize: 35,
                            fontWeight: FontWeight.w500,
                            color: pColor)),
                  ),
                ),
                SizedBox(height: getHeight(context) * .02),
                ListView.builder(
                  physics: const ScrollPhysics(),
                  itemCount: aboutData.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final item = aboutData[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                            isAdmin
                                ? IconButton(
                                    onPressed: () {
                                      createBottomSheet(context, model: item);
                                    },
                                    icon: const Icon(Icons.edit))
                                : const SizedBox()
                          ],
                        ),
                        SizedBox(height: getHeight(context) * .02),
                        Text(
                          item.description,
                          style: const TextStyle(fontSize: 15),
                        ),
                        SizedBox(height: getHeight(context) * .02),
                      ],
                    );
                  },
                ),
              ],
            ),
    );
  }

  void fetchData() async {
    aboutData.clear();
    setState(() => loading = true);

    int userType = await getUserType();

    isAdmin = userType == 1;

    await fireStore.collection('About Us').get().then((value) {
      for (var about in value.docs) {
        log("about = ${about.data()}");
        aboutData.add(AboutUsModel.fromJson(about.data()));
      }
    });
    setState(() => loading = false);
  }

  createBottomSheet(BuildContext context, {AboutUsModel? model}) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return StatefulBuilder(builder: (context, setBottomState) {
            final title = model != null ? model.title : '';
            final desc = model != null ? model.description : '';
            final id = model?.id;
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
                      Text(model != null ? 'Edit Info' : 'Add Info',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500)),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CreateCustomField(
                          text: 'Title',
                          label: title,
                          controller: titleCont,
                          autoFocus: true,
                          keyBoardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the title';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CreateCustomField(
                          text: 'Description',
                          label: desc,
                          controller: descCont,
                          keyBoardType: TextInputType.text,
                          minLines: 4,
                          lines: 4,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the title';
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
                              addData(id: id);
                            }
                          },
                          text: model != null ? 'Update' : 'Save'),
                      SizedBox(height: getHeight(context) * .02)
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  void addData({String? id}) async {
    setState(() => loading = true);

    var doc = fireStore.collection('About Us').doc(id);

    final data = {
      'title': titleCont.text,
      "id": doc.id,
      'description': descCont.text
    };

    await doc.set(data);

    titleCont.clear();
    descCont.clear();

    setState(() => loading = false);
    showSuccessToast(context: context, text: 'Rule added successfully');

    fetchData();
  }
}
