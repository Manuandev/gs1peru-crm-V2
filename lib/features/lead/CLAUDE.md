# Lead Feature

## Propósito
Gestiona la lista y detalle de leads en dos modos: Seguimientos (`PO`) y Propuestas (`PA`).

## Pantallas
- `LeadListPage` → lista de leads con chips de filtro; recibe `filtroInicial` opcional (`LeadListFiltro?`) para preseleccionar un chip al entrar (ej. desde `CardTotalesHome` en el dashboard)
- `LeadDetallePage` → detalle completo del lead con comentarios y stepper de estado

## BLoCs / Cubits
- `LeadListBloc` (list/) → carga leads por tipo, filtra en memoria; conteos por filtro (usa `idEstadoPadre` para agrupar sub-estados bajo su padre)
- `LeadDetalleBloc` (detail/) → carga detalle + comentarios de un lead por `idLead`

## Widgets principales
- `LeadListView` (list/) → vista principal: AppBar simple (solo drawer + título, sin buscar ni popup) + banner de subtítulo "Gestiona el avance de tus casos"; muestra `LeadListSkeleton` en loading
- `LeadListSkeleton` (list/) → skeleton de carga de la lista: chips placeholder + 7 cards placeholder
- `LeadListPortrait` (list/) → StatelessWidget: chips + `LeadListStatsRow` + lista de `LeadCard`s en el orden que entrega el bloc (sin selector de orden — descartado por decisión de negocio)
- `LeadListStatsRow` (list/) → 3 tarjetas resumen (Nuevos / En gestión / Listos para propuesta) con conteos de `LeadListBloc`; mismo tamaño en las 3 (`IntrinsicHeight` + `CrossAxisAlignment.stretch`), orden interno: ícono → etiqueta → número (coloreado azul/verde/morado) → palabra "casos" fija
- `LeadCard` (list/) → único estilo (ya no hay modo compacto/detallado): borde izquierdo por estado efectivo, avatar+badge canal, pill de canal junto al nombre, timestamp + chip de estado, fila de acciones
- `LeadCardActions` (list/) → botón WhatsApp, botón "Ver detalle" y menú "⋯" (favorito / abrir chat)
- `LeadListFilterChips` (list/) → 5 chips (Todos/Asesores*/Nuevos/En gestión/Propuesta — la etiqueta "En gestión" mapea al filtro `enDesarrollo`) en fila con scroll horizontal (`SingleChildScrollView`). Todos/Asesores llevan ícono (`AppIcons.filter` / `AppIcons.userFilled`); Nuevos/En gestión/Propuesta llevan un punto de color (azul `AppColors.info` / verde `AppColors.success` / morado `AppColors.purple`). *Asesores solo lo ve el moderador. El chip "Asesores" nunca aplica el filtro directo — `LeadListPortrait` intercepta su tap y abre `LeadAsesorPickerModal`
- `LeadAsesorPickerModal` (list/) → bottom sheet con buscador (nombre o `codUser`) sobre el catálogo `CatalogsBloc.state.asesores`; cada fila muestra avatar (iniciales + color), nombre, código, punto verde si `disponible` y el conteo de leads (`conteosPorAsesor`, calculado en el bloc sobre `_allLeads`, no en el backend). Retorna el `codUser` elegido o `null`. `LeadListPortrait` interpreta `null` (back, tap fuera, botón cerrar) como "volver a Todos" — nunca deja el filtro a medias
- `LeadDetalleView` (detalle/) → layout principal del detalle con todas las secciones
- `LeadDetalleSkeleton` (detalle/) → skeleton de carga del detalle: reemplaza el BasePage completo
- `LeadDetalleStepper` (detalle/) → stepper visual de 4 etapas con header "ETAPA · X de 4 · Nombre"
- `LeadInfoSectionCard` (detalle/) → card base reutilizable con título en mayúsculas + filas
- `LeadContactoCard` (detalle/) → card CONTACTO: Teléfono (tappable) + Correo
- `LeadContextoCard` (detalle/) → card CONTEXTO: Origen + Curso/Interés + Empresa
- `LeadDetalleComentarios` (detalle/) → lista de comentarios del lead con burbuja y botón agregar
- `LeadDetalleActions` (detalle/) → botones de acción del detalle (WhatsApp, Llamar, Recordatorio, Editar)

## SPs que consume
- `[CRM].[SP_LeadsLst]` → lista de leads por tipo ('PO' o 'PA') y agente/moderador

## Dependencias externas
- `LeadRepository` (RepositoryProvider global)
- `SessionService` → solo para rol de moderador (visibilidad del chip "Asesores")
- `CatalogsBloc` (global) → fuente de `List<AsesorItem>` para `LeadAsesorPickerModal`, cargado una sola vez al iniciar sesión

## Notas importantes

### LeadType — tipos de lista
```dart
enum LeadType {
  seguimientos,  // código SP: 'PO' → ruta AppRoutes.seguimiento
  propuestas,    // código SP: 'PA' → ruta AppRoutes.propuestas
}
```

### LeadListFiltro
```dart
enum LeadListFiltro { todos, asesores, nuevos, enDesarrollo, propuesta }
```
- Filtro inicial siempre `todos` (moderador y agente) — el backend ya limita el dataset del
  agente a sus propios leads, así que "Todos" ya representa "mis casos" para un no-moderador
- Chip "Asesores" (antes "Mis casos") solo lo ve el moderador. Ya NO filtra por el usuario de
  la sesión — abre `LeadAsesorPickerModal` y filtra por `asesor == codUser` del asesor elegido
  ahí (evento `LeadListAsesorSeleccionado`, guardado en `_asesorSeleccionado`/`state.asesorSeleccionado`)
- Conteos se calculan sobre `_allLeads` (lista completa), no sobre la lista filtrada.
  `state.conteosPorAsesor` (`Map<String,int>` por `codUser`) alimenta el picker; no hay una
  entrada de `asesores` en `conteos` — ese chip nunca muestra número, solo el label
- Un lead pertenece a un bucket (`nuevos`/`enDesarrollo`/`propuesta`) si su `idEstado` coincide
  directo **o** si su `idEstadoPadre` apunta a ese id — así un sub-estado (ej. "07 Solicita
  ficha", padre "01") cuenta dentro de "En gestión". Ver `LeadListBloc._perteneceEstado`.
- `propuesta` = idEstado `'02'` (Cotización) + sus hijos

### Navegación
- Seguimiento/Propuestas → `clearAndPush` (limpia stack; se abre desde Drawer)
- `context.goToSeguimiento(filtroInicial: LeadListFiltro.nuevos)` → abre Seguimiento con un chip
  preseleccionado. Usado por `CardTotalesHome` (dashboard de Home): Nuevos → `nuevos`,
  En gestión → `enDesarrollo`, Propuestas → `propuesta`. Sin `filtroInicial` (ej. desde el
  Drawer) el filtro por defecto es `todos`.
- Detalle de chat desde lead → `context.goToDetalleChat(idLead: lead.idLead)` (apila)

### Campos principales de Lead
```dart
lead.idLead         // int — identificador único
lead.idEstado       // String — '00'–'15' (ver AppIcons etapas)
lead.idEstadoPadre  // String? — si existe, es un sub-estado del padre
lead.idEstadoEfectivo // String — getter: idEstadoPadre si existe, si no idEstado
lead.estadoEfectivo   // String — getter: descripcionEstadoPadre si existe, si no estado
lead.idCanal        // int — canal de origen (ver AppIcons canales)
lead.asesor         // String — codUser del agente asignado (filtro asesores)
lead.nombreCompleto // String — getter: nombre + apellido
lead.fechaHora      // String — usar .formatSinHoy() para mostrar
lead.evento         // String — oportunidad/producto (subtítulo 1ª parte)
lead.interes        // String — interés del lead (subtítulo 2ª parte)
lead.nombreEmpresa  // String — empresa (subtítulo 3ª parte)
lead.canal          // String — nombre del canal
lead.estado         // String — label del estado propio (usar estadoEfectivo para mostrar)
```
**Siempre usar `idEstadoEfectivo`/`estadoEfectivo` para mostrar/agrupar** (borde de card, chip
de estado, conteos) — nunca `idEstado`/`estado` directo, para no ignorar el padre.

---

## Patrón de skeletons

Ambas pantallas usan `SkeletonBox` (animación pulse grey300↔grey200, 900ms) del core. No hay dependencia de paquetes externos — el shimmer es propio.

### LeadListSkeleton — cuerpo del BlocBuilder
- **Archivo:** `presentation/widgets/list/lead_list_skeleton.dart`
- **Uso:** dentro del `BlocBuilder` de `LeadListView`, reemplaza al estado `LeadListLoading | LeadListInitial`
- **Estructura:** `Column` → fila de chips placeholder + `ListView` con 7 `_LeadCardSkeleton`
- **Tokens nuevos en `AppSizing` (`lib/core/constants/app_breakpoints.dart`):**
  - `skeletonChipHeight = 30.0` — altura del chip placeholder (chipPaddingV×2 + labelMedium)
  - `skeletonChipWidthSm = 72.0` — chip corto (Todas, Nuevos, badge de estado)
  - `skeletonChipWidthMd = 96.0` — chip largo (Mis casos, En desarrollo)

### LeadDetalleSkeleton — BasePage completo
- **Archivo:** `presentation/widgets/detalle/lead_detalle_skeleton.dart`
- **Uso:** devuelve un `BasePage` completo desde `LeadDetallePage` mientras `LeadDetalleBloc` está en `Initial | Loading`
- **Estructura:** AppBar con nombre placeholder + stepper + última interacción + 2 info-cards + comentarios
