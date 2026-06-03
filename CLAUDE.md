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