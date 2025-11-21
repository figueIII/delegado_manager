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
  String? errorMsg; // Para guardar el mensaje de alerta

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataManager>(context);
    final tema = data.temaActual;

    return Scaffold(
      backgroundColor: tema.bgPrincipal,
      appBar: AppBar(
        title: Text('PROTOCOLO DE SUSTITUCIÓN', style: TextStyle(color: tema.colorPositivo, fontSize: 14)),
        backgroundColor: tema.bgPrincipal,
        iconTheme: IconThemeData(color: tema.colorPositivo),
      ),
      body: Column(
        children: [
          // ... [PARTE DE LISTAS IGUAL QUE ANTES] ...
          Expanded(
            child: Row(
              children: [
                // COLUMNA IZQUIERDA: SALE
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity, color: tema.colorNegativo.withOpacity(0.1), padding: const EdgeInsets.all(10),
                        child: Text("SALE", textAlign: TextAlign.center, style: TextStyle(color: tema.colorNegativo, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: data.titulares.length,
                          itemBuilder: (context, index) {
                            final j = data.titulares[index];
                            final isSelected = titularSeleccionado == j;
                            return ListTile(
                              title: Text(j.nombre, style: TextStyle(color: tema.textoPrincipal)),
                              subtitle: Text(j.etiquetas, style: TextStyle(color: Colors.grey, fontSize: 10)),
                              trailing: Text(j.tiempoFormateado, style: TextStyle(color: tema.colorNegativo, fontFamily: 'Courier')),
                              tileColor: isSelected ? tema.colorNegativo.withOpacity(0.3) : null,
                              onTap: () => setState(() { titularSeleccionado = j; errorMsg = null; }),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, color: Colors.white10),
                // COLUMNA DERECHA: ENTRA
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity, color: tema.colorPositivo.withOpacity(0.1), padding: const EdgeInsets.all(10),
                        child: Text("ENTRA", textAlign: TextAlign.center, style: TextStyle(color: tema.colorPositivo, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: data.suplentes.length,
                          itemBuilder: (context, index) {
                            final j = data.suplentes[index];
                            final isSelected = suplenteSeleccionado == j;
                            return ListTile(
                              title: Text(j.nombre, style: TextStyle(color: tema.textoPrincipal)),
                              subtitle: Text(j.etiquetas, style: TextStyle(color: Colors.grey, fontSize: 10)),
                              trailing: Text(j.tiempoFormateado, style: TextStyle(color: Colors.grey, fontFamily: 'Courier')),
                              tileColor: isSelected ? tema.colorPositivo.withOpacity(0.3) : null,
                              onTap: () => setState(() { suplenteSeleccionado = j; errorMsg = null; }),
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
          
          // ZONA VALIDACIÓN CON ALERTA
          Container(
            padding: const EdgeInsets.all(20),
            // CORRECCIÓN 1: Usamos BoxDecoration para el fondo del panel inferior
            decoration: BoxDecoration(
              color: tema.bgPanel,
              border: Border(top: BorderSide(color: tema.colorPositivo.withOpacity(0.5))),
            ),
            child: Column(
              children: [
                if (errorMsg != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    // CORRECCIÓN 2: El borde y color de la alerta dentro de BoxDecoration
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(child: Text(errorMsg!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),

                Text(
                  (titularSeleccionado != null && suplenteSeleccionado != null)
                  ? "${titularSeleccionado!.nombre}  ➔  ${suplenteSeleccionado!.nombre}"
                  : "Selecciona jugadores...",
                  style: TextStyle(color: tema.textoPrincipal, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, 
                      side: BorderSide(color: tema.textoPrincipal),
                      padding: const EdgeInsets.symmetric(vertical: 15)
                    ),
                    onPressed: () {
                      if (titularSeleccionado != null && suplenteSeleccionado != null) {
                        // 1. VALIDAR REGLAS PRIMERO
                        String? alerta = data.validarReglasCambio(suplenteSeleccionado!, titularSeleccionado!);
                        
                        if (alerta != null) {
                          // Mostrar Alerta Roja
                          setState(() => errorMsg = alerta);
                        } else {
                          // Todo OK, ejecutar
                          data.realizarCambio(suplenteSeleccionado!, titularSeleccionado!);
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: Text("EJECUTAR CAMBIO", style: TextStyle(color: tema.textoPrincipal)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}