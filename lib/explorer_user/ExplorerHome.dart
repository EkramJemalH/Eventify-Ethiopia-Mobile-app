import 'package:flutter/material.dart';
import 'event_detail_page.dart';
import '../profile_page.dart'; // Make sure this file exists

class ExploreHome extends StatefulWidget {
  ExploreHome({Key? key}) : super(key: key);

  @override
  State<ExploreHome> createState() => _ExploreHomeState();
}

class _ExploreHomeState extends State<ExploreHome> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeContent(),
      BookmarkPage(),
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
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////
// HOME PAGE
//////////////////////////////////////////////////
class HomeContent extends StatelessWidget {
  HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, 'HOME'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search + Filter
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon:
                          Icon(Icons.search, color: Colors.grey.withOpacity(0.7)),
                      hintText: 'Search',
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.filter_list, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Category header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('See All', style: TextStyle(color: Colors.orange)),
              ],
            ),
            const SizedBox(height: 12),

            // Categories
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  CategoryItem(icon: Icons.event, label: 'Casual'),
                  CategoryItem(icon: Icons.festival, label: 'Fest'),
                  CategoryItem(icon: Icons.music_note, label: 'Entertainment'),
                  CategoryItem(icon: Icons.computer, label: 'Tech'),
                  CategoryItem(icon: Icons.people, label: 'Community'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Events
            Expanded(
              child: ListView(
                children: [
                  EventCard(
                    image: 'assets/images/party.jpg',
                    title: 'Concert Night Addis',
                    location: '📍 Friendship Square, Addis Ababa',
                    dateTime: '📅 Dec 21, 2025 — 7:00 PM',
                    performers: '🎤 Featuring: Jano Band, Hewan Gebrewold',
                    price: '🎫 From 300 ETB',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailPage(
                            title: 'Concert Night Addis',
                            image: 'assets/images/party.jpg',
                            dateTime: 'Dec 21, 2025 • 7:00 PM',
                            location: 'Friendship Square, Addis Ababa',
                            performers: 'Jano Band, Hewan Gebrewold, DJ Sky',
                            description:
                                'Concert Night Addis is a lively year-end music show featuring top Ethiopian artists, great sound, and fun night-time vibes at Friendship Square. Perfect for anyone who loves live music and entertainment.',
                            organizer:
                                'EthioFinder Events\n📞 +251 900 123 456\n📧 contact@ethiofinder.com',
                          ),
                        ),
                      );
                    },
                  ),
                  EventCard(
                    image: 'assets/images/tech.jpg',
                    title: 'Tech Expo 2025',
                    location: '📍 Millennium Hall, Addis Ababa',
                    dateTime: '📅 Jan 15, 2026 — 10:00 AM',
                    performers: '🎤 Speakers: AI Experts, Developers',
                    price: '🎫 From 150 ETB',
                    onTap: () {
                      // Add navigation to detail page for Tech Expo if needed
                    },
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

//////////////////////////////////////////////////
// CATEGORY ITEM
//////////////////////////////////////////////////
class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const CategoryItem({
    required this.icon,
    required this.label,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey.withOpacity(0.2),
            child: Icon(icon, color: Colors.grey.withOpacity(0.6), size: 28),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
        ],
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
  final VoidCallback onTap;

  const EventCard({
    required this.image,
    required this.title,
    required this.location,
    required this.dateTime,
    required this.performers,
    required this.price,
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: Image.asset(image, height: 180, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              Text(location),
              Text(dateTime),
              Text(performers),
              Text(price),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tap to view details', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Remove from bookmark functionality
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////
// BOOKMARK PAGE
//////////////////////////////////////////////////
class BookmarkPage extends StatelessWidget {
  BookmarkPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, 'BOOKMARK'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            EventCard(
              image: 'assets/images/party.jpg',
              title: 'Concert Night Addis',
              location: '📍 Friendship Square, Addis Ababa',
              dateTime: '📅 Dec 21, 2025 — 7:00 PM',
              performers: '🎤 Featuring: Jano Band, Hewan Gebrewold',
              price: '🎫 From 300 ETB',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailPage(
                      title: 'Concert Night Addis',
                      image: 'assets/images/party.jpg',
                      dateTime: 'Dec 21, 2025 • 7:00 PM',
                      location: 'Friendship Square, Addis Ababa',
                      performers: 'Jano Band, Hewan Gebrewold, DJ Sky',
                      description:
                          'Concert Night Addis is a lively year-end music show featuring top Ethiopian artists, great sound, and fun night-time vibes at Friendship Square. Perfect for anyone who loves live music and entertainment.',
                      organizer:
                          'EthioFinder Events\n📞 +251 900 123 456\n📧 contact@ethiofinder.com',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
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
    title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 24)),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 16),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
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
