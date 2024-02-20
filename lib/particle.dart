import 'package:flutter/material.dart';

class Particle {
  Particle.empty();

  Particle(this.positionX, this.positionY, this.type);

  double positionX = 0;
  double positionY = 0;
  double forceX = 0;
  double forceY = 0;
  double velocityX = 0;
  double velocityY = 0;
  double density = 0;
  double densityNear = 0;
  int gridX = 0;
  int gridY = 0;
  int type = 0;

  Color get color => switch (type) {
        0 => Colors.blue,
        1 => Colors.red,
        2 => Colors.green,
        3 => Colors.yellow,
        4 => Colors.purple,
        _ => Colors.black,
      };
}
