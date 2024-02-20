import 'package:flutter_multiphase_flow/particle.dart';

class Grid {
  final List<Particle> particles = [];

  void addParticle(Particle particle) {
    particles.add(particle);
  }
}
