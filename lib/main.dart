import 'package:flutter/material.dart';
import 'organizer/organizer_dashboard_page.dart';

void main() {
  runApp(EventifyApp());
}

class EventifyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eventify',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: OrganizerDashboardPage(), // ✅ NO const
    );
  }
}
