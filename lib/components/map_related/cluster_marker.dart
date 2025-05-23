import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ClusterMarker {
  static final Map<int, BitmapDescriptor> _cache = {};

  /// Draws a white circle with a green stroke and the cluster count.
  static Future<BitmapDescriptor> create(int count) async {
    if (_cache.containsKey(count)) return _cache[count]!;

    const double size = 160;
    const double strokeWidth = 6;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // fill circle
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    canvas.drawCircle(Offset(size/2, size/2), size/2, fillPaint);

    // stroke circle
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = Colors.green.shade700;
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      (size / 2) - strokeWidth / 2,
      strokePaint,
    );

    // draw count text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$count',
        style: TextStyle(
          color: Colors.green.shade800,
          fontSize: 60,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final textOffset = Offset(
      (size - textPainter.width) / 2,
      (size - textPainter.height) / 2,
    );
    textPainter.paint(canvas, textOffset);

    // finish image
    final image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = data!.buffer.asUint8List();
    final descriptor = BitmapDescriptor.fromBytes(bytes);

    _cache[count] = descriptor;
    return descriptor;
  }
}
