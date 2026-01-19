import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  final DatabaseReference _tripsRef = FirebaseDatabase.instance.ref().child(
    'my_trips',
  );
  List<Map<String, dynamic>> _myTrips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyTrips();
  }

  Future<void> _loadMyTrips() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }
      final snapshot = await _tripsRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> trips = [];
        data.forEach((key, value) {
          final tripData = Map<String, dynamic>.from(value as Map);
          if (tripData['createdBy'] == user.uid) {
            tripData['tripId'] = key;
            trips.add(tripData);
          }
        });
        // Sort by creation date (newest first)
        trips.sort((a, b) {
          final aDate = DateTime.parse(a['createdAt'] ?? '');
          final bDate = DateTime.parse(b['createdAt'] ?? '');
          return bDate.compareTo(aDate);
        });
        setState(() {
          _myTrips = trips;
          _isLoading = false;
        });
      } else {
        setState(() {
          _myTrips = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading trips: $e');
      setState(() => _isLoading = false);
    }
  }

  String _formatDateRange(String startDate, String endDate) {
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    return '${_formatDate(start)} - ${_formatDate(end)}';
  }

  String _formatDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  int _getActiveTripsCount() {
    return _myTrips.where((trip) => trip['status'] == 'open').length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Your Trips'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/add-trip');
              if (result == true) {
                _loadMyTrips();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myTrips.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadMyTrips,
              child: Column(
                children: [
                  // Header with trip count
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Text(
                      '${_getActiveTripsCount()} active',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  // Trips list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _myTrips.length,
                      itemBuilder: (context, index) {
                        return _buildTripCard(_myTrips[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
      // ───────────────────────────────────────────────────────────────
      //                   BOTTOM NAVIGATION BAR
      // ───────────────────────────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // My Trips is index 1
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            // Already on My Trips → optional: refresh or do nothing
            _loadMyTrips();
          } else if (index == 2) {
            // Browse
            Navigator.pushReplacementNamed(context, '/browse');
          } else if (index == 3) {
            // Gallery
            Navigator.pushReplacementNamed(context, '/gallery');
          }
        },
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // good when > 3 items
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_travel),
            label: 'My Trips',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Browse'),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Gallery',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.travel_explore, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No trips yet',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first trip!',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/add-trip');
              if (result == true) {
                _loadMyTrips();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Trip'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    final status = trip['status'] ?? 'open';
    final numberOfPeople = trip['numberOfPeople'] ?? 1;
    final joinedUsers = (trip['joinedUsers'] as List?)?.length ?? 0;
    final requestCount = 0; // TODO: Implement join requests

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder with status badges
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.teal.shade300, Colors.teal.shade600],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.landscape, size: 80, color: Colors.white70),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  children: [
                    if (status == 'open')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (requestCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$requestCount requests',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          // Trip details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip['destination'] ?? 'Unknown Destination',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDateRange(
                        trip['startDate'] ?? DateTime.now().toIso8601String(),
                        trip['endDate'] ?? DateTime.now().toIso8601String(),
                      ),
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.attach_money,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      trip['budget'] ?? 'Medium',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      '$joinedUsers / $numberOfPeople spots filled',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (trip['tripTypes'] != null &&
                    (trip['tripTypes'] as List).isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (trip['tripTypes'] as List).map((type) {
                      return Chip(
                        label: Text(
                          type.toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.teal.shade100,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showManageTripDialog(trip),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Manage Trip'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showRequestsDialog(trip),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Requests ($requestCount)',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showManageTripDialog(Map<String, dynamic> trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Trip'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Destination: ${trip['destination']}'),
            const SizedBox(height: 8),
            Text('Status: ${trip['status']}'),
            const SizedBox(height: 8),
            if (trip['description'] != null &&
                trip['description'].toString().isNotEmpty)
              Text('Description: ${trip['description']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTrip(trip['tripId']);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Trip'),
          ),
        ],
      ),
    );
  }

  void _showRequestsDialog(Map<String, dynamic> trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Requests'),
        content: const Text(
          'No join requests yet.\n\n'
          'Other users can request to join your trip, and you can accept or decline them here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTrip(String tripId) async {
    try {
      await _tripsRef.child(tripId).remove();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip deleted successfully')),
      );
      _loadMyTrips();
    } catch (e) {
      debugPrint('Error deleting trip: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete trip')));
    }
  }
}
