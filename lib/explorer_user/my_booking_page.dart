import 'package:flutter/material.dart';
import 'ticket_qr_page.dart'; // 👈 Import the QR page

class MyBookingPage extends StatefulWidget {
  const MyBookingPage({Key? key}) : super(key: key);

  @override
  State<MyBookingPage> createState() => _MyBookingPageState();
}

class _MyBookingPageState extends State<MyBookingPage> {
  bool showUpcoming = true;

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

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Header
            const Center(
              child: Text(
                'My Booking',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Upcoming / Past buttons
            Row(
              children: [
                _tabButton(
                  title: 'Upcoming',
                  isActive: showUpcoming,
                  onTap: () {
                    setState(() {
                      showUpcoming = true;
                    });
                  },
                ),
                const SizedBox(width: 12),
                _tabButton(
                  title: 'Past',
                  isActive: !showUpcoming,
                  onTap: () {
                    setState(() {
                      showUpcoming = false;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Booking cards
            Expanded(
              child: ListView(
                children: [
                  _bookingCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tab button widget
  Widget _tabButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.orange : const Color(0xFFFAEBDB),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Booking card widget
  Widget _bookingCard() {
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
          const Text(
            '🎫 Addis Tech Summit 2025',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text('📅 12 Dec 2025 | ⏰ 10:00 AM'),
          const SizedBox(height: 4),

          const Text('📍 Addis Ababa'),
          const SizedBox(height: 4),

          const Text('💳 Paid • Telebirr (Simulated)'),
          const SizedBox(height: 4),

          const Text('🎟️ Tickets: 2'),
          const SizedBox(height: 4),

          const Text(
            'Status: Confirmed',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          GestureDetector(
            onTap: () {
              // ✅ Navigate to QR Code page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TicketQrPage(),
                ),
              );
            },
            child: const Text(
              'View Tickets',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
