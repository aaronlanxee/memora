
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memora/api_service.dart';
import 'package:memora/theme.dart';

class RegisterObjectScreen extends StatefulWidget {
  const RegisterObjectScreen({super.key});

  @override
  State<RegisterObjectScreen> createState() =>
      _RegisterObjectScreenState();
}

class _RegisterObjectScreenState extends State<RegisterObjectScreen> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Capture an image using the camera.
  Future<void> _captureImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (image != null && mounted) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showMessage('Unable to open camera: $e');
    }
  }

  // Select an existing image from the gallery.
  Future<void> _uploadImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (image != null && mounted) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showMessage('Unable to select image: $e');
    }
  }

  // Display camera and gallery options.
  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose an Image',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: darkNavy,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: darkNavy,
                    size: 30,
                  ),
                  title: const Text(
                    'Take a Photo',
                    style: TextStyle(
                      fontSize: 18,
                      color: darkNavy,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _captureImage();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: darkNavy,
                    size: 30,
                  ),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      fontSize: 18,
                      color: darkNavy,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _uploadImage();
                  },
                ),
                if (_selectedImage != null)
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 30,
                    ),
                    title: const Text(
                      'Remove Image',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Submit the object to the Django backend.
  Future<void> _registerObject() async {
    final String name = _nameController.text.trim();

    if (name.isEmpty) {
      _showMessage('Please enter the object name.');
      return;
    }

    if (_selectedImage == null) {
      _showMessage('Please capture or upload an image.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final formData = FormData.fromMap({
        'name': name,
        'image': await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: _selectedImage!.path.split(Platform.pathSeparator).last,
        ),
      });

      final response = await ApiService.dio.post(
        '/api/register_object/',
        data: formData,
      );

      if (!mounted) return;

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        _showMessage('Object registered successfully!');

        _nameController.clear();

        setState(() {
          _selectedImage = null;
        });

        // Return to the previous screen after successful registration.
        Navigator.pop(context, true);
      } else {
        _showMessage('Failed to register object.');
      }
    } on DioException catch (e) {
      debugPrint('Registration error: ${e.response?.data ?? e.message}');

      if (!mounted) return;

      final responseData = e.response?.data;
      String message = 'Failed to register object. Please try again.';

      if (responseData is Map) {
        message = responseData['error']?.toString() ??
            responseData['detail']?.toString() ??
            message;
      }

      _showMessage(message);
    } catch (e) {
      if (!mounted) return;

      debugPrint('Unexpected registration error: $e');
      _showMessage('An unexpected error occurred.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: darkNavy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: const Text(
          'Register Object',
          style: TextStyle(
            color: darkNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: white,
        foregroundColor: darkNavy,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add a New Object',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: darkNavy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter the object name and add a clear photo '
                    'so Memora can help you find it.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // Image selection area.
              const Text(
                'Object Image',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkNavy,
                ),
              ),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: _showImageOptions,
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: indigoPurple,
                      width: 2,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _selectedImage != null
                      ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        _selectedImage!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image,
                            size: 60,
                            color: Colors.grey,
                          );
                        },
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: darkNavy,
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  )
                      : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        size: 70,
                        color: indigoPurple,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Add Object Photo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkNavy,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap to capture or upload an image',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Camera and gallery buttons.
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSubmitting ? null : _captureImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: darkNavy,
                        side: const BorderSide(color: indigoPurple),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSubmitting ? null : _uploadImage,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: darkNavy,
                        side: const BorderSide(color: indigoPurple),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Object name input.
              const Text(
                'Object Name',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkNavy,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                enabled: !_isSubmitting,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(
                  fontSize: 18,
                  color: darkNavy,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Keys, Wallet, Medicine',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(
                    Icons.label_outline,
                    color: indigoPurple,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: indigoPurple,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Register button.
              SizedBox(
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _registerObject,
                  icon: _isSubmitting
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: darkNavy,
                    ),
                  )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    _isSubmitting ? 'Registering...' : 'Register Object',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pastelYellow,
                    foregroundColor: darkNavy,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
