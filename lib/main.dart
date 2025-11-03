import 'package:flutter/material.dart';
import 'Pages/Home.dart';  // ✅ Yeh import add karo

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),  // ✅ const add karo
    );
  }
}