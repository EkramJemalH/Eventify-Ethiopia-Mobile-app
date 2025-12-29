import 'package:flutter/material.dart';

class OrganizerEventDetailPage extends StatelessWidget {
  final String eventId;
  final String title;
  final String image;
  final String dateTime;
  final String location;
  final String performers;
  final String description;
  final String organizer;
  final double price;
  final int capacity;

  const OrganizerEventDetailPage({
    Key? key,
    required this.eventId,
    required this.title,
    required this.image,
    required this.dateTime,
    required this.location,
    required this.performers,
    required this.description,
    required this.organizer,
    required this.price,
    required this.capacity,
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
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: image.isNotEmpty
                ? Image.network(image, height: 200, width: double.infinity, fit: BoxFit.cover)
                : Image.asset('assets/images/placeholder.png', height: 200, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          Text(title.isNotEmpty ? title : 'No Title', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('🗓 ${dateTime.isNotEmpty ? dateTime : 'N/A'}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text('📍 ${location.isNotEmpty ? location : 'N/A'}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text('🎤 Performing Artists: ${performers.isNotEmpty ? performers : 'N/A'}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Text(description.isNotEmpty ? description : 'No description provided', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Text('Organizer: ${organizer.isNotEmpty ? organizer : 'N/A'}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Text('Price: ₵${price.toInt()}', style: const TextStyle(fontSize: 16)),
          Text('Capacity: $capacity spots', style: const TextStyle(fontSize: 16)),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Edit event logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Edit', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Delete event logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
