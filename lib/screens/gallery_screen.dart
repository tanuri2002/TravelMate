import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'add_trip_screen.dart';

class Trip {
  final String id; // Firebase key
  final String name;
  final String date;
  final List<String> photoUrls; // Store local file paths (for now)

  Trip({
    required this.id,
    required this.name,
    required this.date,
    required this.photoUrls,
  });

  int get photoCount => photoUrls.length;

  Map<String, dynamic> toMap() {
    return {'name': name, 'date': date, 'photoUrls': photoUrls};
  }

  factory Trip.fromMap(String id, Map<dynamic, dynamic> map) {
    return Trip(
      id: id,
      name: map['name'] ?? '',
      date: map['date'] ?? '',
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
    );
  }
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int _selectedIndex = 2; // Gallery tab
  final DatabaseReference _tripsRef = FirebaseDatabase.instance.ref().child(
    'trips',
  );
  List<Trip> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await _tripsRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final trips = data.entries.map((e) {
          return Trip.fromMap(
            e.key as String,
            Map<String, dynamic>.from(e.value),
          );
        }).toList();

        setState(() {
          _trips = trips;
          _isLoading = false;
        });
      } else {
        setState(() {
          _trips = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading trips: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/my-trips');
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, '/account');
    }
  }

  Future<void> _addTrip(String name, String date, List<File> photos) async {
    final photoPaths = photos.map((f) => f.path).toList();
    final newTripRef = _tripsRef.push();
    final newTrip = Trip(
      id: newTripRef.key!,
      name: name,
      date: date,
      photoUrls: photoPaths,
    );

    await newTripRef.set(newTrip.toMap());
    await _loadTrips(); // refresh list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Top header
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
                    'My Trips Gallery',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _trips.isEmpty
                  ? const Center(
                      child: Text(
                        "No trips yet.\nAdd your first adventure! ✈️",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _trips.length,
                      itemBuilder: (context, index) {
                        final trip = _trips[index];
                        return TripCard(trip: trip);
                      },
                    ),
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTripScreen(
                onSave: _addTrip, // <-- now matches the expected type
              ),
            ),
          );
        },
        backgroundColor: Colors.teal[800],
        child: const Icon(Icons.add),
      ),

      // Bottom Navigation Bar
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

// TripCard widget (unchanged)
class TripCard extends StatelessWidget {
  final Trip trip;

  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final hasPhotos = trip.photoUrls.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.teal.shade300, Colors.cyan.shade200],
        ),
      ),
      child: Stack(
        children: [
          if (hasPhotos)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: GridView.count(
                  crossAxisCount: 3,
                  physics: const NeverScrollableScrollPhysics(),
                  children: trip.photoUrls.take(3).map((path) {
                    return Image.file(
                      File(path),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image),
                    );
                  }).toList(),
                ),
              ),
            ),

          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ),

          // Trip info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  trip.date,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.photo, size: 16, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      "${trip.photoCount} photos",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
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
}
