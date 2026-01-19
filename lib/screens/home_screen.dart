import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'add_a_trip_screen.dart';
import 'join_trip_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  String? get currentUserUid => FirebaseAuth.instance.currentUser?.uid;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.pushNamed(context, '/my-trips');
    }
    // index 2 → Browse (TODO)
    // index 3 → Gallery (TODO)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Action Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      label: 'Add a Trip',
                      icon: Icons.add_circle_outline,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddATripScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      label: 'Join a Trip',
                      icon: Icons.group_add_outlined,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JoinTripScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Upcoming Trips',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Your Upcoming Trips (still demo / static for now) ──
                    SizedBox(
                      height: 240,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          final locations = [
                            'Mirissa, Sri Lanka',
                            'Unawatuna, Sri Lanka',
                            'Arugam Bay, Sri Lanka',
                            'Bentota, Sri Lanka',
                            'Weligama, Sri Lanka',
                          ];
                          final images = [
                            'https://images.unsplash.com/photo-1544750040-4ea9b8a27d38?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTh8fHNyaWxhbmthfGVufDB8fDB8fHww',
                            'https://images.unsplash.com/photo-1607896477672-21ffa8e2b36e?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8dHVydGxlJTIwYmVhY2h8ZW58MHx8MHx8fDA%3D',
                            'https://images.unsplash.com/photo-1552055568-f8c4fb8c6320?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8YXJ1Z2FtJTIwYmF5fGVufDB8fDB8fHww',
                            'https://images.unsplash.com/photo-1706257023817-851555857321?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8YmVudG90YXxlbnwwfHwwfHx8MA%3D%3D',
                            'https://images.unsplash.com/photo-1453210110568-1384e93a200e?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8d2VsaWdhbWF8ZW58MHx8MHx8fDA%3D',
                          ];
                          return _buildTripCard(
                            location: locations[index],
                            imageUrl: images[index],
                            spotsLeft: 5 - index,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'Popular Destinations',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Popular public trips (others only) ──
                    // SizedBox(
                    //   height: 260,
                    //   child: currentUserUid == null
                    //       ? const Center(
                    //           child: Text('Please log in to see trips'),
                    //         )
                    //       : StreamBuilder<DatabaseEvent>(
                    //           stream: FirebaseDatabase.instance
                    //               .ref('trips')
                    //               .orderByChild('isPublic')
                    //               .equalTo(true)
                    //               .onValue,
                    //           builder: (context, snapshot) {
                    //             if (snapshot.hasError) {
                    //               return Center(
                    //                 child: Text(
                    //                   'Something went wrong: ${snapshot.error}',
                    //                 ),
                    //               );
                    //             }

                    //             if (snapshot.connectionState ==
                    //                 ConnectionState.waiting) {
                    //               return const Center(
                    //                 child: CircularProgressIndicator(),
                    //               );
                    //             }

                    //             final event = snapshot.data;
                    //             if (event == null ||
                    //                 event.snapshot.value == null) {
                    //               return const Center(
                    //                 child: Text('No public trips found'),
                    //               );
                    //             }

                    //             final data =
                    //                 event.snapshot.value
                    //                     as Map<dynamic, dynamic>;

                    //             final List<Map<String, dynamic>> popularTrips =
                    //                 [];

                    //             data.forEach((key, value) {
                    //               if (value is! Map<dynamic, dynamic>) return;

                    //               final trip = value;
                    //               final createdBy =
                    //                   trip['createdBy'] as String?;
                    //               final isPublic =
                    //                   trip['isPublic'] as bool? ?? false;

                    //               if (!isPublic)
                    //                 return; // defense (query should already filter)

                    //               if (createdBy != null &&
                    //                   createdBy != currentUserUid) {
                    //                 popularTrips.add({
                    //                   'key': key as String,
                    //                   'title':
                    //                       (trip['title'] ??
                    //                               trip['location'] ??
                    //                               'Trip')
                    //                           as String,
                    //                   'organizer':
                    //                       (trip['organizer'] ??
                    //                               'Unknown Organizer')
                    //                           as String,
                    //                   'imageUrl':
                    //                       (trip['imageUrl'] ?? '') as String,
                    //                   'tags':
                    //                       (trip['tags'] as List<dynamic>?)
                    //                           ?.map((e) => e.toString())
                    //                           .toList() ??
                    //                       <String>[],
                    //                 });
                    //               }
                    //             });

                    //             if (popularTrips.isEmpty) {
                    //               return const Center(
                    //                 child: Text('No popular destinations yet'),
                    //               );
                    //             }

                    //             return ListView.builder(
                    //               scrollDirection: Axis.horizontal,
                    //               itemCount: popularTrips.length,
                    //               itemBuilder: (context, index) {
                    //                 final trip = popularTrips[index];
                    //                 return _buildPopularDestinationCard(
                    //                   title: trip['title'],
                    //                   organizer: trip['organizer'],
                    //                   imageUrl: trip['imageUrl'],
                    //                   tags: trip['tags'],
                    //                 );
                    //               },
                    //             );
                    //           },
                    //         ),
                    // ),
                    SizedBox(
                      height: 260,
                      child: currentUserUid == null
                          ? const Center(
                              child: Text('Please log in to see trips'),
                            )
                          : StreamBuilder<DatabaseEvent>(
                              stream: FirebaseDatabase.instance
                                  .ref('trips')
                                  .onValue, // ← removed the orderByChild + equalTo filter
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text('Error: ${snapshot.error}'),
                                  );
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                final event = snapshot.data;
                                if (event == null ||
                                    event.snapshot.value == null) {
                                  return const Center(
                                    child: Text('No trips found'),
                                  );
                                }

                                final data =
                                    event.snapshot.value
                                        as Map<dynamic, dynamic>;

                                final List<Map<String, dynamic>> allTrips = [];
                                data.forEach((key, value) {
                                  if (value is! Map<dynamic, dynamic>) return;

                                  final trip = value;
                                  final createdBy =
                                      trip['createdBy'] as String?;
                                  final title =
                                      (trip['title'] ??
                                              trip['location'] ??
                                              'Untitled Trip')
                                          as String;
                                  final organizer =
                                      (trip['organizer'] ?? 'Unknown Organizer')
                                          as String;
                                  final imageUrl =
                                      (trip['imageUrl'] ?? '') as String;
                                  final tags =
                                      (trip['tags'] as List<dynamic>?)
                                          ?.map((e) => e.toString())
                                          .toList() ??
                                      <String>[];

                                  allTrips.add({
                                    'key': key as String,
                                    'title': title,
                                    'organizer': organizer,
                                    'imageUrl': imageUrl,
                                    'tags': tags,
                                    // Optional: add these if you want to show them later
                                    'isPublic':
                                        trip['isPublic'] as bool? ?? false,
                                    'createdBy': createdBy,
                                  });
                                });

                                if (allTrips.isEmpty) {
                                  return const Center(
                                    child: Text('No trips yet'),
                                  );
                                }

                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: allTrips.length,
                                  itemBuilder: (context, index) {
                                    final trip = allTrips[index];
                                    return _buildPopularDestinationCard(
                                      title: trip['title'],
                                      organizer: trip['organizer'],
                                      imageUrl: trip['imageUrl'],
                                      tags: trip['tags'],
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.teal[800],
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'My Trips'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Browse'),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Gallery',
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  Helper methods (mostly unchanged, just minor consistency fixes)
  // ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(color: Colors.teal[800]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
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
                    'Find your perfect travel companion',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              Row(
                children: [
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '5',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.person, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal[800],
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildTripCard({
    required String location,
    required String imageUrl,
    required int spotsLeft,
  }) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(imageUrl, fit: BoxFit.cover),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$spotsLeft spots left',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularDestinationCard({
    required String title,
    required String organizer,
    required String imageUrl,
    required List<String> tags,
  }) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 80),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 80),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    organizer,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: tags.map((tag) {
                      return Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.teal.shade100,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
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
