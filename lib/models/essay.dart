class Essay {
  final String id;
  String title;
  String content;
  DateTime updatedAt;
  bool favorite;

  Essay({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
    this.favorite = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'updatedAt': updatedAt.toIso8601String(),
        'favorite': favorite,
      };

  factory Essay.fromJson(Map<String, dynamic> json) => Essay(
        id: json['id'] as String,
        title: json['title'] as String? ?? 'Untitled essay',
        content: json['content'] as String? ?? '',
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
            DateTime.now(),
        favorite: json['favorite'] as bool? ?? false,
      );
}
