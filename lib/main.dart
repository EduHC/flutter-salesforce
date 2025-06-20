import 'package:flutter/material.dart';
import 'package:salesforce/presentation/screen/main_screen.dart';
import 'package:salesforce/presentation/screen/product_screen.dart';
import 'package:salesforce/setup.dart';

void main() async {
  await Setup.doInitialTasks();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: TextTheme(
          headlineMedium: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'Times New Roman',
          ),
          headlineSmall: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            fontFamily: 'Times New Roman',
          ),
          bodyMedium: TextStyle(color: Colors.black87, fontSize: 16),
          bodyLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.green[700],
          ),
        ),
      ),
      home: const MainScreen(),
      routes: {'product_list': (context) => const ProductScreen()},
    );
  }
}
