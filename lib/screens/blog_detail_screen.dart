import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gemini_ai_app/models/blog_model.dart';

class BlogDetailScreen extends StatelessWidget {
  final BlogModel blogModel;

  const BlogDetailScreen({super.key, required this.blogModel});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Calculate 30% of the screen height
    final desiredHeight = screenHeight * 0.4;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Top Image Section
            Stack(
              children: [
                if (blogModel.image != null)
                  Image.file(File(blogModel.image!.path)),
                if (blogModel.image == null)
                  Image.network(
                    'https://cdn.pixabay.com/photo/2015/09/05/07/28/writing-923882_1280.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: desiredHeight,
                  ),
                Container(
                  height: desiredHeight,
                  width: double.infinity,
                  alignment: Alignment.bottomLeft,
                  padding: EdgeInsetsGeometry.only(
                    bottom: 10,
                    left: 16,
                    right: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withAlpha(60)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                Positioned(
                  bottom: 10,
                  left: 16,
                  right: 16,
                  child: Text(
                    blogModel.title,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 8,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {
                      Navigator.maybePop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.keyboard_arrow_left,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            /// Blog Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                blogModel.description,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
