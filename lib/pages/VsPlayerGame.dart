import 'package:bandersnatch/Models/personajes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../models/datos.dart';

class VsPlayerGame extends StatefulWidget {
  const VsPlayerGame({super.key});

  @override
  State<VsPlayerGame> createState() => _VsPlayerGameState();
}

class _VsPlayerGameState extends State<VsPlayerGame> {
  // Lista de personajes para cada jugador
  late List<Personaje> personajesJugador1;
  late List<Personaje> personajesJugador2;

  // Personajes secretos
  late Personaje personajeSecretoJ1;
  late Personaje personajeSecretoJ2;

  // Control del juego
  int turnoActual = 1; // 1 o 2
  int intentosJ1 = 0;
  int intentosJ2 = 0;
  bool juegoTerminado = false;
  String? ganador;

  @override
  void initState() {
    super.initState();
    _iniciarJuego();
  }

  void _iniciarJuego() {
    setState(() {
      // Crear listas independientes para cada jugador
      personajesJugador1 = personajesData
          .map((data) => Personaje.fromJson(data))
          .toList();

      personajesJugador2 = personajesData
          .map((data) => Personaje.fromJson(data))
          .toList();

      // Seleccionar personajes secretos aleatorios
      final random = Random();
      personajeSecretoJ1 = personajesJugador1[random.nextInt(personajesJugador1.length)];
      personajeSecretoJ2 = personajesJugador2[random.nextInt(personajesJugador2.length)];

      turnoActual = 1;
      intentosJ1 = 0;
      intentosJ2 = 0;
      juegoTerminado = false;
      ganador = null;
    });

    // Mostrar los personajes secretos asignados después de que el widget esté construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mostrarPersonajesSecretos();
    });
  }

  void _mostrarPersonajesSecretos() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1F3A), Color(0xFF2D1B4E)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFD700), width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¡PERSONAJES ASIGNADOS!',
                textAlign: TextAlign.center,
                style: GoogleFonts.bangers(
                  fontSize: 28,
                  color: const Color(0xFFFFD700),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Cada jugador debe memorizar su personaje secreto sin que el otro lo vea.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _mostrarPersonajeJugador(1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  'VER PERSONAJE JUGADOR 1',
                  style: GoogleFonts.bangers(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarPersonajeJugador(int jugador) {
    final personaje = jugador == 1 ? personajeSecretoJ1 : personajeSecretoJ2;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: jugador == 1
                  ? [const Color(0xFF3D5AFE), const Color(0xFF7C4DFF)]
                  : [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'JUGADOR $jugador',
                style: GoogleFonts.bangers(
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tu personaje secreto es:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        personaje.imagen,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            width: 150,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.person, size: 80),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      personaje.nombre.toUpperCase(),
                      style: GoogleFonts.bangers(
                        fontSize: 28,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '¡Memoriza bien este personaje!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (jugador == 1) {
                    // Pasar al jugador 2
                    Future.delayed(const Duration(milliseconds: 300), () {
                      _mostrarPersonajeJugador(2);
                    });
                  }
                  // Si es jugador 2, simplemente cerrar y empezar el juego
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: jugador == 1
                      ? const Color(0xFF3D5AFE)
                      : const Color(0xFFFF6B6B),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  jugador == 1 ? 'CONTINUAR' : 'COMENZAR JUEGO',
                  style: GoogleFonts.bangers(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _hacerPregunta(String pregunta) {
    if (juegoTerminado) return;

    final personajesActuales = turnoActual == 1 ? personajesJugador1 : personajesJugador2;
    final personajeObjetivo = turnoActual == 1 ? personajeSecretoJ2 : personajeSecretoJ1;

    setState(() {
      if (turnoActual == 1) {
        intentosJ1++;
      } else {
        intentosJ2++;
      }

      bool respuesta = personajeObjetivo.caracteristicas.contains(pregunta);

      // Eliminar personajes según la respuesta
      for (var personaje in personajesActuales) {
        if (respuesta) {
          if (!personaje.caracteristicas.contains(pregunta)) {
            personaje.isEliminado = true;
          }
        } else {
          if (personaje.caracteristicas.contains(pregunta)) {
            personaje.isEliminado = true;
          }
        }
      }
    });

    // Mostrar respuesta y cambiar turno
    _mostrarRespuesta(pregunta, personajeObjetivo.caracteristicas.contains(pregunta));
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
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    turnoActual = turnoActual == 1 ? 2 : 1;
                  });
                  _mostrarCambioTurno();
                },
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

  void _mostrarCambioTurno() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: turnoActual == 1
                  ? [const Color(0xFF3D5AFE), const Color(0xFF7C4DFF)]
                  : [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.swap_horiz,
                color: Colors.white,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'TURNO DEL',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Text(
                'JUGADOR $turnoActual',
                style: GoogleFonts.bangers(
                  fontSize: 36,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: turnoActual == 1
                      ? const Color(0xFF3D5AFE)
                      : const Color(0xFFFF6B6B),
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

    final personajeObjetivo = turnoActual == 1 ? personajeSecretoJ2 : personajeSecretoJ1;

    setState(() {
      if (turnoActual == 1) {
        intentosJ1++;
      } else {
        intentosJ2++;
      }
      juegoTerminado = true;

      if (personaje.nombre == personajeObjetivo.nombre) {
        ganador = 'Jugador $turnoActual';
        _mostrarResultadoFinal(true);
      } else {
        ganador = 'Jugador ${turnoActual == 1 ? 2 : 1}';
        _mostrarResultadoFinal(false);
      }
    });
  }

  void _mostrarResultadoFinal(bool adivinoCorrectamente) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: adivinoCorrectamente
                  ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                  : [const Color(0xFF1A1F3A), const Color(0xFF2D1B4E)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: adivinoCorrectamente ? Colors.white : const Color(0xFFFFD700),
              width: 3,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                adivinoCorrectamente ? '🎉 ¡CORRECTO! 🎉' : '❌ ¡INCORRECTO!',
                style: GoogleFonts.bangers(
                  fontSize: 32,
                  color: adivinoCorrectamente ? Colors.black : const Color(0xFFFFD700),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '¡GANADOR!',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: adivinoCorrectamente ? Colors.black87 : Colors.white,
                ),
              ),
              Text(
                ganador!.toUpperCase(),
                style: GoogleFonts.bangers(
                  fontSize: 32,
                  color: adivinoCorrectamente ? Colors.black : const Color(0xFFFFD700),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Los personajes secretos eran:',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: adivinoCorrectamente ? Colors.black87 : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'J1: ${personajeSecretoJ1.nombre}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: adivinoCorrectamente ? Colors.black : const Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'J2: ${personajeSecretoJ2.nombre}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: adivinoCorrectamente ? Colors.black : const Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Intentos J1: $intentosJ1 | J2: $intentosJ2',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: adivinoCorrectamente ? Colors.black87 : Colors.white,
                      ),
                    ),
                  ],
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
                      backgroundColor: adivinoCorrectamente ? Colors.black : const Color(0xFFFFD700),
                      foregroundColor: adivinoCorrectamente ? Colors.white : Colors.black,
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
                      foregroundColor: adivinoCorrectamente ? Colors.black : const Color(0xFFFFD700),
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
    final personajesActuales = turnoActual == 1 ? personajesJugador1 : personajesJugador2;

    // Recopilar todas las características únicas de personajes activos
    Set<String> todasCaracteristicas = {};
    for (var personaje in personajesActuales) {
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: turnoActual == 1
                ? [const Color(0xFF3D5AFE), const Color(0xFF7C4DFF)]
                : [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
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
                    'JUGADOR $turnoActual',
                    style: GoogleFonts.bangers(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'HAZ UNA PREGUNTA',
                    style: GoogleFonts.bangers(
                      fontSize: 24,
                      color: Colors.white,
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
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white, width: 2),
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
    final personajesActuales = turnoActual == 1 ? personajesJugador1 : personajesJugador2;
    final personajesActivos = personajesActuales.where((p) => !p.isEliminado).toList();

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
                          'VS JUGADOR',
                          style: GoogleFonts.bangers(
                            fontSize: 24,
                            color: const Color(0xFFFFD700),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: turnoActual == 1
                                  ? [const Color(0xFF3D5AFE), const Color(0xFF7C4DFF)]
                                  : [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'TURNO: JUGADOR $turnoActual',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3D5AFE), Color(0xFF7C4DFF)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'JUGADOR 1',
                              style: GoogleFonts.bangers(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Intentos: $intentosJ1',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'JUGADOR 2',
                              style: GoogleFonts.bangers(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Intentos: $intentosJ2',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Personajes activos: ${personajesActivos.length}/${personajesActuales.length}',
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
                  itemCount: personajesActuales.length,
                  itemBuilder: (context, index) {
                    final personaje = personajesActuales[index];
                    return GestureDetector(
                      onTap: () => _adivinarPersonaje(personaje),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: personaje.isEliminado
                                ? [Colors.grey.shade800, Colors.grey.shade900]
                                : turnoActual == 1
                                ? [const Color(0xFF3D5AFE), const Color(0xFF7C4DFF)]
                                : [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
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