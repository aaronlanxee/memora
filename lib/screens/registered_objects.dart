import 'package:flutter/material.dart';

class RegisteredObjectsScreen extends StatefulWidget {
  const RegisteredObjectsScreen({super.key});

  @override
  State<RegisteredObjectsScreen> createState() => _RegisteredObjectsScreenState();
}

class _RegisteredObjectsScreenState extends State<RegisteredObjectsScreen> {
  // Sample registered objects - in a real app, this would come from a database
  final List<String> _registeredObjects = [
    'Keys',
    'Wallet',
    'Phone',
    'Glasses',
    'Watch',
    'Backpack',
    'Water Bottle',
    'Medication Box'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registered Objects"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: _registeredObjects.isEmpty
          ? const Center(
              child: Text(
                "No objects registered yet",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _registeredObjects.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(_registeredObjects[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // TODO: Implement delete functionality
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add functionality to register new object
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
