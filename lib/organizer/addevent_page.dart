import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AddEventPage extends StatefulWidget {
  final String userId; // Added userId

  const AddEventPage({super.key, required this.userId});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _ticketPriceController = TextEditingController();
  final TextEditingController _paymentLinkController = TextEditingController();

  String category = 'Sports & Fitness';
  bool isFree = true;

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _locationController.dispose();
    _detailsController.dispose();
    _ticketPriceController.dispose();
    _paymentLinkController.dispose();
    super.dispose();
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    final newEvent = {
      'title': _eventNameController.text.trim(),
      'date': _eventDateController.text.trim(),
      'startTime': _startTimeController.text.trim(),
      'endTime': _endTimeController.text.trim(),
      'location': _locationController.text.trim(),
      'details': _detailsController.text.trim(),
      'category': category,
      'isFree': isFree,
      'price': isFree ? 0 : double.tryParse(_ticketPriceController.text.trim()) ?? 0,
      'paymentLink': _paymentLinkController.text.trim(),
      'creatorId': widget.userId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'image': '', // TODO: Replace with actual image URL
      'video': '', // TODO: Replace with actual video URL
    };

    try {
      await _dbRef.child('events').push().set(newEvent);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event created successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Go back to dashboard
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create event: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Event Name
              TextFormField(
                controller: _eventNameController,
                decoration: const InputDecoration(
                  labelText: 'Event Name*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Enter event name' : null,
              ),
              const SizedBox(height: 16),

              // Event Date
              TextFormField(
                controller: _eventDateController,
                decoration: const InputDecoration(
                  labelText: 'Event Date*',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    _eventDateController.text =
                        "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                  }
                },
                validator: (value) => (value == null || value.isEmpty) ? 'Select event date' : null,
              ),
              const SizedBox(height: 16),

              // Event Time
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startTimeController,
                      decoration: const InputDecoration(
                        labelText: 'From',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          _startTimeController.text = pickedTime.format(context);
                        }
                      },
                      validator: (value) => (value == null || value.isEmpty) ? 'Select start time' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _endTimeController,
                      decoration: const InputDecoration(
                        labelText: 'To',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          _endTimeController.text = pickedTime.format(context);
                        }
                      },
                      validator: (value) => (value == null || value.isEmpty) ? 'Select end time' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: category,
                items: <String>['Sports & Fitness', 'Music', 'Business', 'Art', 'Other']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => category = val!),
                decoration: const InputDecoration(
                  labelText: 'Category*',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location*',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.location_on),
                    onPressed: () {
                      // TODO: Integrate map/location picker
                    },
                  ),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Enter location' : null,
              ),
              const SizedBox(height: 16),

              // Event Details
              TextFormField(
                controller: _detailsController,
                decoration: const InputDecoration(
                  labelText: 'Event Details',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              // Ticket Price
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Free'),
                      value: true,
                      groupValue: isFree,
                      onChanged: (val) => setState(() => isFree = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Paid'),
                      value: false,
                      groupValue: isFree,
                      onChanged: (val) => setState(() => isFree = val!),
                    ),
                  ),
                ],
              ),
              if (!isFree)
                TextFormField(
                  controller: _ticketPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Enter the amount',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => (!isFree && (value == null || value.isEmpty))
                      ? 'Enter ticket price'
                      : null,
                ),
              const SizedBox(height: 16),

              // Payment Link
              TextFormField(
                controller: _paymentLinkController,
                decoration: const InputDecoration(
                  labelText: 'Payment Link',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Reset & Create Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _formKey.currentState?.reset();
                        _eventNameController.clear();
                        _eventDateController.clear();
                        _startTimeController.clear();
                        _endTimeController.clear();
                        _locationController.clear();
                        _detailsController.clear();
                        _ticketPriceController.clear();
                        _paymentLinkController.clear();
                        setState(() {
                          category = 'Sports & Fitness';
                          isFree = true;
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _createEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Create',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
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
