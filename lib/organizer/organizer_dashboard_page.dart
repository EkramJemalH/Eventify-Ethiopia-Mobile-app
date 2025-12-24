import 'package:flutter/material.dart';
import 'organizer_event_detail.dart'; // existing detail page
import 'addevent_page.dart'; // new Add Event page

class OrganizerDashboardPage extends StatefulWidget {
  @override
  State<OrganizerDashboardPage> createState() => _OrganizerDashboardPageState();
}

class _OrganizerDashboardPageState extends State<OrganizerDashboardPage> {
  List<Map<String, String>> events = [
    {
      'title': 'Concert Night Addis',
      'date': 'Dec 21, 2025 • 7:00 PM',
      'location': 'Friendship Square, Addis Ababa',
      'category': 'Music',
      'status': 'Upcoming',
      'image': 'assets/images/concert.jpg',
      'performers': 'Local Band',
      'description': 'Enjoy an amazing night of music!',
      'organizer': 'John Doe',
    },
    {
      'title': 'Startup Pitch Night',
      'date': 'Jan 10, 2026 • 6:00 PM',
      'location': 'Ice Addis',
      'category': 'Business',
      'status': 'Upcoming',
      'image': 'assets/images/startup.jpg',
      'performers': 'Entrepreneurs',
      'description': 'Pitch your startup ideas and network!',
      'organizer': 'Jane Doe',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ===== AppBar =====
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Events',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                // TODO: Navigate to organizer profile
              },
              child: const CircleAvatar(
                backgroundColor: Color(0xFFFAEBDB),
                child: Icon(Icons.person, color: Colors.orange),
              ),
            ),
          ),
        ],
      ),

      // ===== Body =====
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Add New Event Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to Add Event page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddEventPage()),
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
                  'Add New Event',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Event List
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
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
                        Text(
                          event['title'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(event['date'] ?? ''),
                        Text(event['location'] ?? ''),
                        const SizedBox(height: 12),

                        // Buttons Row: Tap to Edit & Delete
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Navigate to Event Detail Page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OrganizerEventDetailPage(
                                      title: event['title']!,
                                      image: event['image']!,
                                      dateTime: event['date']!,
                                      location: event['location']!,
                                      performers: event['performers']!,
                                      description: event['description']!,
                                      organizer: event['organizer']!,
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Tap to Edit',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    events.removeAt(index);
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 223, 93, 6),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
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
                                  textAlign: TextAlign.center,
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
    );
  }
}
