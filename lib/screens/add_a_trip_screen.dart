import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddATripScreen extends StatefulWidget {
  const AddATripScreen({super.key});

  @override
  State<AddATripScreen> createState() => _AddATripScreenState();
}

class _AddATripScreenState extends State<AddATripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _numberOfPeopleController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedBudget = 'Medium';
  int _numberOfPeople = 1;
  File? _selectedImage;
  String? _imageUrl;

  // Trip types
  final Map<String, bool> _tripTypes = {
    'Adventure': false,
    'Relax': false,
    'Sightseeing': false,
    'Backpacking': false,
  };

  bool _isLoading = false;

  @override
  void dispose() {
    _destinationController.dispose();
    _descriptionController.dispose();
    _numberOfPeopleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Reset end date if it's before start date
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      _showSnackBar('Failed to pick image');
    }
  }

  Future<void> _createTrip() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      _showSnackBar('Please select travel dates');
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      _showSnackBar('End date must be after start date');
      return;
    }

    // Check if at least one trip type is selected
    if (!_tripTypes.containsValue(true)) {
      _showSnackBar('Please select at least one trip type');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnackBar('You must be logged in to create a trip');
        setState(() => _isLoading = false);
        return;
      }

      debugPrint('Creating trip for user: ${user.uid}');

      // Get selected trip types
      List<String> selectedTripTypes = _tripTypes.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      debugPrint('Selected trip types: $selectedTripTypes');

      // Create trip data
      final tripData = {
        'destination': _destinationController.text.trim(),
        'startDate': _startDate!.toIso8601String(),
        'endDate': _endDate!.toIso8601String(),
        'budget': _selectedBudget,
        'numberOfPeople': _numberOfPeople,
        'tripTypes': selectedTripTypes,
        'description': _descriptionController.text.trim(),
        'createdBy': user.uid,
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'open', // open, full, completed, cancelled
        'joinedUsers': [], // List of user IDs who joined
        'imageUrl': _selectedImage?.path ?? '', // Store local path for now
      };

      debugPrint('Trip data prepared: $tripData');
      debugPrint('Attempting to write to Realtime Database...');

      // Save to Realtime Database
      final DatabaseReference db = FirebaseDatabase.instance.ref();
      final newTripRef = db.child("my_trips").push();
      await newTripRef.set(tripData);

      final tripId = newTripRef.key;
      debugPrint('Trip created successfully with ID: $tripId');

      if (!mounted) return;

      _showSnackBar('Trip created successfully!');
      Navigator.pop(context, true); // Return true to indicate success
    } on FirebaseException catch (e) {
      debugPrint('Firebase error creating trip: ${e.code} - ${e.message}');
      _showSnackBar('Firebase Error: ${e.code} - ${e.message}');
    } catch (e) {
      debugPrint('Error creating trip: $e');
      _showSnackBar('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create a Trip'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo selection
                const Text(
                  '1. Trip Photo (Optional)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to add a photo',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Destination
                const Text(
                  '2. Destination *',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _destinationController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Goa, Manali, Jaipur',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Destination is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Travel Dates
                const Text(
                  '3. Travel Dates *',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[50],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Start Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(_startDate),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _startDate == null
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[50],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'End Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(_endDate),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _endDate == null
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Budget Range
                const Text(
                  '4. Budget Range *',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildBudgetOption('Low')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildBudgetOption('Medium')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildBudgetOption('High')),
                  ],
                ),
                const SizedBox(height: 24),

                // Number of People
                const Text(
                  '5. Number of Travel Mates *',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_numberOfPeople > 1) {
                          setState(() => _numberOfPeople--);
                        }
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                      color: Colors.teal,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.teal),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _numberOfPeople.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (_numberOfPeople < 20) {
                          setState(() => _numberOfPeople++);
                        }
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      color: Colors.teal,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _numberOfPeople == 1 ? 'person' : 'people',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Trip Type
                const Text(
                  '6. Trip Type / Travel Style *',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tripTypes.keys.map((type) {
                    return FilterChip(
                      label: Text(type),
                      selected: _tripTypes[type]!,
                      onSelected: (selected) {
                        setState(() {
                          _tripTypes[type] = selected;
                        });
                      },
                      selectedColor: Colors.teal.withOpacity(0.3),
                      checkmarkColor: Colors.teal,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Description
                const Text(
                  '7. Description (Optional)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText:
                        'Any extra info? e.g., "Budget-friendly trip, staying in hostels"',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 32),

                // Create Trip Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createTrip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Create Trip',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetOption(String budget) {
    final isSelected = _selectedBudget == budget;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedBudget = budget;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.grey[50],
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            budget,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
