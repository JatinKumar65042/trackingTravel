import 'package:flutter/material.dart';

class EcoIcons {
  static const String carIcon =
      '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 16H9m10 0h3v-3.15a1 1 0 0 0-.84-.99L16 11l-2.7-3.6a1 1 0 0 0-.8-.4H5.24a2 2 0 0 0-1.8 1.1l-.8 1.63A6 6 0 0 0 2 12.42V16h2"/><circle cx="6.5" cy="16.5" r="2.5"/><circle cx="16.5" cy="16.5" r="2.5"/></svg>''';

  static const String bikeIcon =
      '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="5.5" cy="17.5" r="3.5"/><circle cx="18.5" cy="17.5" r="3.5"/><path d="M15 6a1 1 0 1 0 0-2 1 1 0 0 0 0 2zm-3 11.5V14l-3-3 4-3 2 3h2"/></svg>''';

  static const String busIcon =
      '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 12V5c0-1.1.9-2 2-2h12a2 2 0 0 1 2 2v7M4 12h16M4 12v5a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-5M10 5v5M14 5v5"/><circle cx="7" cy="17" r="1"/><circle cx="17" cy="17" r="1"/></svg>''';

  static const String trainIcon =
      '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="3" width="16" height="16" rx="2"/><path d="M4 11h16M12 3v16M8 19l-2 3M16 19l2 3M8 3v8M16 3v8"/></svg>''';

  static const String planeIcon =
      '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.8 19.2L16 11l3.5-3.5C21 6 21.5 4 21 3c-1-.5-3 0-4.5 1.5L13 8 4.8 6.2c-.5-.1-.9.1-1.1.5l-.3.5c-.2.5-.1 1 .3 1.3L9 12l-2 3H4l-1 1 3 2 2 3 1-1v-3l3-2 3.5 5.3c.3.4.8.5 1.3.3l.5-.2c.4-.3.6-.7.5-1.2z"/></svg>''';

  static const String walkingIcon =
      '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="4" r="2"/><path d="M14 8h-4l-1.5 4 3.5 3-2 4.5L11.5 22M10 14l-1.5-3L7 12l1 3h3"/></svg>''';

  static Widget svgIcon(String svgContent, {double size = 150, Color? color}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: SvgIconPainter(svgContent, color: color ?? Colors.blue),
      ),
    );
  }
}

class SvgIconPainter extends CustomPainter {
  final String svgContent;
  final Color color;

  SvgIconPainter(this.svgContent, {required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Basic SVG path rendering implementation
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final scale = size.width / 24; // SVG viewBox is 24x24

    canvas.save();
    canvas.scale(scale);

    // Draw basic shape based on icon type
    if (svgContent.contains('circle')) {
      path.addOval(Rect.fromCircle(center: Offset(12, 12), radius: 8));
    } else if (svgContent.contains('rect')) {
      path.addRect(Rect.fromLTWH(4, 4, 16, 16));
    } else {
      // Default path for complex icons
      path.moveTo(4, 12);
      path.lineTo(20, 12);
      path.moveTo(12, 4);
      path.lineTo(12, 20);
    }

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(SvgIconPainter oldDelegate) =>
      svgContent != oldDelegate.svgContent || color != oldDelegate.color;
}
