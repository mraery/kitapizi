import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/reading_service.dart';
import 'add_book_dialog.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final ReadingService _service = ReadingService();
  ReadingStatus? _filterStatus = ReadingStatus.reading;

  void _showProgressDialog(Book book) {
    int newPage = book.currentPage;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(book.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sayfa: $newPage / ${book.totalPages}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Slider(
                  value: newPage.toDouble(),
                  min: 0,
                  max: book.totalPages.toDouble(),
                  divisions: book.totalPages,
                  activeColor: const Color(0xFF2E7D32),
                  onChanged: (val) {
                    setDialogState(() {
                      newPage = val.round();
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        setDialogState(() {
                          newPage = (newPage - 10).clamp(0, book.totalPages);
                        });
                      },
                      child: const Text('-10'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        setDialogState(() {
                          newPage = (newPage + 10).clamp(0, book.totalPages);
                        });
                      },
                      child: const Text('+10'),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('İptal'),
              ),
              FilledButton(
                onPressed: () {
                  _service.updateBookProgress(book.id, newPage);
                  Navigator.pop(ctx);
                },
                child: const Text('Kaydet'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _service,
      builder: (context, _) {
        List<Book> books = _service.books;
        if (_filterStatus != null) {
          books = books.where((b) => b.status == _filterStatus).toList();
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF9F7F1),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF9F7F1),
            elevation: 0,
            foregroundColor: const Color(0xFF263238),
            title: const Row(
              children: [
                Icon(Icons.auto_stories, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text('Kitapİzi', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFF2E7D32), size: 28),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const AddBookDialog(),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Şu An Okuduklarım', ReadingStatus.reading),
                      const SizedBox(width: 8),
                      _buildFilterChip('Bitenler', ReadingStatus.completed),
                      const SizedBox(width: 8),
                      _buildFilterChip('Okunacaklar', ReadingStatus.wantToRead),
                      const SizedBox(width: 8),
                      _buildFilterChip('Tüm Kitaplık', null),
                    ],
                  ),
                ),
              ),

              // Book List
              Expanded(
                child: books.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu_book, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              _filterStatus == ReadingStatus.reading
                                  ? 'Şu anda okuduğunuz bir kitap bulunmuyor.'
                                  : 'Bu kategoride kitap bulunamadı.',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFF2E7D32),
                                              Colors.teal.shade700,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Center(
                                          child: Icon(Icons.menu_book, color: Colors.white, size: 28),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              book.title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF263238),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              book.author,
                                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: book.status == ReadingStatus.completed
                                                        ? const Color(0xFFE8F5E9)
                                                        : const Color(0xFFE0F2F1),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    book.status == ReadingStatus.completed
                                                        ? 'Bitti'
                                                        : (book.status == ReadingStatus.reading
                                                            ? 'Okunuyor'
                                                            : 'Okunacak'),
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: book.status == ReadingStatus.completed
                                                          ? const Color(0xFF2E7D32)
                                                          : const Color(0xFF00796B),
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  '${book.currentPage} / ${book.totalPages} sf (%${book.progressPercent})',
                                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Progress Bar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: book.progress,
                                      minHeight: 6,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => _showProgressDialog(book),
                                        icon: const Icon(Icons.bookmark_border, size: 16),
                                        label: const Text('Sayfayı Güncelle', style: TextStyle(fontSize: 12)),
                                        style: TextButton.styleFrom(
                                          foregroundColor: const Color(0xFF2E7D32),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                                        onSelected: (val) {
                                          if (val == 'reading') {
                                            _service.updateBookStatus(book.id, ReadingStatus.reading);
                                          } else if (val == 'completed') {
                                            _service.updateBookStatus(book.id, ReadingStatus.completed);
                                          } else if (val == 'delete') {
                                            _service.deleteBook(book.id);
                                          }
                                        },
                                        itemBuilder: (_) => [
                                          const PopupMenuItem(value: 'reading', child: Text('Okunuyor Yap')),
                                          const PopupMenuItem(value: 'completed', child: Text('Bitti Olarak İşaretle')),
                                          const PopupMenuItem(value: 'delete', child: Text('Kitaplıktan Sil', style: TextStyle(color: Colors.red))),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, ReadingStatus? status) {
    final isSelected = _filterStatus == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _filterStatus = status;
        });
      },
      selectedColor: const Color(0xFFC8E6C9),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF1B5E20) : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade300),
      ),
    );
  }
}
