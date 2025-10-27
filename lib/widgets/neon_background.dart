import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget de fondo animado con estilo cyberpunk/neón
/// Incluye gradientes, partículas flotantes y líneas de grid animadas
class NeonBackground extends StatefulWidget {
  const NeonBackground({Key? key}) : super(key: key);

  @override
  State<NeonBackground> createState() => _NeonBackgroundState();
}

class _NeonBackgroundState extends State<NeonBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradiente base oscuro
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0f172a), // Azul muy oscuro
                Color(0xFF1e293b), // Azul oscuro medio
                Color(0xFF0f172a), // Azul muy oscuro
              ],
            ),
          ),
        ),

        // Partículas y líneas animadas
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: NeonParticlesPainter(_controller.value),
              size: Size.infinite,
            );
          },
        ),

        // Overlay de gradiente para profundidad
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Color(0xFF0f172a).withOpacity(0.7),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Painter personalizado que dibuja las partículas y efectos neón
class NeonParticlesPainter extends CustomPainter {
  final double animationValue;
  final math.Random random = math.Random(42); // Seed fijo para consistencia

  NeonParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // ========== LÍNEAS VERTICALES DE GRID ==========
    for (int i = 0; i < 15; i++) {
      double x = (size.width / 15) * i;
      double offset = (animationValue * size.height) % size.height;

      // Líneas estáticas muy sutiles
      paint.color = Color(0xFF00bcd4).withOpacity(0.05);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );

      // Líneas brillantes que se mueven verticalmente
      if (i % 3 == 0) {
        paint.color = Color(0xFF00bcd4).withOpacity(0.2);
        canvas.drawLine(
          Offset(x, offset - 100),
          Offset(x, offset),
          paint,
        );
      }
    }

    // ========== CÍRCULOS FLOTANTES (PARTÍCULAS) ==========
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 8; i++) {
      double xPos = (size.width / 8) * i + (random.nextDouble() * 100);
      double yPos = ((animationValue + (i * 0.1)) % 1.0) * size.height;
      double radius = 2 + random.nextDouble() * 3;

      // Partícula principal
      paint.color = Color(0xFF00bcd4).withOpacity(0.3);
      canvas.drawCircle(
        Offset(xPos, yPos),
        radius,
        paint,
      );

      // Efecto de glow/brillo alrededor
      paint.color = Color(0xFF00bcd4).withOpacity(0.1);
      canvas.drawCircle(
        Offset(xPos, yPos),
        radius * 2,
        paint,
      );
    }

    // ========== LÍNEAS HORIZONTALES OPCIONALES ==========
    paint.style = PaintingStyle.stroke;
    for (int i = 0; i < 10; i++) {
      double y = (size.height / 10) * i;
      paint.color = Color(0xFF00bcd4).withOpacity(0.03);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
