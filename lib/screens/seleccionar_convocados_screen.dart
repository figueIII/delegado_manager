import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_manager.dart';

class SeleccionarConvocadosScreen extends StatelessWidget {
  const SeleccionarConvocadosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataManager>(context);
    final tema = data.temaActual;

    return Scaffold(
      backgroundColor: tema.bgPrincipal,
      appBar: AppBar(
        title: Text('SELECCIONAR ESCUADRON', style: TextStyle(color: tema.colorPositivo, letterSpacing: 2, fontSize: 16)),
        backgroundColor: tema.bgPrincipal,
        iconTheme: IconThemeData(color: tema.colorPositivo),
        elevation: 0,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: tema.colorPositivo.withOpacity(0.3), height: 1)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text("MARCAR OPERATIVOS DISPONIBLES", 
              style: TextStyle(color: tema.textoPrincipal.withOpacity(0.7), fontStyle: FontStyle.italic, fontSize: 12)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: data.plantilla.length,
              itemBuilder: (context, index) {
                final jugador = data.plantilla[index];
                final esConvocado = data.convocados.contains(jugador);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: esConvocado ? tema.colorPositivo.withOpacity(0.1) : Colors.transparent,
                    border: Border.all(color: esConvocado ? tema.colorPositivo : Colors.white10),
                  ),
                  child: ListTile(
                    title: Text(jugador.nombre, 
                      style: TextStyle(color: esConvocado ? Colors.white : tema.textoPrincipal.withOpacity(0.5))),
                    trailing: Icon(
                      esConvocado ? Icons.check_box : Icons.check_box_outline_blank,
                      color: esConvocado ? tema.colorPositivo : Colors.grey,
                    ),
                    onTap: () => data.toggleConvocado(jugador),
                  ),
                );
              },
            ),
          ),
          // --- ZONA INFERIOR ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tema.bgPanel,
              border: Border(top: BorderSide(color: tema.colorPositivo.withOpacity(0.5)))
            ),
            child: Column(
              children: [
                Text("EFECTIVOS: ${data.convocados.length}", 
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
                          // LÓGICA DE VALIDACIÓN (AQUÍ ESTABA EL ERROR ANTES)
                          String? alerta = data.validarReglasConvocatoria();

                          if (alerta != null) {
                            // Mostrar Alerta Roja (Dialog)
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: tema.bgPanel,
                                title: Row(children: [Icon(Icons.warning, color: Colors.red), const SizedBox(width: 10), const Text("ALERTA REGLAMENTO", style: TextStyle(color: Colors.red))]),
                                content: Text(alerta, style: TextStyle(fontSize: 16, color: tema.textoPrincipal)),
                                actions: [
                                  TextButton(
                                    child: const Text("Corregir"),
                                    onPressed: () => Navigator.pop(ctx),
                                  ),
                                  TextButton(
                                    child: const Text("Ignorar y Seguir", style: TextStyle(color: Colors.red)),
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      Navigator.pushNamed(context, '/elegir_titulares');
                                    },
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // Todo correcto
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
}