import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:memora/api_service.dart';
import 'package:memora/theme.dart';
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

    try {
      final response = await ApiService.dio.post(
        '/api/logout/',
        data: {},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final message = responseData['message'] as String?;

        if (message == 'Logged out successfully') {
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
              SnackBar(content: Text('Logout failed: \$message')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to connect to server: \${response.statusCode}')),
          );
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: \${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: \$e')),
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
        backgroundColor: white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            "Caregiver Preferences",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: white,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: darkNavy, width: 2.0),
              borderRadius: BorderRadius.circular(12.0),
            ),
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.all(8.0),
            child: SwitchListTile(
              title: const Text("Enable Notifications"),
              subtitle: const Text("Receive alerts and updates"),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              secondary: const Icon(Icons.notifications, color: darkNavy),
              activeColor: pastelYellow,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: darkNavy, width: 2.0),
              borderRadius: BorderRadius.circular(12.0),
            ),
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.all(8.0),
            child: SwitchListTile(
              title: const Text("Location Sharing"),
              subtitle: const Text("Share location with trusted contacts"),
              value: _locationSharing,
              onChanged: (bool value) {
                setState(() {
                  _locationSharing = value;
                });
              },
              secondary: const Icon(Icons.location_on, color: darkNavy),
              activeColor: pastelYellow,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: darkNavy, width: 2.0),
              borderRadius: BorderRadius.circular(12.0),
            ),
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.all(8.0),
            child: SwitchListTile(
              title: const Text("Emergency Alerts"),
              subtitle: const Text("Send automatic alerts in emergencies"),
              value: _emergencyAlerts,
              onChanged: (bool value) {
                setState(() {
                  _emergencyAlerts = value;
                });
              },
              secondary: const Icon(Icons.warning_amber_rounded, color: darkNavy),
              activeColor: pastelYellow,
            ),
          ),
          Divider(height: 40, color: white.withOpacity(0.2)),
          const Text(
            "Account Information",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: white,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: darkNavy, width: 2.0),
              borderRadius: BorderRadius.circular(12.0),
            ),
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.person, color: darkNavy),
              title: const Text("Caregiver Profile"),
              trailing: const Icon(Icons.chevron_right, color: darkNavy),
              onTap: () {
                // TODO: Navigate to profile screen
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: darkNavy, width: 2.0),
              borderRadius: BorderRadius.circular(12.0),
            ),
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.security, color: darkNavy),
              title: const Text("Privacy & Security"),
              trailing: const Icon(Icons.chevron_right, color: darkNavy),
              onTap: () {
                // TODO: Navigate to privacy settings
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: darkNavy, width: 2.0),
              borderRadius: BorderRadius.circular(12.0),
            ),
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.logout, color: darkNavy),
              title: const Text("Sign Out"),
              trailing: const Icon(Icons.chevron_right, color: darkNavy),
              onTap: _isLoggingOut ? null : () => _logout(),
            ),
          ),
        ],
      ),
    );
  }
}
