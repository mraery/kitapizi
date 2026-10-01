import 'dart:async';
import 'package:flutter/material.dart';

class Passage {
  final String title;
  final String author;
  final String text;

  const Passage({
    required this.title,
    required this.author,
    required this.text,
  });

  int get wordCount => text.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
}

class ReadingSpeedScreen extends StatefulWidget {
  const ReadingSpeedScreen({super.key});

  @override
  State<ReadingSpeedScreen> createState() => _ReadingSpeedScreenState();
}

class _ReadingSpeedScreenState extends State<ReadingSpeedScreen> {
  final List<Passage> _passages = const [
    Passage(
      title: 'Huzur ve Zaman',
      author: 'Ahmet Hamdi Tanpınar',
      text: 'Saat, insanın kendi hayatı ile kurduğu en hassas muvazenelerden biridir. '
          'Akıp giden zamanın içinde kendimizi bulmak, geçmişle gelecek arasında durup soluklanmak '
          'ancak içsel bir derinlikle mümkündür. Bir şehrin sokaklarında adımlarken hissettiğimiz '
          'o tarifsiz melankoli, aslında geçmiş zamanın taşlara, pencerelere ve insan yüzlerine '
          'sinmiş gölgesidir. İnsan kendi zamanını yaratmadıkça, başkalarının zamanında kaybolmaya mahkûmdur.',
    ),
    Passage(
      title: 'Son Kuşlar',
      author: 'Sait Faik Abasıyanık',
      text: 'Kuşları boğdular, çimenleri söktüler, yollar çamur içinde kaldı. Dünya yalnız bizim gibi '
          'iki ayaklılara kalırsa yaşanmaz olur. Kuşlar gökyüzünü bir neşe ve hürriyet çizgisiyle '
          'doldururken, bizler aşağıda kendi küçük hesaplarımızla boğuşuruz. Doğanın fısıltısını '
          'dinlemeyi unutan bir kalp, hiçbir şiirin sıcaklığını duyamaz. Ağaçların gölgesinde '
          'dinlenen martıların gözlerinde denizin sonsuzluğu vardır.',
    ),
    Passage(
      title: 'İçimizdeki Dünya',
      author: 'Sabahattin Ali',
      text: 'İnsanların birbirini anlaması için aynı dili konuşması yetmez; aynı hissiyatı '
          'paylaşması gerekir. Bazen tek bir bakış, binlerce sayfadan daha derin bir hakikati haykırır. '
          'Bizler çoğu zaman kendi yarattığımız vehimlerin ve korkuların esiri oluruz. Oysa dünyayı '
          'güzelleştiren şey, çıkarsız bir sevgi ve gerçeğin peşinden korkusuzca gitme cesaretidir.',
    ),
  ];

  int _selectedPassageIndex = 0;
  bool _isReading = false;
  bool _isCompleted = false;
  int _secondsElapsed = 0;
  Timer? _timer;
  int _calculatedWpm = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTest() {
    setState(() {
      _isReading = true;
      _isCompleted = false;
      _secondsElapsed = 0;
      _calculatedWpm = 0;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  void _finishTest() {
    _timer?.cancel();
    final passage = _passages[_selectedPassageIndex];
    final words = passage.wordCount;
    final seconds = _secondsElapsed > 0 ? _secondsElapsed : 1;
    final wpm = ((words / seconds) * 60).round();

    setState(() {
      _isReading = false;
      _isCompleted = true;
      _calculatedWpm = wpm;
    });
  }

  String _getWpmEvaluation(int wpm) {
    if (wpm < 150) return 'Sakin & Dikkatli Okuyucu';
    if (wpm < 250) return 'Ortalama Yetişkin Hızı';
    if (wpm < 350) return 'Hızlı & Akıcı Okuyucu';
    return 'İleri Seviye Hızlı Okuyucu';
  }

  Color _getEvaluationColor(int wpm) {
    if (wpm < 150) return Colors.blueGrey;
    if (wpm < 250) return Colors.teal;
    if (wpm < 350) return const Color(0xFF2E7D32);
    return Colors.deepPurple;
  }

  @override
  Widget build(BuildContext context) {
    final passage = _passages[_selectedPassageIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F7F1),
        elevation: 0,
        foregroundColor: const Color(0xFF263238),
        title: const Row(
          children: [
            Icon(Icons.speed, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text('Okuma Hızı Testi', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Passage selector dropdown
            if (!_isReading) ...[
              const Text(
                'Metin Seçin',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedPassageIndex,
                    isExpanded: true,
                    items: List.generate(_passages.length, (idx) {
                      final p = _passages[idx];
                      return DropdownMenuItem(
                        value: idx,
                        child: Text('${p.title} — ${p.author} (${p.wordCount} kelime)'),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedPassageIndex = val;
                          _isCompleted = false;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Active Reading Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        passage.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF263238),
                        ),
                      ),
                      if (_isReading)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '⏱️ $_secondsElapsed sn',
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    passage.author,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const Divider(height: 24),
                  if (!_isReading && !_isCompleted)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(Icons.visibility_outlined, size: 54, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text(
                              'Metin gizlendi',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Başla butonuna bastığınızda metin görünecek ve süreniz saymaya başlayacaktır.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Text(
                      passage.text,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.8,
                        letterSpacing: 0.2,
                        color: Color(0xFF263238),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action Button
            if (!_isReading)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _startTest,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: Text(
                    _isCompleted ? 'Testi Tekrar Başlat' : 'Okumaya Başla',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _finishTest,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text(
                    'Okumayı Bitirdim',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            // Results Card
            if (_isCompleted) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getEvaluationColor(_calculatedWpm),
                      _getEvaluationColor(_calculatedWpm).withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _getEvaluationColor(_calculatedWpm).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'OKUMA HIZINIZ',
                      style: TextStyle(
                        color: Colors.white70,
                        letterSpacing: 1.5,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$_calculatedWpm',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'kelime / dk',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _getWpmEvaluation(_calculatedWpm),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 8),
                    Text(
                      'Bu hızla 200 sayfalık bir kitabı yaklaşık ${((200 * 250) / (_calculatedWpm * 60)).toStringAsFixed(1)} saatte bitirebilirsiniz.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
