import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ResultScreen extends StatefulWidget {
  final String responseText;

  const ResultScreen({
    super.key,
    required this.responseText,
  });

  @override
  ResultScreenState createState() => ResultScreenState();
}

class ResultScreenState extends State<ResultScreen> {
  FlutterTts? _flutterTts;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    // Optional configuration:
    // await _flutterTts!.setLanguage("en-US");
    // await _flutterTts!.setVolume(1.0);
  }

  @override
  void dispose() {
    _flutterTts?.stop(); // Stop any ongoing speech
    super.dispose();
  }

  Future<void> _speak() async {
    if (_flutterTts != null) {
      await _flutterTts!.speak(widget.responseText);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Speak the text after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speak();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                widget.responseText,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  "Back",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}