import 'package:flutter/material.dart';
import 'package:shop_app/widgets/grocery_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          surface: Colors.blueGrey
        ),
        scaffoldBackgroundColor: Color.fromARGB(255, 12, 12, 12),
        useMaterial3: true,
      ),
      home: GroceryList(),
    );
  }
}

