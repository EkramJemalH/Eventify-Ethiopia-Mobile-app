import 'package:flutter/material.dart';
import 'ExploreHome.dart'; // Import your ExploreHome page

void main() {
  runApp(EventifyApp());
}

class EventifyApp extends StatelessWidget {
  const EventifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eventify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: ExploreHome(), // <-- Remove const here
    );
  }
}
