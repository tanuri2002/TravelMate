// add_trip_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'gallery_screen.dart'; // import Trip class

class AddTripScreen extends StatefulWidget {
  final Function(Trip) onSave;

  const AddTripScreen({super.key, required this.onSave});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Trip"),
        actions: [
          TextButton(
            onPressed: () {
              if (_nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter trip name")),
                );
                return;
              }
              if (_startDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please select date")),
                );
                return;
              }

              final trip = Trip(
                name: _nameController.text.trim(),
                date: _formatDateRange(),
                photos: _selectedPhotos,
              );

              widget.onSave(trip);
              Navigator.pop(context);
            },
            child: const Text("Save", style: TextStyle(fontSize: 17)),
          ),
        ],
      ),
      body: ListView(
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
            ),
          ),
          if (_selectedPhotos.isNotEmpty) ...[
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _selectedPhotos.length,
              itemBuilder: (context, i) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_selectedPhotos[i], fit: BoxFit.cover),
                );
              },
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// Extension helper
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
