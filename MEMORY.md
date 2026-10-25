# MEMORY.md — FlutterBot 🐦 / Proyecto ASA-2026-001

_Última actualización: 5-oct-2026_

## 🎯 Propósito
App `asada` para Odoo 20 (como contacts, accounting) + app Flutter offline-first:
gestión de medidores (NIS), lecturas con foto+GPS, órdenes de trabajo,
facturación multi-escenario (flat_fee, metered_own, metered_regulated) y multi-país.

## 🏗️ Arquitectura final

```
Odoo 20 — Módulo 'asada' (app principal, grupo propio)
├── 📊 Medidores/NIS
├── 📝 Lecturas (foto + GPS)
├── 🔧 Órdenes trabajo (fotos + GPS)
├── 📄 Contratos
├── ⚙️ Motor tarifario (3 escenarios)
└── 🌐 Country hooks

Extensiones:
├── asada_cr (Costa Rica: AyA, FE opcional)
└── asada_xx (países futuros)

App Flutter:
└── asada_app (offline-first, foto+GPS, Bloc Pattern)
```

## 🔐 Seguridad
- `group_asada_user` → CRUD en `asada.*`, solo lectura en `res.partner`
- ASADA data SOLO visible desde módulo ASADA
- Cada app su grupo (contacts, accounting, purchases...)

## 📦 Repos
| Repo | Rama | Estado |
|:-----|:-----|:-------|
| `fibostech/asada_base` | `20.dev` | ✅ Creado |
| `fibostech/asada_cr` | `20.dev` | ✅ Creado |
| `fibostech/asada_app` | `20.dev` | ✅ Creado |

## 🎯 Odoo Projects
- ID 21 — ASA-2026-001 — Sistema ASADAS
- Status: **En Progreso** (on_track, 5%)
- 6 etapas · 5 hitos · 15 tareas
- URL: https://fibostech.odoo.com/web#id=21&model=project.project

## 🐾 Agentes
- 🐦 **FlutterBot** — App Flutter + PM del proyecto
- ⚙️ **OdooBot** — Módulos Odoo (asada, asada_cr)
- 🐺 **Argos** — QA + despliegue