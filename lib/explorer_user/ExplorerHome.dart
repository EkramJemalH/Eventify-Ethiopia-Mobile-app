import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'event_detail_page.dart';
import '../profile_page.dart';
import 'bookmark_page.dart';
import 'my_booking_page.dart';

class ExploreHome extends StatefulWidget {
  final int initialIndex;

  const ExploreHome({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<ExploreHome> createState() => _ExploreHomeState();
}

class _ExploreHomeState extends State<ExploreHome> {
  int _selectedIndex = 0;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _allEvents = [];
  List<Map<String, dynamic>> _filteredEvents = [];
  bool _isLoading = true;
  String _selectedCategory = 'All'; // Default to 'All'
  final TextEditingController _searchController = TextEditingController();

  // Define your categories
  final List<Map<String, dynamic>> _categories = [
    {'id': 'All', 'icon': Icons.all_inclusive, 'label': 'All'},
    {'id': 'Sports & Fitness', 'icon': Icons.sports_soccer, 'label': 'Sports'},
    {'id': 'Music', 'icon': Icons.music_note, 'label': 'Music'},
    {'id': 'Business', 'icon': Icons.business, 'label': 'Business'},
    {'id': 'Art', 'icon': Icons.palette, 'label': 'Art'},
    {'id': 'Tech', 'icon': Icons.computer, 'label': 'Tech'},
    {'id': 'Entertainment', 'icon': Icons.movie, 'label': 'Entertainment'},
    {'id': 'Community', 'icon': Icons.people, 'label': 'Community'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Set initial index
    _initializeFirebaseAndLoadEvents();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeFirebaseAndLoadEvents() async {
    try {
      await Firebase.initializeApp();
      _loadAllEvents();
    } catch (e) {
      print('Error initializing Firebase: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAllEvents() async {
    try {
      final snapshot = await _dbRef.child('events').get();
      final List<Map<String, dynamic>> events = [];

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        
        data.forEach((key, value) {
          try {
            final event = Map<String, dynamic>.from(value as Map);
            event['firebaseKey'] = key.toString();
            if (event['image'] == null || event['image'].toString().isEmpty) {
              event['image'] = '';
            }
            events.add(event);
          } catch (e) {
            print('Error parsing event: $e');
          }
        });
        
        events.sort((a, b) {
          final timestampA = a['timestamp'] ?? a['createdAt'] ?? 0;
          final timestampB = b['timestamp'] ?? b['createdAt'] ?? 0;
          return (timestampB as int).compareTo(timestampA as int);
        });
      }

      setState(() {
        _allEvents = events;
        _filteredEvents = events; // Initially show all events
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading events: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterEvents() {
    String searchText = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredEvents = _allEvents.where((event) {
        // Category filter
        bool categoryMatch = _selectedCategory == 'All' || 
                           (event['category']?.toString() == _selectedCategory);
        
        // Search filter
        bool searchMatch = searchText.isEmpty ||
            (event['title']?.toString().toLowerCase().contains(searchText) ?? false) ||
            (event['location']?.toString().toLowerCase().contains(searchText) ?? false) ||
            (event['description']?.toString().toLowerCase().contains(searchText) ?? false) ||
            (event['performers']?.toString().toLowerCase().contains(searchText) ?? false);
        
        return categoryMatch && searchMatch;
      }).toList();
    });
  }

  void _onSearchChanged() {
    _filterEvents();
  }

  void _selectCategory(String categoryId) {
    setState(() {
      _selectedCategory = categoryId;
    });
    _filterEvents();
  }

  Future<void> _toggleBookmark(String eventId) async {
    try {
      await Firebase.initializeApp();
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to save bookmarks'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final dbRef = FirebaseDatabase.instance.ref();
      final bookmarkRef = dbRef
          .child('users')
          .child(user.uid)
          .child('bookmarks')
          .child(eventId);

      final snapshot = await bookmarkRef.get();
      
      if (snapshot.exists) {
        await bookmarkRef.remove();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from bookmarks'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        await bookmarkRef.set({
          'eventId': eventId,
          'bookmarkedAt': ServerValue.timestamp,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to bookmarks'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error toggling bookmark: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeContent(
        events: _filteredEvents, // Use filtered events
        isLoading: _isLoading,
        loadEvents: _loadAllEvents,
        toggleBookmark: _toggleBookmark,
        categories: _categories,
        selectedCategory: _selectedCategory,
        onCategorySelected: _selectCategory,
        searchController: _searchController,
        eventCount: _filteredEvents.length,
        totalEventCount: _allEvents.length,
      ),

      BookmarkPage(),
      const MyBookingPage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.orange,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Bookmark'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'My Booking'),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////
// HOME PAGE CONTENT
//////////////////////////////////////////////////
class HomeContent extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final bool isLoading;
  final VoidCallback loadEvents;
  final Function(String) toggleBookmark;
  final List<Map<String, dynamic>> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final TextEditingController searchController;
  final int eventCount;
  final int totalEventCount;

  const HomeContent({
    Key? key,
    required this.events,
    required this.isLoading,
    required this.loadEvents,
    required this.toggleBookmark,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.searchController,
    required this.eventCount,
    required this.totalEventCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, 'HOME'),
      body: RefreshIndicator(
        onRefresh: () async => loadEvents(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search + Filter
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.grey.withOpacity(0.7)),
                        hintText: 'Search events...',
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Filter button removed since we have category chips
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.filter_alt, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Category header with count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$eventCount events',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Categories - Horizontal Scrollable Chips
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = selectedCategory == category['id'];
                    
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index == categories.length - 1 ? 0 : 8,
                        left: index == 0 ? 0 : 4,
                      ),
                      child: FilterChip(
                        label: Text(
                          category['label'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        avatar: Icon(
                          category['icon'],
                          size: 18,
                          color: isSelected ? Colors.white : Colors.grey,
                        ),
                        selected: isSelected,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        selectedColor: Colors.orange,
                        checkmarkColor: Colors.white,
                        onSelected: (selected) {
                          onCategorySelected(category['id']);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Events List
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                    : events.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_note, size: 80, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                const Text(
                                  'No events found',
                                  style: TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  selectedCategory == 'All' 
                                    ? 'Check back later for new events'
                                    : 'No events in "$selectedCategory" category',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              final event = events[index];
                              final eventId = event['firebaseKey']?.toString() ?? '';
                              
                              final title = event['title']?.toString() ?? 'Untitled Event';
                              final date = event['date']?.toString() ?? 'Date not set';
                              final time = event['startTime']?.toString() ?? '';
                              final location = event['location']?.toString() ?? 'Location not set';
                              final performers = event['performers']?.toString() ?? '';
                              final description = event['description']?.toString() ?? '';
                              final organizer = event['organizer']?.toString() ?? 'Organizer';
                              final price = (event['price'] as num?)?.toDouble() ?? 0.0;
                              final image = event['image']?.toString() ?? '';
                              final isFree = event['isFree'] ?? false;
                              final category = event['category']?.toString() ?? 'General';

                              return EventCard(
                                image: image,
                                title: title,
                                location: '📍 $location',
                                dateTime: '📅 $date${time.isNotEmpty ? ' — $time' : ''}',
                                performers: performers.isNotEmpty ? '🎤 Featuring: $performers' : '',
                                price: '🎫 ${isFree == true ? 'Free' : '₵${price.toInt()}'}',
                                category: category,
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
                                        description: description,
                                        organizer: organizer,
                                        price: price,
                                      ),
                                    ),
                                  );
                                },
                                onBookmark: () {
                                  toggleBookmark(eventId);
                                },
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

//////////////////////////////////////////////////
// EVENT CARD
//////////////////////////////////////////////////
class EventCard extends StatelessWidget {
  final String image;
  final String title;
  final String location;
  final String dateTime;
  final String performers;
  final String price;
  final String category;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const EventCard({
    required this.image,
    required this.title,
    required this.location,
    required this.dateTime,
    required this.performers,
    required this.price,
    required this.category,
    required this.onTap,
    required this.onBookmark,
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Image with proper error handling
              _buildEventImage(image),
              const SizedBox(height: 12),
              
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(location, style: const TextStyle(fontSize: 14)),
              Text(dateTime, style: const TextStyle(fontSize: 14)),
              if (performers.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(performers, style: const TextStyle(fontSize: 14)),
              ],
              const SizedBox(height: 8),
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tap to view details',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_border, color: Colors.orange),
                    onPressed: onBookmark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImagePlaceholder();
          },
        ),
      );
    } else if (imageUrl.isNotEmpty && imageUrl.contains('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imageUrl,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImagePlaceholder();
          },
        ),
      );
    } else {
      return _buildImagePlaceholder();
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.event,
        size: 50,
        color: Colors.grey,
      ),
    );
  }
}

//////////////////////////////////////////////////
// SHARED APP BAR
//////////////////////////////////////////////////
PreferredSizeWidget _buildAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w900,
        fontSize: 24,
      ),
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 16),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          },
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/images/profile.png'),
          ),
        ),
      ),
    ],
  );
}