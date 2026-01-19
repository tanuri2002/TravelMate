import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  final DatabaseReference _tripsRef = FirebaseDatabase.instance.ref().child('my_trips');
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
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
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
                _loadMyTrips(); // Reload trips after creating new one
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
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
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

  Widget _buildPlaceholderImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.teal.shade300,
            Colors.teal.shade600,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.landscape,
          size: 80,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    final status = trip['status'] ?? 'open';
    final numberOfPeople = trip['numberOfPeople'] ?? 1;
    final joinedUsers = (trip['joinedUsers'] as List?)?.length ?? 0;
    final spotsAvailable = numberOfPeople - joinedUsers;
    final requestCount = (trip['joinRequests'] as List?)?.length ?? 0;

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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: (trip['imageUrl'] != null && trip['imageUrl'].toString().isNotEmpty)
                      ? Image.file(
                          File(trip['imageUrl']),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        )
                      : _buildPlaceholderImage(),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  children: [
                    if (status == 'open')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                // Destination
                Text(
                  trip['destination'] ?? 'Unknown Destination',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Dates
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
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

                // Budget
                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      trip['budget'] ?? 'Medium',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Spots available
                Row(
                  children: [
                    const Icon(Icons.people, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      '$joinedUsers of $numberOfPeople spots available',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Trip types
                if (trip['tripTypes'] != null && (trip['tripTypes'] as List).isNotEmpty)
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

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _showManageTripDialog(trip);
                        },
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
                        onPressed: () {
                          _showRequestsDialog(trip);
                        },
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
            if (trip['description'] != null && trip['description'].toString().isNotEmpty)
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
    List<dynamic> joinRequests = trip['joinRequests'] ?? [];
    
    if (joinRequests.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Join Requests'),
          content: const Text('No join requests yet.\n\nOther users can request to join your trip, and you can accept or decline them here.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Join Requests (${joinRequests.length})'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: joinRequests.length,
            itemBuilder: (context, index) {
              final userId = joinRequests[index];
              return FutureBuilder<DataSnapshot>(
                future: FirebaseDatabase.instance
                    .ref()
                    .child('users')
                    .child(userId)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Card(
                      child: ListTile(
                        leading: CircularProgressIndicator(),
                        title: Text('Loading...'),
                      ),
                    );
                  }

                  String userName = 'User';
                  String userEmail = userId;

                  if (snapshot.hasData && snapshot.data?.value != null) {
                    final userData = snapshot.data?.value as Map?;
                    userName = userData?['name'] ?? userData?['username'] ?? 'User';
                    userEmail = userData?['email'] ?? userId;
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal,
                        child: Text(
                          userName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(userName),
                      subtitle: Text(
                        userEmail,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () {
                              _acceptJoinRequest(trip, userId);
                              Navigator.pop(context);
                            },
                            tooltip: 'Accept',
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              _declineJoinRequest(trip, userId);
                              Navigator.pop(context);
                            },
                            tooltip: 'Decline',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
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

  Future<void> _acceptJoinRequest(Map<String, dynamic> trip, String userId) async {
    try {
      final tripId = trip['tripId'];
      
      // Get current trip data
      final snapshot = await _tripsRef.child(tripId).get();
      if (!snapshot.exists) {
        throw Exception('Trip not found');
      }

      final tripData = Map<String, dynamic>.from(snapshot.value as Map);
      
      // Remove from join requests
      List<dynamic> joinRequests = List.from(tripData['joinRequests'] ?? []);
      joinRequests.remove(userId);
      
      // Add to joined users
      List<dynamic> joinedUsers = List.from(tripData['joinedUsers'] ?? []);
      if (!joinedUsers.contains(userId)) {
        joinedUsers.add(userId);
      }

      // Update both fields
      await _tripsRef.child(tripId).child('joinRequests').set(joinRequests);
      await _tripsRef.child(tripId).child('joinedUsers').set(joinedUsers);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Join request accepted!')),
      );
      
      _loadMyTrips();
    } catch (e) {
      debugPrint('Error accepting join request: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept: ${e.toString()}')),
      );
    }
  }

  Future<void> _declineJoinRequest(Map<String, dynamic> trip, String userId) async {
    try {
      final tripId = trip['tripId'];
      
      // Get current trip data
      final snapshot = await _tripsRef.child(tripId).get();
      if (!snapshot.exists) {
        throw Exception('Trip not found');
      }

      final tripData = Map<String, dynamic>.from(snapshot.value as Map);
      
      // Remove from join requests
      List<dynamic> joinRequests = List.from(tripData['joinRequests'] ?? []);
      joinRequests.remove(userId);

      await _tripsRef.child(tripId).child('joinRequests').set(joinRequests);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Join request declined')),
      );
      
      _loadMyTrips();
    } catch (e) {
      debugPrint('Error declining join request: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to decline: ${e.toString()}')),
      );
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete trip')),
      );
    }
  }
}
