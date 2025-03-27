import 'package:flutter/material.dart';
import 'screens/inventory_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario Ferretería',
      debugShowCheckedModeBanner: false,
      home: InventoryScreen(),
    );
  }
}
