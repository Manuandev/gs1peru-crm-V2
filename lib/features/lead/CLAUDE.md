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
- `LeadCard` (list/) → compacta, borde izquierdo por estado efectivo. Avatar chico (`avatarRadiusSm`, mismo estilo que `ChatTile` de Conversaciones — color por nombre + `AppIcons.user`, sin iniciales ni badge de canal) a la izquierda; a su derecha 3 líneas: (1) nombre + ícono de canal inline (sin texto/pill, `AppSocialUtils.widgetCanalById`) ... fecha alineada a la derecha; (2) oportunidad (`lead.evento`, negrita chica) ... "Hace X" + chip de estado (el chip siempre comparte esta fila con hace-X, nunca va solo en su propia línea); (3) empresa (`lead.nombreEmpresa`, sin negrita). Debajo, `LeadCardActions` en fila
- `LeadCardActions` (list/) → 2 botones chicos en fila (`AppSizing.miniActionButton` = 32dp): WhatsApp cuadrado verde (`AppSocialUtils.colorCanalById(1)`, ícono only) + "Ver detalle" con borde y texto en `colorScheme.primary`. El menú "⋯" (favorito / abrir chat) se quitó — `ToggleFavoritoPressed` sigue viva en `LeadListBloc` pero sin trigger de UI en la lista por ahora
- `LeadListFilterChips` (list/) → 5 chips (Todos/Asesores*/Nuevos/En gestión/Propuesta — la etiqueta "En gestión" mapea al filtro `enDesarrollo`) en fila con scroll horizontal (`SingleChildScrollView`). Todos/Asesores llevan ícono (`AppIcons.filter` / `AppIcons.userFilled`); Nuevos/En gestión/Propuesta llevan un punto de color (azul `AppColors.info` / verde `AppColors.success` / morado `AppColors.purple`). *Asesores solo lo ve el moderador. El chip "Asesores" nunca aplica el filtro directo — `LeadListPortrait` intercepta su tap y abre `LeadAsesorPickerModal`
- `LeadAsesorPickerModal` (list/) → bottom sheet con buscador (nombre o `codUser`), reactivo a `CatalogsBloc` (`BlocBuilder<CatalogsBloc, CatalogsState>`, no recibe la lista como snapshot estático); cada fila muestra avatar (iniciales + color), nombre, código, punto verde si `disponible` y el conteo de leads (`conteosPorAsesor`, calculado en el bloc sobre `_allLeads`, no en el backend). Ícono de refrescar en el header dispara `CatalogsLoadRequested` (reusa el catálogo completo — sin endpoint dedicado, ver nota abajo). Retorna el `codUser` elegido o `null`. `LeadListPortrait` interpreta `null` (back, tap fuera, botón cerrar) como "volver a Todos" — nunca deja el filtro a medias
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
- Task `'LCG'` (`obtenerHistorialComentarios(idNumero)`) → comentarios de **todos los leads** del mismo número. Usado por `HistorialTab` en `ContactoDetalleView` (`HistorialTab(idNumero: ...)`)
- Task `'LH'` (`obtenerHistorialSeguimiento(idLead)`) → seguimiento de **un lead puntual** (no agrupa por número). Usado por `HistorialTab` en `ChatLeadPanel` (`HistorialTab(idLead: ...)`). Trae menos columnas que 'LCG' (sin ícono/color de actividad ni usuario nominal) y no distingue `TipoActor.cliente` — ambos SPs comparten la entidad `HistorialComentario` y el cubit `HistorialLeadCubit`, que expone `cargarHistorial(idNumero)` y `cargarHistorialSeguimiento(idLead)` por separado

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
- `CatalogsBloc.asesores` se carga una sola vez al iniciar sesión — un asesor recién asignado
  a un lead no aparece hasta refrescar. Dos puntos de refresco (ambos disparan el mismo
  `CatalogsLoadRequested`, sin endpoint dedicado solo-asesores — el payload total de catálogos
  es pequeño y no justifica separarlo): ícono en el header de `LeadAsesorPickerModal`, y el
  pull-to-refresh de `HomeView` (que además de `HomeRefresh` ahora dispara `CatalogsLoadRequested`)
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
- Botón WhatsApp de `LeadCard` → `context.goToDetalleChat(idChatCab: lead.idChatCab)` (apila)

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

---

## EditLeadPortrait — reglas de negocio y flag `desdeConversacion`

`EditLeadPortrait` (widgets/edit_lead/) es la pantalla "Crear/Editar negociación", compartida por
varios orígenes (Conversaciones, `NegociacionesTab` de Lead, `ContactoNegociacionesTab` de
Seguimiento, `ContactoDetallePage`). Solo muestra 2 secciones — **Información de la negociación**
e **Información financiera** — nunca "Información adicional" (nombre/modalidad de la negociación):
ese widget se eliminó (`EditLeadAdicionalSection`, ya no existe) porque el campo no se muestra en
ningún origen, edite o cree, venga o no de conversación.

### Reglas universales (todos los orígenes)

- **Precio base** y **Descuento** nunca son editables por el usuario, en ningún origen ni
  pantalla — `EditLeadFinancieraSection` los renderiza siempre `enabled: false`. Precio base se
  autocompleta al elegir Oportunidad (`item.importeGeneral`, en `_onOportunidadChanged`);
  Descuento se autocalcula como `subtotal - costoFinal`. El único campo editable de esa fila es
  **Costo final** (`_costoFinalCtrl`) — ya no existe el toggle `costoFinalEditable`, es el
  comportamiento único.
- **Campaña/Oportunidad** solo son editables al **crear** (`negociacion.idLead == 0`), sin
  importar el origen — al editar una negociación ya existente quedan siempre bloqueadas
  (`campaniaOportunidadBloqueada: !_esNuevo` en `_EditLeadPortraitState.build()`).
- **Cantidad** arranca en `1` por defecto al crear (antes quedaba en 0/blanco) — ver
  `initState()._cantidadInicial`.
- Para **crear** una negociación son obligatorios Campaña, Oportunidad, Canal y Cantidad — el
  botón Guardar no se habilita hasta tenerlos completos (`_puedeGuardar` /
  `_camposObligatoriosCompletos`, reemplaza a `_hayCambios` como gate del `FormSaveBar` cuando
  `_esNuevo`). Los labels llevan `(*)` en `EditLeadNegociacionSection`/`EditLeadFinancieraSection`.

### Flag `desdeConversacion`

Viaja `context.goToEditarLead(desdeConversacion: true)` → `AppRoutes.detalleEditarLead` →
`EditLeadPage` → `EditLeadView` → `EditLeadPortrait`, y se activa solo cuando se entra desde el
AppBar de `ChatDetailView` (Conversaciones). Restringe además:

- **Canal** siempre bloqueado, fijo en WhatsApp — tanto al crear como al editar.
- **Estado/Subestado** bloqueados fijos en "Nuevo" **solo al crear** (`negociacion.idLead == 0`);
  al editar una negociación ya creada, se pueden mover de estado normalmente.
- **Interés** siempre editable.

**Ojo — Estado/Canal bloqueados se renderizan como `CustomTextField` deshabilitado con texto fijo
("Nuevo"/"WhatsApp"), NUNCA como `CustomComboField` con `enabled: false`.** Motivo: `CustomComboField`
solo lee `initialValue` en su propio `initState()` (`custom_combo_field.dart`) — si el valor forzado
se calcula después del primer build del combo (o el catálogo no trae ese estado marcado `esPadre`),
el combo queda visualmente vacío y no refleja el valor bloqueado. `_guardar()` tampoco depende de que
`_estado`/`_canal` hayan matcheado contra el catálogo: al crear desde conversación manda `idEstado:
'00'`/`estado: 'Nuevo'` directo. El canal si intenta matchear por id `1` y, si falla, por nombre
(`contains('whatsapp')`) — ver `_inicializarCombos`.

Si se agrega un nuevo origen que también deba usar el modo restringido de conversación, reusar el
flag `desdeConversacion` — no crear uno paralelo.
