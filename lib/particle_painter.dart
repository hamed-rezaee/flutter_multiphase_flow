import 'package:flutter/material.dart';
import 'package:flutter_multiphase_flow/constants.dart';
import 'package:flutter_multiphase_flow/grid.dart';
import 'package:flutter_multiphase_flow/main.dart';
import 'package:flutter_multiphase_flow/neighbor.dart';
import 'package:flutter_multiphase_flow/particle.dart';

class ParticlePainter extends CustomPainter {
  ParticlePainter({required this.particles});

  List<Particle> particles;

  final List<Neighbor> neighbors = [];
  final List<List<Grid>> grids = [];

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < numGrids; i++) {
      grids.add([]);

      for (int j = 0; j < numGrids; j++) {
        grids[i].add(Grid());
      }
    }

    move(canvas, size, particles);
  }

  void move(Canvas canvas, Size size, List<Particle> particles) {
    count++;

    updateGrids();
    findNeighbors();
    calcForce();

    for (int i = 0; i < numParticles; i++) {
      Particle p = particles[i];

      moveParticle(p);

      drawParticle(canvas, p);
    }
  }

  void updateGrids() {
    Particle p;
    for (var i = 0; i < numGrids; i++) {
      for (var j = 0; j < numGrids; j++) {
        grids[i][j].particles.clear();
        grids[i][j].numParticles = 0;
      }
    }

    for (var i = 0; i < numParticles; i++) {
      p = particles[i];

      p.fx = 0;
      p.fy = 0;
      p.density = 0;
      p.densityNear = 0;

      p.gx = (p.x * invGridSize).floor();
      p.gy = (p.y * invGridSize).floor();

      if (p.gx < 0) {
        p.gx = 0;
      }

      if (p.gy < 0) {
        p.gy = 0;
      }

      if (p.gx > numGrids - 1) {
        p.gx = numGrids - 1;
      }

      if (p.gy > numGrids - 1) {
        p.gy = numGrids - 1;
      }
    }
  }

  void findNeighbors() {
    Particle p;
    numNeighbors = 0;

    for (var i = 0; i < numParticles; i++) {
      p = particles[i];

      var xMin = p.gx != 0;
      var xMax = p.gx != (numGrids - 1);

      var yMin = p.gy != 0;
      var yMax = p.gy != (numGrids - 1);

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

  void findNeighborsInGrid(Particle pi, Grid g) {
    Particle pj;
    double distance;

    for (var j = 0; j < g.numParticles; j++) {
      pj = g.particles[j];

      distance = (pi.x - pj.x) * (pi.x - pj.x) + (pi.y - pj.y) * (pi.y - pj.y);

      if (distance < range2) {
        if (neighbors.length == numNeighbors) {
          neighbors.add(Neighbor());
        }

        neighbors[numNeighbors++].setParticle(pi, pj);
      }
    }
  }

  void calcForce() {
    for (var i = 0; i < numNeighbors; i++) {
      neighbors[i].calcForce();
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
      2.5,
      Paint()
        ..color = p.color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
