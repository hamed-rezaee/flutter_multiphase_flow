import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_multiphase_flow/constants.dart';
import 'package:flutter_multiphase_flow/particle.dart';
import 'package:flutter_multiphase_flow/particle_painter.dart';

List<Particle> particles = [];

int numNeighbors = 0;

double count = 0;
double press = 0;

bool mouseDown = false;
Offset position = Offset.zero;

void main() => runApp(const MainApp());

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  StreamController<List<Particle>> streamController =
      StreamController<List<Particle>>();

  @override
  void initState() {
    super.initState();

    Timer.periodic(
      const Duration(milliseconds: interval),
      (timer) {
        if (mouseDown) {
          pour(position.dx, position.dy);
        }

        streamController.add(particles);
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
              onPanDown: (p) {
                position = p.localPosition;
                mouseDown = true;
              },
              onPanEnd: (_) {
                mouseDown = false;
              },
              onPanUpdate: (p) {
                position = p.localPosition;
                mouseDown = true;
              },
              child: StreamBuilder<List<Particle>>(
                stream: streamController.stream,
                initialData: const <Particle>[],
                builder: (context, snapshot) {
                  return CustomPaint(
                    size: const Size(width, height),
                    painter: ParticlePainter(particles: particles),
                  );
                },
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
      particles.last.velocityY = 5;

      if (particles.length > maxParticles) {
        particles.removeAt(0);
      }
    }
  }
}
