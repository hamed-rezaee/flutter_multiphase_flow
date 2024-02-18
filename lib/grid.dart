import 'package:flutter_multiphase_flow/particle.dart';

class Grid {
  List<Particle> particles = [];
  double numParticles = 0;

  void addParticle(Particle p) {
    particles.add(p);
    numParticles += 1;
  }
}
