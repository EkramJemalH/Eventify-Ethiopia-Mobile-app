import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'booking_page.dart';

class EventDetailPage extends StatefulWidget {
  final String eventId;
  final String title;
  final String image;
  final String dateTime;
  final String location;
  final String performers;
  final String description;
  final String organizer;
  final double price;

  const EventDetailPage({
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
  }) : super(key: key);

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  bool _isBookmarked = false;
  bool _isLoadingBookmark = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _isBookmarked = false;
          _isLoadingBookmark = false;
        });
        return;
      }

      final snapshot = await _dbRef
          .child('users')
          .child(user.uid)
          .child('bookmarks')
          .child(widget.eventId)
          .get();

      setState(() {
        _isBookmarked = snapshot.exists;
        _isLoadingBookmark = false;
      });
    } catch (e) {
      print('Error checking bookmark status: $e');
      setState(() {
        _isLoadingBookmark = false;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to save bookmarks'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() {
        _isBookmarked = !_isBookmarked;
      });

      final bookmarkRef = _dbRef
          .child('users')
          .child(user.uid)
          .child('bookmarks')
          .child(widget.eventId);

      if (_isBookmarked) {
        // Add bookmark
        await bookmarkRef.set({
          'eventId': widget.eventId,
          'bookmarkedAt': ServerValue.timestamp,
          'eventTitle': widget.title,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to bookmarks'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Remove bookmark
        await bookmarkRef.remove();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from bookmarks'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error toggling bookmark: $e');
      // Revert on error
      setState(() {
        _isBookmarked = !_isBookmarked;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildImage() {
    if (widget.image.startsWith('http')) {
      return Image.network(
        widget.image,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    } else if (widget.image.isNotEmpty) {
      return Image.asset(
        widget.image,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.event,
        size: 60,
        color: Colors.grey,
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
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _buildImage(),
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text('🗓 ${widget.dateTime}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text('📍 ${widget.location}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          if (widget.performers.isNotEmpty)
            Text(
              '🎤 Performing Artists: ${widget.performers}',
              style: const TextStyle(fontSize: 16),
            ),
          const SizedBox(height: 12),
          Text(widget.description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Text('Organizer: ${widget.organizer}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            'Price: ${widget.price > 0 ? '₵${widget.price.toInt()}' : 'Free'}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.price > 0 ? Colors.orange : Colors.green,
            ),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingPage(
                        eventId: widget.eventId,
                        eventTitle: widget.title,
                        price: widget.price,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _isLoadingBookmark ? null : _toggleBookmark,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isLoadingBookmark
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.grey,
                        ),
                      )
                    : Icon(
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: _isBookmarked ? Colors.orange : Colors.grey,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}