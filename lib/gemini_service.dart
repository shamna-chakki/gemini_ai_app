import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'blog_caption.dart';
import 'env.dart';


class GeminiService {
  final GenerativeModel _model;

  GeminiService(String apiKey)
      : _model = GenerativeModel(
    model: Env.model, // or latest available model
    apiKey: Env.apiKey,
  );

  Future<BlogCaption?> generateCaption(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();

      final prompt = TextPart(
        'Return only JSON like {"title":"...", "description":"..."}.\n'
            'Generate a catchy blog title (<=8 words) and a short description.',
      );

      final imagePart = DataPart('image/jpeg', bytes);
      // _model = GenerativeModel(
      //    model: Env.model,
      //     apiKey: Env.apiKey,);

      final response =
      await _model.generateContent([Content.multi([prompt, imagePart])]);

      final text = response.text ?? '';
      final match = RegExp(r'\{[\s\S]*\}').firstMatch(text);
      if (match == null) return null;

      final jsonMap = json.decode(match.group(0)!);
      return BlogCaption.fromJson(jsonMap);
    } catch (e) {
      print('Error generating caption: $e');
      return null;
    }
  }
}