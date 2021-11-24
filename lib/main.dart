import 'package:flutter/material.dart';

import 'screens/map_display_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kono Eki De Ori-Timer',
      theme: ThemeData(brightness: Brightness.dark),
      debugShowCheckedModeBanner: false,
      home: MapDisplayScreen(
        lat: 35.658034,
        lng: 139.701636,
      ),
    );
  }
}
