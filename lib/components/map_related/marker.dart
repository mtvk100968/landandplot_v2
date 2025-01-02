import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A class that handles the creation of custom markers.
class CustomMarker {
  // A cache to store already generated BitmapDescriptors to improve performance.
  static final Map<String, BitmapDescriptor> _markerCache = {};

  /// Creates a custom marker [BitmapDescriptor] with the given [price].
  ///
  /// The marker is a green rectangle with rounded edges, a thin border,
  /// and a seamlessly connected downward-pointing triangle that displays the price text.
  static Future<BitmapDescriptor> createMarker(String price) async {
    // Check if the marker with the given price is already cached.
    if (_markerCache.containsKey(price)) {
      return _markerCache[price]!;
    }

    // Define the fixed marker height and pointer height.
    const double height = 80; // Fixed height as requested
    const double pointerHeight = 16; // Triangle pointer height
    const double cornerRadius = 0; // Corner radius for rounded corners

    // Define the width based on the length of the price text
    final double width = _calculateWidthBasedOnText(price);

    // Create a recorder to capture the painting.
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // Define the paint for the rectangle and pointer.
    final Paint rectPaint = Paint()
      // ..color = const ui.Color.fromARGB(255, 30, 67, 31)
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    // Define the paint for the border.
    Paint borderPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Create the path for the rectangle and the pointer (combined into one polygon).
    final Path path = Path()
      ..moveTo(cornerRadius, 0) // Start from top-left with space for rounding
      ..lineTo(width - cornerRadius, 0)
      ..quadraticBezierTo(width, 0, width, cornerRadius) // Top-right corner
      ..lineTo(width, height - cornerRadius)
      ..quadraticBezierTo(
          width, height, width - cornerRadius, height) // Bottom-right corner
      ..lineTo(width / 2 + 20, height) // Right side of triangle
      ..lineTo(width / 2, height + pointerHeight) // Triangle pointer
      ..lineTo(width / 2 - 20, height) // Left side of triangle
      ..lineTo(cornerRadius, height) // Adjust bottom-left corner
      ..quadraticBezierTo(
          0, height, 0, height - cornerRadius) // Bottom-left corner rounded
      ..lineTo(0, cornerRadius) // Left side
      ..quadraticBezierTo(0, 0, cornerRadius, 0) // Top-left corner rounded
      ..close();

    // Draw the path (rectangle + pointer).
    canvas.drawPath(path, rectPaint);
    canvas.drawPath(path, borderPaint);

    // Prepare to draw the text with a fixed font size.
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: price,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 40, // Fixed font size
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    // Layout the text.
    textPainter.layout(
      minWidth: 0,
      maxWidth: width - 2, // Padding from sides
    );

    // Calculate the position to center the text.
    final double textX = (width - textPainter.width) / 2;
    final double textY = (height - textPainter.height) / 2;

    // Paint the text onto the canvas.
    textPainter.paint(canvas, Offset(textX, textY));

    // End recording and convert to image.
    final ui.Image image = await pictureRecorder.endRecording().toImage(
          width.toInt(),
          (height + pointerHeight).toInt(),
        );

    // Convert the image to bytes.
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Create a BitmapDescriptor from the bytes.
    final BitmapDescriptor bitmapDescriptor =
        BitmapDescriptor.fromBytes(pngBytes);

    // Cache the descriptor for future use.
    _markerCache[price] = bitmapDescriptor;

    return bitmapDescriptor;
  }

  /// Dynamically calculates the width of the rectangle based on the price text length.
  static double _calculateWidthBasedOnText(String price) {
    // Base width for short prices
    double baseWidth = 180;

    // Additional width per character
    double additionalWidthPerChar = 1;

    return baseWidth + (price.length * additionalWidthPerChar);
  }
}
