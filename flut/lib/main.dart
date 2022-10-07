import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
// import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // initializer();
  }

  final record = Record();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text('Audio Recording and Playing'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                createElevatedButton(icon: Icons.mic, iconColor: Colors.red, onPressFunc: startRecording),
                SizedBox(
                  width: 30,
                ),
                createElevatedButton(icon: Icons.stop, iconColor: Colors.red, onPressFunc: stopRecording),
              ],
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton createElevatedButton({required IconData icon, required Color iconColor, required VoidCallback onPressFunc}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(6),
        side: BorderSide(
          color: Colors.red,
          width: 4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        primary: Colors.white,
        elevation: 9,
      ),
      onPressed: onPressFunc,
      icon: Icon(
        icon,
        color: iconColor,
        size: 38,
      ),
      label: Text(''),
    );
  }

  void startRecording() async {
    if (await record.hasPermission()) {
      // var directoryPath = await _directoryPath();
      var directory = await getApplicationSupportDirectory();
      var directoryPath = '${directory.path}/wave.mp4';
      // directoryPath = '${directoryPath}wave.mp4';
      print(directoryPath);
      await record.start(
        path: directoryPath,
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        samplingRate: 44100,
      );
    }
  }

  void stopRecording() async {
    // var directoryPath = await _directoryPath();
    var directory = await getApplicationSupportDirectory();
    // var directoryPath = '${directory.path}wave.mp4';
    var recordedPath = '${directory.path}/wave.mp4';
    // var recordedPath = '${directoryPath}wave.mp4';
    await record.stop();

    var dio = Dio();
    var formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        recordedPath,
        filename: 'wave.mp4',
        contentType: MediaType('audio', 'mpeg'),
      ),
    });
    var url = 'http://127.0.0.1:3000/';
    var response = await dio.post(url, data: formData);
    print(response);
  }

  // Future<String> _directoryPath() async {
  //   var directory = await getApplicationSupportDirectory();
  //   var directoryPath = directory.path;
  //   return "$directoryPath/records";
  // }
}
