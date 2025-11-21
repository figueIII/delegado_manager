import 'package:flutter/material.dart';

class GameTheme {
  final String id;
  final String nombre;
  final Color bgPrincipal;    // Fondo de pantalla
  final Color bgPanel;        // Fondo de los paneles/marcadores
  final Color colorPositivo;  // Color para BUC/Local (Cian, Verde...)
  final Color colorNegativo;  // Color para Rival/Visitante (Magenta, Rojo...)
  final Color textoPrincipal; // Color de los números y títulos

  GameTheme({
    required this.id,
    required this.nombre,
    required this.bgPrincipal,
    required this.bgPanel,
    required this.colorPositivo,
    required this.colorNegativo,
    required this.textoPrincipal,
  });

  // --- CATÁLOGO DE ESTILOS ---
  
  static final GameTheme cyberpunk = GameTheme(
    id: 'cyberpunk',
    nombre: 'Cyberpunk 2077',
    bgPrincipal: const Color(0xFF050A14),
    bgPanel: const Color(0xFF0A1020),
    colorPositivo: const Color(0xFF00F0FF), // Cian
    colorNegativo: const Color(0xFFFF003C), // Magenta
    textoPrincipal: const Color(0xCCFFFFFF),
  );

  static final GameTheme clasico = GameTheme(
    id: 'clasico',
    nombre: 'Césped Clásico',
    bgPrincipal: const Color(0xFF2E7D32), // Verde Césped
    bgPanel: const Color(0xFF1B5E20),     // Verde Oscuro
    colorPositivo: const Color(0xFFFFD700), // Dorado
    colorNegativo: const Color(0xFFFFFFFF), // Blanco
    textoPrincipal: const Color(0xFFFFFFFF),
  );

  static final GameTheme tactico = GameTheme(
    id: 'tactico',
    nombre: 'Pizarra Táctica',
    bgPrincipal: const Color(0xFF212121), // Gris Pizarra
    bgPanel: const Color(0xFF424242),
    colorPositivo: const Color(0xFF69F0AE), // Tiza Verde
    colorNegativo: const Color(0xFFFF5252), // Tiza Roja
    textoPrincipal: const Color(0xFFE0E0E0),
  );
  
  // Lista para mostrar en el menú
  static final List<GameTheme> todos = [cyberpunk, clasico, tactico];
  
  // Buscar por ID
  static GameTheme getById(String id) {
    return todos.firstWhere((t) => t.id == id, orElse: () => cyberpunk);
  }
}