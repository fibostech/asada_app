import 'package:flutter/widgets.dart';

import '../bloc/route_bloc.dart';
import '../models/route.dart';
import 'route_detail_page.dart';

/// Pantalla de lista de rutas asignadas.
class RouteListPage extends StatefulWidget {
  final RouteBloc routeBloc;

  const RouteListPage({required this.routeBloc});

  @override
  State<RouteListPage> createState() => _RouteListPageState();
}

class _RouteListPageState extends State<RouteListPage> {
  @override
  Widget build(BuildContext context) {
    final bloc = widget.routeBloc;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Rutas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildBody(context, bloc),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _refreshRoutes(bloc),
        tooltip: 'Descargar rutas',
        child: const Icon(Icons.download),
      ),
    );
  }

  Widget _buildBody(BuildContext context, RouteBloc bloc) {
    switch (bloc.state) {
      case RouteBlocState.loading:
        return Center(
          child: Column(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(),
              ),
              SizedBox(height: 16),
              Text('Descargando rutas...'),
            ],
          ),
        );

      case RouteBlocState.error:
        return Center(
          child: Column(
            children: [
              Icon(Icons.error, size: 48, color: Colors.red),
              SizedBox(height: 12),
              Text(
                bloc.errorMessage ?? 'Error desconocido',
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _refreshRoutes(bloc),
                child: Text('Reintentar'),
              ),
            ],
          ),
        );

      case RouteBlocState.ready:
        final routes = bloc.routes;
        if (routes.isEmpty) {
          return Center(
            child: Column(
              children: [
                Icon(Icons.info, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'No hay rutas asignadas.\n'
                  'Presione + para descargar.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView(
          children: [
            for (final route in routes)
              _buildRouteCard(context, route),
          ],
        );

      default:
        return Center(
          child: Column(
            children: [
              Icon(Icons.cloudDownload, size: 48, color: Colors.blue),
              SizedBox(height: 12),
              Text(
                'Presione + para descargar\nsus rutas asignadas.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
    }
  }

  Widget _buildRouteCard(BuildContext context, Route route) {
    return Card(
      child: InkWell(
        onTap: () => _openRoute(route),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            cross: CrossAxisAlignment.start,
            children: [
              Text(
                route.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (route.description != null) SizedBox(height: 4),
              if (route.description != null)
                Text(
                  route.description!,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${route.meters.length} medidores',
                    style: TextStyle(fontSize: 13),
                  ),
                  Text(
                    '${route.progressPercent.toStringAs(places: 1)}% completado',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
              SizedBox(height: 4),
              LinearProgressIndicator(
                value: route.progressPercent / 100,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _refreshRoutes(RouteBloc bloc) async {
    // En producción tomaría el userId del AuthBloc
    await bloc.downloadRoutes(1);
  }

  void _openRoute(Route route) {
    // Navegación a detalle de ruta
    // En producción usar Navigator.pushNamed
  }
}