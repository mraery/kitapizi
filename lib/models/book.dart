import 'dart:convert';

enum ReadingStatus { reading, completed, wantToRead }

class Book {
  final String id;
  final String title;
  final String author;
  final int totalPages;
  int currentPage;
  ReadingStatus status;
  int rating; // 1 to 5
  String notes;
  final DateTime dateAdded;
  DateTime? dateFinished;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.totalPages,
    this.currentPage = 0,
    this.status = ReadingStatus.wantToRead,
    this.rating = 0,
    this.notes = '',
    required this.dateAdded,
    this.dateFinished,
  });

  double get progress => totalPages > 0 ? (currentPage / totalPages).clamp(0.0, 1.0) : 0.0;
  int get progressPercent => (progress * 100).toInt();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'status': status.name,
      'rating': rating,
      'notes': notes,
      'dateAdded': dateAdded.toIso8601String(),
      'dateFinished': dateFinished?.toIso8601String(),
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      totalPages: map['totalPages'] ?? 100,
      currentPage: map['currentPage'] ?? 0,
      status: ReadingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReadingStatus.wantToRead,
      ),
      rating: map['rating'] ?? 0,
      notes: map['notes'] ?? '',
      dateAdded: map['dateAdded'] != null ? DateTime.parse(map['dateAdded']) : DateTime.now(),
      dateFinished: map['dateFinished'] != null ? DateTime.parse(map['dateFinished']) : null,
    );
  }

  String toJson() => json.encode(toMap());
  factory Book.fromJson(String source) => Book.fromMap(json.decode(source));
}
