import 'package:flutter/material.dart';
import 'package:flutter_multiphase_flow/constants.dart';
import 'package:flutter_multiphase_flow/grid.dart';
import 'package:flutter_multiphase_flow/main.dart';
import 'package:flutter_multiphase_flow/neighbor.dart';
import 'package:flutter_multiphase_flow/particle.dart';

class ParticlePainter extends CustomPainter {
  ParticlePainter({required this.particles, required this.grids});

  List<Particle> particles;
  List<List<Grid>> grids;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke,
    );

    move(canvas, size, particles);
  }

  void move(Canvas canvas, Size size, List<Particle> particles) {
    count++;

    updateGrid();
    findNeighbors();
    calculateForce();

    for (int i = 0; i < numParticles; i++) {
      Particle p = particles[i];

      moveParticle(p);

      drawParticle(canvas, p);
    }
  }

  void updateGrid() {
    for (int i = 0; i < numGrids; i++) {
      for (int j = 0; j < numGrids; j++) {
        grids[i][j].particles = [];
        grids[i][j].numParticles = 0;
      }
    }

    for (int i = 0; i < numParticles; i++) {
      Particle p = particles[i];

      p.fx = 0;
      p.fy = 0;
      p.density = 0;
      p.densityNear = 0;

      p.gx = (p.x * invGridSize).floor();
      p.gy = (p.y * invGridSize).floor();

      if (p.gx < 0) p.gx = 0;
      if (p.gy < 0) p.gy = 0;

      if (p.gx > numGrids - 1) p.gx = numGrids - 1;
      if (p.gy > numGrids - 1) p.gy = numGrids - 1;
    }
  }

  void findNeighbors() {
    int i;
    Particle p;
    numNeighbors = 0;

    for (i = 0; i < numParticles; i++) {
      p = particles[i];

      bool xMin = p.gx != 0;
      bool xMax = p.gx != (numGrids - 1);

      bool yMin = p.gy != 0;
      bool yMax = p.gy != (numGrids - 1);

      findNeighborsInGrid(p, grids[p.gx][p.gy]);

      if (xMin) {
        findNeighborsInGrid(p, grids[p.gx - 1][p.gy]);
      }

      if (xMax) {
        findNeighborsInGrid(p, grids[p.gx + 1][p.gy]);
      }

      if (yMin) {
        findNeighborsInGrid(p, grids[p.gx][p.gy - 1]);
      }

      if (yMax) {
        findNeighborsInGrid(p, grids[p.gx][p.gy + 1]);
      }

      if (xMin && yMin) {
        findNeighborsInGrid(p, grids[p.gx - 1][p.gy - 1]);
      }

      if (xMin && yMax) {
        findNeighborsInGrid(p, grids[p.gx - 1][p.gy + 1]);
      }

      if (xMax && yMin) {
        findNeighborsInGrid(p, grids[p.gx + 1][p.gy - 1]);
      }

      if (xMax && yMax) {
        findNeighborsInGrid(p, grids[p.gx + 1][p.gy + 1]);
      }

      grids[p.gx][p.gy].addParticle(p);
    }
  }

  void findNeighborsInGrid(Particle p, Grid g) {
    for (int i = 0; i < g.numParticles; i++) {
      Particle q = g.particles[i];

      double distance = (p.x - q.x) * (p.x - q.x) + (p.y - q.y) * (p.y - q.y);

      if (distance < range2) {
        if (neighbors.length == numNeighbors) {
          neighbors.add(Neighbor());
        }

        neighbors[numNeighbors++].setParticle(p, q);
      }
    }
  }

  void calculateForce() {
    for (int i = 0; i < numNeighbors; i++) {
      neighbors[i].calculateForce();
    }
  }

  void moveParticle(Particle p) {
    p.vy += gravity;

    if (p.density > 0) {
      p.vx += p.fx / (p.density * 0.9 + 0.1);
      p.vy += p.fy / (p.density * 0.9 + 0.1);
    }

    p.x += p.vx;
    p.y += p.vy;

    if (p.x < 5) {
      p.vx += (5 - p.x) * 0.5 - p.vx * 0.5;
    }

    if (p.x > 275) {
      p.vx += (275 - p.x) * 0.5 - p.vx * 0.5;
    }

    if (p.y < 5) {
      p.vy += (5 - p.y) * 0.5 - p.vy * 0.5;
    }

    if (p.y > 275) {
      p.vy += (275 - p.y) * 0.5 - p.vy * 0.5;
    }
  }

  void drawParticle(Canvas canvas, Particle p) {
    canvas.drawCircle(
      Offset(p.x, p.y),
      12,
      Paint()
        ..color = p.getColor()
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
