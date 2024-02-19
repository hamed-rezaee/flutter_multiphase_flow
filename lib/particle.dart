import 'package:flutter/material.dart';

class Particle {
  Particle.empty();

  Particle(this.x, this.y, this.type);

  double x = 0;
  double y = 0;
  double fx = 0;
  double fy = 0;
  double vx = 0;
  double vy = 0;
  double density = 0;
  double densityNear = 0;
  int gx = 0;
  int gy = 0;
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
