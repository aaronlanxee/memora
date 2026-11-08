
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:memora/screens/register_object.dart';
import 'package:memora/theme.dart';
import 'package:memora/api_service.dart';

class RegisteredObjectsScreen extends StatefulWidget {
  const RegisteredObjectsScreen({super.key});

  @override
  State<RegisteredObjectsScreen> createState() =>
      _RegisteredObjectsScreenState();
}

class _RegisteredObjectsScreenState extends State<RegisteredObjectsScreen> {
  List<dynamic> _registeredObjects = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRegisteredObjects();
  }

  Future<void> _fetchRegisteredObjects() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.dio.get(
        '/api/get_registered_objects/',
      );

      final data = response.data;

      if (data is! Map || data['registered_objects'] is! List) {
        throw Exception('Invalid response format from server.');
      }

      if (!mounted) return;

      setState(() {
        _registeredObjects = data['registered_objects'] as List<dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching registered objects: $e');

      if (!mounted) return;

      setState(() {
        _errorMessage = 'Failed to load registered objects.';
        _isLoading = false;
      });
    }
  }

  // Decode the Base64 image returned by Django.
  Widget _buildObjectImage(dynamic imageBase64) {
    if (imageBase64 == null ||
        imageBase64 is! String ||
        imageBase64.isEmpty) {
      return _buildImagePlaceholder();
    }

    try {
      String base64String = imageBase64;

      // Support data URI format as well as plain Base64.
      if (base64String.startsWith('data:') &&
          base64String.contains(',')) {
        base64String = base64String.split(',').last;
      }

      final imageBytes = base64Decode(base64String);

      return Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder();
        },
      );
    } catch (e) {
      debugPrint('Error decoding object image: $e');
      return _buildImagePlaceholder();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: const Text(
          'Registered Objects',
          style: TextStyle(
            color: darkNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: white,
        foregroundColor: darkNavy,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _fetchRegisteredObjects,
            tooltip: 'Refresh',
            icon: const Icon(
              Icons.refresh,
              color: darkNavy,
            ),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RegisterObjectScreen(),
            ),
          );

          if (result == true) {
            _fetchRegisteredObjects();
          }
        },
        backgroundColor: pastelYellow,
        child: const Icon(
          Icons.add,
          color: darkNavy,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: indigoPurple,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 56,
                color: indigoPurple,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: darkNavy,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchRegisteredObjects,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_registeredObjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 72,
              color: indigoPurple,
            ),
            const SizedBox(height: 16),
            const Text(
              'No objects registered yet',
              style: TextStyle(
                fontSize: 20,
                color: darkNavy,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap + to register your first object.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchRegisteredObjects,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchRegisteredObjects,
      color: darkNavy,
      backgroundColor: pastelYellow,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.78,
        ),
        itemCount: _registeredObjects.length,
        itemBuilder: (context, index) {
          final object = _registeredObjects[index];

          final String name =
          (object['name'] ?? 'Unnamed Object').toString();

          final dynamic imageBase64 = object['image'];

          return Card(
            color: white,
            elevation: 3,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildObjectImage(imageBase64),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: darkNavy,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      width: double.infinity,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        size: 64,
        color: Colors.grey,
      ),
    );
  }
}
