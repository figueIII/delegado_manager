import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/jugador.dart';
import '../models/game_theme.dart';

class DataManager extends ChangeNotifier {
  GameTheme temaActual = GameTheme.cyberpunk;
  // Método para guardar cambios tras editar un jugador (Nombre, Dorsal, etc.)
  void actualizarJugador() {
    _guardarDatos();
    notifyListeners();
  }
  // CONFIGURACIÓN DE REGLAS (Ajustes)
  int minFormacionRequeridos = 4; // Valor por defecto, editable en Ajustes

  // DATOS
  List<Jugador> plantilla = [];
  List<Jugador> convocados = [];
  List<Jugador> titulares = [];
  List<Jugador> suplentes = [];

  int puntosBUC = 0;
  int puntosRival = 0;
  int segundosPartido = 0;
  bool relojCorriendo = false;
  Timer? _timerPartido;

  DataManager() {
    _cargarDatos();
  }

  // --- VALIDACIONES DE REGLAS (EL CEREBRO DEL DELEGADO) ---

  // 1. Validar CONVOCATORIA (Lista de 23)
  // 1. Validar CONVOCATORIA (Lista de 23)
  String? validarReglasConvocatoria() {
    int total = convocados.length;
    int primerasLineas = convocados.where((j) => j.esPrimeraLinea).length;
    int formacion = convocados.where((j) => j.esFormacion).length;

    // Regla de Tamaño
    if (total > 23) return "ALERTA: Demasiados jugadores. Máximo 23.";

    // --- REGLA DE ORO DE LA PRIMERA LÍNEA (World Rugby) ---
    int min1a = 0;
    
    // Si convocas 15 o menos -> Necesitas 3 primeras líneas (para empezar)
    if (total <= 15) min1a = 3; 
    // Si convocas 16, 17 o 18 -> Necesitas 4 primeras líneas
    else if (total <= 18) min1a = 4;
    // Si convocas 19, 20, 21 o 22 -> Necesitas 5 primeras líneas
    else if (total <= 22) min1a = 5;
    // Si convocas 23 -> Necesitas 6 primeras líneas (obligatorio tener recambio completo)
    else if (total == 23) min1a = 6;

    if (primerasLineas < min1a) {
      return "ALERTA 1a LÍNEA: Con $total jugadores convocados, el reglamento exige tener al menos $min1a primeras líneas. Tienes $primerasLineas.";
    }

    // Regla de Formación (Slider)
    if (formacion < minFormacionRequeridos) {
      return "ALERTA FORMACIÓN: Faltan cupos 'F'. Tienes $formacion, necesitas $minFormacionRequeridos.";
    }

    return null; // Todo OK
  }
  // 2. Validar XV INICIAL
  String? validarReglasTitulares() {
    int primeras = titulares.where((j) => j.esPrimeraLinea).length;
    
    if (primeras < 3) {
      return "ALERTA: El XV inicial debe tener al menos 3 primeras líneas.";
    }
    return null;
  }

  // 3. Validar CAMBIOS (Sustituciones en directo)
  String? validarReglasCambio(Jugador entra, Jugador sale) {
    // Hacemos una simulación: ¿Cómo quedaría el campo si hacemos el cambio?
    int primerasEnCampo = titulares.where((j) => j.esPrimeraLinea).length;
    
    // Si sale un 1a...
    if (sale.esPrimeraLinea) {
      // ...y entra alguien que NO es 1a...
      if (!entra.esPrimeraLinea) {
        // ...verificamos cuántos quedarían
        int quedarian = primerasEnCampo - 1;
        if (quedarian < 3) {
          return "ALERTA GRAVE: Si sacas a ${sale.nombre}, te quedas sin primeras líneas suficientes ($quedarian). Melés simuladas.";
        }
      }
    }
    return null; // Cambio legal
  }

  // --- MÉTODOS DE GESTIÓN (Guardar/Cargar/Logic) ---
  
  // Configuración
  void setMinFormacion(int valor) {
    minFormacionRequeridos = valor;
    _guardarDatos();
    notifyListeners();
  }

  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    String temaId = prefs.getString('temaId') ?? 'cyberpunk';
    temaActual = GameTheme.getById(temaId);
    
    minFormacionRequeridos = prefs.getInt('minFormacion') ?? 4;

    final plantillaString = prefs.getStringList('plantilla') ?? [];
    plantilla = plantillaString.map((e) => Jugador.fromJson(jsonDecode(e))).toList();

    final titularesString = prefs.getStringList('titulares') ?? [];
    titulares = titularesString.map((e) => Jugador.fromJson(jsonDecode(e))).toList();
    
    final suplentesString = prefs.getStringList('suplentes') ?? [];
    suplentes = suplentesString.map((e) => Jugador.fromJson(jsonDecode(e))).toList();

    puntosBUC = prefs.getInt('puntosBUC') ?? 0;
    puntosRival = prefs.getInt('puntosRival') ?? 0;
    segundosPartido = prefs.getInt('segundosPartido') ?? 0;

    notifyListeners();
  }

  Future<void> _guardarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('temaId', temaActual.id);
    prefs.setInt('minFormacion', minFormacionRequeridos);
    prefs.setStringList('plantilla', plantilla.map((e) => jsonEncode(e.toJson())).toList());
    prefs.setStringList('titulares', titulares.map((e) => jsonEncode(e.toJson())).toList());
    prefs.setStringList('suplentes', suplentes.map((e) => jsonEncode(e.toJson())).toList());
    prefs.setInt('puntosBUC', puntosBUC);
    prefs.setInt('puntosRival', puntosRival);
    prefs.setInt('segundosPartido', segundosPartido);
  }

  // ... [RESTO DE MÉTODOS DE GESTIÓN IGUAL QUE ANTES] ...
  // Agregar, Eliminar, Toggle Convocado, Toggle Titular, Iniciar Partido, Reloj, Puntos, Reset...
  // COPIA AQUÍ EL RESTO DE TUS MÉTODOS EXISTENTES O USA EL ARCHIVO ANTERIOR AÑADIENDO LO NUEVO ARRIBA.
  
  // Para completitud, incluyo los métodos básicos necesarios para que compile directo:
  void cambiarTema(GameTheme t) { temaActual = t; _guardarDatos(); notifyListeners(); }
  void agregarJugador(Jugador j) { plantilla.add(j); _guardarDatos(); notifyListeners(); }
  void eliminarJugador(Jugador j) { plantilla.remove(j); _guardarDatos(); notifyListeners(); }
  void toggleConvocado(Jugador j) { 
    if(convocados.contains(j)) {
      convocados.remove(j);
    } else {
      convocados.add(j);
    } 
    notifyListeners(); 
  }
  void limpiarConvocados() { convocados.clear(); notifyListeners(); }
  void toggleTitular(Jugador j) {
    if(titulares.contains(j)) {
      titulares.remove(j);
    } else {
      titulares.add(j);
    }
    notifyListeners();
  }
  void iniciarPartidoLogica() {
    suplentes = convocados.where((j) => !titulares.contains(j)).toList();
    _guardarDatos();
    notifyListeners();
  }
  void toggleReloj() {
    relojCorriendo = !relojCorriendo;
    if (relojCorriendo) {
      _timerPartido = Timer.periodic(const Duration(seconds: 1), (t) {
        segundosPartido++;
        for (var j in titulares) {
          j.segundosJugados++;
        }
        if(segundosPartido % 5 == 0) _guardarDatos();
        notifyListeners();
      });
    } else { _timerPartido?.cancel(); _guardarDatos(); }
    notifyListeners();
  }
  void cambiarPuntos(bool esBUC, int v) { 
    if(esBUC) {
      puntosBUC += v;
    } else {
      puntosRival += v;
    } 
    if(puntosBUC < 0) puntosBUC = 0; if(puntosRival < 0) puntosRival = 0;
    notifyListeners(); 
  }
  void reiniciarTiempoPartido() { segundosPartido = 0; _guardarDatos(); notifyListeners(); }
  void reiniciarTiemposJugadores() { for(var j in plantilla) {
    j.segundosJugados = 0;
  } _guardarDatos(); notifyListeners(); }
  void finalizarPartido() { 
    _timerPartido?.cancel(); relojCorriendo = false; 
    titulares.clear(); suplentes.clear(); convocados.clear(); 
    segundosPartido = 0; puntosBUC = 0; puntosRival = 0; 
    _guardarDatos(); notifyListeners(); 
  }
  bool realizarCambio(Jugador entra, Jugador sale) {
    if (!suplentes.contains(entra) || !titulares.contains(sale)) return false;
    suplentes.remove(entra); titulares.remove(sale);
    titulares.add(entra); suplentes.add(sale);
    _guardarDatos(); notifyListeners();
    return true;
  }
  String get tiempoPartidoFormateado {
    int m = (segundosPartido / 60).floor(); int s = segundosPartido % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }
}