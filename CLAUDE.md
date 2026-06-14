# GS1 Perú — CRM App
> Flutter · Material 3 · BLoC · Clean Architecture

---

## Reglas globales — leer siempre

### Imports obligatorios
```dart
import 'package:app_crm/core/index_core.dart';        // tokens + widgets custom
import 'package:app_crm/config/index_config.dart';    // rutas + navegación
import 'package:app_crm/index_dependencies.dart';     // paquetes externos
// Cada feature tiene su propio index_xxx.dart — usarlo siempre
```

Nunca importar archivos individuales si existe un `index_*.dart` que los re-exporta.

---

### Reglas de código — sin excepciones

1. **Nunca literales** de color, tamaño, espaciado, ícono o ruta. Siempre tokens del Design System.
2. **Nunca widgets nativos** donde existe un custom widget (`CustomPrimaryButton`, `CustomTextField`, etc.).
3. **Íconos UI** → `AppIcons` | **Íconos sociales/etapas** → `AppIconsSocial`.
4. **`const`** donde sea posible.
5. **Variables, métodos y comentarios en español.** Clases en `PascalCase`. Archivos en `snake_case`.
6. Si un **token no existe**, crearlo primero en el archivo correspondiente de `lib/core/constants/` con un comentario que explique su uso, luego usarlo. Nunca hardcodear el valor.
7. Estar **mínimo 95% seguro** de lo que el usuario quiere antes de generar código. Si hay ambigüedad, hacer **una sola pregunta concreta** antes de proceder.
8. Material 3 activo — usar `colorScheme`, no colores hardcodeados en widgets individuales.

---

### Documentación por carpeta

| Carpeta | CLAUDE.md con detalle |
|---|---|
| `lib/core/` | Design System completo (colores, spacing, tipografía, iconos, widgets, temas, utilidades) |
| `lib/config/` | Rutas, navegación, transiciones, extensions |
| `lib/features/` | Patrones BLoC, UseCase, Repository, DataSource, modelos, ApiResult, CrudResult |

---

## Convención de estructura por feature

```
features/mi_feature/
└── presentation/
    ├── bloc/
    │   └── [pantalla]/        ← subcarpeta obligatoria por pantalla/función
    │       ├── mi_bloc.dart
    │       ├── mi_event.dart
    │       └── mi_state.dart
    ├── pages/                 ← un archivo por pantalla
    │   └── mi_page.dart
    └── widgets/
        └── [pantalla]/        ← subcarpeta obligatoria por pantalla
            ├── mi_view.dart
            └── mi_widget.dart
```

**Ejemplos reales:**
```
lead/presentation/bloc/list/       → LeadListBloc
lead/presentation/bloc/detail/     → LeadDetalleBloc
home/presentation/bloc/home/       → HomeBloc
home/presentation/bloc/notifications/ → NotificationsBloc
chat/presentation/bloc/chat_list/  → ChatListBloc
chat/presentation/bloc/chat_detail/→ ChatDetailBloc
chat/presentation/bloc/edit_lead/  → EditLeadBloc
chat/presentation/bloc/info_lead/  → InfoLeadCubit
chat/presentation/bloc/template/   → SelectTemplateBloc
```

---

## Convención de nombres

- **Carpetas de BLoC y widgets**: inglés preferido (`list/`, `detail/`)
- **Excepciones de dominio en español** cuando el término no tiene equivalente natural: `factura/`, `plan/`, `cobranza/`
- **BLoCs**: `[Modulo][Pantalla]Bloc` o `[Modulo][Pantalla]Cubit`
- **Pages**: `[modulo]_[pantalla]_page.dart`
- **Widgets de vista**: `[modulo]_[pantalla]_view.dart`
- **Widgets auxiliares**: `[modulo]_[descripcion]_widget.dart` o `[descripcion].dart`

---

## Separadores de SP (nunca usar literales)

```dart
AppConstants.sepRegistros  // '¬' — separa registros en una lista
AppConstants.sepCampos     // '¦' — separa campos de un registro
AppConstants.sepListas     // '¯' — separa secciones en respuesta
AppConstants.sepComodin    // '¨' — uso libre
AppConstants.sepComodin2   // '±' — uso libre
AppConstants.sepComodin3   // '¶' — uso libre
```

---

## Regla de mantenimiento

Cada vez que agregues una pantalla, BLoC, SP o widget importante:
1. Crea la subcarpeta correspondiente en `bloc/` y `widgets/`
2. Actualiza el `CLAUDE.md` del feature con la nueva pantalla/BLoC/SP
3. Actualiza el `index_[feature].dart` con los nuevos exports