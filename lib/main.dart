import 'package:flutter/material.dart';
import 'package:gemini_ai_app/env.dart';
import 'package:gemini_ai_app/providers/blog_provider.dart';
import 'package:gemini_ai_app/screens/add_blog_screen.dart';
import 'package:provider/provider.dart';

import 'services/gemini_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const apiKey = Env.apiKey;
    final geminiService = GeminiService(apiKey);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),

      home: ChangeNotifierProvider(create: (context) => BlogProvider(geminiService:geminiService ),child: AddBlogScreen()),
    );
  }
}


