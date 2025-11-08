import 'package:bandersnatch/pages/GameScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DragonBallSplash extends StatefulWidget {
  const DragonBallSplash({super.key});

  @override
  State<DragonBallSplash> createState() => _DragonBallSplashState();
}

class _DragonBallSplashState extends State<DragonBallSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _titleTextAnimation;
  late Animation<double> _subtitleTextAnimation;
  late Animation<double> _dragonBallRotation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _titleTextAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.7, curve: Curves.easeInOut),
      ),
    );

    _subtitleTextAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.8, curve: Curves.easeInOut),
      ),
    );

    _dragonBallRotation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 4000), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const GameScreen(),
              transitionDuration: const Duration(milliseconds: 800),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF6B35), // Naranja intenso
              Color(0xFFE63946), // Rojo Dragon Ball
              Color(0xFF8B0000), // Rojo oscuro
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                // Estrellas del fondo
                ...List.generate(30, (index) {
                  return Positioned(
                    left: (index * 43) % size.width,
                    top: (index * 67) % size.height,
                    child: FadeTransition(
                      opacity: _logoOpacityAnimation,
                      child: Container(
                        width: index % 3 == 0 ? 3 : 2,
                        height: index % 3 == 0 ? 3 : 2,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Contenido principal
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),

                      // Dragon Ball con estrellas
                      FadeTransition(
                        opacity: _logoOpacityAnimation,
                        child: ScaleTransition(
                          scale: _logoScaleAnimation,
                          child: RotationTransition(
                            turns: _dragonBallRotation,
                            child: Container(
                              width: size.width * 0.45,
                              height: size.width * 0.45,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(
                                  colors: [
                                    Color(0xFFFFD700), // Dorado brillante
                                    Color(0xFFFFA500), // Naranja
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700).withOpacity(0.6),
                                    blurRadius: 40,
                                    spreadRadius: 15,
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFFFFA500).withOpacity(0.4),
                                    blurRadius: 60,
                                    spreadRadius: 20,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Estrellas rojas en la Dragon Ball
                                  Positioned(
                                    top: size.width * 0.12,
                                    child: _buildStar(size.width * 0.08),
                                  ),
                                  Positioned(
                                    bottom: size.width * 0.12,
                                    left: size.width * 0.12,
                                    child: _buildStar(size.width * 0.06),
                                  ),
                                  Positioned(
                                    bottom: size.width * 0.15,
                                    right: size.width * 0.10,
                                    child: _buildStar(size.width * 0.05),
                                  ),
                                  Positioned(
                                    top: size.width * 0.18,
                                    left: size.width * 0.08,
                                    child: _buildStar(size.width * 0.055),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.06),

                      // Título DRAGON BALL
                      FadeTransition(
                        opacity: _titleTextAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _controller,
                              curve: const Interval(0.5, 0.7, curve: Curves.easeOut),
                            ),
                          ),
                          child: Text(
                            "DRAGON BALL",
                            style: GoogleFonts.bangers(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFFD700),
                              letterSpacing: 4.0,
                              shadows: [
                                Shadow(
                                  color: const Color(0xFFFF4500),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                                Shadow(
                                  color: Colors.black.withOpacity(0.8),
                                  blurRadius: 10,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Subtítulo
                      FadeTransition(
                        opacity: _subtitleTextAnimation,
                        child: Text(
                          "ADIVINA QUIÉN",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 4.0,
                            shadows: [
                              Shadow(
                                color: Colors.blue.withOpacity(0.8),
                                blurRadius: 15,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Indicador de carga
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: SizedBox(
                          width: 35,
                          height: 35,
                          child: CircularProgressIndicator(
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFFFD700),
                            ),
                            backgroundColor: Colors.white.withOpacity(0.2),
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFDC143C), // Rojo intenso
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC143C).withOpacity(0.6),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.star,
          color: const Color(0xFFFFD700),
          size: size * 0.6,
        ),
      ),
    );
  }
}
