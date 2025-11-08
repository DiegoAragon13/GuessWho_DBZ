import 'package:bandersnatch/Models/personajes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../models/datos.dart';

class VsMachineGame extends StatefulWidget {
  const VsMachineGame({super.key});

  @override
  State<VsMachineGame> createState() => _VsMachineGameState();
}

class _VsMachineGameState extends State<VsMachineGame> {
  late List<Personaje> personajes;
  late Personaje personajeSecreto;
  int intentos = 0;
  String? mensajeResultado;
  bool juegoTerminado = false;

  @override
  void initState() {
    super.initState();
    _iniciarJuego();
  }

  void _iniciarJuego() {
    setState(() {
      personajes = personajesData
          .map((data) => Personaje.fromJson(data))
          .toList();

      final random = Random();
      personajeSecreto = personajes[random.nextInt(personajes.length)];
      intentos = 0;
      mensajeResultado = null;
      juegoTerminado = false;
    });
  }

  void _hacerPregunta(String pregunta) {
    if (juegoTerminado) return;

    setState(() {
      intentos++;
      bool respuesta = personajeSecreto.caracteristicas.contains(pregunta);

      // Eliminar personajes según la respuesta
      for (var personaje in personajes) {
        if (respuesta) {
          // Si la respuesta es SÍ, eliminar los que NO tienen esa característica
          if (!personaje.caracteristicas.contains(pregunta)) {
            personaje.isEliminado = true;
          }
        } else {
          // Si la respuesta es NO, eliminar los que SÍ tienen esa característica
          if (personaje.caracteristicas.contains(pregunta)) {
            personaje.isEliminado = true;
          }
        }
      }

      // Mostrar resultado de la pregunta
      _mostrarRespuesta(pregunta, respuesta);
    });
  }

  void _mostrarRespuesta(String pregunta, bool respuesta) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: respuesta
                  ? [const Color(0xFF00C853), const Color(0xFF64DD17)]
                  : [const Color(0xFFD32F2F), const Color(0xFFB71C1C)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                respuesta ? Icons.check_circle : Icons.cancel,
                color: Colors.white,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                respuesta ? '¡SÍ!' : '¡NO!',
                style: GoogleFonts.bangers(
                  fontSize: 36,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                pregunta,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: respuesta
                      ? const Color(0xFF00C853)
                      : const Color(0xFFD32F2F),
                ),
                child: Text(
                  'CONTINUAR',
                  style: GoogleFonts.bangers(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _adivinarPersonaje(Personaje personaje) {
    if (juegoTerminado) return;

    setState(() {
      intentos++;
      juegoTerminado = true;

      if (personaje.nombre == personajeSecreto.nombre) {
        mensajeResultado = '¡GANASTE!';
        _mostrarResultadoFinal(true);
      } else {
        mensajeResultado = '¡PERDISTE!';
        _mostrarResultadoFinal(false);
      }
    });
  }

  void _mostrarResultadoFinal(bool gano) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gano
                  ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                  : [const Color(0xFF1A1F3A), const Color(0xFF2D1B4E)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: gano ? Colors.white : const Color(0xFFFFD700),
              width: 3,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                gano ? '🎉 ¡GANASTE! 🎉' : '😢 ¡PERDISTE!',
                style: GoogleFonts.bangers(
                  fontSize: 32,
                  color: gano ? Colors.black : const Color(0xFFFFD700),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'El personaje era:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: gano ? Colors.black87 : Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                personajeSecreto.nombre.toUpperCase(),
                style: GoogleFonts.bangers(
                  fontSize: 28,
                  color: gano ? Colors.black : const Color(0xFFFFD700),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Intentos: $intentos',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: gano ? Colors.black87 : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _iniciarJuego();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gano ? Colors.black : const Color(0xFFFFD700),
                      foregroundColor: gano ? Colors.white : Colors.black,
                    ),
                    child: Text(
                      'JUGAR DE NUEVO',
                      style: GoogleFonts.bangers(fontSize: 14),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: gano ? Colors.black : const Color(0xFFFFD700),
                    ),
                    child: Text(
                      'MENÚ',
                      style: GoogleFonts.bangers(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarPreguntas() {
    // Recopilar todas las características únicas de personajes activos
    Set<String> todasCaracteristicas = {};
    for (var personaje in personajes) {
      if (!personaje.isEliminado) {
        todasCaracteristicas.addAll(personaje.caracteristicas);
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1F3A),
              Color(0xFF2D1B4E),
            ],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'HAZ UNA PREGUNTA',
                    style: GoogleFonts.bangers(
                      fontSize: 24,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: todasCaracteristicas.length,
                itemBuilder: (context, index) {
                  final caracteristica = todasCaracteristicas.elementAt(index);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _hacerPregunta(caracteristica);
                        },
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF3D5AFE),
                                Color(0xFF7C4DFF),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3D5AFE).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.help_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  caracteristica,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final personajesActivos = personajes.where((p) => !p.isEliminado).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1A1F3A),
              Color(0xFF2D1B4E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        Text(
                          'VS MÁQUINA',
                          style: GoogleFonts.bangers(
                            fontSize: 24,
                            color: const Color(0xFFFFD700),
                          ),
                        ),
                        Text(
                          'Intentos: $intentos',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Personajes activos: ${personajesActivos.length}/${personajes.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Grid de personajes
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: personajes.length,
                  itemBuilder: (context, index) {
                    final personaje = personajes[index];
                    return GestureDetector(
                      onTap: () => _adivinarPersonaje(personaje),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: personaje.isEliminado
                                ? [Colors.grey.shade800, Colors.grey.shade900]
                                : [const Color(0xFF3D5AFE), const Color(0xFF7C4DFF)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: personaje.isEliminado
                                ? Colors.grey
                                : const Color(0xFFFFD700),
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Imagen del personaje
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                personaje.imagen,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.person,
                                        size: 50,
                                        color: personaje.isEliminado
                                            ? Colors.grey.shade600
                                            : Colors.white,
                                      ),
                                      const SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: Text(
                                          personaje.nombre,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: personaje.isEliminado
                                                ? Colors.grey.shade600
                                                : Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            // Nombre superpuesto
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.8),
                                      Colors.transparent,
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  personaje.nombre,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: personaje.isEliminado
                                        ? Colors.grey.shade500
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Overlay de eliminado
                            if (personaje.isEliminado)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 60,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Botón de preguntas
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: juegoTerminado ? null : _mostrarPreguntas,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 60),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.help_outline, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'HACER PREGUNTA',
                        style: GoogleFonts.bangers(
                          fontSize: 24,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}