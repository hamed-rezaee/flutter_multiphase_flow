import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_multiphase_flow/constants.dart';
import 'package:flutter_multiphase_flow/grid.dart';
import 'package:flutter_multiphase_flow/neighbor.dart';
import 'package:flutter_multiphase_flow/particle.dart';
import 'package:flutter_multiphase_flow/particle_painter.dart';

List<Particle> particles = [];
List<Neighbor> neighbors = [];
List<List<Grid>> grids = [];

int numParticles = 0;
int numNeighbors = 0;

double count = 0;
double press = 0;

void main() => runApp(const MainApp());

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();

    for (int i = 0; i < numGrids; i++) {
      grids.add([]);

      for (int j = 0; j < numGrids; j++) {
        grids[i].add(Grid());
      }
    }

    Timer.periodic(
      const Duration(milliseconds: 16),
      (timer) {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Container(
            width: width,
            height: height,
            color: Colors.white,
            child: GestureDetector(
              onPanUpdate: (details) {
                pour(details.localPosition.dx, details.localPosition.dy);

                setState(() {});
              },
              child: CustomPaint(
                size: const Size(width, height),
                painter: ParticlePainter(
                  particles: particles,
                  neighbors: neighbors,
                  grids: grids,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void pour(double x, double y) {
    for (var i = -4; i <= 4; i++) {
      particles.add(Particle(x + i * 10, y, (count ~/ 10) % 4));

      numParticles++;

      particles[numParticles - 1].vy = 5;

      if (numParticles >= 1000) {
        particles.removeAt(0);
        numParticles--;
      }
    }
  }
}
