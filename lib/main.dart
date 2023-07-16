import 'package:flutter/material.dart';
import 'package:gpt/home_page.dart';
import 'package:gpt/pallete.dart';
import 'package:gpt/feature_box.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlutterGPT',
      theme: ThemeData.light(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: Pallete.whiteColor,
          appBarTheme:
              AppBarTheme(backgroundColor: Color.fromARGB(177, 51, 20, 105))),
      home: const HomePage(),
    );
  }
}
