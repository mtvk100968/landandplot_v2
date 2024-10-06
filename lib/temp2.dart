// Modify the moveTo starting point to account for the stroke width on the left side
final Path path = Path()
  ..moveTo(cornerRadius + borderPaint.strokeWidth / 2, 0)  // Adjusted starting point
  ..lineTo(width - cornerRadius - borderPaint.strokeWidth / 2, 0)  // Adjust for stroke
  // The rest remains the same
  ..quadraticBezierTo(
      width - borderPaint.strokeWidth / 2, 0, width - borderPaint.strokeWidth / 2, cornerRadius)
  // ...
