import 'package:flutter/material.dart';

class EventDetailPage extends StatelessWidget {
  final String title;
  final String image;
  final String dateTime;
  final String location;
  final String performers;
  final String description;
  final String organizer;

  const EventDetailPage({
    Key? key,
    required this.title,
    required this.image,
    required this.dateTime,
    required this.location,
    required this.performers,
    required this.description,
    required this.organizer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Center(
              child: Text(
                'Back',
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/images/profile.png'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Image banner
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(image, height: 200, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          
          // Event title and details BELOW the app bar
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('🗓 $dateTime', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text('📍 $location', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text('🎤 Performing Artists: $performers', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Text(description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Text(organizer, style: const TextStyle(fontSize: 16)),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.bookmark, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
