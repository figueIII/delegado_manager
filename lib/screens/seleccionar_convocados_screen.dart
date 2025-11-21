import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_manager.dart';
import '../models/jugador.dart';

class SeleccionarConvocadosScreen extends StatefulWidget {
  const SeleccionarConvocadosScreen({super.key});

  @override
  State<SeleccionarConvocadosScreen> createState() => _SeleccionarConvocadosScreenState();
}

class _SeleccionarConvocadosScreenState extends State<SeleccionarConvocadosScreen> {
  int _sortMode = 0; // 0: Nombre, 1: Dorsal

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataManager>(context);
    final tema = data.temaActual;

    List<Jugador> lista = List.from(data.plantilla);
    if (_sortMode == 0) {
      lista.sort((a, b) => a.nombre.compareTo(b.nombre));
    } else {
      lista.sort((a, b) => a.dorsal.compareTo(b.dorsal));
    }

    return Scaffold(
      backgroundColor: tema.bgPrincipal,
      appBar: AppBar(
        title: Text('CONVOCATORIA Y 1ª LÍNEA', style: TextStyle(color: tema.colorPositivo, fontSize: 14)),
        backgroundColor: tema.bgPrincipal,
        iconTheme: IconThemeData(color: tema.colorPositivo),
        actions: [
          IconButton(
            icon: Icon(_sortMode == 0 ? Icons.sort_by_alpha : Icons.format_list_numbered, color: tema.colorPositivo),
            onPressed: () => setState(() => _sortMode = _sortMode == 0 ? 1 : 0),
            tooltip: "Ordenar",
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Toca para convocar. Marca '1a' si es primera línea.", 
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: lista.length,
              itemBuilder: (context, index) {
                final jugador = lista[index];
                final esConvocado = data.convocados.contains(jugador);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: esConvocado ? tema.colorPositivo.withOpacity(0.05) : Colors.transparent,
                    border: Border.all(color: esConvocado ? tema.colorPositivo : Colors.white10),
                  ),
                  child: ListTile(
                    // PARTE IZQUIERDA: DORSAL EDITABLE
                    leading: GestureDetector(
                      onTap: () => _editarDorsal(context, jugador, data, tema),
                      child: CircleAvatar(
                        backgroundColor: esConvocado ? tema.colorPositivo : Colors.grey[800],
                        foregroundColor: esConvocado ? tema.bgPrincipal : Colors.white,
                        child: Text(jugador.dorsal == 0 ? "#" : "${jugador.dorsal}", 
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    
                    // CENTRO: NOMBRE
                    title: Text(jugador.nombre, 
                      style: TextStyle(
                        color: esConvocado ? Colors.white : tema.textoPrincipal.withOpacity(0.5),
                        fontWeight: esConvocado ? FontWeight.bold : FontWeight.normal
                      )
                    ),
                    
                    // PARTE DERECHA: TOGGLE 1a LÍNEA
                    trailing: SizedBox(
                      width: 80, // Espacio para el botón
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Botón 1a Línea
                          GestureDetector(
                            onTap: () {
                              // Cambiamos el estado de 1a linea directamente
                              jugador.esPrimeraLinea = !jugador.esPrimeraLinea;
                              data.actualizarJugador(); // Guardamos cambios
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: jugador.esPrimeraLinea ? tema.colorPositivo : Colors.transparent,
                                border: Border.all(color: jugador.esPrimeraLinea ? tema.colorPositivo : Colors.grey),
                                borderRadius: BorderRadius.circular(4)
                              ),
                              child: Text("1a", 
                                style: TextStyle(
                                  color: jugador.esPrimeraLinea ? tema.bgPrincipal : Colors.grey, 
                                  fontWeight: FontWeight.bold, fontSize: 12
                                )
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // AL TOCAR LA FILA: CONVOCAR
                    onTap: () => data.toggleConvocado(jugador),
                  ),
                );
              },
            ),
          ),
          // ZONA INFERIOR IGUAL
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tema.bgPanel,
              border: Border(top: BorderSide(color: tema.colorPositivo.withOpacity(0.5)))
            ),
            child: Column(
              children: [
                Text("CONVOCADOS: ${data.convocados.length}", 
                   style: TextStyle(color: tema.colorPositivo, fontWeight: FontWeight.bold, fontFamily: 'Courier')),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(side: BorderSide(color: tema.colorNegativo)),
                        onPressed: () => data.limpiarConvocados(),
                        child: Text('LIMPIAR', style: TextStyle(color: tema.colorNegativo)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tema.colorPositivo.withOpacity(0.2),
                          side: BorderSide(color: tema.colorPositivo)
                        ),
                        onPressed: () {
                          if (data.convocados.isEmpty) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(content: Text('Selecciona al menos un jugador')));
                             return;
                          }
                          String? alerta = data.validarReglasConvocatoria();
                          if (alerta != null) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: Colors.red[50],
                                title: Row(children: [Icon(Icons.warning, color: Colors.red), SizedBox(width: 10), Text("ALERTA REGLAMENTO")]),
                                content: Text(alerta),
                                actions: [
                                  TextButton(child: const Text("Corregir"), onPressed: () => Navigator.pop(ctx)),
                                  TextButton(child: const Text("Ignorar"), onPressed: () { Navigator.pop(ctx); Navigator.pushNamed(context, '/elegir_titulares'); }),
                                ],
                              ),
                            );
                          } else {
                            Navigator.pushNamed(context, '/elegir_titulares');
                          }
                        },
                        child: Text('SIGUIENTE', style: TextStyle(color: tema.colorPositivo)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _editarDorsal(BuildContext context, Jugador j, DataManager data, dynamic tema) {
    final ctrl = TextEditingController(text: j.dorsal == 0 ? "" : j.dorsal.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tema.bgPanel,
        title: Text("Dorsal para ${j.nombre}", style: TextStyle(color: tema.textoPrincipal, fontSize: 16)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: TextStyle(color: tema.colorPositivo, fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          decoration: InputDecoration(hintText: "#", hintStyle: TextStyle(color: Colors.grey)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              int? d = int.tryParse(ctrl.text);
              if (d != null) {
                j.dorsal = d;
                data.actualizarJugador();
              }
              Navigator.pop(ctx);
            },
            child: Text("OK", style: TextStyle(color: tema.colorPositivo)),
          )
        ],
      ),
    );
  }
}