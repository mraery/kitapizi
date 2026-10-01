import 'package:flutter/material.dart';
import '../services/reading_service.dart';
import '../models/book.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  final ReadingService _service = ReadingService();

  void _showSetTargetDialog() {
    int target = _service.annualTarget;
    final controller = TextEditingController(text: target.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yıllık Okuma Hedefi'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Hedef Kitap Sayısı',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                _service.setAnnualTarget(val);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _service,
      builder: (context, _) {
        final completed = _service.completedBooksCount;
        final target = _service.annualTarget;
        final progress = (completed / target).clamp(0.0, 1.0);
        final percent = (progress * 100).toInt();
        final totalPages = _service.totalPagesRead;
        final completedBooks = _service.books.where((b) => b.status == ReadingStatus.completed).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF9F7F1),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF9F7F1),
            elevation: 0,
            foregroundColor: const Color(0xFF263238),
            title: const Row(
              children: [
                Icon(Icons.emoji_events_outlined, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text('Yıllık Okuma Hedefi', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Color(0xFF2E7D32)),
                tooltip: 'Hedefi Düzenle',
                onPressed: _showSetTargetDialog,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Circular Progress Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '2026 OKUMA MARATONU',
                        style: TextStyle(
                          letterSpacing: 1.5,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 12,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                '$completed / $target',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF263238),
                                ),
                              ),
                              Text(
                                '%$percent Tamamlandı',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn('Okunan Kitap', '$completed'),
                          Container(width: 1, height: 36, color: Colors.grey.shade200),
                          _buildStatColumn('Okunan Sayfa', '$totalPages'),
                          Container(width: 1, height: 36, color: Colors.grey.shade200),
                          _buildStatColumn('Kalan', '${(target - completed).clamp(0, target)}'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Completed Books Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tamamlanan Kitaplar (${completedBooks.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF263238),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                if (completedBooks.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Henüz bitirilen kitap bulunmuyor. Okumaya devam!',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: completedBooks.length,
                    itemBuilder: (context, index) {
                      final b = completedBooks[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
                          title: Text(
                            b.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(b.author, style: const TextStyle(fontSize: 12)),
                          trailing: Text(
                            '${b.totalPages} sf',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF263238),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
