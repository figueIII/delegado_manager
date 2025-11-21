import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_manager.dart';

class ElegirTitularesScreen extends StatelessWidget {
  const ElegirTitularesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataManager>(context);
    final tema = data.temaActual;

    return Scaffold(
      backgroundColor: tema.bgPrincipal,
      appBar: AppBar(
        title: Text('DEFINIR UNIDAD ACTIVA', style: TextStyle(color: tema.colorPositivo, letterSpacing: 2, fontSize: 16)),
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
            child: Text("ASIGNAR ROLES (ACTIVO / RESERVA)", 
               style: TextStyle(color: tema.textoPrincipal.withOpacity(0.7), fontSize: 10, letterSpacing: 1)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: data.convocados.length,
              itemBuilder: (context, index) {
                final jugador = data.convocados[index];
                final esTitular = data.titulares.contains(jugador);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: esTitular ? tema.colorPositivo.withOpacity(0.1) : tema.bgPanel.withOpacity(0.3),
                    border: Border(
                      left: BorderSide(
                        color: esTitular ? tema.colorPositivo : Colors.transparent, 
                        width: 4
                      ),
                      bottom: BorderSide(color: Colors.white10)
                    ),
                  ),
                  child: ListTile(
                    title: Text(jugador.nombre, 
                      style: TextStyle(
                        color: esTitular ? Colors.white : tema.textoPrincipal.withOpacity(0.5),
                        fontWeight: esTitular ? FontWeight.bold : FontWeight.normal
                      )),
                    subtitle: Text(esTitular ? "TITULAR" : "RESERVA", 
                      style: TextStyle(
                        color: esTitular ? tema.colorPositivo : Colors.grey, 
                        fontSize: 10, 
                        letterSpacing: 1.5
                      )),
                    trailing: Icon(
                      esTitular ? Icons.shield : Icons.shield_outlined,
                      color: esTitular ? tema.colorPositivo : Colors.grey,
                    ),
                    onTap: () => data.toggleTitular(jugador),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: tema.colorPositivo.withOpacity(0.2),
                  foregroundColor: tema.colorPositivo,
                  side: BorderSide(color: tema.colorPositivo),
                  padding: const EdgeInsets.symmetric(vertical: 18)
                ),
                onPressed: () {
                  if (data.titulares.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Elige al menos un titular')));
                    return;
                  }
                  data.iniciarPartidoLogica();
                  Navigator.pushNamed(context, '/partido');
                },
                child: const Text("INICIAR MISION", style: TextStyle(fontSize: 16, letterSpacing: 3)),
              ),
            ),
          )
        ],
      ),
    );
  }
}