import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_manager.dart';
import '../models/jugador.dart';

class GestionPlantillaScreen extends StatefulWidget {
  const GestionPlantillaScreen({super.key});

  @override
  State<GestionPlantillaScreen> createState() => _GestionPlantillaScreenState();
}

class _GestionPlantillaScreenState extends State<GestionPlantillaScreen> {
  final _nameController = TextEditingController();
  final _dorsalController = TextEditingController();
  bool _esPrimeraLinea = false;
  bool _esFormacion = false;

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataManager>(context);
    final tema = data.temaActual;

    return Scaffold(
      backgroundColor: tema.bgPrincipal,
      appBar: AppBar(
        title: Text('GESTIÓN DE PLANTILLA', style: TextStyle(color: tema.colorPositivo)),
        backgroundColor: tema.bgPrincipal,
        iconTheme: IconThemeData(color: tema.colorPositivo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // FORMULARIO DE CREACIÓN
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: tema.bgPanel,
                border: Border.all(color: tema.colorPositivo.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8)
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: _dorsalController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: tema.textoPrincipal),
                          decoration: InputDecoration(
                            labelText: '#',
                            labelStyle: TextStyle(color: tema.textoPrincipal.withOpacity(0.5)),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: tema.colorPositivo)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          style: TextStyle(color: tema.textoPrincipal),
                          decoration: InputDecoration(
                            labelText: 'Nombre Apellido',
                            labelStyle: TextStyle(color: tema.textoPrincipal.withOpacity(0.5)),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: tema.colorPositivo)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      FilterChip(
                        label: const Text("1a LÍNEA"),
                        selected: _esPrimeraLinea,
                        onSelected: (v) => setState(() => _esPrimeraLinea = v),
                        checkmarkColor: tema.bgPrincipal,
                        selectedColor: tema.colorPositivo,
                        labelStyle: TextStyle(color: _esPrimeraLinea ? tema.bgPrincipal : tema.textoPrincipal),
                      ),
                      const SizedBox(width: 10),
                      FilterChip(
                        label: const Text("FORMACIÓN (F)"),
                        selected: _esFormacion,
                        onSelected: (v) => setState(() => _esFormacion = v),
                        checkmarkColor: tema.bgPrincipal,
                        selectedColor: Colors.orangeAccent,
                        labelStyle: TextStyle(color: _esFormacion ? tema.bgPrincipal : tema.textoPrincipal),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: tema.colorPositivo),
                        onPressed: () {
                          if (_nameController.text.isNotEmpty) {
                            final nuevo = Jugador(
                              nombre: _nameController.text,
                              dorsal: int.tryParse(_dorsalController.text) ?? 0,
                              esPrimeraLinea: _esPrimeraLinea,
                              esFormacion: _esFormacion,
                            );
                            data.agregarJugador(nuevo);
                            // Reset form
                            _nameController.clear();
                            _dorsalController.clear();
                            setState(() {
                              _esPrimeraLinea = false;
                              _esFormacion = false;
                            });
                          }
                        },
                        child: Text("AÑADIR", style: TextStyle(color: tema.bgPrincipal)),
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // LISTA
            Expanded(
              child: ListView.builder(
                itemCount: data.plantilla.length,
                itemBuilder: (context, index) {
                  final j = data.plantilla[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: tema.colorPositivo.withOpacity(0.2),
                      child: Text("${j.dorsal}", style: TextStyle(color: tema.colorPositivo, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(j.nombre, style: TextStyle(color: tema.textoPrincipal)),
                    subtitle: Text(j.etiquetas, style: TextStyle(color: tema.colorPositivo, fontSize: 12)),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: tema.colorNegativo),
                      onPressed: () => data.eliminarJugador(j),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}