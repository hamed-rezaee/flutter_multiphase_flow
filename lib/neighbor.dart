import 'dart:math';

import 'package:flutter_multiphase_flow/constants.dart';
import 'package:flutter_multiphase_flow/particle.dart';

class Neighbor {
  Particle particle1 = Particle.empty();
  Particle particle2 = Particle.empty();
  double distance = 0;
  double normalX = 0;
  double normalY = 0;
  double weight = 0;

  void setParticles(Particle p1, Particle p2) {
    particle1 = p1;
    particle2 = p2;

    normalX = particle1.x - particle2.x;
    normalY = particle1.y - particle2.y;

    distance = _calculateDistance();

    weight = 1 - distance / range;

    var density = weight * weight;

    p1.density += density;
    p2.density += density;

    density *= weight * pressureNear;

    p1.densityNear += density;
    p2.densityNear += density;

    var invDistance = 1 / distance;

    normalX *= invDistance;
    normalY *= invDistance;
  }

  void calculateForce() {
    double force = 0;

    var p1 = particle1;
    var p2 = particle2;

    if (particle1.type != particle2.type) {
      force = (p1.density + p2.density - density * 1.5) * pressure;
    } else {
      force = (p1.density + p2.density - density * 2) * pressure;
    }

    var pn = (p1.densityNear + p2.densityNear) * pressureNear;

    var pressureWeight = weight * (force + weight * pn);
    var viscosityWeight = weight * viscosity;

    var fx = normalX * pressureWeight;
    var fy = normalY * pressureWeight;

    fx += (p2.vx - p1.vx) * viscosityWeight;
    fy += (p2.vy - p1.vy) * viscosityWeight;

    p1.fx += fx;
    p1.fy += fy;

    p2.fx -= fx;
    p2.fy -= fy;
  }

  double _calculateDistance() => sqrt(normalX * normalX + normalY * normalY);
}
