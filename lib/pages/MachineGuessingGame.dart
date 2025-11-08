import 'package:bandersnatch/Models/personajes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../models/datos.dart';

class MachineGuessingGame extends StatefulWidget {
  const MachineGuessingGame({super.key});

  @override
  State<MachineGuessingGame> createState() => _MachineGuessingGameState();
}

class _MachineGuessingGameState extends State<MachineGuessingGame> {
  late List<Personaje> personajesDisponibles;
  int intentosMaquina = 0;
  bool juegoTerminado = false;
  Personaje? personajeAdivinado;
  String? preguntaActual;

  @override
  void initState() {
    super.initState();
    _iniciarJuego();
  }

  void _iniciarJuego() {
    setState(() {
      personajesDisponibles = personajesData
          .map((data) => Personaje.fromJson(data))
          .toList();
      intentosMaquina = 0;
      juegoTerminado = false;
      personajeAdivinado = null;
      preguntaActual = null;
    });

    // Mostrar instrucciones iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mostrarInstrucciones();
    });
  }

  void _mostrarInstrucciones() {
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
              const Icon(
                Icons.psychology,
                color: Color(0xFFFFD700),
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                '¡LA MÁQUINA ADIVINA!',
                textAlign: TextAlign.center,
                style: GoogleFonts.bangers(
                  fontSize: 28,
                  color: const Color(0xFFFFD700),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Piensa en un personaje de Dragon Ball y la máquina intentará adivinarlo haciendo preguntas.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Responde SÍ o NO a cada pregunta según el personaje que elegiste.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _hacerPreguntaMaquina();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  'EMPEZAR',
                  style: GoogleFonts.bangers(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _obtenerPreguntaInteligente() {
    if (personajesDisponibles.isEmpty) return '';

    // Contar frecuencia de cada característica en los personajes disponibles
    Map<String, int> frecuenciaCaracteristicas = {};

    for (var personaje in personajesDisponibles) {
      for (var caracteristica in personaje.caracteristicas) {
        frecuenciaCaracteristicas[caracteristica] =
            (frecuenciaCaracteristicas[caracteristica] ?? 0) + 1;
      }
    }

    // Encontrar la característica que divide mejor el conjunto
    // (lo más cercano a 50% de los personajes)
    String? mejorPregunta;
    int mejorDiferencia = personajesDisponibles.length;
    int mitad = personajesDisponibles.length ~/ 2;

    frecuenciaCaracteristicas.forEach((caracteristica, frecuencia) {
      int diferencia = (frecuencia - mitad).abs();
      if (diferencia < mejorDiferencia) {
        mejorDiferencia = diferencia;
        mejorPregunta = caracteristica;
      }
    });

    return mejorPregunta ?? personajesDisponibles.first.caracteristicas.first;
  }

  void _hacerPreguntaMaquina() {
    if (juegoTerminado) return;

    // Si solo queda un personaje, la máquina intenta adivinar
    if (personajesDisponibles.length == 1) {
      _intentarAdivinar(personajesDisponibles.first);
      return;
    }

    // Si quedan pocos personajes, puede intentar adivinar directamente
    if (personajesDisponibles.length <= 3 && Random().nextBool()) {
      final personajeAleatorio = personajesDisponibles[
      Random().nextInt(personajesDisponibles.length)];
      _intentarAdivinar(personajeAleatorio);
      return;
    }

    setState(() {
      preguntaActual = _obtenerPreguntaInteligente();
      intentosMaquina++;
    });

    _mostrarPregunta();
  }

  void _mostrarPregunta() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3D5AFE), Color(0xFF7C4DFF)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.help_outline,
                color: Colors.white,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'LA MÁQUINA PREGUNTA:',
                style: GoogleFonts.bangers(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '¿$preguntaActual?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _procesarRespuesta(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.check, size: 30),
                          const SizedBox(height: 4),
                          Text(
                            'SÍ',
                            style: GoogleFonts.bangers(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _procesarRespuesta(false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.close, size: 30),
                          const SizedBox(height: 4),
                          Text(
                            'NO',
                            style: GoogleFonts.bangers(fontSize: 20),
                          ),
                        ],
                      ),
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

  void _procesarRespuesta(bool respuesta) {
    setState(() {
      // Eliminar personajes según la respuesta
      personajesDisponibles = personajesDisponibles.where((personaje) {
        bool tieneCaracteristica = personaje.caracteristicas.contains(preguntaActual);

        if (respuesta) {
          // Si la respuesta es SÍ, mantener solo los que tienen la característica
          return tieneCaracteristica;
        } else {
          // Si la respuesta es NO, mantener solo los que NO tienen la característica
          return !tieneCaracteristica;
        }
      }).toList();

      // Marcar como eliminados los que ya no están disponibles
      for (var personaje in personajesData.map((data) => Personaje.fromJson(data))) {
        if (!personajesDisponibles.any((p) => p.nombre == personaje.nombre)) {
          personaje.isEliminado = true;
        }
      }
    });

    // Esperar un momento antes de la siguiente pregunta
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _hacerPreguntaMaquina();
      }
    });
  }

  void _intentarAdivinar(Personaje personaje) {
    setState(() {
      personajeAdivinado = personaje;
      intentosMaquina++;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lightbulb,
                color: Colors.white,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                '¡YA LO SÉ!',
                style: GoogleFonts.bangers(
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '¿Tu personaje es...?',
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
                '¿Es correcto?',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _finalizarJuego(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        '¡SÍ, ACERTÓ!',
                        style: GoogleFonts.bangers(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _falloAdivinanza();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'NO ES ESE',
                        style: GoogleFonts.bangers(fontSize: 16),
                      ),
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

  void _falloAdivinanza() {
    // Eliminar el personaje que falló y continuar
    setState(() {
      personajesDisponibles.removeWhere((p) => p.nombre == personajeAdivinado?.nombre);
    });

    if (personajesDisponibles.isEmpty) {
      _finalizarJuego(false);
    } else {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _hacerPreguntaMaquina();
        }
      });
    }
  }

  void _finalizarJuego(bool maquinaGano) {
    setState(() {
      juegoTerminado = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: maquinaGano
                  ? [const Color(0xFF3D5AFE), const Color(0xFF7C4DFF)]
                  : [const Color(0xFF1A1F3A), const Color(0xFF2D1B4E)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: maquinaGano ? Colors.white : const Color(0xFFFFD700),
              width: 3,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                maquinaGano ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                color: maquinaGano ? const Color(0xFFFFD700) : Colors.white,
                size: 80,
              ),
              const SizedBox(height: 16),
              Text(
                maquinaGano ? '¡LA MÁQUINA GANÓ!' : '¡GANASTE!',
                style: GoogleFonts.bangers(
                  fontSize: 32,
                  color: maquinaGano ? const Color(0xFFFFD700) : Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                maquinaGano
                    ? '¡La máquina adivinó tu personaje!'
                    : 'La máquina no pudo adivinar tu personaje.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Preguntas realizadas: $intentosMaquina',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (maquinaGano && personajeAdivinado != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Personaje: ${personajeAdivinado!.nombre}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
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
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
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
                      foregroundColor: maquinaGano
                          ? const Color(0xFF3D5AFE)
                          : const Color(0xFFFFD700),
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

  @override
  Widget build(BuildContext context) {
    // Crear lista completa para mostrar
    final todosPersonajes = personajesData
        .map((data) => Personaje.fromJson(data))
        .toList();

    // Marcar como eliminados los que ya no están disponibles
    for (var personaje in todosPersonajes) {
      personaje.isEliminado = !personajesDisponibles.any((p) => p.nombre == personaje.nombre);
    }

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
                        Row(
                          children: [
                            const Icon(
                              Icons.psychology,
                              color: Color(0xFFFFD700),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'MÁQUINA ADIVINA',
                              style: GoogleFonts.bangers(
                                fontSize: 24,
                                color: const Color(0xFFFFD700),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Preguntas: $intentosMaquina',
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
                    'Personajes posibles: ${personajesDisponibles.length}/${todosPersonajes.length}',
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
                  itemCount: todosPersonajes.length,
                  itemBuilder: (context, index) {
                    final personaje = todosPersonajes[index];
                    return Container(
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
                    );
                  },
                ),
              ),

              // Botón de ayuda
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFFFFD700),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFFFFD700),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'La máquina está pensando y eliminando personajes...',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                          ),
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