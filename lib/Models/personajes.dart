class Personaje {
  final String nombre;
  final List<String> caracteristicas;
  final String imagen;
  bool isEliminado;

  Personaje({
    required this.nombre,
    required this.caracteristicas,
    required this.imagen,
    this.isEliminado = false,
  });

  factory Personaje.fromJson(Map<String, dynamic> json) {
    return Personaje(
      nombre: json['nombre'],
      caracteristicas: List<String>.from(json['caracteristicas']),
      imagen: json['imagen'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'caracteristicas': caracteristicas,
      'imagen': imagen,
    };
  }
}