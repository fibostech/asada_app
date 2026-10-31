import 'package:flutter/material.dart';

import '../main.dart' show AsadaColors;
import '../models/service_status.dart';

/// Widget que muestra el estado de servicio como un badge.
class StatusBadge extends StatelessWidget {
  final ServiceState state;
  final String? label;

  const StatusBadge({required this.state, this.label});

  @override
  Widget build(BuildContext context) {
    final config = _configForState(state);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      decoration: BoxDecoration(
        color: config.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label ?? _defaultLabel(state),
        style: TextStyle(
          color: config.textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  _BadgeConfig _configForState(ServiceState state) {
    switch (state) {
      case ServiceState.active:
        return _BadgeConfig(AsadaColors.secondary, AsadaColors.white);
      case ServiceState.suspended:
        return _BadgeConfig(const Color(0xFFE8BB1D), AsadaColors.white);
      case ServiceState.disconnected:
        return _BadgeConfig(const Color(0xFFEE2D2D), AsadaColors.white);
      case ServiceState.damaged:
        return _BadgeConfig(const Color(0xFFEE2D2D), AsadaColors.white);
      case ServiceState.pendingInstallation:
        return _BadgeConfig(AsadaColors.primary, AsadaColors.white);
    }
  }

  String _defaultLabel(ServiceState state) {
    switch (state) {
      case ServiceState.active:
        return 'Activo';
      case ServiceState.suspended:
        return 'Suspendido';
      case ServiceState.disconnected:
        return 'Desconectado';
      case ServiceState.damaged:
        return 'Dañado';
      case ServiceState.pendingInstallation:
        return 'Pendiente';
    }
  }
}

class _BadgeConfig {
  final Color color;
  final Color textColor;
  const _BadgeConfig(this.color, this.textColor);
}