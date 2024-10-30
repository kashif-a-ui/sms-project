import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/master.dart';
import '../screens/admin/notice_board/notice_model.dart';

class NoticePage extends StatefulWidget {
  const NoticePage({Key? key}) : super(key: key);

  @override
  State<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  List<NoticeModel> dataModel = [];
  bool loading = false;

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notice Board'),
      ),
      body: loading
          ? const Loader()
          : ListView.builder(
              padding: EdgeInsets.symmetric(
                  horizontal: getWidth(context) * .05,
                  vertical: getHeight(context) * .02),
              itemCount: dataModel.length,
              itemBuilder: (context, index) {
                final item = dataModel[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  color: Colors.green.shade100,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                        item.image.isNotEmpty
                            ? InkWell(
                                onTap: () {
                                  Get.to(() => DetailScreen(
                                      image: item.image, tag: 'image$index'));
                                },
                                child: Hero(
                                  tag: 'image$index',
                                  child: Container(
                                    width: getWidth(context),
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.network(item.image,
                                        height: getHeight(context) * .12,
                                        fit: BoxFit.fitWidth),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            )),
                      ],
                    ),
                  ),
                );
              },
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
        if (noticeModel.active) {
          dataModel.add(noticeModel);
        }
      }
    });

    setState(() => loading = false);
  }
}
