
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';

import '../screens/speech.dart';
import '../screens/registered_objects.dart';
import '../screens/ask.dart';
import '../screens/reminders.dart';
import '../screens/caregiver_settings.dart';
import '../theme.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;
  bool _isHoldingMic = false;
  bool _showMicEffect = false;

  Timer? _effectTimer;
  Timer? _listenTimer;

  final GlobalKey<SpeechScreenState> _speechKey =
  GlobalKey<SpeechScreenState>();

  late final List<Widget> _pages = [
    const RegisteredObjectsScreen(),
    const AskScreen(),
    SpeechScreen(key: _speechKey),
    const RemindersScreen(),
    const CaregiverSettingsScreen(),
  ];

  void _goToSpeech() {
    setState(() {
      _selectedIndex = 2;
      _isHoldingMic = false;
    });

    _triggerMicEffect();
  }

  void _holdToSpeak() {
    setState(() {
      _selectedIndex = 2;
      _isHoldingMic = true;
    });

    _triggerMicEffect();

    _listenTimer?.cancel();
    _listenTimer = Timer(
      const Duration(milliseconds: 100),
          () {
        if (mounted && _isHoldingMic) {
          _speechKey.currentState?.startListening();
        }
      },
    );
  }

  void _stopSpeaking() {
    _listenTimer?.cancel();
    _speechKey.currentState?.stopListening();

    if (mounted) {
      setState(() {
        _isHoldingMic = false;
      });
    }
  }

  void _triggerMicEffect() {
    _effectTimer?.cancel();

    setState(() {
      _showMicEffect = true;
    });

    _effectTimer = Timer(
      const Duration(milliseconds: 800),
          () {
        if (mounted) {
          setState(() {
            _showMicEffect = false;
          });
        }
      },
    );
  }

  // Larger circular background for the selected icon.
  // Icon color remains white for every navigation item.
  Widget _buildNavItem(IconData icon, int index) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isSelected ? 46 : 38,
          height: isSelected ? 46 : 38,
          decoration: BoxDecoration(
            color: isSelected
                ? darkNavy
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 24,
            color: white,
          ),
        ),
      ),
    );
  }

  // Microphone button with glow effect.
  Widget _buildMicItem() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _goToSpeech,
      onLongPress: _holdToSpeak,
      onLongPressUp: _stopSpeaking,
      child: SizedBox(
        width: 60,
        height: 60,
        child: Center(
          child: _showMicEffect
              ? AvatarGlow(
            animate: true,
            glowColor: pastelYellow,
            glowRadiusFactor: 4.5,
            duration: const Duration(milliseconds: 800),
            child: _buildMicButton(),
          )
              : _buildMicButton(),
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: pastelYellow,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.mic_none_outlined,
        size: 38,
        color: darkNavy,
      ),
    );
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
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 4,
          ),
          decoration: const BoxDecoration(
            color: indigoPurple,
            borderRadius: BorderRadius.zero,
          ),
          child: SizedBox(
            height: 55,
            child: Row(
              children: [
                Expanded(
                  child: _buildNavItem(
                    Icons.star_outline_rounded,
                    0,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    Icons.question_mark_outlined,
                    1,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _buildMicItem(),
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    Icons.notifications_active_outlined,
                    3,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    Icons.settings_outlined,
                    4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
