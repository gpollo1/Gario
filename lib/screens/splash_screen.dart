import 'dart:async';
import 'package:flutter/material.dart';
import 'game_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool visible = true;
  late Timer blinkTimer;
  late AnimationController scaleController;
  late Animation<double> scaleAnim;

  @override
  void initState() {
    super.initState();

    // Timer che alterna visible ogni 550ms per far lampeggiare il testo
    blinkTimer = Timer.periodic(
      const Duration(milliseconds: 550),
          (_) => setState(() => visible = !visible),
    );

    // AnimationController che scala il titolo tra 0.95 e 1.05 in loop
    scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true); // reverse: true fa andare avanti e indietro

    scaleAnim = Tween(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    blinkTimer.cancel();
    scaleController.dispose();
    super.dispose();
  }

  void startGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: startGame,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1a1a2e),
                Color(0xFF16213e),
                Color(0xFF0f3460),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: scaleAnim,
                  child: const Text(
                    "MINI\nMOTION\nGAMES",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                AnimatedOpacity(
                  opacity: visible ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: const Text(
                    "DOUBLE TAP TO START",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Hold tight… it gets fast 😈",
                  style: TextStyle(fontSize: 14, color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}