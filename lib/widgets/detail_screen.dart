import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../master.dart';

class DetailScreen extends StatelessWidget {
  final String image, tag;

  const DetailScreen({Key? key, required this.image, required this.tag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: pColor),
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        centerTitle: true,
        title: const Text('Detail View', style: TextStyle(color: pColor)),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: black),
        ),
      ),
      body: Hero(
          tag: tag,
          child: InteractiveViewer(
              minScale: 0.1,
              maxScale: 3.0,
              panEnabled: true,
              scaleEnabled: true,
              child: Image.network(image,
                  fit: BoxFit.contain,
                  height: getHeight(context),
                  width: getWidth(context)))),
    );
  }
}
