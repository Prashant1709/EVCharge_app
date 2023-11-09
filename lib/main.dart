import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ledtest/Welcome.dart';
import 'package:ledtest/appfile.dart';
import 'package:ledtest/scan.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Welcome()
    );
  }
}
