import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../profile_page.dart';
import 'organizer_event_detail.dart';
import 'addevent_page.dart';

class OrganizerDashboardPage extends StatefulWidget {
  const OrganizerDashboardPage({super.key});

  @override
  State<OrganizerDashboardPage> createState() => _OrganizerDashboardPageState();
}

class _OrganizerDashboardPageState extends State<OrganizerDashboardPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  String _userName = 'Organizer';
  String _userUid = '';

  @override
  void initState() {
    super.initState();
    _loadUserAndEvents();
  }

  Future<void> _loadUserAndEvents() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    _userName = user.displayName?.split(' ').first ?? 'Organizer';
    _userUid = user.uid;

    try {
      final snapshot = await _dbRef.child('events').orderByChild('timestamp').get();
      final List<Map<String, dynamic>> events = [];

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        
        data.forEach((key, value) {
          try {
            final event = Map<String, dynamic>.from(value as Map);
            
            // Check multiple possible fields for organizer ID
            final creatorId = event['creatorId']?.toString() ?? 
                             event['userId']?.toString() ?? 
                             event['organizerId']?.toString() ?? 
                             event['organizerUid']?.toString() ?? '';
            
            // Only show events created by current user
            if (creatorId == user.uid) {
              event['firebaseKey'] = key.toString();
              
              // Set default values if missing
              event['title'] = event['title'] ?? 'Untitled Event';
              event['date'] = event['date'] ?? 'Date not set';
              event['location'] = event['location'] ?? 'Location not set';
              event['price'] = event['price'] ?? 0.0;
              event['capacity'] = event['capacity'] ?? 0;
              event['image'] = event['image'] ?? 'assets/images/event_placeholder.jpg';
              
              events.add(event);
            }
          } catch (e) {
            print('Error parsing event $key: $e');
          }
        });
        
        // Sort events by date (newest first)
        events.sort((a, b) {
          final timestampA = a['timestamp'] ?? a['createdAt'] ?? 0;
          final timestampB = b['timestamp'] ?? b['createdAt'] ?? 0;
          return (timestampB as int).compareTo(timestampA as int);
        });
      }

      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading events: $e');
      setState(() => _isLoading = false);
      
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading events: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteEvent(String firebaseKey, int index) async {
    if (!mounted) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    try {
      await _dbRef.child('events').child(firebaseKey).remove();
      
      if (mounted) {
        setState(() {
          _events.removeAt(index);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event deleted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete event: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Helper methods for safe data extraction
  String _getString(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    if (value is String) return value.trim();
    return value.toString().trim();
  }

  double _getPrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {
      // Try to parse, remove currency symbols
      final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  int _getCapacity(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'Date not set';
    final dateStr = _getString(dateValue);
    
    // If it's already a readable date string, return as is
    if (dateStr.contains('-') || dateStr.contains('/')) {
      return dateStr;
    }
    
    // Try to parse as timestamp or DateTime
    try {
      DateTime? date;
      if (dateValue is int) {
        date = DateTime.fromMillisecondsSinceEpoch(dateValue);
      } else if (dateValue is String && RegExp(r'^\d+$').hasMatch(dateValue)) {
        date = DateTime.fromMillisecondsSinceEpoch(int.parse(dateValue));
      } else {
        date = DateTime.tryParse(dateStr);
      }
      
      if (date != null) {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      print('Date formatting error: $e');
    }
    
    return dateStr;
  }

  Future<void> _handleAddEvent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEventPage(userId: _userUid),
      ),
    );
    
    // Refresh events if a new event was added
    if (result == true || result == null) {
      await _loadUserAndEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Welcome, $_userName',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              ).then((_) {
                // Refresh user info when returning from profile
                final user = _auth.currentUser;
                if (user != null) {
                  setState(() {
                    _userName = user.displayName?.split(' ').first ?? 'Organizer';
                  });
                }
              }),
              child: CircleAvatar(
                backgroundColor: const Color(0xFFFAEBDB),
                backgroundImage: _auth.currentUser?.photoURL != null
                    ? NetworkImage(_auth.currentUser!.photoURL!)
                    : null,
                child: _auth.currentUser?.photoURL == null
                    ? const Icon(Icons.person, color: Colors.orange)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : RefreshIndicator(
              onRefresh: _loadUserAndEvents,
              color: Colors.orange,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    // Stats card
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.event, color: Colors.orange, size: 24),
                                const SizedBox(height: 8),
                                Text(
                                  '${_events.length}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Total Events',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Add New Event Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleAddEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Add New Event',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Event List Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Events',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_events.length} event${_events.length != 1 ? 's' : ''}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Event List
                    Expanded(
                      child: _events.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_note,
                                    size: 80,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No events yet',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Tap "Add New Event" to create your first event',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _events.length,
                              itemBuilder: (context, index) {
                                final event = _events[index];
                                final firebaseKey = _getString(event['firebaseKey']);
                                
                                // Extract event data with fallbacks
                                final title = _getString(event['title'], 'Untitled Event');
                                final date = _formatDate(event['date']);
                                final location = _getString(event['location'], 'Location not set');
                                final performers = _getString(event['performers'], '');
                                final description = _getString(event['description'], 'No description');
                                final organizer = _getString(event['organizer'], _userName);
                                final price = _getPrice(event['price']);
                                final capacity = _getCapacity(event['capacity']);
                                final image = _getString(event['image'], 'assets/images/event_placeholder.jpg');

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAEBDB),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Event Image
                                      if (image.isNotEmpty)
                                        Container(
                                          height: 180,
                                          width: double.infinity,
                                          margin: const EdgeInsets.only(bottom: 12),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            image: DecorationImage(
                                              image: image.startsWith('http')
                                                  ? NetworkImage(image) as ImageProvider
                                                  : AssetImage(image),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      
                                      // Event Title
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // Event Details
                                      Text(date),
                                      Text(location),
                                      const SizedBox(height: 12),

                                      // Price and Capacity
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '₵${price.toInt()}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(
                                            '$capacity spots',
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Action Buttons
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => OrganizerEventDetailPage(
                                                    eventId: firebaseKey,
                                                    title: title,
                                                    image: image,
                                                    dateTime: date,
                                                    location: location,
                                                    performers: performers,
                                                    description: description,
                                                    organizer: organizer,
                                                    price: price,
                                                    capacity: capacity,
                                                  ),
                                                ),
                                              ).then((_) => _loadUserAndEvents());
                                            },
                                            child: const Text(
                                              'Edit Event',
                                              style: TextStyle(
                                                color: Colors.orange,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 80,
                                            child: ElevatedButton(
                                              onPressed: () => _deleteEvent(firebaseKey, index),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color.fromARGB(255, 223, 93, 6),
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}