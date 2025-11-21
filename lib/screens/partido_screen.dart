import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_manager.dart';
import '../models/jugador.dart';
import '../models/game_theme.dart';

class PartidoScreen extends StatelessWidget {
  const PartidoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataManager>(context);
    final tema = data.temaActual;

    return Scaffold(
      backgroundColor: tema.bgPrincipal,
      appBar: AppBar(
        backgroundColor: tema.bgPrincipal,
        elevation: 0,
        title: Text('GESTIÓN DE MINUTOS', 
          style: TextStyle(
            color: tema.colorPositivo, 
            letterSpacing: 4, 
            fontWeight: FontWeight.w200, 
            fontSize: 16
          )
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: tema.colorPositivo.withOpacity(0.3), height: 1), 
        ),
        actions: [
           IconButton(
             icon: Icon(Icons.palette_outlined, color: tema.colorPositivo),
             tooltip: "Cambiar Visualización",
             onPressed: () => _mostrarSelectorTemas(context, data),
           ),
           IconButton(
             icon: Icon(Icons.power_settings_new, color: tema.colorNegativo),
             onPressed: () => _confirmarSalida(context, data),
           )
        ],
      ),
      body: Column(
        children: [
          // --- MARCADOR PRINCIPAL (CUADRADO) ---
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tema.bgPanel,
              border: Border.all(color: tema.colorPositivo.withOpacity(0.5), width: 1),
              boxShadow: [
                BoxShadow(color: tema.colorPositivo.withOpacity(0.1), blurRadius: 15, spreadRadius: 1)
              ]
            ),
            child: Column(
              children: [
                // RELOJ
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    data.tiempoPartidoFormateado, 
                    style: TextStyle(
                      color: data.relojCorriendo ? tema.colorPositivo : tema.textoPrincipal.withOpacity(0.8),
                      fontSize: 60, 
                      fontWeight: FontWeight.w100, 
                      letterSpacing: 5,
                      fontFamily: 'Courier', 
                    )
                  ),
                ),
                const SizedBox(height: 15),
                
                // MARCADORES Y BOTONES
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _ThemeScore(
                        label: "BUC", 
                        score: data.puntosBUC, 
                        color: tema.colorPositivo, 
                        textoColor: tema.textoPrincipal, 
                        onChange: (v) => data.cambiarPuntos(true, v)
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: InkWell(
                        onTap: data.toggleReloj,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: data.relojCorriendo ? tema.colorNegativo : tema.colorPositivo, width: 2),
                            color: (data.relojCorriendo ? tema.colorNegativo : tema.colorPositivo).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4)
                          ),
                          child: Text(
                            data.relojCorriendo ? "STOP" : "RUN", 
                            style: TextStyle(
                              color: data.relojCorriendo ? tema.colorNegativo : tema.colorPositivo, 
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                              fontSize: 14
                            )
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: _ThemeScore(
                        label: "RIVAL", 
                        score: data.puntosRival, 
                        color: tema.colorNegativo, 
                        textoColor: tema.textoPrincipal, 
                        onChange: (v) => data.cambiarPuntos(false, v)
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // --- PANELES DE JUGADORES (SIN TIEMPO) ---
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _ThemePanel(
                    titulo: "JUGANDO",
                    color: tema.colorPositivo,
                    textColor: tema.textoPrincipal,
                    jugadores: data.titulares,
                    alineacion: CrossAxisAlignment.start,
                  ),
                ),
                Container(width: 1, color: Colors.white10),
                Expanded(
                  child: _ThemePanel(
                    titulo: "EN EL BANQUILLO",
                    color: Colors.grey,
                    textColor: tema.textoPrincipal,
                    jugadores: data.suplentes,
                    alineacion: CrossAxisAlignment.end,
                  ),
                ),
              ],
            ),
          ),

          // --- ZONA DE CONTROL ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tema.bgPanel,
              border: Border(top: BorderSide(color: tema.colorPositivo, width: 1))
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: tema.colorPositivo.withOpacity(0.5),
                      elevation: 10,
                      side: BorderSide(color: tema.colorPositivo, width: 1),
                      shape: const BeveledRectangleBorder(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomRight: Radius.circular(10))
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18)
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/cambios'),
                    child: Text("REALIZAR UNA SUSTITUCION", 
                      style: TextStyle(color: tema.colorPositivo, letterSpacing: 2, fontWeight: FontWeight.w300)),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ThemeTextButton("RESET CRONO", tema.textoPrincipal, 
                       () => _confirmarAccion(context, "REINICIAR CRONO", "¿Resetear tiempo de partido?", data.reiniciarTiempoPartido, tema)),
                    const Text("|", style: TextStyle(color: Colors.white10)),
                    // HE QUITADO EL BOTÓN DE RESET JUGADORES DE AQUÍ TAMBIÉN
                    _ThemeTextButton("FINALIZAR", tema.colorNegativo, 
                       () => _confirmarSalida(context, data)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- MENU SELECTOR DE TEMAS ---
  void _mostrarSelectorTemas(BuildContext context, DataManager data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: data.temaActual.bgPanel,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 300,
          child: Column(
            children: [
              Text("SELECCIONAR INTERFAZ", 
                style: TextStyle(color: data.temaActual.textoPrincipal, fontSize: 18, letterSpacing: 2)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: GameTheme.todos.length,
                  itemBuilder: (ctx, i) {
                    final t = GameTheme.todos[i];
                    final isSelected = t.id == data.temaActual.id;
                    return ListTile(
                      leading: CircleAvatar(backgroundColor: t.colorPositivo),
                      title: Text(t.nombre, style: TextStyle(color: data.temaActual.textoPrincipal)),
                      trailing: isSelected ? Icon(Icons.check, color: t.colorPositivo) : null,
                      onTap: () {
                        data.cambiarTema(t);
                        Navigator.pop(ctx); 
                      },
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // --- DIÁLOGOS ---
  void _confirmarAccion(BuildContext context, String titulo, String mensaje, VoidCallback accion, GameTheme tema) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tema.bgPanel,
        shape: BeveledRectangleBorder(side: BorderSide(color: tema.colorPositivo, width: 0.5)),
        title: Text(titulo, style: TextStyle(color: tema.colorPositivo, letterSpacing: 2, fontSize: 14)),
        content: Text(mensaje, style: TextStyle(color: tema.textoPrincipal, fontWeight: FontWeight.w300)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCELAR", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              accion();
              Navigator.pop(ctx);
            }, 
            child: Text("EJECUTAR", style: TextStyle(color: tema.colorPositivo))
          ),
        ],
      ),
    );
  }

  void _confirmarSalida(BuildContext context, DataManager data) {
    final tema = data.temaActual;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tema.bgPrincipal,
        shape: BeveledRectangleBorder(side: BorderSide(color: tema.colorNegativo, width: 0.5)),
        title: Text("FINALIZAR PARTIDO", style: TextStyle(color: tema.colorNegativo, letterSpacing: 2, fontSize: 14)),
        content: Text("Los datos se perderán.", style: TextStyle(color: tema.textoPrincipal, fontWeight: FontWeight.w300)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCELAR", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              data.finalizarPartido();
              Navigator.pop(ctx);
              Navigator.popUntil(context, ModalRoute.withName('/'));
            }, 
            child: Text("FINALIZAR", style: TextStyle(color: tema.colorNegativo))
          ),
        ],
      ),
    );
  }
}

// --- WIDGETS AUXILIARES ---

class _ThemeScore extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  final Color textoColor;
  final Function(int) onChange;

  const _ThemeScore({required this.label, required this.score, required this.color, required this.textoColor, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, style: TextStyle(color: color, letterSpacing: 2, fontSize: 24, fontWeight: FontWeight.bold))
        ),
        const SizedBox(height: 5),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text("$score", style: TextStyle(color: textoColor, fontSize: 50, fontWeight: FontWeight.bold))
        ),
        const SizedBox(height: 5),
        FittedBox(
          fit: BoxFit.scaleDown, 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MiniButton(Icons.remove, color, () => onChange(-1)),
              const SizedBox(width: 10),
              _MiniButton(Icons.add, color, () => onChange(1)),
            ],
          ),
        )
      ],
    );
  }
}

class _MiniButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MiniButton(this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12), 
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.8), width: 2),
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}

class _ThemePanel extends StatelessWidget {
  final String titulo;
  final Color color;
  final Color textColor;
  final List<Jugador> jugadores;
  final CrossAxisAlignment alineacion;

  const _ThemePanel({required this.titulo, required this.color, required this.textColor, required this.jugadores, required this.alineacion});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alineacion,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          color: color.withOpacity(0.05),
          child: Text(titulo, 
            textAlign: alineacion == CrossAxisAlignment.start ? TextAlign.left : TextAlign.right,
            style: TextStyle(color: color, fontSize: 10, letterSpacing: 3)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: jugadores.length,
            itemBuilder: (context, index) {
              final j = jugadores[index];
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.02)))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: alineacion == CrossAxisAlignment.start 
                    ? [
                        Flexible(child: Text("${j.dorsal}. ${j.nombre}", overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor.withOpacity(0.9), fontWeight: FontWeight.w300))),
                        // AQUI QUITAMOS EL TIEMPO
                        // Text(j.tiempoFormateado, style: TextStyle(color: color, fontFamily: 'Courier', fontSize: 18, fontWeight: FontWeight.bold)),
                      ]
                    : [
                        // AQUI QUITAMOS EL TIEMPO
                        // Text(j.tiempoFormateado, style: TextStyle(color: color, fontFamily: 'Courier', fontSize: 18, fontWeight: FontWeight.bold)),
                        Flexible(child: Text("${j.dorsal}. ${j.nombre}", overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor.withOpacity(0.6), fontWeight: FontWeight.w300))),
                      ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ThemeTextButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const _ThemeTextButton(this.text, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text, style: TextStyle(color: color, fontSize: 10, letterSpacing: 1)),
      ),
    );
  }
}