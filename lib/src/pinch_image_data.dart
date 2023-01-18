import 'package:flutter/material.dart';

// A photo initialization data - position and size
@immutable
class PinchImageData {
  const PinchImageData({
    required this.globalPosition,
    required this.paintBounds,
    required this.imagePath,
  });

  final Offset globalPosition;
  final Rect paintBounds;
  final String imagePath;
}