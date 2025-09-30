import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/blog_model.dart';
import '../services/gemini_service.dart';

class BlogProvider extends ChangeNotifier {
  final GeminiService geminiService;

  BlogProvider({required this.geminiService});

  BlogModel? blogModel;
  bool _loading = false;

  BlogModel? get caption => blogModel;

  bool get loading => _loading;

  String? _error;

  String? get error => _error;

  Future<void> generate(File imageFile) async {
    _loading = true;
    notifyListeners();

    blogModel = await geminiService.generateCaption(imageFile);
    _loading = false;
    notifyListeners();
  }

  Future<BlogModel?> getBlog({BlogModel? blogModel}) async {
    try {
      _loading = true;
      notifyListeners();

      blogModel = await geminiService.generateBlog(blogModel: blogModel);
      log('${blogModel?.image?.path}', name: 'Image');
      if (blogModel == null) {
        _error = 'Failed to generate blog content';
        notifyListeners();
      }
      return blogModel;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
