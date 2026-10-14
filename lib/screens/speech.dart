import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'result.dart';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({
    super.key,
    this.autoStart = false,
  });

  final bool autoStart;

  @override
  SpeechScreenState createState() => SpeechScreenState();
}

class SpeechScreenState extends State<SpeechScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Hold the mic button and speak...";
  double _confidence = 0;
  Timer? _silenceTimer;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    if (widget.autoStart) {
      Future.delayed(const Duration(milliseconds: 300), () {
        startListening();
      });
    }
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _speech.stop();
    super.dispose();
  }

  Future<void> startListening() async {
    if (_isListening) return;

    final available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _text = "Listening...";
      });

      await _speech.listen(
        onResult: (val) {
          setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating) _confidence = val.confidence;
          });
          if (_isListening) _startSilenceTimer();
        },
      );
    }
  }

  void _startSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(seconds: 1), _handleSilenceTimeout);
  }

  Future<void> _handleSilenceTimeout() async {
    await stopListening();
    await _sendQueryToAPI();
  }

  Future<void> stopListening() async {
    if (_isListening) {
      setState(() => _isListening = false);
      await _speech.stop();
    }
    _silenceTimer?.cancel();
  }

  Future<void> _sendQueryToAPI() async {
    final uri = Uri.parse('http://192.168.100.22:8000/api/find_object/');
    final body = jsonEncode({'query': _text.trim()});
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseText = data['response'] as String?;
        if (responseText != null && responseText.isNotEmpty) {
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ResultScreen(responseText: responseText)),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Server returned empty response')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Server error: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reach server: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Text(
                  _text,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isListening) {
            stopListening();
          } else {
            startListening();
          }
        },
        child: Icon(_isListening ? Icons.mic_none : Icons.mic),
      ),
    );
  }
}