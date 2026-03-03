import 'package:flutter/material.dart';

class HUD extends StatelessWidget {
  final int score;
  final int lives;
  final double timeProgress;

  const HUD({
    super.key,
    required this.score,
    required this.lives,
    required this.timeProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 40,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Score: $score",
                  style: const TextStyle(color: Colors.white)),
              Text("Lives: $lives",
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: LinearProgressIndicator(value: timeProgress),
        ),
      ],
    );
  }
}