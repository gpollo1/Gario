import 'dart:ui';

//gabbiano
// Offset è una coordinata x,y nel sistema Flutter Alignment (-1 a +1)
class Enemy {
  Offset position;
  Enemy(this.position);
}

// barca
class Goal {
  Offset position;
  Goal(this.position);
}

// vita extra
class Bonus {
  Offset position;
  Bonus(this.position);
}