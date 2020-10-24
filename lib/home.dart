import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:tflite/tflite.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool firstRun = true;
  File selected_image;
  List output;

  detectObject(File image) async {
    var recognitions = await Tflite.detectObjectOnImage(
        path: image.path,
        // required
        model: "SSDMobileNet",
        imageMean: 127.5,
        imageStd: 127.5,
        threshold: 0.4,
        numResultsPerClass: 2,
        asynch: true
        );
    print(recognitions[0]);
    setState(() {
      output = recognitions;
    });
  }

  getImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    // ignore: unrelated_type_equality_checks
    if (pickedFile != Null) {
      selected_image = File(pickedFile.path);
      detectObject(selected_image);
      firstRun = false;
    }
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/ssd_mobilenet.tflite",
        labels: "assets/ssd_mobilenet.txt",
        numThreads: 5);
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey,
        
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                firstRun
                    ? Container(
                        child: Text(
                          "Resim Seç",
                          style: TextStyle(fontSize: 30),
                        ),
                      )
                    : Container(
                        child: Column(
                          children: [
                            Container(
                              height: 350,
                              child: Stack(
                                children: [
                                  Container(alignment: Alignment.center, child: Image.file(selected_image,fit: BoxFit.fitWidth,)),
                                  Positioned(
                                    left: MediaQuery.of(context).size.width * output[0]['rect']['x'],
                                    width: MediaQuery.of(context).size.width * output[0]['rect']['w'],
                                    top: 350* output[0]['rect']['y'] ,
                                    height:350* output[0]['rect']['h'],
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.red, width: 3)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            Container(
                              child: Text(output[0]['detectedClass'], style: TextStyle(fontSize: 28,color: Colors.white),),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              child: Text("% " +
                                  (output[0]['confidenceInClass'] * 100)
                                      .toString(), style: TextStyle(fontSize: 28,color: Colors.white),),
                            )
                          ],
                        ),
                      ),
                SizedBox(
                  height: 75,
                ),
                Center(
                  child: FlatButton(color: Colors.red,textColor: Colors.white,
                    child: Text(
                      "Resim Seç",
                      style: TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      getImage();
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
