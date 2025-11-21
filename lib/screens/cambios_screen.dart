import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_manager.dart';
import '../models/jugador.dart';

class CambiosScreen extends StatefulWidget {
  const CambiosScreen({super.key});

  @override
  State<CambiosScreen> createState() => _CambiosScreenState();
}

class _CambiosScreenState extends State<CambiosScreen> {
  Jugador? titularSeleccionado;
  Jugador? suplenteSeleccionado;
  int _sortMode = 1; // Por defecto por Dorsal

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataManager>(context);
    final tema = data.temaActual;

    // Preparar listas ordenadas
    List<Jugador> titularesOrd = List.from(data.titulares);
    List<Jugador> suplentesOrd = List.from(data.suplentes);
    
    if (_sortMode == 0) { // Nombre
      titularesOrd.sort((a, b) => a.nombre.compareTo(b.nombre));
      suplentesOrd.sort((a, b) => a.nombre.compareTo(b.nombre));
    } else { // Dorsal
      titularesOrd.sort((a, b) => a.dorsal.compareTo(b.dorsal));
      suplentesOrd.sort((a, b) => a.dorsal.compareTo(b.dorsal));
    }

    return Scaffold(
      backgroundColor: tema.bgPrincipal,
      appBar: AppBar(
        title: Text('SUSTITUCIÓN', style: TextStyle(color: tema.colorPositivo, fontSize: 14)),
        backgroundColor: tema.bgPrincipal,
        iconTheme: IconThemeData(color: tema.colorPositivo),
        actions: [
          IconButton(
            icon: Icon(_sortMode == 0 ? Icons.sort_by_alpha : Icons.format_list_numbered, color: tema.colorPositivo),
            onPressed: () => setState(() => _sortMode = _sortMode == 0 ? 1 : 0),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // --- SALE (TITULARES) ---
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity, color: tema.colorNegativo.withOpacity(0.1), padding: const EdgeInsets.all(10),
                        child: Text("SALE", textAlign: TextAlign.center, style: TextStyle(color: tema.colorNegativo, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: titularesOrd.length,
                          itemBuilder: (context, index) {
                            final j = titularesOrd[index];
                            final isSelected = titularSeleccionado == j;
                            return ListTile(
                              leading: Text("${j.dorsal}", style: TextStyle(color: tema.colorNegativo, fontWeight: FontWeight.bold)),
                              title: Text(j.nombre, style: TextStyle(color: tema.textoPrincipal)),
                              subtitle: Text(j.etiquetas, style: TextStyle(color: Colors.grey, fontSize: 10)),
                              tileColor: isSelected ? tema.colorNegativo.withOpacity(0.3) : null,
                              onTap: () => setState(() { titularSeleccionado = j; suplenteSeleccionado = null; }),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, color: Colors.white10),
                
                // --- ENTRA (SUPLENTES) ---
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity, color: tema.colorPositivo.withOpacity(0.1), padding: const EdgeInsets.all(10),
                        child: Text("ENTRA", textAlign: TextAlign.center, style: TextStyle(color: tema.colorPositivo, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: suplentesOrd.length,
                          itemBuilder: (context, index) {
                            final j = suplentesOrd[index];
                            final isSelected = suplenteSeleccionado == j;
                            
                            // LÓGICA DE RESALTADO (Punto 4)
                            bool esValido = true;
                            if (titularSeleccionado != null) {
                              // Verificamos si este cambio sería legal
                              esValido = data.validarReglasCambio(j, titularSeleccionado!) == null;
                            }

                            return Opacity(
                              opacity: (titularSeleccionado != null && !esValido) ? 0.3 : 1.0,
                              child: ListTile(
                                leading: Text("${j.dorsal}", style: TextStyle(color: tema.colorPositivo, fontWeight: FontWeight.bold)),
                                title: Text(j.nombre, style: TextStyle(color: tema.textoPrincipal)),
                                subtitle: Text(j.etiquetas, style: TextStyle(color: Colors.grey, fontSize: 10)),
                                tileColor: isSelected 
                                    ? tema.colorPositivo.withOpacity(0.3) 
                                    : (esValido && titularSeleccionado != null) 
                                        ? tema.colorPositivo.withOpacity(0.05) // Resaltado sutil de "disponible"
                                        : null,
                                onTap: () {
                                  if (titularSeleccionado != null && !esValido) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cambio inválido por normativa"), duration: Duration(seconds: 1)));
                                  } else {
                                    setState(() => suplenteSeleccionado = j);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // ZONA VALIDACIÓN
          if (titularSeleccionado != null && suplenteSeleccionado != null)
          Container(
            padding: const EdgeInsets.all(20),
            color: tema.bgPanel,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, 
                  side: BorderSide(color: tema.textoPrincipal),
                  padding: const EdgeInsets.symmetric(vertical: 15)
                ),
                onPressed: () {
                   data.realizarCambio(suplenteSeleccionado!, titularSeleccionado!);
                   Navigator.pop(context);
                },
                child: Text("EJECUTAR INTERCAMBIO", style: TextStyle(color: tema.textoPrincipal, letterSpacing: 2)),
              ),
            ),
          )
        ],
      ),
    );
  }
}