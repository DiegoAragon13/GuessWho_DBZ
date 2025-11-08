import 'package:bandersnatch/pages/VsMachineGame.dart';
import 'package:bandersnatch/pages/VsPlayerGame.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bandersnatch/pages/MachineGuessingGame.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  void _showGameInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1F3A),
                  Color(0xFF2D1B4E),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFD700),
                width: 3,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Text(
                  '¿CÓMO JUGAR?',
                  style: GoogleFonts.bangers(
                    fontSize: 28,
                    color: const Color(0xFFFFD700),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                // Descripción
                Text(
                  'Adivina el personaje secreto de Dragon Ball\n\n'
                      'Haz preguntas de SÍ o NO sobre el personaje\n\n'
                      'Usa la información para descubrir quién es\n\n'
                      '¡Gana adivinando con menos preguntas!\n\n'
                      'Juega contra la máquina o con un amigo',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Botón cerrar
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    '¡ENTENDIDO!',
                    style: GoogleFonts.bangers(
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
              Color(0xFFFF6B35),
              Color(0xFFE63946),
              Color(0xFF8B0000),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Estrellas de fondo
              ...List.generate(25, (index) {
                return Positioned(
                  left: (index * 47) % size.width,
                  top: (index * 71) % size.height,
                  child: Container(
                    width: 2,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),

              // Contenido principal
              Column(
                children: [
                  const Spacer(),

                  // Título del juego
                  Text(
                    'DRAGON BALL',
                    style: GoogleFonts.bangers(
                      fontSize: 54,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFD700),
                      letterSpacing: 4.0,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.8),
                          blurRadius: 15,
                          offset: const Offset(3, 3),
                        ),
                        const Shadow(
                          color: Color(0xFFFF4500),
                          blurRadius: 25,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'ADIVINA QUIÉN',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 3.0,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.7),
                          blurRadius: 10,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Botones de juego
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        // Botón VS Máquina

                        _buildMenuButton(
                          context: context,
                          icon: Icons.smart_toy,
                          label: 'VS JUGADOR',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const VsMachineGame(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        _buildMenuButton(
                          context: context,
                          label: 'VS MÁQUINA',
                          icon: Icons.person_2,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MachineGuessingGame(
                            ),),
                            );
                          },
                        ),
//
                        const SizedBox(height: 20),

                        // Botón VS Jugador
                        _buildMenuButton(
                          context: context,
                          icon: Icons.person,
                          label: 'VS Jugador',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const VsPlayerGame(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),
                ],
              ),

              // Botón de ayuda (?)
              Positioned(
                top: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () => _showGameInfo(context),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFD700),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.help_outline,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFD700),
            Color(0xFFFFA500),
          ],
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(35),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.black,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.bangers(
                  fontSize: 28,
                  color: Colors.black,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}