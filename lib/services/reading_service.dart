import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import '../models/quote.dart';

class ReadingService extends ChangeNotifier {
  static final ReadingService _instance = ReadingService._internal();
  factory ReadingService() => _instance;
  ReadingService._internal();

  List<Book> _books = [];
  List<BookQuote> _quotes = [];
  int _annualTarget = 24;

  List<Book> get books => _books;
  List<BookQuote> get quotes => _quotes;
  int get annualTarget => _annualTarget;

  int get completedBooksCount =>
      _books.where((b) => b.status == ReadingStatus.completed).length;

  int get currentlyReadingCount =>
      _books.where((b) => b.status == ReadingStatus.reading).length;

  int get totalPagesRead => _books.fold(0, (sum, b) => sum + b.currentPage);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final booksRaw = prefs.getStringList('kitapizi_books');
    if (booksRaw != null && booksRaw.isNotEmpty) {
      _books = booksRaw.map((s) => Book.fromJson(s)).toList();
    } else {
      _books = [
        Book(
          id: '1',
          title: 'Kürk Mantolu Madonna',
          author: 'Sabahattin Ali',
          totalPages: 160,
          currentPage: 94,
          status: ReadingStatus.reading,
          rating: 5,
          notes: 'Raif Efendi ve Maria Puder arasındaki derin ve melankolik bağ.',
          dateAdded: DateTime.now().subtract(const Duration(days: 10)),
        ),
        Book(
          id: '2',
          title: 'Küçük Prens',
          author: 'Antoine de Saint-Exupéry',
          totalPages: 112,
          currentPage: 112,
          status: ReadingStatus.completed,
          rating: 5,
          notes: 'Her yaşta yeniden okunması gereken bir başyapıt.',
          dateAdded: DateTime.now().subtract(const Duration(days: 30)),
          dateFinished: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Book(
          id: '3',
          title: 'Simyacı',
          author: 'Paulo Coelho',
          totalPages: 188,
          currentPage: 188,
          status: ReadingStatus.completed,
          rating: 4,
          notes: 'Kişisel menkıbesini arayan çoban Santiago’nun ilham verici yolculuğu.',
          dateAdded: DateTime.now().subtract(const Duration(days: 60)),
          dateFinished: DateTime.now().subtract(const Duration(days: 20)),
        ),
        Book(
          id: '4',
          title: 'Saatleri Ayarlama Enstitüsü',
          author: 'Ahmet Hamdi Tanpınar',
          totalPages: 382,
          currentPage: 0,
          status: ReadingStatus.wantToRead,
          rating: 0,
          notes: 'Doğu ile batı arasındaki bocalayan Türk modernleşmesi hicvi.',
          dateAdded: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
      _saveBooks();
    }

    final quotesRaw = prefs.getStringList('kitapizi_quotes');
    if (quotesRaw != null && quotesRaw.isNotEmpty) {
      _quotes = quotesRaw.map((s) => BookQuote.fromJson(s)).toList();
    } else {
      _quotes = [
        const BookQuote(
          id: 'q1',
          text: 'Gözler kördür, insan ancak yüreğiyle baktığı zaman gerçeği görebilir.',
          author: 'Antoine de Saint-Exupéry',
          bookTitle: 'Küçük Prens',
          pageNumber: 74,
          themeIndex: 0,
        ),
        const BookQuote(
          id: 'q2',
          text: 'Bir şeyi gerçekten istersen, bütün evren onu gerçekleştirmen için iş birliği yapar.',
          author: 'Paulo Coelho',
          bookTitle: 'Simyacı',
          pageNumber: 38,
          themeIndex: 1,
        ),
        const BookQuote(
          id: 'q3',
          text: 'İçimizde şeytan yok... İçimizde aciz var. Tembellik var. İradesizlik ve hakikatleri görmekten kaçmak var.',
          author: 'Sabahattin Ali',
          bookTitle: 'İçimizdeki Şeytan',
          pageNumber: 122,
          themeIndex: 2,
        ),
      ];
      _saveQuotes();
    }

    _annualTarget = prefs.getInt('kitapizi_annual_target') ?? 24;
    notifyListeners();
  }

  Future<void> addBook(Book book) async {
    _books.insert(0, book);
    notifyListeners();
    _saveBooks();
  }

  Future<void> updateBookProgress(String id, int newPage) async {
    final idx = _books.indexWhere((b) => b.id == id);
    if (idx != -1) {
      final b = _books[idx];
      b.currentPage = newPage.clamp(0, b.totalPages);
      if (b.currentPage >= b.totalPages) {
        b.status = ReadingStatus.completed;
        b.dateFinished = DateTime.now();
      } else if (b.currentPage > 0 && b.status == ReadingStatus.wantToRead) {
        b.status = ReadingStatus.reading;
      }
      notifyListeners();
      _saveBooks();
    }
  }

  Future<void> updateBookStatus(String id, ReadingStatus status) async {
    final idx = _books.indexWhere((b) => b.id == id);
    if (idx != -1) {
      _books[idx].status = status;
      if (status == ReadingStatus.completed) {
        _books[idx].currentPage = _books[idx].totalPages;
        _books[idx].dateFinished = DateTime.now();
      }
      notifyListeners();
      _saveBooks();
    }
  }

  Future<void> deleteBook(String id) async {
    _books.removeWhere((b) => b.id == id);
    notifyListeners();
    _saveBooks();
  }

  Future<void> addQuote(BookQuote quote) async {
    _quotes.insert(0, quote);
    notifyListeners();
    _saveQuotes();
  }

  Future<void> deleteQuote(String id) async {
    _quotes.removeWhere((q) => q.id == id);
    notifyListeners();
    _saveQuotes();
  }

  Future<void> setAnnualTarget(int target) async {
    _annualTarget = target;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('kitapizi_annual_target', target);
  }

  Future<void> _saveBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _books.map((b) => b.toJson()).toList();
    await prefs.setStringList('kitapizi_books', raw);
  }

  Future<void> _saveQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _quotes.map((q) => q.toJson()).toList();
    await prefs.setStringList('kitapizi_quotes', raw);
  }
}
