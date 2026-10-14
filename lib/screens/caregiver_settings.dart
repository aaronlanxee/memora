import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

class CaregiverSettingsScreen extends StatefulWidget {
  const CaregiverSettingsScreen({super.key});

  @override
  State<CaregiverSettingsScreen> createState() => _CaregiverSettingsScreenState();
}

class _CaregiverSettingsScreenState extends State<CaregiverSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationSharing = false;
  bool _emergencyAlerts = true;
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
    final uri = Uri.parse('http://192.168.100.22:8000/api/logout/');
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] as String?;

        if (message == 'Logout successful') {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Logout failed: $message')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to connect to server: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            "Caregiver Preferences",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text("Enable Notifications"),
            subtitle: const Text("Receive alerts and updates"),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            secondary: const Icon(Icons.notifications),
          ),
          SwitchListTile(
            title: const Text("Location Sharing"),
            subtitle: const Text("Share location with trusted contacts"),
            value: _locationSharing,
            onChanged: (bool value) {
              setState(() {
                _locationSharing = value;
              });
            },
            secondary: const Icon(Icons.location_on),
          ),
          SwitchListTile(
            title: const Text("Emergency Alerts"),
            subtitle: const Text("Send automatic alerts in emergencies"),
            value: _emergencyAlerts,
            onChanged: (bool value) {
              setState(() {
                _emergencyAlerts = value;
              });
            },
            secondary: const Icon(Icons.warning_amber_rounded),
          ),
          const Divider(height: 40),
          const Text(
            "Account Information",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Caregiver Profile"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to profile screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text("Privacy & Security"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to privacy settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Sign Out"),
            trailing: const Icon(Icons.chevron_right),
            onTap: _isLoggingOut ? null : () => _logout(),
          ),
        ],
      ),
    );
  }
}
