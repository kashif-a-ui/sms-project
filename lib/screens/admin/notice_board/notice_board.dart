import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '/master.dart';
import 'notice_model.dart';

class NoticeBoard extends StatefulWidget {
  const NoticeBoard({Key? key}) : super(key: key);

  @override
  State<NoticeBoard> createState() => _NoticeBoardState();
}

class _NoticeBoardState extends State<NoticeBoard> {
  bool loading = false;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final firebaseStorage = FirebaseStorage.instance;
  final titleCont = TextEditingController();
  final descCont = TextEditingController();
  final dateCont = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  XFile? _image;
  final imagePicker = ImagePicker();
  List<NoticeModel> dataModel = [];

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notice board'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => createBottomSheet(context),
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Loader()
          : ListView(
              padding: EdgeInsets.symmetric(
                  horizontal: getWidth(context) * .04,
                  vertical: getHeight(context) * .02),
              children: [
                Image.asset('assets/board.png'),
                dataModel.isNotEmpty
                    ? ListView.builder(
                        itemCount: dataModel.length,
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemBuilder: (context, index) {
                          final item = dataModel[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 15),
                            color: Colors.green.shade50,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Align(
                                      alignment: Alignment.topRight,
                                      child: Switch(
                                        activeColor: Colors.greenAccent,
                                        value: item.active,
                                        onChanged: (value) {
                                          item.active = value;
                                          updateStatus(item);
                                        },
                                      )),
                                  Text(item.title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: pColor)),
                                  item.image.isNotEmpty
                                      ? InkWell(
                                          onTap: () {
                                            Get.to(() => DetailScreen(
                                                image: item.image,
                                                tag: 'image$index'));
                                          },
                                          child: Hero(
                                            tag: 'image$index',
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Image.network(item.image,
                                                  height:
                                                      getHeight(context) * .3),
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                  SizedBox(height: getHeight(context) * .01),
                                  Text(
                                    item.description,
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
                      )
                    : const SizedBox()
              ],
            ),
    );
  }

  void fetchData() async {
    dataModel.clear();
    setState(() => loading = true);

    await fireStore.collection('NoticeBoard').get().then((value) {
      for (var noticeData in value.docs) {
        log("noticeData = ${noticeData.data()}");

        final noticeModel = NoticeModel.fromJson(noticeData.data());
        dataModel.add(noticeModel);
      }
    });
    setState(() => loading = false);
  }

  void updateStatus(NoticeModel model) async {
    setState(() => loading = true);

    await fireStore
        .collection('NoticeBoard')
        .doc(model.id)
        .update({'active': model.active});
    setState(() => loading = false);
    showSuccessToast(context: context, text: 'Status updated successfully');
  }

  void addData() async {
    setState(() => loading = true);

    String downloadUrl = '';

    if (_image != null) {
      File file = File(_image!.path);

      int uploadTimestamp = DateTime.now().millisecondsSinceEpoch;
      Reference ref = firebaseStorage.ref().child('Images/$uploadTimestamp');

      UploadTask uploadTask = ref.putFile(file);
      downloadUrl = await (await uploadTask).ref.getDownloadURL();
      log('image url: $downloadUrl');
    }
    String date = DateFormat("MMMM dd, yyyy").format(DateTime.now());

    var doc = fireStore.collection('NoticeBoard').doc();

    final data = {
      'title': titleCont.text,
      "image": downloadUrl,
      "id": doc.id,
      "date": date,
      "description": descCont.text,
      'active': true
    };

    await doc.set(data);

    _image = null;
    titleCont.clear();
    descCont.clear();

    setState(() => loading = false);
    showSuccessToast(context: context, text: 'Notice added successfully');

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
                      _image != null
                          ? Image.file(File(_image!.path), height: 50)
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      showPicker(context);
                                    },
                                    child: const Text('Pick Image'),
                                  ),
                                  const Text('optional')
                                ],
                              )),
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

  showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                    leading: const Icon(Icons.camera_alt, color: pColor),
                    title: const Text('Capture Now'),
                    onTap: () {
                      imgFromCamera();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.image, color: pColor),
                  title: const Text('Pick from Gallery'),
                  onTap: () {
                    imgFromGallery();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  imgFromCamera() async {
    XFile? image = await ImagePicker.platform
        .getImage(source: ImageSource.camera, imageQuality: 30) as XFile;

    _image = image;
    log("image selected");

    setState(() {});

    createBottomSheet(context);
  }

  imgFromGallery() async {
    final XFile? selectedImage = await imagePicker.pickImage(
        imageQuality: 70, source: ImageSource.gallery);

    if (selectedImage != null) {
      _image = selectedImage;

      log("image selected");
    }
    setState(() {});
    createBottomSheet(context);
  }
}
