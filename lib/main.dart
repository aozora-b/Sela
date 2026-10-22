import 'package:flutter/material.dart';
import 'features/dev/spike_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sela Spike',
      theme: ThemeData.dark(),
      home: const SpikeScreen(),
    );
  }
}
