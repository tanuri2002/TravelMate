import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddTripScreen extends StatefulWidget {
  final Future<void> Function(String name, String date, List<File> photos)
  onSave;

  const AddTripScreen({super.key, required this.onSave});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  int _selectedIndex = 0; // default home tab
  final _nameController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  List<File> _selectedPhotos = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() {
        _selectedPhotos = images.map((x) => File(x.path)).toList();
      });
    }
  }

  String _formatDateRange() {
    if (_startDate == null) return "Select date";
    if (_endDate == null || _startDate == _endDate) {
      return "${_startDate!.monthName} ${_startDate!.year}";
    }
    return "${_startDate!.monthName} ${_startDate!.year} – ${_endDate!.monthName} ${_endDate!.year}";
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/my-trips');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/gallery');
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, '/account');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,

      body: SafeArea(
        child: Column(
          children: [
            // === TOP HEADER (exact same as GalleryScreen) ===
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: BoxDecoration(color: Colors.teal[800]),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TravelMate',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Add a New Trip', // subtitle specific to AddTripScreen
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // === BODY FORM ===
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Trip name",
                      border: OutlineInputBorder(),
                      hintText: "e.g. Old friends in Paris",
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(_formatDateRange()),
                    subtitle: const Text("Trip period"),
                    onTap: _pickDateRange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.photo_library),
                    label: Text(
                      _selectedPhotos.isEmpty
                          ? "Choose photos"
                          : "${_selectedPhotos.length} photo${_selectedPhotos.length == 1 ? '' : 's'} selected",
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.teal[600],
                    ),
                  ),
                  if (_selectedPhotos.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: _selectedPhotos.length,
                      itemBuilder: (context, i) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedPhotos[i],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter trip name"),
                          ),
                        );
                        return;
                      }
                      if (_startDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please select date")),
                        );
                        return;
                      }

                      await widget.onSave(
                        _nameController.text.trim(),
                        _formatDateRange(),
                        _selectedPhotos,
                      );

                      if (mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("Save Trip"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),

      // === BOTTOM NAVIGATION BAR ===
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.teal[800],
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.travel_explore),
            label: 'My Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Gallery',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}

// === DATE EXTENSION ===
extension DateHelper on DateTime {
  String get monthName {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
  }
}
