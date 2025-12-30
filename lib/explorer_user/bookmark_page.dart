import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'event_detail_page.dart';

class BookmarkPage extends StatefulWidget {
  BookmarkPage({Key? key}) : super(key: key);

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  
  List<Map<String, dynamic>> bookmarkedEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get user's bookmarks from Firebase
      final snapshot = await _dbRef
          .child('users')
          .child(user.uid)
          .child('bookmarks')
          .get();

      final List<Map<String, dynamic>> events = [];

      if (snapshot.exists) {
        final bookmarks = snapshot.value as Map<dynamic, dynamic>;
        
        // Get details for each bookmarked event
        for (final eventId in bookmarks.keys) {
          final eventSnapshot = await _dbRef
              .child('events')
              .child(eventId.toString())
              .get();

          if (eventSnapshot.exists) {
            final event = Map<String, dynamic>.from(eventSnapshot.value as Map);
            event['firebaseKey'] = eventId.toString();
            events.add(event);
          }
        }
      }

      setState(() {
        bookmarkedEvents = events;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading bookmarks: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeBookmark(String eventId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Remove from Firebase
      await _dbRef
          .child('users')
          .child(user.uid)
          .child('bookmarks')
          .child(eventId)
          .remove();

      // Update UI
      setState(() {
        bookmarkedEvents.removeWhere((event) => event['firebaseKey'] == eventId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed from bookmarks'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error removing bookmark: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove bookmark'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            )
          : Padding(
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
                        
                        // Extract event data with fallbacks
                        final title = event['title']?.toString() ?? 'Untitled Event';
                        final date = event['date']?.toString() ?? 'Date not set';
                        final time = event['startTime']?.toString() ?? '';
                        final location = event['location']?.toString() ?? 'Location not set';
                        final performers = event['performers']?.toString() ?? '';
                        final price = event['price'] ?? 0.0;
                        final image = event['image']?.toString() ?? 'assets/images/event_placeholder.jpg';
                        final isFree = event['isFree'] ?? false;
                        final eventId = event['firebaseKey']?.toString() ?? '';

                        return EventCard(
                          image: image,
                          title: title,
                          location: '📍 $location',
                          dateTime: '📅 $date${time.isNotEmpty ? ' — $time' : ''}',
                          performers: performers.isNotEmpty ? '🎤 Featuring: $performers' : '',
                          price: '🎫 ${isFree == true ? 'Free' : 'From ${(price as double).toInt()} ETB'}',
                          onRemove: () {
                            _removeBookmark(eventId);
                          },
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventDetailPage(
                                  eventId: eventId,
                                  title: title,
                                  image: image,
                                  dateTime: '$date${time.isNotEmpty ? ' • $time' : ''}',
                                  location: location,
                                  performers: performers,
                                  description: event['description']?.toString() ?? '',
                                  organizer: event['organizer']?.toString() ?? 'Organizer',
                                  price: price as double,
                                ),
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
  final VoidCallback onRemove; // required remove button
  final VoidCallback onTap; // for viewing details

  EventCard({
    required this.image,
    required this.title,
    required this.location,
    required this.dateTime,
    required this.performers,
    required this.price,
    required this.onRemove,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: const Color(0xFFFAEBDB),
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: image.startsWith('http')
                  ? Image.network(
                      image,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.event, size: 50, color: Colors.grey),
                        );
                      },
                    )
                  : Image.asset(
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
                  // Row: details + remove button
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
      ),
    );
  }
}