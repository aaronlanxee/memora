import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../api_service.dart';
import 'package:memora/theme.dart';

class AskScreen extends StatefulWidget {
  const AskScreen({super.key});

  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;

  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    if (!mounted) return;

    try {
      final response =
      await ApiService.dio.get('/api/message_list/');

      if (response.statusCode == 200) {
        final data = response.data;
        final dynamic messageData =
        data is Map ? data['messages'] : null;

        if (messageData is! List) {
          _showError('Invalid message format received.');
          return;
        }

        final loadedMessages = <Map<String, dynamic>>[];

        for (final msg in messageData) {
          if (msg is Map) {
            loadedMessages.add({
              'id': msg['id'] ?? '',
              'content': msg['content']?.toString() ?? '',
              'is_ai': msg['is_ai'] == true,
              'created_at': msg['created_at'] ?? '',
            });
          }
        }

        if (!mounted) return;

        setState(() {
          _messages
            ..clear()
            ..addAll(loadedMessages);
        });

        _scrollToBottom();
      } else {
        _showError(
          'Failed to load messages: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _showError('Error loading messages: ${e.message}');
    } catch (e) {
      _showError('Error: $e');
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();

    if (text.isEmpty || _isLoading) return;

    setState(() {
      _isLoading = true;
      _controller.clear();
    });

    try {
      final response = await ApiService.dio.post(
        '/api/user_prompt/',
        data: {'query': text},
      );

      if (response.statusCode == 200) {
        await _fetchMessages();
        _scrollToBottom();
      } else {
        _showError(
          'Failed to send message: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _showError('Error sending message: ${e.message}');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !_scrollController.hasClients) return;

      // Wait for the message list to finish laying out.
      await WidgetsBinding.instance.endOfFrame;

      if (!mounted || !_scrollController.hasClients) return;

      try {
        final position = _scrollController.position;
        final bottom = position.maxScrollExtent;

        if ((position.pixels - bottom).abs() > 1) {
          await _scrollController.animateTo(
            bottom,
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
          );
        }

        // Recheck in case a long message changed the scroll extent.
        await WidgetsBinding.instance.endOfFrame;

        if (!mounted || !_scrollController.hasClients) return;

        final updatedPosition = _scrollController.position;
        final updatedBottom = updatedPosition.maxScrollExtent;

        if ((updatedPosition.pixels - updatedBottom).abs() > 2) {
          await _scrollController.animateTo(
            updatedBottom,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      } catch (e) {
        debugPrint('Scroll error: $e');
      }
    });
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask Anything'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty && _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: indigoPurple,
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                vertical: 8,
              ),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final bool isAI = message['is_ai'] == true;

                return Align(
                  alignment: isAI
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth:
                      MediaQuery.of(context).size.width *
                          0.8,
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isAI
                          ? pastelYellow.withOpacity(0.2)
                          : indigoPurple.withOpacity(0.2),
                      border: Border.all(
                        color: darkNavy,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(
                          isAI ? 0 : 12,
                        ),
                        bottomRight: Radius.circular(
                          isAI ? 12 : 0,
                        ),
                      ),
                    ),
                    child: Text(
                      message['content']?.toString() ?? '',
                      style: const TextStyle(
                        color: darkNavy,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_isLoading,
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: darkNavy,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: darkNavy,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: darkNavy,
                          ),
                        ),
                        contentPadding:
                        const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkNavy,
                      foregroundColor: white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: white,
                      ),
                    )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}