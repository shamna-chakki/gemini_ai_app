import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/blog_model.dart';
import '../env.dart';


class GeminiService {
  final GenerativeModel _model;// Declaring Generative artificial intelligence.
  GeminiService(String apiKey)
      : _model = GenerativeModel(
    model: Env.model, // or latest available model
    apiKey: Env.apiKey,
  );

  Future<BlogModel?> generateBlog({required BlogModel? blogModel}) async {
    try {
      final bytes = await blogModel?.image?.readAsBytes();

      if (bytes == null) {
        print('Error: No image data available');
        return null;
      }

      final prompt = TextPart(
        'Analyze this image and generate a blog post about it.\n\n'
            'Requirements:\n'
            '- Title: Create a catchy, engaging title that is at least 2 lines long regarding ${blogModel?.title}\n'
            '- Description: Write a detailed,regarding ${blogModel?.description} informative description of at least 100 words that discusses what you see in the image\n\n'
            'Return ONLY valid JSON in this exact format:\n'
            '{"title":"your multi-line title here", "description":"your detailed 1000+ word description here"}\n\n'
            'Do not include any markdown formatting, code blocks, or extra text. Just the raw JSON object.',
      );

      final imagePart = DataPart('image/jpeg', bytes);

      final response = await _model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      final text = response.text ?? '';
      print('Gemini Response: $text'); // Debug logging

      // Extract JSON from response (handles cases with markdown code blocks)
      String jsonString = text.trim();

      // Remove markdown code blocks if present
      if (jsonString.startsWith('```')) {
        final codeBlockRegex = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
        final match = codeBlockRegex.firstMatch(jsonString);
        if (match != null) {
          jsonString = match.group(1)!.trim();
        }
      }

      // Extract JSON object
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(jsonString);
      if (jsonMatch == null) {
        print('Error: No valid JSON found in response');
        return null;
      }

      final jsonMap = json.decode(jsonMatch.group(0)!);

      // Validate the response meets requirements
      final title = jsonMap['title'] ?? '';
      final description = jsonMap['description'] ?? '';

      if (title.split(' ').length < 10) {
        print('Warning: Title is shorter than recommended');
      }

      if (description.split(' ').length < 1000) {
        print('Warning: Description is shorter than 1000 words');
      }

      return BlogModel.fromJson({
        'title': title,
        'description': description,
        'image': blogModel?.image,
      });

    } catch (e) {
      print('Error generating caption: $e');
      return null;
    }
  }

  Future<BlogModel?> generateCaption(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();

      final prompt = TextPart(
        'Return only JSON like {"title":"...", "description":"..."}.\n'
            'Generate a catchy blog title (<=8 words) and a short description.',
      );

      final imagePart = DataPart('image/jpeg', bytes);


      final response =
      await _model.generateContent([Content.multi([prompt, imagePart])]);

      final text = response.text ?? '';
      final match = RegExp(r'\{[\s\S]*\}').firstMatch(text);
      if (match == null) return null;

      final jsonMap = json.decode(match.group(0)!);
      return BlogModel.fromJson(jsonMap);
    } catch (e) {
      print('Error generating caption: $e');
      return null;
    }
  }

}