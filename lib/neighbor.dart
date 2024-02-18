import 'dart:math';

import 'package:flutter_multiphase_flow/constants.dart';
import 'package:flutter_multiphase_flow/particle.dart';

class Neighbor {
  Particle p1 = Particle.empty();
  Particle p2 = Particle.empty();
  double distance = 0;
  double nx = 0;
  double ny = 0;
  double weight = 0;

  void setParticle(Particle p1, Particle p2) {
    this.p1 = p1;
    this.p2 = p2;

    nx = p1.x - p2.x;
    ny = p1.y - p2.y;

    distance = _calculateDistance();

    weight = 1 - distance / range;

    var density = weight * weight;

    p1.density += density;
    p2.density += density;

    density *= weight * pressureNear;

    p1.densityNear += density;
    p2.densityNear += density;

    // Inverted distance
    var invDistance = 1 / distance;

    nx *= invDistance;
    ny *= invDistance;
  }

  double _calculateDistance() {
    return sqrt(nx * nx + ny * ny);
  }

  void calcForce() {
    double p;
    var p1 = this.p1;
    var p2 = this.p2;

    if (this.p1.type != this.p2.type) {
      p = (p1.density + p2.density - density * 1.5) * pressure;
    } else {
      p = (p1.density + p2.density - density * 2) * pressure;
    }

    var pn = (p1.densityNear + p2.densityNear) * pressureNear;

    var pressureWeight = weight * (p + weight * pn);
    var viscosityWeight = weight * viscosity;

    var fx = nx * pressureWeight;
    var fy = ny * pressureWeight;

    fx += (p2.vx - p1.vx) * viscosityWeight;
    fy += (p2.vy - p1.vy) * viscosityWeight;

    p1.fx += fx;
    p1.fy += fy;

    p2.fx -= fx;
    p2.fy -= fy;
  }
}
