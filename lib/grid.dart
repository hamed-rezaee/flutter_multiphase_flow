import 'package:flutter_multiphase_flow/particle.dart';

class Grid {
  List<Particle> particles = [];
  double numParticles = 0;

  void addParticle(Particle particle) {
    particles.add(particle);
    numParticles++;
  }
}
