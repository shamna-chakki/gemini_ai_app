
import 'dart:io';


class BlogModel {
 final String title;
 final String description;
 final File? image;

 BlogModel({required this.title, required this.description, this.image});

 factory BlogModel.fromJson(Map<String, dynamic> json) {
  return BlogModel(
   title: json['title'] ?? 'Untitled',
   description: json['description'] ?? '',
   image: json['image'],
  );
 }
 Map<String, dynamic> toJson() {
  return {
   'title': title,
   'description': description,
   // Note: XFile is not serializable to JSON, handle separately
  };
 }

 // Helper to get word counts
 int get titleWordCount => title.split(' ').where((w) => w.isNotEmpty).length;
 int get descriptionWordCount => description.split(' ').where((w) => w.isNotEmpty).length;
}