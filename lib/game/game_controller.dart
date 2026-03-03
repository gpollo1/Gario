import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'game_objects.dart';
import 'package:flutter/material.dart';

class GameController {
  double fishX = 0;
  double fishY = 0;

  int score = 0;
  int lives = 3;
  int level = 1;

  double timeProgress = 1.0;
  String fishDirection = "down";

  final Random random = Random();

  List<Enemy> enemies = [];
  Goal goal = Goal(Offset.zero);
  Bonus? bonus;

  int fishesCaught = 0;

  bool isShowingSequence = false;
  bool isGameOver = false;

  Timer? gameTimer;
  StreamSubscription? accelSub;

  VoidCallback? onUpdate;
  VoidCallback? onGameOver;

  double _rawX = 0;
  double _rawY = 0;

  void start() {
    fishesCaught = 0;
    startLevel();
    startTimer();
    listenAccelerometer();
  }

  void startLevel() {
    final double minDistance = 0.25;

    fishX = random.nextDouble() * 2 - 1;
    fishY = random.nextDouble() * 2 - 1;

    enemies.clear();
    int enemyCount = 2 + level;

    for (int i = 0; i < enemyCount; i++) {
      Offset pos;
      bool tooClose;
      do {
        pos = Offset(random.nextDouble() * 2 - 1, random.nextDouble() * 2 - 1);
        tooClose = false;
        if ((pos - Offset(fishX, fishY)).distance < minDistance) {
          tooClose = true;
          continue;
        }
        for (var e in enemies) {
          if ((pos - e.position).distance < minDistance) {
            tooClose = true;
            break;
          }
        }
      } while (tooClose);
      enemies.add(Enemy(pos));
    }

    Offset goalPos;
    bool goalTooClose;
    do {
      goalPos = Offset(random.nextDouble() * 2 - 1, random.nextDouble() * 2 - 1);
      goalTooClose = false;
      if ((goalPos - Offset(fishX, fishY)).distance < minDistance) {
        goalTooClose = true;
        continue;
      }
      for (var e in enemies) {
        if ((goalPos - e.position).distance < minDistance) {
          goalTooClose = true;
          break;
        }
      }
    } while (goalTooClose);
    goal = Goal(goalPos);

    bonus = null;
    if (random.nextDouble() < 0.25) {
      Offset bonusPos;
      bool bonusTooClose;
      do {
        bonusPos = Offset(random.nextDouble() * 2 - 1, random.nextDouble() * 2 - 1);
        bonusTooClose = false;
        if ((bonusPos - Offset(fishX, fishY)).distance < minDistance) {
          bonusTooClose = true;
          continue;
        }
        for (var e in enemies) {
          if ((bonusPos - e.position).distance < minDistance) {
            bonusTooClose = true;
            break;
          }
        }
        if ((bonusPos - goal.position).distance < minDistance) {
          bonusTooClose = true;
        }
      } while (bonusTooClose);
      bonus = Bonus(bonusPos);
    }

    timeProgress = 1.0;
  }

  void listenAccelerometer() {
    accelSub?.cancel();
    accelSub = accelerometerEvents.listen((event) {
      _rawX = event.x;
      _rawY = event.y;
    });
  }

  void update() {
    if (isGameOver || isShowingSequence) return;

    double targetX = fishX - _rawX * 0.03;
    double targetY = fishY + _rawY * 0.03;

    // smoothing: movimento fluido senza scatti
    fishX = fishX * 0.85 + targetX * 0.15;
    fishY = fishY * 0.85 + targetY * 0.15;

    fishX = fishX.clamp(-1.2, 1.2);
    fishY = fishY.clamp(-1.2, 1.2);

    if (_rawY < -1) fishDirection = "up";
    if (_rawY > 1) fishDirection = "down";
    if (_rawX > 1) fishDirection = "left";
    if (_rawX < -1) fishDirection = "right";

    // nemici e barca FERMI — nessun aggiornamento di posizione

    checkCollisions();
    onUpdate?.call();
  }

  void startTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      timeProgress -= 0.002 * (1 + level * 0.2);
      if (timeProgress <= 0) {
        loseLife();
      }
    });
  }

  void checkCollisions() {
    Offset fishPos = Offset(fishX, fishY);

    // collisione con nemico
    final hitEnemy = enemies.firstWhereOrNull(
          (e) => (fishPos - e.position).distance < 0.15,
    );
    if (hitEnemy != null) {
      lives--;
      enemies.remove(hitEnemy);
      if (lives <= 0) {
        isGameOver = true;
        onGameOver?.call();
        stop();
      }
      return;
    }

    // collisione con barca: ferma tutto e aspetta doppio tap
    if ((fishPos - goal.position).distance < 0.15) {
      isShowingSequence = true; // blocca update()
      fishesCaught++;
      stop(); // ferma timer e accelerometro
      onUpdate?.call(); // notifica GameScreen per avviare la sequenza
      return;
    }

    // collisione con bonus
    if (bonus != null && (fishPos - bonus!.position).distance < 0.15) {
      lives++;
      bonus = null;
    }
  }

  void loseLife() {
    lives--;
    if (lives <= 0) {
      isGameOver = true;
      onGameOver?.call();
      stop();
    } else {
      startLevel();
    }
  }

  void nextLevel() {
    score += 100;
    level++;
    startLevel();
  }

  void stop() {
    gameTimer?.cancel();
    accelSub?.cancel();
  }
}

extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (var e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}