import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddEventPage extends StatefulWidget {
  final String userId;

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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Image picker
  XFile? _pickedImage;
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _pickedImage = pickedFile;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not authenticated'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Generate unique event key
      final eventKey = _dbRef.child('events').push().key;

      // Format combined date and time for sorting
      final combinedDateTime = '${_eventDateController.text.trim()} ${_startTimeController.text.trim()}';

      // Get organizer name from user
      final organizerName = user.displayName ?? 'Organizer';

      // Upload image if picked
      String imageUrl = 'assets/images/event_placeholder.jpg';
      if (_pickedImage != null && _imageBytes != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('event_images')
            .child('$eventKey.jpg');
        
        // Upload bytes (works on both Web and Mobile)
        final metadata = SettableMetadata(contentType: 'image/jpeg');
        await storageRef.putData(_imageBytes!, metadata);
        imageUrl = await storageRef.getDownloadURL();
      }

      // Prepare event data
      final newEvent = {
        'title': _eventNameController.text.trim(),
        'date': _eventDateController.text.trim(),
        'startTime': _startTimeController.text.trim(),
        'endTime': _endTimeController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _detailsController.text.trim(),
        'details': _detailsController.text.trim(),
        'performers': '',
        'category': category,
        'isFree': isFree,
        'price': isFree ? 0.0 : double.tryParse(_ticketPriceController.text.trim()) ?? 0.0,
        'paymentLink': _paymentLinkController.text.trim(),
        'organizer': organizerName,
        'organizerId': user.uid,
        'userId': user.uid,
        'creatorId': user.uid,
        'organizerUid': user.uid,
        'eventId': eventKey,
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'dateTime': combinedDateTime,
        'sortDate': _eventDateController.text.trim(),
        'image': imageUrl,
        'video': '',
        'capacity': 100,
        'availableSpots': 100,
        'status': 'upcoming',
      };

      // Save to Firebase
      await _dbRef.child('events').child(eventKey!).set(newEvent);

      // Success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event created successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Reset form and navigate back
      _resetForm();
      await Future.delayed(const Duration(milliseconds: 1500));
      Navigator.pop(context, true);

    } catch (e) {
      print('Error creating event: $e');
      final errorMessage = e.toString();

      if (errorMessage.contains('PERMISSION_DENIED') || errorMessage.contains('permission-denied')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Permission denied. Check Firebase security rules.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'FIX NOW',
              textColor: Colors.white,
              onPressed: _showSecurityRulesHelp,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create event: ${errorMessage.length > 100 ? '${errorMessage.substring(0, 100)}...' : errorMessage}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showSecurityRulesHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Firebase Security Rules Issue'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Your app cannot write to Firebase due to security rules.'),
              const SizedBox(height: 16),
              const Text('To fix this, go to Firebase Console:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('1. Open your Firebase project'),
              const Text('2. Click "Realtime Database"'),
              const Text('3. Go to "Rules" tab'),
              const SizedBox(height: 16),
              const Text('Paste these rules for testing:', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const SelectableText(
                  '{\n'
                  '  "rules": {\n'
                  '    "events": {\n'
                  '      ".read": true,\n'
                  '      ".write": "auth != null"\n'
                  '    }\n'
                  '  }\n'
                  '}',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),
              const Text('⚠️ Note: These are development rules. Update them for production.', style: TextStyle(fontSize: 12, color: Colors.orange)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  void _resetForm() {
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
      _pickedImage = null;
      _imageBytes = null;
    });
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
              // Image picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    image: _imageBytes != null
                        ? DecorationImage(
                            image: MemoryImage(_imageBytes!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imageBytes == null
                      ? const Center(
                          child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),

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
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
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
                        labelText: 'From*',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final TimeOfDay? pickedTime = await showTimePicker(
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
                        labelText: 'To*',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                            DateTime.now().add(const Duration(hours: 1)),
                          ),
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
                validator: (value) => (value == null || value.isEmpty) ? 'Select category' : null,
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
                  labelText: 'Event Details*',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) => (value == null || value.isEmpty) ? 'Enter event details' : null,
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
                    labelText: 'Ticket Price*',
                    border: OutlineInputBorder(),
                    prefixText: '₵',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (!isFree && (value == null || value.isEmpty)) {
                      return 'Enter ticket price';
                    }
                    if (!isFree && double.tryParse(value!) == null) {
                      return 'Enter valid price';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),

              // Payment Link
              if (!isFree)
                TextFormField(
                  controller: _paymentLinkController,
                  decoration: const InputDecoration(
                    labelText: 'Payment Link (Optional)',
                    border: OutlineInputBorder(),
                    hintText: 'https://example.com/payment',
                  ),
                  keyboardType: TextInputType.url,
                ),
              const SizedBox(height: 24),

              // Reset & Create Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetForm,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
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
                        'Create Event',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),

              // Info message
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This event will be visible on the home page for all users',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
