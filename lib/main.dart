import 'package:flutter/material.dart';
import 'registration_screen.dart'; // Import the registration screen
import 'login_screen.dart';
import 'home_screen.dart';
import 'connectionScreen.dart';

void main() {
  runApp(const SinoltaApp());
}

class SinoltaApp extends StatelessWidget {
  const SinoltaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SINOLTA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(), // Set HomePage as the initial screen
      debugShowCheckedModeBanner: false, // Disable debug banner
      routes: {
        '/register': (context) =>
            const RegistrationScreen(), // Route to RegistrationScreen
        '/login': (context) => const LoginScreen(), // Route to LoginScreen
        '/home': (context) {
          final sessionId =
              ModalRoute.of(context)?.settings.arguments as String;
          return HomeScreen(sessionId: sessionId);
        },
        '/connection': (context) =>
            const ConnectionScreen(), // Route to ConnectionScreen
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _images = [
    'assets/images/Convergance.png',
    'assets/images/power.png',
    'assets/images/wastewater.png',
    'assets/images/first page.png'
  ];
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _startImageCarousel();
  }

  void _startImageCarousel() {
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % _images.length;
      });
      _startImageCarousel(); // Loop the carousel
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Section
            Image.asset('assets/images/logo.jpg', width: 150, height: 150),
            const SizedBox(height: 10),
            const Text(
              'SINOLTA',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),

            // Image Carousel
            Container(
              width: 200,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  _images[_currentImageIndex],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Get Started Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/register');
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
