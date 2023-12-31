import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'conscious_cart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Conscious Cart',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        ),
        home: ConsciousCart(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
}