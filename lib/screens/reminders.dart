import 'package:flutter/material.dart';
import 'package:memora/theme.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reminders"),
        centerTitle: true,
        backgroundColor: white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Reminders",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: white,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildReminderCard(
                    "Take medication",
                    "Today at 9:00 AM",
                    Icons.medical_services,
                    pastelYellow,
                  ),
                  _buildReminderCard(
                    "Doctor\'s appointment",
                    "Tomorrow at 2:30 PM",
                    Icons.local_hospital,
                    pastelYellow,
                  ),
                  _buildReminderCard(
                    "Buy groceries",
                    "Friday at 5:00 PM",
                    Icons.shopping_cart,
                    pastelYellow,
                  ),
                ],
              ),
            ),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Add new reminder functionality
                },
                icon: const Icon(Icons.add),
                label: const Text("Add New Reminder"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pastelYellow,
                  foregroundColor: darkNavy,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard(String title, String time, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: indigoPurple,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: white),
        ),
        subtitle: Text(time, style: TextStyle(color: white)),
        trailing: const Icon(Icons.chevron_right, color: white),
      ),
    );
  }
}
