import 'package:flutter/material.dart';

/// Drawing state.
class DrawingState {
  /// Default constructor.
  DrawingState({
    required this.points,
    required this.redoStack,
    required this.isDrawing,
  });

  /// Initial state.
  DrawingState.initial()
      : points = [],
        redoStack = [],
        isDrawing = false;

  /// Points.
  final List<Offset?> points;

  /// Redo stack.
  final List<Offset?> redoStack;

  /// Is drawing.
  bool isDrawing;
}
