import 'package:flutter/material.dart';

class TicketQrPage extends StatelessWidget {
  const TicketQrPage({Key? key}) : super(key: key);

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            const Text(
              'Your Ticket',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            // QR Code Placeholder
            Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFFAEBDB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.qr_code,
                  size: 160,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Addis Tech Summit 2025',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              '🎟 Tickets: 2\n'
              '📅 12 Dec 2025 | ⏰ 10:00 AM\n'
              '📍 Addis Ababa',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            const Text(
              'Show this QR code at the entrance',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
