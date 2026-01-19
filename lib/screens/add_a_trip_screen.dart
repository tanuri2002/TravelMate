import 'package:flutter/material.dart';

class AddATripScreen extends StatelessWidget {
  const AddATripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Trip'),
        backgroundColor: Colors.teal[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add a Trip',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Create a new travel plan and invite companions.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Placeholder form fields
            TextField(
              decoration: InputDecoration(
                labelText: 'Trip Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Destination',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Start Date',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Save trip logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Trip created! (demo)')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Create Trip',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
