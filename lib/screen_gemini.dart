import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'caption_provider.dart';

class ScreenGemini extends StatefulWidget {
  const ScreenGemini({super.key});

  @override
  State<ScreenGemini> createState() => _ScreenGeminiState();
}

class _ScreenGeminiState extends State<ScreenGemini> {
  File? _image;
  final picker = ImagePicker();

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
      final provider = context.read<CaptionProvider>();
      provider.generate(_image!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CaptionProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Blog Image")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_image != null)
              Image.file(_image!, height: 200, fit: BoxFit.cover),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Pick Image"),
            ),
            const SizedBox(height: 16),
            if (provider.loading) const CircularProgressIndicator(),
            if (provider.caption != null) ...[
              Text(
                "Title: ${provider.caption!.title}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text("Description: ${provider.caption!.description}"),
            ],
          ],
        ),
      ),
    );
  }

}
