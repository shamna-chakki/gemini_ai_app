import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'blog_caption.dart';
import 'gemini_service.dart';

class CaptionProvider extends ChangeNotifier{

  final GeminiService geminiService;

  CaptionProvider({required this.geminiService});

  BlogCaption? _caption;
  bool _loading = false;

  BlogCaption? get caption => _caption;
  bool get loading => _loading;

  Future<void> generate(File imageFile) async {
    _loading = true;
    notifyListeners();

    _caption = await geminiService.generateCaption(imageFile);
log('$_caption',name: 'Caption');
    _loading = false;
    notifyListeners();
  }

}