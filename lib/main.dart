import 'package:flutter/material.dart';

import 'app.dart';
import 'pages/login_page.dart';
import 'pages/route_list_page.dart';
import 'pages/sync_page.dart';

void main() {
  runApp(const AsadaApp());
}

/// Widget raíz de la aplicación ASADA.
class AsadaApp extends StatelessWidget {
  const AsadaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = AppDependencies();

    return MaterialApp(
      title: 'ASADA App — Lectura de Medidores',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(deps: deps),
    );
  }
}

/// Página principal que maneja la navegación según autenticación.
class HomePage extends StatefulWidget {
  final AppDependencies deps;

  const HomePage({super.key, required this.deps});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final deps = widget.deps;

    // Si no está autenticado, mostrar login
    if (!deps.authBloc.isLoggedIn) {
      return LoginPage(authBloc: deps.authBloc);
    }

    // Usuario autenticado — mostrar navegación principal
    return _buildMainNavigation(context, deps);
  }

  Widget _buildMainNavigation(BuildContext context, AppDependencies deps) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ASADA App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildDashboard(context, deps),
      bottomAppBar: _buildBottomNav(context, deps),
    );
  }

  Widget _buildDashboard(BuildContext context, AppDependencies deps) {
    return Column(
      children: [
        // Bienvenida
        Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.person, size: 32),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bienvenido, ${deps.authBloc.currentUser?.name ?? "Fontanero"}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Tiene ${deps.meterService.pendingReadings.length} '
                  'lecturas pendientes de sincronizar.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16),

        // Accesos rápidos
        Row(
          children: [
            _quickAccessCard(
              context,
              Icons.route,
              'Rutas',
              'Ver mis rutas asignadas',
              Colors.blue,
              () {
                Navigator.push(
                  context,
                  RouteListPage(routeBloc: deps.routeBloc),
                );
              },
            ),
            _quickAccessCard(
              context,
              Icons.sync,
              'Sincronizar',
              'Enviar lecturas pendientes',
              Colors.green,
              () {
                Navigator.push(
                  context,
                  SyncPage(syncBloc: deps.syncBloc),
                );
              },
            ),
          ],
        ),

        SizedBox(height: 12),

        Row(
          children: [
            _quickAccessCard(
              context,
              Icons.history,
              'Historial',
              'Lecturas anteriores',
              Colors.purple,
              () {
                // Navegar a historial
              },
            ),
            _quickAccessCard(
              context,
              Icons.settings,
              'Ajustes',
              'Configuración de la app',
              Colors.grey,
              () {
                // Navegar a ajustes
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickAccessCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: Card(
        child: InkWell(
          onTap: () => onTap(),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              cross: CrossAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: color),
                SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, AppDependencies deps) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icons.home,
            tooltip: 'Inicio',
            onPressed: () {
              Navigator.push(context, HomePage(deps: deps));
            },
          ),
          IconButton(
            icon: Icons.route,
            tooltip: 'Rutas',
            onPressed: () {
              Navigator.push(
                context,
                RouteListPage(routeBloc: deps.routeBloc),
              );
            },
          ),
          IconButton(
            icon: Icons.sync,
            tooltip: 'Sincronizar',
            onPressed: () {
              Navigator.push(
                context,
                SyncPage(syncBloc: deps.syncBloc),
              );
            },
          ),
          IconButton(
            icon: Icons.person,
            tooltip: 'Perfil',
            onPressed: () {
              // Perfil / Cerrar sesión
            },
          ),
        ],
      ),
    );
  }
}