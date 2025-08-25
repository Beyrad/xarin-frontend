import 'package:flutter/material.dart';
import 'package:untitled1/HomePage.dart';
import 'package:untitled1/login.dart';
import 'package:untitled1/main_page.dart';
import 'package:untitled1/music_player.dart';
import 'package:untitled1/profile.dart';
import 'package:untitled1/constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home : Login()
    );
  }
}
