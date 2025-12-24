import 'package:flutter/material.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int ticketCount = 1;
  String selectedTicketType = 'Normal';
  String selectedPaymentMethod = 'Telebirr';

  int ticketPrice = 400;
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
              radius: 18,
              backgroundImage:
                  AssetImage('assets/images/profile.png'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 12),

          // Event description
          const Text(
            'Concert Night Addis',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            '🗓 Dec 21, 2025 • 7:00 PM\n'
            '📍 Friendship Square, Addis Ababa',
            style: TextStyle(fontSize: 14),
          ),

          const SizedBox(height: 24),

          // Ticket details
          const Text(
            'Ticket Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          const Text(
            'Number of Tickets',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          _ticketCounter(),

          const SizedBox(height: 24),

          // Ticket type
          const Text(
            'Ticket Type',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _selectionRow(
            options: const ['Normal', 'VIP', 'VVIP'],
            selected: selectedTicketType,
            onSelect: (value) {
              setState(() {
                selectedTicketType = value;
              });
            },
          ),

          const SizedBox(height: 16),

          Text(
            'Ticket Price = $ticketPrice ETB',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 24),

          // Payment method
          const Text(
            'Payment Method',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _selectionRow(
            options: const ['Telebirr', 'CBE Birr', 'Chapa'],
            selected: selectedPaymentMethod,
            onSelect: (value) {
              setState(() {
                selectedPaymentMethod = value;
              });
            },
          ),

          const SizedBox(height: 24),

          // Order summary
          const Text(
            'Order Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _summaryRow('Subtotal:', '$subtotal ETB'),
          _summaryRow('Service Fee:', '$serviceFee ETB'),
          const Divider(),
          _summaryRow(
            'Total:',
            '$total ETB',
            isBold: true,
          ),

          const SizedBox(height: 24),

          // Confirm button
          ElevatedButton(
            onPressed: () {
              // TODO: Payment simulation / confirmation
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Confirm & Pay',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Ticket counter widget
  Widget _ticketCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAEBDB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: ticketCount > 1
                ? () {
                    setState(() {
                      ticketCount--;
                    });
                  }
                : null,
          ),
          Text(
            '$ticketCount',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                ticketCount++;
              });
            },
          ),
        ],
      ),
    );
  }

  // Selection row (ticket type & payment)
  Widget _selectionRow({
    required List<String> options,
    required String selected,
    required Function(String) onSelect,
  }) {
    return Row(
      children: options.map((option) {
        final bool isSelected = option == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(option),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.orange
                    : const Color(0xFFFAEBDB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  option,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.black
                        : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Order summary row
  Widget _summaryRow(String label, String value,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight:
                      isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontWeight:
                      isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
