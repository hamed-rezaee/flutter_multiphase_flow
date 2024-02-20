import 'package:flutter/material.dart';
import 'package:flutter_multiphase_flow/constants.dart';
import 'package:flutter_multiphase_flow/grid.dart';
import 'package:flutter_multiphase_flow/main.dart';
import 'package:flutter_multiphase_flow/neighbor.dart';
import 'package:flutter_multiphase_flow/particle.dart';

class ParticlePainter extends CustomPainter {
  ParticlePainter({required this.particles});

  final List<Particle> particles;

  final List<Neighbor> _neighbors = [];
  final List<List<Grid>> _grids = [];

  @override
  void paint(Canvas canvas, Size size) {
    _initializeGrid();
    _move(canvas, size, particles);
  }

  void _initializeGrid() {
    for (int i = 0; i < numGrids; i++) {
      _grids.add([]);

      for (int j = 0; j < numGrids; j++) {
        _grids[i].add(Grid());
      }
    }
  }

  void _move(Canvas canvas, Size size, List<Particle> particles) {
    count++;

    _updateGrids();
    _findNeighbors();
    _calculateForce();

    for (Particle particle in particles) {
      _moveParticle(particle);
      _drawParticle(canvas, particle);
    }
  }

  void _updateGrids() {
    for (var i = 0; i < numGrids; i++) {
      for (var j = 0; j < numGrids; j++) {
        _grids[i][j].particles.clear();
      }
    }

    for (Particle particle in particles) {
      particle.fx = 0;
      particle.fy = 0;
      particle.density = 0;
      particle.densityNear = 0;

      particle.gx = (particle.x * invGridSize).floor();
      particle.gy = (particle.y * invGridSize).floor();

      if (particle.gx < 0) {
        particle.gx = 0;
      }

      if (particle.gy < 0) {
        particle.gy = 0;
      }

      if (particle.gx > numGrids - 1) {
        particle.gx = numGrids - 1;
      }

      if (particle.gy > numGrids - 1) {
        particle.gy = numGrids - 1;
      }
    }
  }

  void _findNeighbors() {
    numNeighbors = 0;

    for (Particle particle in particles) {
      var xMin = particle.gx != 0;
      var xMax = particle.gx != (numGrids - 1);

      var yMin = particle.gy != 0;
      var yMax = particle.gy != (numGrids - 1);

      _findNeighborsInGrid(particle, _grids[particle.gx][particle.gy]);

      if (xMin) {
        _findNeighborsInGrid(particle, _grids[particle.gx - 1][particle.gy]);
      }

      if (xMax) {
        _findNeighborsInGrid(particle, _grids[particle.gx + 1][particle.gy]);
      }

      if (yMin) {
        _findNeighborsInGrid(particle, _grids[particle.gx][particle.gy - 1]);
      }

      if (yMax) {
        _findNeighborsInGrid(particle, _grids[particle.gx][particle.gy + 1]);
      }

      if (xMin && yMin) {
        _findNeighborsInGrid(
            particle, _grids[particle.gx - 1][particle.gy - 1]);
      }

      if (xMin && yMax) {
        _findNeighborsInGrid(
            particle, _grids[particle.gx - 1][particle.gy + 1]);
      }

      if (xMax && yMin) {
        _findNeighborsInGrid(
            particle, _grids[particle.gx + 1][particle.gy - 1]);
      }

      if (xMax && yMax) {
        _findNeighborsInGrid(
            particle, _grids[particle.gx + 1][particle.gy + 1]);
      }

      _grids[particle.gx][particle.gy].addParticle(particle);
    }
  }

  void _findNeighborsInGrid(Particle particle, Grid grid) {
    for (Particle gridParticle in grid.particles) {
      double distance =
          (particle.x - gridParticle.x) * (particle.x - gridParticle.x) +
              (particle.y - gridParticle.y) * (particle.y - gridParticle.y);

      if (distance < range2) {
        if (_neighbors.length == numNeighbors) {
          _neighbors.add(Neighbor());
        }

        _neighbors[numNeighbors++].setParticle(particle, gridParticle);
      }
    }
  }

  void _calculateForce() {
    for (var i = 0; i < numNeighbors; i++) {
      _neighbors[i].calculateForce();
    }
  }

  void _moveParticle(Particle particle) {
    particle.vy += gravity;

    if (particle.density > 0) {
      particle.vx += particle.fx / (particle.density * 0.9 + 0.1);
      particle.vy += particle.fy / (particle.density * 0.9 + 0.1);
    }

    particle.x += particle.vx;
    particle.y += particle.vy;

    if (particle.x < particleDiameter) {
      particle.vx += (particleDiameter - particle.x) / 2 - particle.vx / 2;
    }

    if (particle.x > width) {
      particle.vx += (width - particle.x) / 2 - particle.vx / 2;
    }

    if (particle.y < particleDiameter) {
      particle.vy += (particleDiameter - particle.y) / 2 - particle.vy / 2;
    }

    if (particle.y > height) {
      particle.vy += (height - particle.y) / 2 - particle.vy / 2;
    }
  }

  void _drawParticle(Canvas canvas, Particle particle) {
    canvas.drawCircle(
      Offset(particle.x, particle.y),
      particleDiameter / 2,
      Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
