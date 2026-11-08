import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:memora/api_service.dart';
import 'package:memora/theme.dart';

import 'result.dart';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({
    super.key,
    this.autoStart = false,
  });

  final bool autoStart;

  @override
  State<SpeechScreen> createState() => SpeechScreenState();
}

class SpeechScreenState extends State<SpeechScreen> {
  late final stt.SpeechToText _speech;

  bool _isListening = false;
  bool _isSending = false;
  bool _hasSubmitted = false;

  String _text = 'Press the microphone and speak.';
  String _recognizedText = '';

  Timer? _silenceTimer;

  @override
  void initState() {
    super.initState();

    _speech = stt.SpeechToText();

    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) startListening();
      });
    }
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _speech.cancel();
    super.dispose();
  }

  Future<void> startListening() async {
    if (_isListening || _isSending) return;

    _silenceTimer?.cancel();
    _recognizedText = '';
    _hasSubmitted = false;

    setState(() {
      _isListening = false;
      _text = 'Starting microphone...';
    });

    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Speech status: $status');
        },
        onError: (error) {
          debugPrint('Speech error: $error');

          if (!mounted) return;

          _silenceTimer?.cancel();

          setState(() {
            _isListening = false;
            if (_recognizedText.isEmpty) {
              _text = 'Could not recognize speech. Please try again.';
            }
          });
        },
      );

      if (!mounted) return;

      if (!available) {
        setState(() {
          _text = 'Speech recognition is unavailable.';
        });
        return;
      }

      setState(() {
        _isListening = true;
        _text = 'Listening...';
      });

      await _speech.listen(
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 10),
        onResult: (result) {
          if (!mounted || _hasSubmitted) return;

          final words = result.recognizedWords.trim();

          debugPrint('Recognized speech: $words');

          setState(() {
            if (words.isNotEmpty) {
              _recognizedText = words;
              _text = words;
            } else if (_recognizedText.isEmpty) {
              _text = 'Listening...';
            }
          });

          if (words.isNotEmpty) {
            // Every new speech result resets the silence timer.
            _silenceTimer?.cancel();

            _silenceTimer = Timer(
              const Duration(seconds: 1),
              _finishRecording,
            );
          }
        },
      );
    } catch (e) {
      debugPrint('Failed to start listening: $e');

      if (mounted) {
        setState(() {
          _isListening = false;
          _text = 'Unable to start microphone.';
        });

        _showError('Microphone error: $e');
      }
    }
  }

  Future<void> _finishRecording() async {
    if (!_isListening || _hasSubmitted || _isSending) return;

    // Prevent the timer from submitting more than once.
    _hasSubmitted = true;
    _silenceTimer?.cancel();

    setState(() {
      _isListening = false;
      _text = 'Processing your speech...';
    });

    try {
      // Stop recognition first so the speech plugin can deliver
      // any final recognition result.
      await _speech.stop();

      // Allow the final recognition callback to update the text.
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      final query = _recognizedText.trim();

      debugPrint('Final query: $query');

      if (query.isEmpty) {
        setState(() {
          _text = 'No speech detected. Please try again.';
          _hasSubmitted = false;
        });
        return;
      }

      await _sendQueryToAPI(query);
    } catch (e) {
      debugPrint('Error finishing recording: $e');

      if (mounted) {
        setState(() {
          _text = 'Could not process your speech.';
          _hasSubmitted = false;
        });
      }
    }
  }

  Future<void> stopListening() async {
    _silenceTimer?.cancel();

    if (!_isListening) return;

    // Manual stop also submits the recognized speech.
    await _finishRecording();
  }

  Future<void> _sendQueryToAPI(String query) async {
    if (query.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
      _text = 'Sending your question...';
    });

    try {
      debugPrint('POST /api/user_prompt/');
      debugPrint('Query: $query');

      final response = await ApiService.dio.post(
        '/api/user_prompt/',
        data: {
          'query': query,
        },
      );

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.data}');

      if (!mounted) return;

      final data = response.data;

      if (response.statusCode != 200) {
        _showError('Server returned ${response.statusCode}.');
        return;
      }

      if (data is! Map) {
        _showError('Unexpected response format from the server.');
        return;
      }

      // These keys must match the JSON returned by your Django view.
      final responseText =
          data['response']?.toString() ??
              data['message']?.toString() ??
              '';

      if (responseText.trim().isEmpty) {
        _showError(
          'The API returned no answer. Check the Django response JSON.',
        );
        return;
      }

      // Open the result screen with the API answer.
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            responseText: responseText,
          ),
        ),
      );
    } on DioException catch (e) {
      debugPrint('Dio error: ${e.type}');
      debugPrint('Dio message: ${e.message}');
      debugPrint('Dio response: ${e.response?.data}');

      if (mounted) {
        _showError(
          e.response != null
              ? 'Server error ${e.response?.statusCode}: ${e.response?.data}'
              : 'Cannot connect to the server: ${e.message}',
        );
      }
    } catch (e) {
      debugPrint('Unexpected API error: $e');

      if (mounted) {
        _showError('Request failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mintBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 220,
                  height: 220,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: tealBorder,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    size: 80,
                    color: _isListening ? indigoPurple : darkNavy,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  _text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    color: darkNavy,
                  ),
                ),
                const SizedBox(height: 20),
                if (_isSending)
                  const CircularProgressIndicator(
                    color: indigoPurple,
                  ),
                const SizedBox(height: 20),
                if (!_isSending)
                  ElevatedButton.icon(
                    onPressed: _isListening
                        ? stopListening
                        : startListening,
                    icon: Icon(
                      _isListening ? Icons.stop : Icons.mic,
                    ),
                    label: Text(
                      _isListening ? 'Stop and send' : 'Start speaking',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pastelYellow,
                      foregroundColor: darkNavy,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
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