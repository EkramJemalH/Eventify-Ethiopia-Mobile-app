import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

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

  Future<void> _deleteEvent(BuildContext context) async {
    final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _dbRef.child('events').child(eventId).remove();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Event deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context); // Go back to dashboard
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete event: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

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
          // Event Image
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.grey.shade200,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _buildImageWidget(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Event Title
          Text(
            title.isNotEmpty ? title : 'No Title', 
            style: const TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Event Date
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                dateTime.isNotEmpty ? dateTime : 'N/A', 
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          // Event Location
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                location.isNotEmpty ? location : 'N/A', 
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          
          // Performers (if available)
          if (performers.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.mic, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Performing Artists: $performers', 
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Event Description
          Text(
            description.isNotEmpty ? description : 'No description provided', 
            style: const TextStyle(fontSize: 16),
          ),
          
          const SizedBox(height: 12),
          
          // Organizer
          Row(
            children: [
              const Icon(Icons.person, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Organizer: ${organizer.isNotEmpty ? organizer : 'N/A'}', 
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Price
          Row(
            children: [
              const Icon(Icons.attach_money, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Price: ₵${price.toInt()}', 
                style: const TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          // Capacity
          Row(
            children: [
              const Icon(Icons.people, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Capacity: $capacity spots', 
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to Edit Event page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edit feature coming soon!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Edit', 
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _deleteEvent(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Delete', 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (image.isEmpty) {
      return Image.asset(
        'assets/images/event_placeholder.jpg',
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    
    // Check if it's a network URL
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return Image.network(
        image,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/event_placeholder.jpg',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        },
      );
    }
    
    // Check if it's an asset path
    if (image.startsWith('assets/')) {
      return Image.asset(
        image,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/event_placeholder.jpg',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        },
      );
    }
    
    // For other cases (like file paths), show placeholder
    return Image.asset(
      'assets/images/event_placeholder.jpg',
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}