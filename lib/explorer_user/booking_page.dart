import 'package:flutter/material.dart';
import 'ExplorerHome.dart'; // To navigate after booking

// Simple model for booked tickets
class BookedTicket {
  final String eventId;
  final String eventTitle;
  final int ticketCount;
  final String ticketType;
  final String paymentMethod;
  final double price;

  BookedTicket({
    required this.eventId,
    required this.eventTitle,
    required this.ticketCount,
    required this.ticketType,
    required this.paymentMethod,
    required this.price,
  });
}

// Global list to store booked tickets
List<BookedTicket> bookedTickets = [];

class BookingPage extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final double price;

  const BookingPage({
    Key? key,
    required this.eventId,
    required this.eventTitle,
    required this.price,
  }) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int ticketCount = 1;
  String selectedTicketType = 'Normal';
  String selectedPaymentMethod = 'Telebirr';

  int get ticketPrice => widget.price.toInt();
  int serviceFee = 0;
  int get subtotal => ticketCount * ticketPrice;
  int get total => subtotal + serviceFee;

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
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.eventTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Ticket counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Number of Tickets', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: ticketCount > 1 ? () => setState(() => ticketCount--) : null,
                  ),
                  Text('$ticketCount', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => ticketCount++),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Ticket type
          const Text('Ticket Type', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _selectionRow(options: const ['Normal', 'VIP', 'VVIP'], selected: selectedTicketType, onSelect: (value) => setState(() => selectedTicketType = value)),
          const SizedBox(height: 16),

          // Payment method
          const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _selectionRow(options: const ['Telebirr', 'CBE Birr', 'Chapa'], selected: selectedPaymentMethod, onSelect: (value) => setState(() => selectedPaymentMethod = value)),
          const SizedBox(height: 16),

          // Order summary
          _summaryRow('Subtotal:', '${subtotal} ETB'),
          _summaryRow('Service Fee:', '${serviceFee} ETB'),
          const Divider(),
          _summaryRow('Total:', widget.price > 0 ? '$total ETB' : 'Free', isBold: true),
          const SizedBox(height: 24),

          // Confirm button
          ElevatedButton(
            onPressed: _confirmBooking,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: Text(widget.price > 0 ? 'Confirm & Pay' : 'Confirm Booking', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _selectionRow({required List<String> options, required String selected, required Function(String) onSelect}) {
    return Row(
      children: options.map((option) {
        final bool isSelected = option == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(option),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: isSelected ? Colors.orange : const Color(0xFFFAEBDB), borderRadius: BorderRadius.circular(10)),
              child: Center(
                child: Text(option, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.black87)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ]),
    );
  }

  void _confirmBooking() {
    // Add booking to global list
    bookedTickets.add(BookedTicket(
      eventId: widget.eventId,
      eventTitle: widget.eventTitle,
      ticketCount: ticketCount,
      ticketType: selectedTicketType,
      paymentMethod: selectedPaymentMethod,
      price: widget.price,
    ));

    // Show success
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking Successful!'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
    );

    // Navigate to MyBookingPage
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ExploreHome(initialIndex: 2)));
    });
  }
}
