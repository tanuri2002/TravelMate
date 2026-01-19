import 'package:flutter/material.dart';

class JoinTripScreen extends StatelessWidget {
  const JoinTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join a Trip'),
        backgroundColor: Colors.teal[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Join an Existing Trip',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Enter a trip code or search for open trips.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            TextField(
              decoration: InputDecoration(
                labelText: 'Trip Code / Invitation Link',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: const Icon(Icons.paste),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Or browse open trips:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Dummy list
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    leading: Icon(Icons.flight),
                    title: Text('Bali Group Adventure'),
                    subtitle: Text('Code: BALI2025 • 3 spots left'),
                  ),
                  ListTile(
                    leading: Icon(Icons.flight),
                    title: Text('Japan Cherry Blossom Tour'),
                    subtitle: Text('Code: SAKURA26 • 5 spots left'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Joined trip! (demo)')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Join Trip', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
