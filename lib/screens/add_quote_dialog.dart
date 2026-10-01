import 'package:flutter/material.dart';
import '../models/quote.dart';
import '../services/reading_service.dart';

class AddQuoteDialog extends StatefulWidget {
  const AddQuoteDialog({super.key});

  @override
  State<AddQuoteDialog> createState() => _AddQuoteDialogState();
}

class _AddQuoteDialogState extends State<AddQuoteDialog> {
  final _quoteController = TextEditingController();
  final _authorController = TextEditingController();
  final _bookTitleController = TextEditingController();
  final _pageController = TextEditingController();
  int _themeIndex = 0;

  final List<Color> _themeColorDots = const [
    Color(0xFF0D1B2A),
    Color(0xFF3E2723),
    Color(0xFF004D40),
    Color(0xFF311B92),
    Color(0xFF880E4F),
  ];

  @override
  void dispose() {
    _quoteController.dispose();
    _authorController.dispose();
    _bookTitleController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _save() {
    final text = _quoteController.text.trim();
    if (text.isEmpty) return;

    final quote = BookQuote(
      id: 'quote_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      author: _authorController.text.trim().isEmpty ? 'Bilinmeyen' : _authorController.text.trim(),
      bookTitle: _bookTitleController.text.trim().isEmpty ? 'Kitap' : _bookTitleController.text.trim(),
      pageNumber: int.tryParse(_pageController.text) ?? 0,
      themeIndex: _themeIndex,
    );

    ReadingService().addQuote(quote);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✨ Alıntı stüdyoya eklendi!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Yeni Alıntı Kartı',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _quoteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Alıntı Cümlesi *',
                hintText: '“Gözler kördür...”',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _authorController,
                    decoration: const InputDecoration(labelText: 'Yazar', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _bookTitleController,
                    decoration: const InputDecoration(labelText: 'Kitap Adı', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Sayfa Numarası (Opsiyonel)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Text('Kart Teması Seçin', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(_themeColorDots.length, (idx) {
                final isSelected = _themeIndex == idx;
                return GestureDetector(
                  onTap: () => setState(() => _themeIndex = idx),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _themeColorDots[idx],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.amber : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
                child: const Text('Alıntıyı Kaydet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
