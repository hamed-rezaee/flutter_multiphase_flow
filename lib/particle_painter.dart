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
      particle.forceX = 0;
      particle.forceY = 0;
      particle.density = 0;
      particle.densityNear = 0;

      particle.gridX = (particle.positionX * invGridSize).floor();
      particle.gridY = (particle.positionY * invGridSize).floor();

      if (particle.gridX < 0) {
        particle.gridX = 0;
      }

      if (particle.gridY < 0) {
        particle.gridY = 0;
      }

      if (particle.gridX > numGrids - 1) {
        particle.gridX = numGrids - 1;
      }

      if (particle.gridY > numGrids - 1) {
        particle.gridY = numGrids - 1;
      }
    }
  }

  void _findNeighbors() {
    numNeighbors = 0;

    for (Particle particle in particles) {
      var xMin = particle.gridX != 0;
      var xMax = particle.gridX != (numGrids - 1);

      var yMin = particle.gridY != 0;
      var yMax = particle.gridY != (numGrids - 1);

      _findNeighborsInGrid(particle, _grids[particle.gridX][particle.gridY]);

      if (xMin) {
        _findNeighborsInGrid(
            particle, _grids[particle.gridX - 1][particle.gridY]);
      }

      if (xMax) {
        _findNeighborsInGrid(
            particle, _grids[particle.gridX + 1][particle.gridY]);
      }

      if (yMin) {
        _findNeighborsInGrid(
            particle, _grids[particle.gridX][particle.gridY - 1]);
      }

      if (yMax) {
        _findNeighborsInGrid(
            particle, _grids[particle.gridX][particle.gridY + 1]);
      }

      if (xMin && yMin) {
        _findNeighborsInGrid(
            particle, _grids[particle.gridX - 1][particle.gridY - 1]);
      }

      if (xMin && yMax) {
        _findNeighborsInGrid(
            particle, _grids[particle.gridX - 1][particle.gridY + 1]);
      }

      if (xMax && yMin) {
        _findNeighborsInGrid(
            particle, _grids[particle.gridX + 1][particle.gridY - 1]);
      }

      if (xMax && yMax) {
        _findNeighborsInGrid(
            particle, _grids[particle.gridX + 1][particle.gridY + 1]);
      }

      _grids[particle.gridX][particle.gridY].addParticle(particle);
    }
  }

  void _findNeighborsInGrid(Particle particle, Grid grid) {
    for (Particle gridParticle in grid.particles) {
      double distance = (particle.positionX - gridParticle.positionX) *
              (particle.positionX - gridParticle.positionX) +
          (particle.positionY - gridParticle.positionY) *
              (particle.positionY - gridParticle.positionY);

      if (distance < range2) {
        if (_neighbors.length == numNeighbors) {
          _neighbors.add(Neighbor());
        }

        _neighbors[numNeighbors++].setParticles(particle, gridParticle);
      }
    }
  }

  void _calculateForce() {
    for (var i = 0; i < numNeighbors; i++) {
      _neighbors[i].calculateForce();
    }
  }

  void _moveParticle(Particle particle) {
    particle.velocityY += gravity;

    if (particle.density > 0) {
      particle.velocityX += particle.forceX / (particle.density * 0.9 + 0.1);
      particle.velocityY += particle.forceY / (particle.density * 0.9 + 0.1);
    }

    particle.positionX += particle.velocityX;
    particle.positionY += particle.velocityY;

    if (particle.positionX < particleDiameter) {
      particle.velocityX +=
          (particleDiameter - particle.positionX) / 2 - particle.velocityX / 2;
    }

    if (particle.positionX > width) {
      particle.velocityX +=
          (width - particle.positionX) / 2 - particle.velocityX / 2;
    }

    if (particle.positionY < particleDiameter) {
      particle.velocityY +=
          (particleDiameter - particle.positionY) / 2 - particle.velocityY / 2;
    }

    if (particle.positionY > height) {
      particle.velocityY +=
          (height - particle.positionY) / 2 - particle.velocityY / 2;
    }
  }

  void _drawParticle(Canvas canvas, Particle particle) {
    canvas.drawCircle(
      Offset(particle.positionX, particle.positionY),
      particleDiameter / 2,
      Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
