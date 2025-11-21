import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_manager.dart';

class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataManager>(context);
    final tema = data.temaActual;

    return Scaffold(
      backgroundColor: tema.bgPrincipal,
      appBar: AppBar(
        title: Text('REGLAS DE LIGA', style: TextStyle(color: tema.colorPositivo)),
        backgroundColor: tema.bgPrincipal,
        iconTheme: IconThemeData(color: tema.colorPositivo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "CUPO DE FORMACIÓN (F)",
              style: TextStyle(color: tema.colorPositivo, fontSize: 18, letterSpacing: 2),
            ),
            const SizedBox(height: 10),
            Text(
              "Número mínimo de jugadores de formación requeridos en la lista de convocados (Acta).",
              style: TextStyle(color: tema.textoPrincipal.withOpacity(0.7)),
            ),
            const SizedBox(height: 30),
            
            // SLIDER
            Row(
              children: [
                Text("0", style: TextStyle(color: tema.textoPrincipal)),
                Expanded(
                  child: Slider(
                    value: data.minFormacionRequeridos.toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    activeColor: tema.colorPositivo,
                    inactiveColor: tema.bgPanel,
                    label: data.minFormacionRequeridos.toString(),
                    onChanged: (v) => data.setMinFormacion(v.toInt()),
                  ),
                ),
                Text("10", style: TextStyle(color: tema.textoPrincipal)),
              ],
            ),
            Center(
              child: Text(
                "${data.minFormacionRequeridos} Jugadores",
                style: TextStyle(color: tema.colorPositivo, fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}