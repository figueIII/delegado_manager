class Jugador {
  String nombre;
  int segundosJugados;
  
  // Nuevos atributos para Delegado
  int dorsal;           // Número en la camiseta
  bool esPrimeraLinea;  // "1a" - Prop/Hooker
  bool esFormacion;     // "F" - Homegrown/Canterano

  Jugador({
    required this.nombre,
    this.segundosJugados = 0,
    this.dorsal = 0,
    this.esPrimeraLinea = false,
    this.esFormacion = false,
  });

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'segundosJugados': segundosJugados,
        'dorsal': dorsal,
        'esPrimeraLinea': esPrimeraLinea,
        'esFormacion': esFormacion,
      };

  factory Jugador.fromJson(Map<String, dynamic> json) {
    return Jugador(
      nombre: json['nombre'],
      segundosJugados: json['segundosJugados'] ?? 0,
      dorsal: json['dorsal'] ?? 0,
      esPrimeraLinea: json['esPrimeraLinea'] ?? false,
      esFormacion: json['esFormacion'] ?? false,
    );
  }

  String get tiempoFormateado {
    int minutos = (segundosJugados / 60).floor();
    int segundos = segundosJugados % 60;
    String minStr = minutos.toString().padLeft(2, '0');
    String secStr = segundos.toString().padLeft(2, '0');
    return "$minStr:$secStr";
  }
  
  // Helper para mostrar atributos cortos (ej: "1a | F")
  String get etiquetas {
    List<String> tags = [];
    if (esPrimeraLinea) tags.add("1a");
    if (esFormacion) tags.add("F");
    return tags.join(" | ");
  }
}