import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_manager.dart';
import '../models/game_theme.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataManager>(context);
    final tema = data.temaActual;

    return Scaffold(
      backgroundColor: tema.bgPrincipal,
      appBar: AppBar(
        title: Text('GESTOR DE EQUIPO', style: TextStyle(color: tema.colorPositivo, letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Botón Ajustes
          IconButton(
            icon: Icon(Icons.settings, color: tema.textoPrincipal),
            tooltip: "Configuración de Liga",
            onPressed: () => Navigator.pushNamed(context, '/ajustes'),
          ),
          // Selector de Tema
          IconButton(
            icon: Icon(Icons.palette_outlined, color: tema.colorPositivo),
            tooltip: "Cambiar Estilo Visual",
            onPressed: () => _mostrarSelectorTemas(context, data),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o Icono Grande (Opcional, para decorar)
            Icon(Icons.sports_rugby_rounded, size: 80, color: tema.colorPositivo.withOpacity(0.5)),
            const SizedBox(height: 40),
            
            // MENÚ PRINCIPAL
            _MenuButton(
              text: 'BASE DE JUGADORES',
              tema: tema,
              icon: Icons.people_alt_outlined,
              onTap: () => Navigator.pushNamed(context, '/gestion_plantilla'),
            ),
            const SizedBox(height: 20),
            _MenuButton(
              text: 'NUEVO PARTIDO',
              tema: tema,
              icon: Icons.sports_rugby_outlined,
              onTap: () => Navigator.pushNamed(context, '/seleccionar_convocados'),
            ),
          ],
        ),
      ),
    );
  }

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
                      title: Text(t.nombre, style: const TextStyle(color: Colors.white)),
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
}

class _MenuButton extends StatelessWidget {
  final String text;
  final GameTheme tema;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuButton({required this.text, required this.tema, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(vertical: 25),
        decoration: BoxDecoration(
          color: tema.bgPanel,
          border: Border.all(color: tema.colorPositivo.withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(color: tema.colorPositivo.withOpacity(0.1), blurRadius: 10, spreadRadius: 1)
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            bottomRight: Radius.circular(15)
          )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: tema.colorPositivo, size: 28),
            const SizedBox(width: 15),
            Text(text,
                style: TextStyle(
                  color: tema.textoPrincipal, 
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5
                )),
          ],
        ),
      ),
    );
  }
}