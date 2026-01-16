import 'package:flutter/material.dart';
import 'ticket_qr_page.dart';
import 'booking_page.dart'; // To access bookedTickets

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
        automaticallyImplyLeading: false, // Prevent default back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Center(child: Text('My Booking', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            const SizedBox(height: 16),

            // Toggle
            Row(
              children: [
                _tabButton(title: 'Upcoming', isActive: showUpcoming, onTap: () => setState(() => showUpcoming = true)),
                const SizedBox(width: 12),
                _tabButton(title: 'Past', isActive: !showUpcoming, onTap: () => setState(() => showUpcoming = false)),
              ],
            ),
            const SizedBox(height: 16),

            // Booking list
            Expanded(
              child: bookedTickets.isEmpty
                  ? const Center(child: Text('No bookings yet'))
                  : ListView(
                      children: bookedTickets.map((ticket) => _bookingCard(ticket)).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton({required String title, required bool isActive, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isActive ? Colors.orange : const Color(0xFFFAEBDB), borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }

  Widget _bookingCard(BookedTicket ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFAEBDB), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🎫 ${ticket.eventTitle}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('💳 ${ticket.price > 0 ? 'Paid' : 'Free'} • ${ticket.paymentMethod}'),
          const SizedBox(height: 4),
          Text('🎟️ Tickets: ${ticket.ticketCount}'),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TicketQrPage())),
            child: const Text('View Tickets', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
