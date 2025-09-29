
class BlogCaption {
 final String title;
 final String description;

 BlogCaption({required this.title, required this.description});

 factory BlogCaption.fromJson(Map<String, dynamic> json) {
  return BlogCaption(
   title: json['title'] ?? 'Untitled',
   description: json['description'] ?? '',
  );
 }

}