import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real implementation, navigation logic would evaluate auth state here.
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 80, color: Colors.deepPurple), // Placeholder Vaulted logo
            SizedBox(height: 24),
            Text('Vaulted', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 48),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
