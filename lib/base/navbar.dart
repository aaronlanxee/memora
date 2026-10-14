import 'dart:async';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';

import '../screens/speech.dart';
import '../screens/registered_objects.dart';
import '../screens/ask.dart';
import '../screens/reminders.dart';
import '../screens/caregiver_settings.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;
  bool _isHoldingMic = false; // Track if we're holding the mic (for speech recognition logic)
  bool _showMicEffect = false; // Track if we should show the mic effect (visual feedback)
  Timer? _effectTimer; // Timer to hide the effect after a delay
  Timer? _listenTimer; // Timer for delayed listen start on hold

  final GlobalKey<SpeechScreenState> _speechKey =
  GlobalKey<SpeechScreenState>();

  late final List<Widget> _pages = [
    const RegisteredObjectsScreen(), // Star icon - registered objects list
    const AskScreen(),        // S icon - find object
    SpeechScreen(key: _speechKey),   // Mic icon - speech screen (no autoStart)
    const RemindersScreen(),         // Notifications icon - reminders
    const CaregiverSettingsScreen(), // Settings icon - caregiver settings
  ];

  void _goToSpeech() {
    setState(() {
      _selectedIndex = 2; // Navigate to speech screen (index 2) when mic tapped
      _isHoldingMic = false; // Not holding when just tapping
    });
    // Trigger mic effect for tap (but DO NOT start recording)
    _triggerMicEffect();
  }

  void _holdToSpeak() async {
    setState(() {
      _selectedIndex = 2; // Navigate to speech screen when holding to speak
      _isHoldingMic = true; // Now we're holding (for speech recognition logic)
    });
    // Trigger mic effect for hold start
    _triggerMicEffect();
    // Start listening immediately for long press (with safety check)
    _listenTimer?.cancel();
    _listenTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted && _isHoldingMic) {
        _speechKey.currentState?.startListening();
      }
    });
  }

  void _stopSpeaking() {
    // Cancel any pending listen timer
    _listenTimer?.cancel();
    
    _speechKey.currentState?.stopListening();
    setState(() {
      _isHoldingMic = false; // No longer holding when released
    });
    // Note: We don't trigger an effect on release - only on press start
  }

  void _triggerMicEffect() {
    // Cancel any existing timer
    _effectTimer?.cancel();
    
    // Show the effect
    setState(() => _showMicEffect = true);
    
    // Hide the effect after 800ms
    _effectTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _showMicEffect = false);
      }
    });
  }

  @override
  void dispose() {
    _effectTimer?.cancel();
    _listenTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Memora"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.star, size: 28),
            label: "",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.question_mark_sharp, size: 28),
            label: "",
          ),

          // HOLD TO SPEAK - Show effects when mic icon is pressed (tap or hold start)
          BottomNavigationBarItem(
            icon: _showMicEffect
                ? AvatarGlow(
                    animate: true,
                    glowColor: Colors.blue,
                    glowRadiusFactor: 60,
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: const Icon(
                        Icons.mic,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: _goToSpeech,
                    onLongPress: _holdToSpeak,
                    onLongPressUp: _stopSpeaking,
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: const Icon(
                        Icons.mic,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
            label: "",
          ),

          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications, size: 28),
            label: "",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 28),
            label: "",
          ),
        ],
      ),
    );
  }
}
