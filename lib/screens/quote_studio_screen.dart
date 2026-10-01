import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/reading_service.dart';
import 'add_quote_dialog.dart';

class QuoteStudioScreen extends StatefulWidget {
  const QuoteStudioScreen({super.key});

  @override
  State<QuoteStudioScreen> createState() => _QuoteStudioScreenState();
}

class _QuoteStudioScreenState extends State<QuoteStudioScreen> {
  final ReadingService _service = ReadingService();

  final List<List<Color>> _cardThemes = const [
    [Color(0xFF0D1B2A), Color(0xFF1B263B)], // Midnight Blue
    [Color(0xFF3E2723), Color(0xFF4E342E)], // Vintage Sepia
    [Color(0xFF004D40), Color(0xFF00796B)], // Emerald Jade
    [Color(0xFF311B92), Color(0xFF512DA8)], // Twilight Amethyst
    [Color(0xFF880E4F), Color(0xFFAD1457)], // Crimson Sunset
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _service,
      builder: (context, _) {
        final quotes = _service.quotes;

        return Scaffold(
          backgroundColor: const Color(0xFFF9F7F1),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF9F7F1),
            elevation: 0,
            foregroundColor: const Color(0xFF263238),
            title: const Row(
              children: [
                Icon(Icons.format_quote, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text('Alıntı Stüdyosu', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const AddQuoteDialog(),
              );
            },
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Alıntı Ekle'),
          ),
          body: quotes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.format_quote, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'Henüz alıntı eklenmedi',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Okuduğunuz kitaplardan beğendiğiniz cümleleri ölümsüzleştirin.',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  itemCount: quotes.length,
                  itemBuilder: (context, index) {
                    final q = quotes[index];
                    final themeColors = _cardThemes[q.themeIndex % _cardThemes.length];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: themeColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: themeColors[0].withValues(alpha: 0.35),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.format_quote,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  size: 32,
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.copy, color: Colors.white70, size: 20),
                                      tooltip: 'Alıntıyı Kopyala',
                                      onPressed: () {
                                        final copyText = '“${q.text}”\n— ${q.author}, ${q.bookTitle}';
                                        Clipboard.setData(ClipboardData(text: copyText));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('📋 Alıntı panoya kopyalandı!'),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: Color(0xFF2E7D32),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.white54, size: 20),
                                      onPressed: () {
                                        _service.deleteQuote(q.id);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '“${q.text}”',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 24,
                                  color: Colors.amberAccent,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        q.author,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        q.pageNumber > 0 ? '${q.bookTitle} (sf. ${q.pageNumber})' : q.bookTitle,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.75),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
