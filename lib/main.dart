import 'package:flutter/material.dart';
import 'dart:async';

import 'examples/screenshotexample.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber.shade600,
          leading: Image.asset("assets/images/header.png"),
          title: const Text('Cerealis',
          style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              fontSize: 30)
          ),
        ),
        body: Column(children: [
          Expanded(
            child: ScreenshotWidget(),
          ),
        ]),
      ),
    );
  }
}