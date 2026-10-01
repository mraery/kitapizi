import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/reading_service.dart';
import 'screens/library_screen.dart';
import 'screens/quote_studio_screen.dart';
import 'screens/reading_speed_screen.dart';
import 'screens/challenge_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  await ReadingService().init();
  runApp(const KitapIziApp());
}

class KitapIziApp extends StatelessWidget {
  const KitapIziApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitapİzi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF00796B),
          surface: const Color(0xFFF9F7F1),
        ),
        scaffoldBackgroundColor: const Color(0xFFF9F7F1),
        fontFamily: 'Roboto',
      ),
      home: const KitapIziMainNavigation(),
    );
  }
}

class KitapIziMainNavigation extends StatefulWidget {
  const KitapIziMainNavigation({super.key});

  @override
  State<KitapIziMainNavigation> createState() => _KitapIziMainNavigationState();
}

class _KitapIziMainNavigationState extends State<KitapIziMainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    LibraryScreen(),
    QuoteStudioScreen(),
    ReadingSpeedScreen(),
    ChallengeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFC8E6C9),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: Color(0xFF1B5E20)),
            label: 'Kitaplığım',
          ),
          NavigationDestination(
            icon: Icon(Icons.format_quote_outlined),
            selectedIcon: Icon(Icons.format_quote, color: Color(0xFF1B5E20)),
            label: 'Alıntılar',
          ),
          NavigationDestination(
            icon: Icon(Icons.speed_outlined),
            selectedIcon: Icon(Icons.speed, color: Color(0xFF1B5E20)),
            label: 'Hız Testi',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events, color: Color(0xFF1B5E20)),
            label: 'Hedefler',
          ),
        ],
      ),
    );
  }
}
