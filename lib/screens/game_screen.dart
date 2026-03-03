import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../game/game_controller.dart';
import 'splash_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {

  final GameController controller = GameController(); // logica di gioco

  late Ticker _ticker;

  int sequenceStep = 0;
  bool showPointsScreen = false;
  bool showLoseScreen = false;
  bool waitingDoubleTap = false;

  int gameNumber = 1;

  @override
  void initState() {
    super.initState();

    // Callback chiamata dal controller quando c'è una vittoria
    controller.onUpdate = () {
      if (controller.isShowingSequence && !waitingDoubleTap) {
        startWinSequence();
      }
    };

    // Callback chiamata quando le vite finiscono
    controller.onGameOver = startLoseSequence;

    // Avvia sensori e timer
    controller.start();

    _ticker = createTicker((_) {
      controller.update();
      if (mounted) setState(() {});
    });
    _ticker.start();
  }

  // Sequenza animata di 3 frame
  void startWinSequence() async {
    controller.isShowingSequence = false;
    controller.stop();


    sequenceStep = 1; setState(() {});
    await Future.delayed(const Duration(milliseconds: 600));

    sequenceStep = 2; setState(() {});
    await Future.delayed(const Duration(milliseconds: 600));

    sequenceStep = 3; setState(() {});
    await Future.delayed(const Duration(milliseconds: 600));

    // Mostra schermata punti e aspetta doppio tap
    showPointsScreen = true;
    waitingDoubleTap = true;
    setState(() {});
  }

  // Chiamata dal doppio tap quando showPointsScreen è true
  void continueAfterWin() {
    if (!waitingDoubleTap) return;

    waitingDoubleTap = false;
    showPointsScreen = false;
    sequenceStep = 0;

    gameNumber++;

    // Avanza al livello successivo
    controller.nextLevel();
    controller.startTimer();
    controller.listenAccelerometer();

    // Riavvia il ticker
    if (!_ticker.isActive) _ticker.start();

    setState(() {});
  }

  // Mostra schermata di sconfitta
  void startLoseSequence() {
    showLoseScreen = true;
    controller.stop();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    controller.stop();
    super.dispose();
  }


  String fishAsset() => "assets/images/fish_${controller.fishDirection}.png";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: continueAfterWin, // doppio tap per continuare dopo vittoria
      child: Scaffold(
        body: Stack(
          children: [

            // SFONDO
            Positioned.fill(
              child: Image.asset("assets/images/mare.png", fit: BoxFit.cover),
            ),

            // pesce posizione
            Align(
              alignment: Alignment(controller.fishX, controller.fishY),
              child: Image.asset(fishAsset(), width: 60),
            ),

            //nemici
            ...controller.enemies.map(
                  (e) => Align(
                alignment: Alignment(e.position.dx, e.position.dy),
                child: Image.asset("assets/images/enemy.png", width: 50),
              ),
            ),

            //goal
            Align(
              alignment: Alignment(
                  controller.goal.position.dx, controller.goal.position.dy),
              child: Image.asset("assets/images/goal.png", width: 60),
            ),

            // BONUS: vita extra, visibile solo se bonus != null
            if (controller.bonus != null)
              Align(
                alignment: Alignment(
                    controller.bonus!.position.dx,
                    controller.bonus!.position.dy),
                child: Image.asset("assets/images/bonus.png", width: 50),
              ),

            // score e vite
            Positioned(
              top: 40,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset("assets/images/points.png", width: 25),
                      const SizedBox(width: 5),
                      Text(
                        "${controller.score}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(blurRadius: 3, color: Colors.black)],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset("assets/images/bonus.png", width: 25),
                      const SizedBox(width: 5),
                      Text(
                        "${controller.lives}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(blurRadius: 3, color: Colors.black)],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //tempo
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: controller.timeProgress,
                minHeight: 12,
                backgroundColor: Colors.white24,
                valueColor:
                const AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            ),

            //vittoria
            if (sequenceStep > 0)
              Positioned.fill(
                child: Image.asset(
                  "assets/images/presa$sequenceStep.png",
                  fit: BoxFit.contain,
                ),
              ),

            //punti dopo vittoria
            if (showPointsScreen)
              Positioned.fill(
                child: Container(
                  color: Colors.black54, // sfondo semitrasparente
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset("assets/images/points.png",
                            width: 150, fit: BoxFit.contain),
                        const SizedBox(height: 20),
                        Text(
                          "Partita $gameNumber\nPesci catturati: ${controller.fishesCaught * 100}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 36,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(blurRadius: 5, color: Colors.black)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            //sconfitta
            if (showLoseScreen)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/hai_perso.png",
                          fit: BoxFit.contain, height: 300),
                      const SizedBox(height: 20),
                      // Score e vite finali
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/images/points.png", width: 30),
                          const SizedBox(width: 5),
                          Text("${controller.score}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                        blurRadius: 3, color: Colors.black)
                                  ])),
                          const SizedBox(width: 20),
                          Image.asset("assets/images/bonus.png", width: 30),
                          const SizedBox(width: 5),
                          Text("${controller.lives}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                        blurRadius: 3, color: Colors.black)
                                  ])),
                        ],
                      ),
                      const SizedBox(height: 40),
                      // Pulsante per tornare alla splash screen
                      IconButton(
                        iconSize: 60,
                        color: Colors.white,
                        icon: const Icon(Icons.arrow_circle_left),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SplashScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}