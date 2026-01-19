import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/signup_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Welcome.png'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // App Title
              Text(
                'TravelMate',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  letterSpacing: 0,
                  shadows: [
                    Shadow(
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Tagline
              Text(
                'Capture. Share. Relive your journeys.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      offset: const Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              // Get Started Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  foregroundColor: Colors.black,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
