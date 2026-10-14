import 'package:flutter/material.dart';

class RegisteresObjectsScreen extends StatelessWidget {
  const RegisteresObjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registered Objects'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Registered Objects Screen',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
