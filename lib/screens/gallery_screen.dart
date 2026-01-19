// gallery_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'add_trip_screen.dart';

class Trip {
  final String name;
  final String date; // e.g. "May 2025" or "November 2023 – January 2024"
  final List<File> photos;

  Trip({required this.name, required this.date, required this.photos});

  int get photoCount => photos.length;
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final List<Trip> _trips = [];

  void _addTrip(Trip newTrip) {
    setState(() {
      _trips.add(newTrip);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My trips"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddTripScreen(onSave: _addTrip),
                ),
              );
            },
          ),
        ],
      ),
      body: _trips.isEmpty
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTripScreen(onSave: _addTrip)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  final Trip trip;

  const TripCard({super.key, required this.trip});

  // Simple gradient generator based on trip index (for variety like screenshot)
  List<Color> _getGradientColors(int index) {
    final colors = [
      [Colors.purple.shade300, Colors.pink.shade200],
      [Colors.teal.shade300, Colors.cyan.shade200],
      [Colors.amber.shade300, Colors.orange.shade200],
      [Colors.blue.shade300, Colors.indigo.shade200],
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final hasPhotos = trip.photos.isNotEmpty;

    return GestureDetector(
      onTap: () {
        // TODO: open trip detail / full gallery view
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Open ${trip.name} photos soon...")),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getGradientColors(trip.photoCount),
          ),
        ),
        child: Stack(
          children: [
            // Photo previews (up to 3)
            if (hasPhotos)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: GridView.count(
                    crossAxisCount: 3,
                    physics: const NeverScrollableScrollPhysics(),
                    children: trip.photos.take(3).map((file) {
                      return Image.file(
                        file,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      );
                    }).toList(),
                  ),
                ),
              ),

            // Gradient overlay for text readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.65),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
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
      ),
    );
  }
}
