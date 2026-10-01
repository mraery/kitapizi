import 'dart:convert';

class BookQuote {
  final String id;
  final String text;
  final String author;
  final String bookTitle;
  final int pageNumber;
  final int themeIndex; // 0 to 4 for card background styles

  const BookQuote({
    required this.id,
    required this.text,
    required this.author,
    required this.bookTitle,
    this.pageNumber = 0,
    this.themeIndex = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'bookTitle': bookTitle,
      'pageNumber': pageNumber,
      'themeIndex': themeIndex,
    };
  }

  factory BookQuote.fromMap(Map<String, dynamic> map) {
    return BookQuote(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      author: map['author'] ?? '',
      bookTitle: map['bookTitle'] ?? '',
      pageNumber: map['pageNumber'] ?? 0,
      themeIndex: map['themeIndex'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());
  factory BookQuote.fromJson(String source) => BookQuote.fromMap(json.decode(source));
}
