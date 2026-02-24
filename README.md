# Mini Motion Games🐟

Mini Motion Games è un gioco mobile sviluppato in **Flutter** che combina il movimento fisico tramite accelerometro con elementi di raccolta e sopravvivenza. Il giocatore controlla un pesce e deve evitare nemici, raccogliere bonus e raggiungere l’obiettivo prima che il tempo scada.

---

## Gameplay

- Controllo del pesce tramite accelerometro del dispositivo (tilt X e Y).
- Obiettivi principali:
  - Evitare nemici (gabbiani).
  - Raggiungere la **barca** (goal) per avanzare al livello successivo.
  - Raccogliere **bonus** che aumentano le vite.
- Meccaniche:
  - Timer progressivo che riduce lentamente il tempo a disposizione.
  - Sistema di vite e punteggio.
  - Sequenze animate di vittoria e schermate di sconfitta.
  - Aumento della difficoltà con il progredire dei livelli.

---

## Caratteristiche principali

- **Controllo intuitivo tramite accelerometro** (`sensors_plus`).
- **Gestione dinamica dei livelli** con spawn casuale di nemici, goal e bonus.
- **HUD interattivo** con punteggio, vite e barra tempo.
- **Animazioni fluide** per vittoria, sconfitta e splash screen.
- **Supporto orientamento verticale** (portrait).

---

## Struttura del progetto


lib/
├── main.dart # Entry point dell’app
├── screens/
│ ├── splash_screen.dart
│ └── game_screen.dart
├── widgets/
│ └── hud.dart # HUD con punteggio, vite e tempo
├── game/
│ ├── game_controller.dart
│ └── game_objects.dart # Definizione Enemy, Goal, Bonus
assets/
├── images/
│ ├── fish_up.png
│ ├── fish_down.png
│ ├── fish_left.png
│ ├── fish_right.png
│ ├── enemy.png
│ ├── goal.png
│ ├── bonus.png
│ ├── mare.png
│ ├── presa1.png
│ ├── presa2.png
│ ├── presa3.png
│ ├── points.png
│ └── hai_perso.png


---

## Come giocare

1. Avvia il gioco.
2. Nella schermata iniziale (Splash Screen), fare **double tap** per iniziare.
3. Inclina il dispositivo per muovere il pesce.
4. Evita i gabbiani e raccogli i bonus.
5. Raggiungi la barca per completare il livello.
6. Se perdi tutte le vite, apparirà la schermata di sconfitta.
7. Dopo la vittoria, fare **double tap** per passare al livello successivo.

---

## Dipendenze

- Flutter SDK
- [sensors_plus](https://pub.dev/packages/sensors_plus) per l’input accelerometro.

Aggiungi al tuo `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  sensors_plus: ^3.0.2
