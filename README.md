# ASADA App — Flutter 🐦

Sistema SaaS modular para ASADAS.
App Flutter offline para fontaneros.

## Funcionalidades

- [x] Login offline (credenciales Odoo + API key)
- [x] Descarga de ruta de medidores
- [x] Lectura con foto + OCR
  - Cámara → OCR → validación → guardar
  - Foto siempre adjunta
  - Si OCR falla → ingreso manual
- [x] Sincronización batch
- [x] Estados de servicio
- [x] UI para fontaneros
- [x] Tests unitarios

## Stack

- **Flutter 3.x** / Dart 3.x
- **Isar** — Base de datos offline
- **Dio** — HTTP client
- **image_picker** — Captura de fotos

## Requisitos

- Flutter SDK ^3.5.0
- Dart SDK ^3.5.0

## Instalación

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter test
```

## Estructura

```
lib/
  main.dart              # Entry point
  app.dart               # DI container
  models/                # Data models
  services/              # Business logic
  bloc/                  # State management
  pages/                 # UI pages
  widgets/               # Reusable widgets
  utils/                 # Helpers
test/                    # Unit tests
```

## Repositorio

- Rama `odoo20+dev` — desarrollo continuo
- Rama `20.dev` — estable anterior

## Licencia

FiboSTech — ASA-2026-001