import 'dart:math';

import 'package:flutter_multiphase_flow/constants.dart';
import 'package:flutter_multiphase_flow/particle.dart';

class Neighbor {
  Particle p = Particle.empty();
  Particle q = Particle.empty();
  double distance = 0;
  double nx = 0;
  double ny = 0;
  double weight = 0;

  setParticle(Particle p, Particle q) {
    p = p;
    q = q;

    nx = p.x - q.x;
    ny = p.y - q.y;

    distance = sqrt(nx * nx + ny * ny);

    weight = 1 - distance / range;

    var density = weight * weight;

    p.density += density;
    q.density += density;

    density *= weight * pressureNear;

    p.densityNear += density;
    q.densityNear += density;

    var invDistance = 1 / distance;

    nx *= invDistance;
    ny *= invDistance;
  }

  void calculateForce() {
    double t = 0;

    if (p.type != q.type) {
      t = (p.density + p.density - density * 1.5) * pressure;
    } else {
      t = (p.density + p.density - density * 2) * pressure;
    }

    var pn = (p.densityNear + p.densityNear) * pressureNear;

    var pressureWeight = weight * (t + weight * pn);
    var viscocityWeight = weight * viscosity;

    var fx = nx * pressureWeight;
    var fy = ny * pressureWeight;

    fx += (q.vx - p.vx) * viscocityWeight;
    fy += (q.vy - p.vy) * viscocityWeight;

    p.fx += fx;
    p.fy += fy;

    q.fx -= fx;
    q.fy -= fy;
  }
}
