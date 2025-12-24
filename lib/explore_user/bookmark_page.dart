import 'package:flutter/material.dart';

class BookmarkPage extends StatefulWidget {
  BookmarkPage({Key? key}) : super(key: key);

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  // Sample bookmarked events
  List<Map<String, String>> bookmarkedEvents = [
    {
      'image': 'assets/images/party.jpg',
      'title': 'Concert Night Addis',
      'location': '📍 Friendship Square, Addis Ababa',
      'dateTime': '📅 Dec 21, 2025 — 7:00 PM',
      'performers': '🎤 Featuring: Jano Band, Hewan Gebrewold',
      'price': '🎫 From 300 ETB',
    },
    {
      'image': 'assets/images/tech.jpg',
      'title': 'Tech Expo 2025',
      'location': '📍 Millennium Hall, Addis Ababa',
      'dateTime': '📅 Jan 15, 2026 — 10:00 AM',
      'performers': '🎤 Speakers: AI Experts, Developers',
      'price': '🎫 From 150 ETB',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Book mark',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 24,
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: bookmarkedEvents.isEmpty
            ? const Center(
                child: Text(
                  'No bookmarks yet',
                  style: TextStyle(fontSize: 18),
                ),
              )
            : ListView.builder(
                itemCount: bookmarkedEvents.length,
                itemBuilder: (context, index) {
                  final event = bookmarkedEvents[index];
                  return EventCard(
                    image: event['image']!,
                    title: event['title']!,
                    location: event['location']!,
                    dateTime: event['dateTime']!,
                    performers: event['performers']!,
                    price: event['price']!,
                    onRemove: () {
                      setState(() {
                        bookmarkedEvents.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${event['title']} removed from bookmarks'),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

// -------------------- EventCard with Remove --------------------
class EventCard extends StatelessWidget {
  final String image;
  final String title;
  final String location;
  final String dateTime;
  final String performers;
  final String price;
  final VoidCallback? onRemove; // optional remove button

  EventCard({
    required this.image,
    required this.title,
    required this.location,
    required this.dateTime,
    required this.performers,
    required this.price,
    this.onRemove,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFAEBDB),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Image.asset(
              image,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                Text(location),
                Text(dateTime),
                Text(performers),
                const SizedBox(height: 4),
                Text(price),
                const SizedBox(height: 10),
                // Row: details + optional remove
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tap to view details',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (onRemove != null)
                      GestureDetector(
                        onTap: onRemove,
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
