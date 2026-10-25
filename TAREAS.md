# 🗂️ TAREAS — ASA-2026-001 Sistema ASADAS

_Última actualización: 5-oct-2026 · Versión: 5.0 (arquitectura final)_

---

## 📦 Repositorios

| Repo | Contenido | Rama | Estado |
|:-----|:----------|:-----|:-------|
| `fibostech/asada_base` | **Módulo Odoo `asada`** — App principal (como contacts, accounting) | `20.dev` → `20.0` | ✅ Creado |
| `fibostech/asada_cr` | **Módulo Odoo `asada_cr`** — Extensiones Costa Rica (AyA, FE opcional) | `20.dev` → `20.0` | ✅ Creado |
| `fibostech/asada_app` | **App Flutter** — offline-first con foto+GPS + órdenes | `20.dev` → `20.0` | ✅ Creado |

---

## 🏗️ Arquitectura final

### Módulo `asada` (app principal)

```
asada/  ← módulo raíz, como 'contacts' o 'accounting'
├── __manifest__.py
│   name: 'asada'
│   category: 'Services/ASADA'
│   depends: ['base', 'mail', 'contacts']
│
├── security/
│   ├── asada_groups.xml
│   │   └── group_asada_user (security group propio)
│   └── ir.model.access.csv
│       └── asada.* → FULL; res.partner → READ
│
├── models/
│   ├── asada_pais.py            ← Catálogo países
│   ├── asada_escenario.py       ← flat_fee / metered_own / metered_regulated
│   ├── asada_medidor.py         ← NIS universal
│   ├── asada_lectura.py         ← + foto + GPS
│   ├── asada_orden_trabajo.py   ← + fotos múltiples + GPS
│   ├── asada_contrato.py        ← Contrato servicio
│   ├── asada_tarifa.py          ← Tarifas por escenario
│   ├── asada_factura.py         ← Facturación/recibos
│   └── asada_sincronizacion.py  ← Log sync
│
├── controllers/                 ← API REST (xmlrpc + json)
│   └── asada_api.py
│       ├── GET  /api/asada/v1/config
│       ├── POST /api/asada/v1/auth/login
│       ├── GET  /api/asada/v1/rutas
│       ├── POST /api/asada/v1/lecturas      ← multipart (foto)
│       ├── GET  /api/asada/v1/ordenes
│       └── POST /api/asada/v1/ordenes/<id>/completar
│
├── views/
│   ├── asada_menu.xml           ← Menú principal ASADA
│   │   └── Solo visible con grupo_asada_user
│   ├── asada_medidor_views.xml
│   ├── asada_lectura_views.xml
│   ├── asada_orden_views.xml
│   ├── asada_contrato_views.xml
│   └── asada_tarifa_views.xml
│
└── data/
    └── asada_data.xml           ← Datos demo / configuración base
```

### Módulo `asada_cr` (extensión Costa Rica)

```
asada_cr/
├── __manifest__.py
│   depends: ['asada']  ← hereda del módulo principal
│
├── models/
│   └── asada_cr_tarifa.py       ← Cálculos AyA específicos CR
│
├── views/
│   └── asada_cr_reportes.xml    ← Reportes AyA
│
└── asada_cr_fe/ (OPCIONAL)
    └── Integración Hacienda CR
```

---

## 🔐 Modelo de seguridad

```
grupo_asada_user
├── asada.*             → ✅ CRUD completo
├── res.partner         → ✅ Solo lectura (asignar clientes)
├── Menú ASADA          → ✅ Visible
├── Otros módulos       → ❌ Sin acceso (cada app su grupo)
└── Datos fuera ASADA   → ❌ Invisibles

Ejemplos:
┌───────────────┬──────────────────┬──────────────────┐
│ Usuario       │ Ve ASADA?        │ Ve contactos?    │
├───────────────┼──────────────────┼──────────────────┤
│ group_asada   │ ✅ CRUD completo  │ ✅ Solo lectura  │
│ base.group_user  │ ❌ No existe     │ ✅ CRUD completo  │
│ account.group   │ ❌ No existe     │ ✅ (por contacts) │
└───────────────┴──────────────────┴──────────────────┘
```

---

## 📱 App Flutter (`asada_app`)

```
asada_app/ (Flutter)
├── lib/
│   ├── models/         ← Isar DB (offline)
│   │   ├── medidor.dart
│   │   ├── lectura.dart    ← GPS + foto path
│   │   ├── orden_trabajo.dart  ← fotos paths + GPS
│   │   └── config.dart
│   ├── services/       ← Dio HTTP + offline queue
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   ├── camera_service.dart   ← 📸
│   │   ├── gps_service.dart      ← 📍
│   │   └── sync_service.dart
│   ├── blocs/          ← Bloc Pattern
│   └── pages/          ← Pantallas
│       ├── login.dart
│       ├── dashboard.dart
│       ├── ruta_detalle.dart
│       ├── captura_lectura.dart  ← Foto + GPS + valor
│       ├── orden_trabajo.dart    ← Fotos + GPS + cierre
│       └── sync_status.dart
└── pubspec.yaml
```

---

## 🔷 Tareas por fase

### FASE 0 — Infraestructura 🏗️ (COMPLETADA ✅)
- [x] Crear repos: `asada_base`, `asada_cr`, `asada_app` (rama `20.dev`)
- [x] FlutterBot configurado como agente OpenClaw
- [x] Proyecto Odoo ID 21: 6 etapas, 5 hitos, 15 tareas
- [x] Proyecto marcado En Progreso (on_track, 5%)

### FASE 1 — Módulo `asada` (Odoo 20) ⚙️ (OdooBot)

#### Setup
- [ ] Estructura base: `__manifest__.py`, `models/__init__.py`, etc.
- [ ] Dependencias: base, mail, contacts

#### Seguridad
- [ ] `security/asada_groups.xml` — Crear `group_asada_user`
- [ ] `security/ir.model.access.csv` — Permisos CRUD para asada.*
- [ ] `ir.rule` — Aislamiento: contacts ve contactos, ASADA ve ASADA

#### Modelos
- [ ] `asada_pais` — Catálogo países
- [ ] `asada_escenario` — flat_fee / metered_own / metered_regulated
- [ ] `asada_medidor` — NIS universal (código, GPS, estado)
- [ ] `asada_lectura` — Lectura (medidor, fecha, **gps_lat**, **gps_lng**, **foto**, sync_state)
- [ ] `asada_orden_trabajo` — Avería (cliente, prioridad, estado, **fotos_ids**, **gps_lat**, **gps_lng**, materiales)
- [ ] `asada_contrato` — Contrato (cliente, medidor, escenario, tarifa)
- [ ] `asada_tarifa` — Tarifa configurable por escenario
- [ ] `asada_factura` — Facturación / recibo
- [ ] `asada_sincronizacion` — Log de sincronización app

#### API REST
- [ ] Endpoints: config, auth, rutas, lecturas, ordenes, sincronizar
- [ ] Aceptar multipart (foto) en lecturas y órdenes
- [ ] JWT / API Key

#### Motor tarifario
- [ ] Escenario `flat_fee` — Cuota fija mensual
- [ ] Escenario `metered_own` — Tarifa propia con rangos
- [ ] Escenario `metered_regulated` — Tarifa regulada (hook por país)

#### Vistas
- [ ] Menú principal ASADA (solo grupo_asada_user)
- [ ] Vistas: medidores, lecturas, órdenes, contratos, tarifas

### FASE 2 — Módulo `asada_cr` (Odoo 20) ⚙️ (OdooBot)
- [ ] Tarifas reguladas AyA (residencial, comercial)
- [ ] Reportes legales AyA
- [ ] **FE Opcional** — `asada_cr_fe` (Hacienda CR)

### FASE 3 — App Flutter 🐦 (FlutterBot)
- [ ] Setup proyecto + dependencias (isar, dio, bloc, **geolocator**, **image_picker**)
- [ ] Modelos offline (Isar DB): Medidor, Lectura (foto+GPS), OrdenTrabajo (fotos+GPS)
- [ ] Servicios: Auth, Camera 📸, GPS 📍, API, Sync
- [ ] Pantallas: Login, Dashboard, Ruta, Captura Lectura, Órdenes, Historial, Sync

### FASE 4 — Integración 🔗 (FlutterBot ↔ OdooBot)
- [ ] Contrato API (OpenAPI)
- [ ] Sync lecturas con foto + GPS
- [ ] Sync órdenes con fotos + GPS
- [ ] Pruebas e2e (3 escenarios)

### FASE 5 — QA y Despliegue 🚀
- [ ] QA funcional + pruebas campo
- [ ] Build producción + publicación app
- [ ] Documentación + manual
- [ ] Despliegue rama `20.0`

---

## 📊 Leyenda

| Símbolo | Significado |
|:--------|:------------|
| `[x]` | Completado |
| `[ ]` | Pendiente |
| 🐦 | FlutterBot (app + PM) |
| ⚙️ | OdooBot (backend) |
| 📸 | Función de cámara |
| 📍 | Función de GPS |