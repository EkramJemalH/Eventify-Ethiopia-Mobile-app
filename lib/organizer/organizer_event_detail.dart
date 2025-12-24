import 'package:flutter/material.dart';

class OrganizerEventDetailPage extends StatelessWidget {
  final String title;
  final String image;
  final String dateTime;
  final String location;
  final String performers;
  final String description;
  final String organizer;

  const OrganizerEventDetailPage({
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
            child: Image.asset(
              image.isNotEmpty ? image : 'assets/images/placeholder.png',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Text(title.isNotEmpty ? title : 'No Title',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('🗓 ${dateTime.isNotEmpty ? dateTime : 'N/A'}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text('📍 ${location.isNotEmpty ? location : 'N/A'}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text('🎤 Performing Artists: ${performers.isNotEmpty ? performers : 'N/A'}',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Text(description.isNotEmpty ? description : 'No description provided',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Text('Organizer: ${organizer.isNotEmpty ? organizer : 'N/A'}', style: const TextStyle(fontSize: 16)),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Edit event
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
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete Event'),
                      content: const Text('Are you sure you want to delete this event?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () {
                            // TODO: Delete logic
                            Navigator.pop(context);
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
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
