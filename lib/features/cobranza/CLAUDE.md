# Cobranza Feature

## Lista paginada (keyset) + panel de filtros Desde/Hasta/Campaña/Oportunidad (2026-09-09)

`CobranzaListPage` / `CobranzaListBloc` pasaron a **paginado real** (task `'LSP'` de
`CRM.CSV_COBRANZAS_LST_APP`, mismo patrón que Seguimiento y Solicitudes) — antes `getCobranzas()`
(task `'LS'`) traía TODO (~500 filas y creciendo) con ~10 subconsultas pesadas (`SUM` sobre
`T_TECMSOLINSCRIPCION02`, `ROW_NUMBER`, scan completo de `dbo.Comprobante`, etc.) y filtraba en
memoria. `'LS'` + `CobranzaModel` + `GetCobranzasUseCase` **siguen existiendo** (sin caller hoy,
se conservan).

**SP — task `'LSP'` nuevo** (`'LS'` y `'DT'` intactos):
- `#Base` filtrada PRIMERO (asesor + fecha + campaña `OP.ID_CAMPANIA` +
  oportunidad + chip contado/crédito), `SELECT DISTINCT`. Keyset por `FC_ULTIMA DESC, NUMSOL
  DESC`. `#Pagina` = `TOP (@TAM)` NUMSOL con el filtro de **estado** (las 4 tarjetas) aplicado
  acá. Los `SUM`/joins de importe/moneda/ejecutivo/estado se resuelven **solo sobre `#Pagina`**
  (los joins muertos de `'LS'` — HL/F/CO/G/CU/FC/EV — se descartaron).
- **Fecha = `FC_ULTIMA = ISNULL(CI.FC_USUARIO_M, CI.FC_USUARIO_C)`** (2026-09-09) — última
  modificación de `EVT.T_TECMSOLINSCRIPCION01`, y si es NULL, la creación. Mismo criterio que el
  `'LSP'` de Solicitudes/Seguimiento. Antes el `'LSP'` de Cobranza usaba `CI.FC_USUARIO_C` puro
  (creación) — se cambió en los 6 puntos: expresión de `#Base` (alias renombrado
  `FC_USUARIO_C`→`FC_ULTIMA`), índice `IX_BASE`, filtro Desde/Hasta, keyset `B.FC_ULTIMA
  </=@CUR_FECHA`, `ORDER BY` de `#Pagina`, campo 10 mostrado, campo 23 cursor y el `WITHIN GROUP`
  del `STRING_AGG` final. Flutter no cambió (el modelo ya trataba el campo como opaco). El `'LS'`
  viejo **no** se tocó (sigue con `FC_USUARIO_C`). Pendiente `ALTER PROCEDURE`.
- **Contadores** (solo 1ª página, bloque `¯` al inicio): `total¦facturar(2)¦pendDoc(0)¦pendPago(5)
  ¦cancelado(3)¦pendGlobal`. Los 4 de tarjeta aplican fecha/campaña/oportunidad + chip (NO el
  filtro de tarjeta). `pendGlobal` = Pend. de documento **sin ningún filtro del panel** → alimenta
  el badge "Cobranza" del drawer (mismo criterio que `TOT_COBRANZA` del SP de home).
- **Contrato de fila:** mismos 23 campos (0..22) que `'LS'` → se reusa `CobranzaModel.fromRawString`
  sin cambios. Campo **23** nuevo = `CONVERT(VARCHAR(23), CONVERT(DATETIME2(3), ISNULL(CI.FC_USUARIO_M,
  CI.FC_USUARIO_C)), 126)` = cursor (junto al NUMSOL, campo 0, de la última fila). El `DATETIME2(3)`
  fijo en ambos lados (acá y `@CUR_FECHA/@FC_DESDE/@FC_HASTA`) evita el bug de precisión de ms que
  cortaba la lista a ~1 página (ver `solicitudes/CLAUDE.md` → "keyset perdía precisión").
- **Body `'LSP'`:** `codUser¦mod¦chip¦idAsesor¦curFecha¦curNumsol¦tam¦fcDesde¦fcHasta¦idCampania¦
  idOportunidad¦estados`. `chip` `''`/`C`/`CR`; `estados` = ID_ESTADO_GES separados por coma (ej.
  `2,5`), `''` = las 4.

**Flutter:**
- `CobranzaFiltroAvanzado` (entidad, `porDefecto()` = 1 del mes actual → hoy, ambos activos) +
  eventos `CobranzaFiltroAvanzadoAplicado`/`Limpiado`. `CobranzaFiltroDrawer` (nuevo,
  `endDrawerWidget` + botón de filtro en el AppBar, naranja si `esDistintoDelDefecto`) — Campaña
  → Oportunidad en cascada, mismo widget que Seguimiento.
- `CobranzaListBloc` reescrito paginado: `_epoca` (restartable para chip/tarjeta/filtro/refresh),
  `_cargandoPagina` (droppable para página siguiente). Cambiar chip / tocar una tarjeta de estado
  / aplicar el filtro → **recarga desde cero** (todos van al SP). Estados nuevos:
  `CobranzaListCargando` (skeleton 1ª carga) / `CobranzaListErrorInicial` / `CobranzaListCargado`
  (con `recargandoLista`, `finLista`, `cargandoMas`, `loadMoreError`, cursor). `CobranzaListSuccess`
  /`Loading`/`Error` (viejos) eliminados.
- `CobranzaListPortrait` → `StatefulWidget` con scroll infinito al 80% + pie (`_CobranzaFooter`:
  spinner / "Reintentar" / "Fin de la lista"). Tamaños de página: 40 / 20.
- `CobranzaListPage` dispara `CatalogsFiltrosRefreshed` al entrar (campañas + oportunidades).
- `goToCobranza({sinRangoFecha})` + el total "Cobranza" de `CardTotalesHome` manda
  `sinRangoFecha: true` → `CobranzaFiltroAvanzado.sinRango()`: las MISMAS fechas del default
  (1 del mes actual / hoy) **ya cargadas** pero con los checkboxes **apagados** (trae todo; si
  el asesor tilda un checkbox, la fecha ya está puesta). Igual que el embudo → Seguimiento.
  Drawer/menú → `.porDefecto()`.
- `conteosPorAsesor` (picker de Asesores) se calcula best-effort sobre las páginas cargadas.

⚠️ Pendiente `ALTER PROCEDURE` de `CRM.CSV_COBRANZAS_LST_APP` en SSMS.

## `CobranzaAsesorPickerModal` — refresco angosto de asesores + tarjetas de estado rediseñadas (2026-08-21)
Dos pedidos del usuario el mismo día, seguimiento directo del revert de abajo:

- **Refresco angosto, no manual** — el revert de abajo dejó el picker sin ninguna recarga (ideal
  para el crash, pero significaba que si a un asesor le asignaban un lead/cobranza nuevo, no se
  reflejaba en el picker hasta reingresar a la app). En vez de volver a disparar
  `CatalogsLoadRequested()` (recarga el catálogo COMPLETO, ~21 partes — el problema original que
  motivó el revert), se agregó un task angosto nuevo, `'ASE'`, al SP `CRM.CSV_LISTAS_LST_APP`
  (mismo criterio que `'TC'`/`'EN'`, ver `core/CLAUDE.md` → `AsesorItem`/`getAsesores()`) — trae
  **solo** el universo de asesores, mismo `SELECT` que ya usa la parte [5] del catálogo completo.
  `_CobranzaAsesorPickerModalState.initState()` llama `CatalogsRepository.getAsesores()`
  (best-effort, `try/catch` silencioso) y guarda el resultado en `_asesoresFrescos` — mientras no
  llega (o si falla), la lista sigue mostrando `CatalogsBloc.state.asesores` (el snapshot cacheado
  desde el login), sin bloquear ni mostrar loading.
- **Tarjetas de estado (`_EstadoBadgeGrande`, antes `_EstadoBadgeChico`) — siempre visibles, más
  grandes, a la derecha.** Antes cada chip de estado (Pend. documento/Facturar/Pend. pago/
  Cancelado) solo se renderizaba si su cantidad era > 0, chico, debajo del nombre — con un asesor
  que solo tenía cobranzas en "Facturar", el resto de estados ni aparecía (reportado por el
  usuario como si faltaran datos, cuando en realidad era la condición `if (cantidad > 0)` la que
  los ocultaba). Ahora los 4 siempre se pintan, en un `Wrap` a la derecha de la fila (donde antes
  vivía el pill de "total", que se quitó — la suma de las 4 tarjetas ya lo comunica), con ícono +
  número más grandes (`AppSizing.iconSm`/`AppTextStyles.labelMedium`, antes `iconInline`/
  `sizeXs`) y color de fondo/contenido según si está activo (`cantidad > 0` → color del estado,
  `colorEstadoGes`) o inactivo (`cantidad == 0` → gris, `surfaceContainerHighest`/
  `onSurfaceVariant`) — mismo lenguaje "activo en color, en cero en gris" en los dos pickers
  (mismo cambio en `SolicitudAsesorPickerModal`, ver `solicitudes/CLAUDE.md`).

## Revert — `CobranzaAsesorPickerModal` ya no recarga nada al abrir (2026-08-21)
**Revierte por completo** "`CobranzaAsesorPickerModal` — recarga al abrir + desglose por
estado" (2026-08-14, más abajo) — pedido explícito del usuario tras un crash real en vivo:
`Could not find the correct Provider<CobranzaListBloc> above this CobranzaAsesorPickerModal
Widget`. El modal ya no dispara `CatalogsLoadRequested`/`CobranzaListRefresh` ni al abrirse
(`initState`) ni por el ícono manual de refrescar (**se eliminó el ícono**, ya no tiene nada que
disparar) — usa directo `CatalogsBloc.state` (global, cargado una vez al iniciar sesión, sin
recarga) y `widget.conteosPorAsesor` tal cual llega por parámetro (el snapshot que
`CobranzaListBloc` ya calculó sobre la lista pintada en pantalla, sin `context.watch` reactivo).
Motivo, en palabras del usuario: "no debería por qué cargar nuevamente los asesores... que
muestre la data que está pintada en la lista". El desglose por `idEstado` (chips chicos en cada
fila, `_AsesorTile`) **no se tocó** — sigue viniendo de `conteosPorAsesor`, solo cambió de dónde
sale ese mapa (snapshot fijo en vez de reactivo). Mismo cambio aplicado en `solicitudes/`
(`SolicitudAsesorPickerModal`, ver su CLAUDE.md) — mismo bug, mismo picker, mismo fix.

## Bug real — la lista se tapaba con loading gris al abrir el picker de "Asesores" (2026-08-20)
Mismo bug, mismo fix que en `solicitudes/` (ver su CLAUDE.md para el detalle completo) —
regresión desde `f1408d6` (2026-08-14): `CobranzaAsesorPickerModal.initState()` dispara
`CobranzaListRefresh()` al abrirse, y el `BlocBuilder<CobranzaListBloc, CobranzaListState>` de
`cobranza_list_view.dart` (sin `buildWhen`) reconstruía a `AppLoadingView()` en cada `Loading` —
el picker es un bottom sheet parcial, así que la parte superior de la lista (chips incluidos)
quedaba visible mostrando el loading mientras corría el refresh silencioso. Fix:
`buildWhen: (previous, current) => current is! CobranzaListLoading || previous is CobranzaListInitial`
— un refresh en segundo plano ya no tapa la lista ya cargada, solo la primera carga real
(`Initial` → `Loading`) sigue mostrando `AppLoadingView`.

## Bug real — comparación de moneda usaba el símbolo en vez del id + campo `monedaId` nuevo en el SP (2026-08-19)
Reportado por el usuario probando en vivo: facturando una cobranza real en dólares (Factura,
monto > S/700), la detracción salía **0,00** en el Plan de crédito — la regla de arriba nunca se
activaba para dólares. El usuario mandó una captura real de `SYSTABEXTER02 CODTABLA='MON'`:
`codargu` **'01'/'02'**, `descorta` **'S/'/'$.'** — confirmando que `CSV_COBRANZAS_LST_APP` (tasks
`'LS'`/`'DT'`) nunca mandaba el id real del catálogo para moneda, solo `MN.descorta` (el símbolo
corto). Primer intento del fix comparó por símbolo (`m.simbolo == moneda`) — **corregido de
inmediato por pedido explícito del usuario: "compara por ID siempre... jamás hagas por alguna
descripción"** — la solución real es agregar el id de verdad al SP, no comparar por texto.

- **`MN.codargu` agregado como campo nuevo** (`monedaId`) al final del `CONCAT` de ambos tasks —
  `'LS'` campo `/*16*/` (después de `/*15*/ MN.descorta`) y `'DT'` campo `/*18*/` (después de
  `/*17*/ CC.ID_CONVERSACION_CAB`) — mismo criterio "nunca correr los índices existentes" del
  resto del feature. **Pendiente de desplegar** — igual que el task `'TC'` (ver más abajo), el
  `.sql` real vive en `CRM.CSV_COBRANZAS_LST_APP.sql` (repo aparte) y el clasificador de
  seguridad bloqueó la escritura directa ahí — bloque entregado al usuario por archivo aparte
  para pegar y correr `ALTER PROCEDURE`.
- **Flutter**: `Cobranza`/`CobranzaModel` ganaron `monedaId` (campo 22, después de `moneda` en
  21); `CobranzaDetalle`/`CobranzaDetalleModel` ganaron `monedaId` (campo 18, después de
  `idChatCab` en 17). `moneda` (descorta/símbolo) se queda igual, **solo para mostrar** — el
  comentario en ambas entidades ahora advierte "NUNCA usar moneda para decidir dólares/soles,
  usar monedaId".
- **`resolverSimboloMoneda`/`esMonedaDolares` (`resolver_moneda.dart`) vuelven a comparar por
  `m.id ==` (nunca por texto/símbolo/descripción)** — ahora reciben `monedaId`, no `moneda`. Todos
  los call sites que antes pasaban `.moneda` (`cobranza_card.dart`, `cobranza_resumen_card.dart`
  ×6, `cobranza_factura_header.dart`, `cobranza_plan_view.dart`, `cobranza_detalle_info_card.dart`)
  pasan `.monedaId` ahora.
- **`monedaId` threaded de punta a punta** igual que `tipoComprobante` (ver sección de abajo) —
  `CobranzaDetalle.monedaId` → `goToFacturarCobranza(monedaId:)` → `CobranzaFacturaPage` →
  `CobranzaFacturaBloc`/`CobranzaFacturaState.monedaId` → (en la validación de "Validar plan de
  crédito") → `goToPlanCredito(monedaId:)` → `CobranzaPlanPage` → `CobranzaPlanBloc`/
  `CobranzaPlanState.monedaId`. `esMonedaDolares` en `CobranzaFacturaPage` (tanto en `build()`
  como en el listener de `continuarPlan`) usa `monedaId`, nunca `moneda`.
- **Hasta que se despliegue el SP**, `monedaId` llega vacío (`''`) para TODAS las cobranzas
  (campo nuevo, el SP viejo no lo trae) — `esMonedaDolares('')` retorna `false` siempre, así que
  el comportamiento por ahora es "tratar todo como si no fuera dólares" (no bloquea, no convierte)
  hasta que el usuario despliegue el `.sql` — ver "Qué falta desplegar" más abajo.

## Regla de negocio — la detracción solo aplica con Factura y monto ≥ S/700 (2026-08-19)
Pedido de negocio: la detracción (12%) ya no se calcula siempre — ahora depende de 2 condiciones,
ambas deben cumplirse:
1. El comprobante de la Solicitud de origen debe ser **Factura** (nunca Boleta).
2. El monto, **convertido a soles si la moneda es USD**, debe ser **≥ 700**.

- **Catálogo nuevo — `TipoCambioItem`** (`core/models/catalog_item.dart`/`catalog_item_model.dart`,
  parte [21] del SP `lstListas`, `DBO.SYSMTC01` filtrado a `FECHA = hoy`) — fila única (`venta`/
  `compra`, ambos `double`), agregado directo por el usuario al SP
  (`CRM.CSV_LISTAS_LST_APP.sql`, repo aparte). `CatalogsLoaded.tipoCambio` expone el getter (ver
  core/CLAUDE.md). **Se usa el tipo `venta`, nunca `compra`**, para convertir USD→PEN.
- **`tipoComprobante` ahora viaja hasta el formulario de facturar** — antes `CobranzaFacturaState`
  no lo tenía en absoluto (el tipo de comprobante se decide en la Facturación de la Solicitud de
  origen, no se re-elige acá). Threaded de punta a punta: `CobranzaDetalle.tipoComprobante` →
  `goToFacturarCobranza(tipoComprobante:)` → argumento de ruta → `CobranzaFacturaPage` →
  `CobranzaFacturaBloc`/`CobranzaFacturaState.tipoComprobante`.
- **`CobranzaFacturaState`** ganó `tipoComprobante` (String) y `montoTotalEnSoles` (double, ya
  convertido) — este último se resuelve **una sola vez**, en `CobranzaFacturaPage.build()`,
  contra `CatalogsBloc` (`esMonedaDolares(monedas, moneda)` — nuevo helper en
  `resolver_moneda.dart`, mismo criterio de match por `MonedaItem.id` que ya usa
  `resolverSimboloMoneda` — y `tipoCambio.venta` si aplica). `detraccion` ahora es
  `aplicaDetraccion ? montoTotal * 0.12 : 0.0`, con `aplicaDetraccion = esFactura &&
  montoTotalEnSoles >= 700` (`esFactura` = `tipoComprobante` contiene "FACTURA", sin distinguir
  mayúsculas). `importeCredito = montoTotal - detraccion` sin cambios (si no aplica detracción,
  importeCredito == montoTotal). **`montoTotalEnSoles` solo se usa para este chequeo del
  umbral** — nunca para ningún importe/cuota real, esos siguen en la moneda original
  (`montoTotal`).
- **Task dedicado `'TC'`, no el catálogo completo — consulta el tipo de cambio del día al entrar
  a "Validar plan de crédito", solo si la moneda es USD.** Seguimiento del mismo día: el primer
  intento reusaba `CatalogsLoadRequested()` (recarga el catálogo COMPLETO, ~21 partes) — el
  usuario pidió, siguiendo el mismo criterio que ya se usó para `solicitudes/` (task `'NEG'`, ver
  su CLAUDE.md — un task angosto en vez de reusar uno grande), un task nuevo en el SP que traiga
  **solo** venta/compra. Se agregó `'TC'` a `CRM.CSV_LISTAS_LST_APP.sql` (repo aparte, mismo
  `SELECT` que ya usaba la parte [21], sin el resto del catálogo) — **pendiente de desplegar**,
  el `.sql` real vive fuera de este repo y el clasificador de seguridad bloqueó la escritura
  directa ahí (fuera del working directory) — el bloque se entregó al usuario por chat/archivo
  aparte para que lo pegue y corra `ALTER PROCEDURE` él mismo.
  - **Flutter**: `CatalogsRemoteDatasource.getTipoCambio()` (body `¯TC`, mismo endpoint
    `urlListasLst` que el catálogo general) → `CatalogsRepository`/`CatalogsRepositoryImpl.
    getTipoCambio()` → `TipoCambioItem`. `CobranzaFacturaPage` (listener de `continuarPlan`) lo
    llama directo **solo si `esMonedaDolares(monedas, state.moneda)`** — con moneda PEN ni se
    consulta, el tipo de cambio nunca hace falta. `monedas` (para saber si es USD) sigue
    leyéndose del `CatalogsBloc` ya cacheado (ese catálogo casi nunca cambia, no hace falta
    refrescarlo).
  - Si sigue sin haber tipo de cambio (`venta <= 0`) después de la consulta, se corta con
    `AppSnackBar.error` ("No hay tipo de cambio registrado para hoy...") y **no navega** — el
    asesor puede reintentar presionando "Validar plan de crédito" de nuevo en cualquier momento
    (cada intento repite la consulta), sin salir de la pantalla de Facturar.
  - **`detraccion`/`importeCredito` que se le pasan a `CobranzaPlanPage` se recalculan con el
    tipo de cambio recién consultado** (`detraccionFresca`/`importeCreditoFresco`, calculados
    inline en el listener) — no `state.detraccion`/`state.importeCredito` (esos usan el valor
    cacheado al armar la página, que puede haber quedado desactualizado si el tipo de cambio se
    registró recién).
  - **Si la consulta falla** (`AppException`, sin conexión) — no bloquea, cae al `tipoCambio` ya
    cacheado en `CatalogsBloc` (best-effort, mismo criterio que el resto de fallos de catálogo en
    la app) — el bloqueo es específicamente por "no hay tipo de cambio", no por "no se pudo
    consultar".
  - **Pendiente, fuera de alcance por falta de tiempo** — el usuario también pidió un task
    dedicado para "Editar lead"/negociación (traer solo lo que esa pantalla usa, en vez del
    catálogo completo al entrar) — no investigado ni tocado en esta sesión, queda para una
    sesión aparte enfocada en `lead/`.
- **No se tocó** `_onFacturarPressed`/`guardarPlanCredito` — la detracción sigue siendo un valor
  derivado (getter), nunca se manda como columna propia al backend; lo que sí cambia
  indirectamente es `importeCredito` (usado para calcular las cuotas del plan), que ahora puede
  coincidir con `montoTotal` si la detracción no aplica.
- **Pendiente, fuera de alcance de esta sesión (falta de tiempo)** — el usuario mencionó un
  problema relacionado en `lead/` (EditLead/editar negociación): el catálogo cacheado al login no
  siempre trae oportunidades/campañas recién creadas. Pidió evaluar refrescar `CatalogsBloc`
  también al entrar a Editar lead — **no implementado todavía**, needs su propia sesión enfocada
  en `lead/`, no se tocó nada de esa feature acá.

## 3 bugs reales en el Plan de crédito — cronograma con base incorrecta, Fecha no sincronizaba Días, cuota 1 sin validar contra la 2 (2026-08-19)
Reportado por el usuario con un caso real (screenshot): Importe Comprobante 600, Detracción
(12%) 72, Importe a Crédito menos Detracción 528 — con la cuota única por defecto (antes de
tocar "Vista previa") el cronograma mostraba correctamente Total: 528, pero preguntó por qué
"si pongo 3 cuotas, ahí recién se pone bien" (dando a entender que el total cambiaba según N).
Los 3 campos de arriba **sí son datos reales**, no hardcodeados —
`CobranzaFacturaState.detraccion` = `montoTotal * 0.12`, `.importeCredito` = `montoTotal -
detraccion` (confirmado ya desde el 2026-08-09, "Overlay de carga al facturar" documenta el fix
de `detraccion` de 0 hardcodeado a real) — el problema no era esos 3 campos, era el cronograma.

- **Bug 1 — `_onVistaPrevia` (`cobranza_plan_bloc.dart`) dividía el importe INCORRECTO entre las
  N cuotas.** Usaba `state.montoTotal` (Importe Comprobante, 600) en vez de
  `state.importeCredito` (Importe a Crédito menos Detracción, 528) — la detracción se retiene
  aparte, nunca se financia en cuotas, así que el cronograma SIEMPRE debe sumar `importeCredito`,
  sin importar N. La cuota única por defecto (`_estadoInicial`) ya usaba el valor correcto
  (`importeCredito`, pasado directo como parámetro) — por eso al entrar a la pantalla (N=1
  implícito, sin tocar "Vista previa") se veía bien, pero apenas se presionaba "Vista previa"
  con cualquier N, el total saltaba a basarse en 600 en vez de 528. Corregido: `_onVistaPrevia`
  ahora divide `state.importeCredito` entre N (misma reconciliación de la última cuota
  absorbiendo el centavo de redondeo, sin cambios en ese mecanismo — ver "La última cuota del
  plan de crédito absorbe el centavo..." más abajo, solo cambió la base).
- **Bug 2 — cambiar "Fecha vencimiento" no recalculaba "Días" de vuelta.** `_onDiasChanged` (Días
  → Fecha) ya funcionaba bien (`formFecha = hoy + días`); `_onFechaChanged` (Fecha → Días) solo
  actualizaba `formFecha`, dejando `formDias` desincronizado con la fecha realmente elegida en el
  date picker. Corregido: `_onFechaChanged` ahora también recalcula `formDias` con
  `diasDesdeHoy(event.fecha)` (mismo helper que ya usa `_onCuotaSeleccionada`) — ambos campos se
  mantienen sincronizados sin importar cuál edite el asesor primero.
- **Bug 3 — la cuota 1 podía vencer después que la cuota 2, sin ningún aviso.** `_onModificarCuota`
  solo validaba contra la cuota ANTERIOR (`numeroCuota - 1`) — para la cuota 1, esa búsqueda
  siempre da `null` (no existe cuota `0`), así que nunca se validaba nada al modificarla,
  permitiendo dejarla con una fecha posterior a la cuota 2 (cronograma fuera de orden). Corregido
  agregando el chequeo simétrico contra la cuota SIGUIENTE (`numeroCuota + 1`) — si la fecha
  nueva cae después que la cuota siguiente, se rechaza con el mismo tipo de mensaje que ya existía
  para "antes que la anterior". Ahora el cronograma queda garantizado en orden cronológico
  estricto sin importar qué cuota se edite.

## Bug real — la condición de pago quedaba vacía en lista/detalle tras facturar (2026-08-19)
Reportado por el usuario con un caso real: factura al contado, retrocede hasta la lista, y la
cobranza recién facturada aparece sin condición de pago (ni "Contado" ni "Crédito") — mismo
problema para crédito. Causa: `CobranzaUpdateNotifier`/`_onItemActualizado` (ver "Facturar ya no
limpia el stack..." más abajo, el mecanismo de parcheo en memoria sin recargar del backend) solo
parcheaba `idEstado`/`estado` — nunca `idCondicion`/`condicion`. Antes de facturar, esos 2 campos
están vacíos de verdad en la base (`CONDICION_PAGO` recién se fija al facturar, ver `'UE'` más
abajo), así que la cobranza cargada la primera vez ya tenía `idCondicion: ''` — al facturar, el
backend sí la guarda, pero como nada la parcheaba en memoria, la lista/detalle se quedaban con el
`''` viejo hasta la próxima recarga real. Esto no era solo cosmético — `CobranzaListBloc` filtra
los chips Contado/Crédito comparando `c.idCondicion == 'C'`/`'CR'` (ver "Notas importantes" más
abajo), así que una cobranza recién facturada tampoco aparecía en ninguno de los 2 chips hasta
recargar.

- **`CobranzaUpdate`/`CobranzaUpdateNotifier.notify()`** (`core/utils/cobranza_update_notifier.dart`)
  ganaron `idCondicion`/`condicion` (`String`, requeridos) — `CobranzaFacturaBloc._onFacturarPressed`
  ahora los manda (`state.idCondicion`/`state.condicion`, la convención interna 'C'/'CR' + label,
  ya resuelta en el formulario) junto con `idEstado: 2` en el único `notify()` que existe (el de
  `CrudOk()` tras `_cambiarEstadoFacturar`).
- **`CobranzaListItemActualizado`/`CobranzaDetalleItemActualizado`** (eventos de lista/detalle)
  ganaron los mismos 2 campos, threaded desde el listener del stream hasta `_onItemActualizado`
  de cada bloc — ambos ahora pasan `idCondicion`/`condicion` al `copyWith(...)` de
  `Cobranza`/`CobranzaDetalle` junto con `idEstado`/`estado`, mismo patrón exacto ya usado para el
  estado. `CobranzaDetalle.copyWith()` no tenía parámetros para esto — solo aceptaba `idEstado`/
  `estado` — se amplió recién en este fix.
- **Aplica igual a contado y crédito** — el `notify()` vive después de que ambos caminos
  convergen en `_cambiarEstadoFacturar` (crédito primero guarda el plan vía `'RC'`, ver
  "Flujo real" más abajo, y solo si sale bien continúa con `'UE'`) — no hizo falta ningún cambio
  en `CobranzaPlanPage`/`CobranzaPlanBloc` (la vista especial del plan de crédito), ese flujo ya
  terminaba en el mismo punto de guardado que contado.

## Monto de la lista con símbolo de moneda real, no `'S/'` hardcodeado (2026-08-14)
Pedido explícito del usuario ("¿esto está hardcodeado?" al ver `S/ 1200.00` en `CobranzaCard`).
Confirmado: `_CobranzaDatos` (`widgets/lista/cobranza_card.dart`) tenía el símbolo `'S/ '` como
literal fijo — y el SP de lista (`CSV_COBRANZAS_LST_APP`, task `'LS'`) **no traía moneda en
absoluto** (solo el task `'DT'`/detalle la traía, vía join a `SYSTABEXTER02 MN`). Se agregó el
mismo dato a `'LS'`, mismo criterio que `'DT'`:
- **SP** (`CRM.CSV_COBRANZAS_LST_APP.sql`, task `'LS'`) — nuevo `LEFT JOIN SYSTABEXTER02 MN ON
  TC.MONEDA = MN.codargu AND MN.CODTABLA = 'MON'` (ojo: en `'LS'`, a diferencia de `'DT'`, el
  alias `TC` es la tabla de facturación `EVT.T_TECMSOLINSCRIPCION01_FACTURACION`, no
  `SYSTABEXTER02` — no confundir los dos usos de `TC` entre tasks) y nuevo campo posicional
  `21`, `MN.descorta`, agregado al final del `CONCAT` para no correr las posiciones 0-20 ya
  consumidas por `CobranzaModel.fromRawString`. **Este archivo vive fuera del repo Flutter**
  (`C:\DEV\BDNatCodee\NC.SQLChangeLock\DBEAN\StoredProcedures\`) **y está en UTF-16LE** — nunca
  editarlo con herramientas de texto plano que asuman UTF-8/ASCII (lo corrompen); convertir a
  UTF-8 para editar y volver a guardar como UTF-16LE (`[System.IO.File]::WriteAllText(...,
  [System.Text.Encoding]::Unicode)`).
- **Flutter** — `Cobranza`/`CobranzaModel` ganaron el campo `moneda` (String, default `''`,
  campo `21`). `CobranzaCard._CobranzaDatos` ahora arma el valor con
  `resolverSimboloMoneda(context, cobranza.moneda)` (mismo resolver que ya usaba
  `CobranzaPlanView`/`resolver_moneda.dart` — contra `CatalogsBloc.monedas`, cae al id crudo si
  el catálogo no cargó o no matchea) en vez del literal `'S/ '`.
- **Mismo literal encontrado y corregido en el resto del flujo** (el usuario pidió revisar más
  allá de la lista): `CobranzaDetalleInfoCard` (`widgets/detalle/`, monto del detalle —
  `detalle.moneda` ya existía ahí, venía del task `'DT'` desde antes, solo faltaba usarlo),
  `CobranzaFacturaHeader` y `CobranzaResumenCard` (`widgets/factura/`, 6 montos: comprobante/
  detracción/importe a crédito en el resumen de crédito, total curso/pago a cuenta/saldo en el
  de contado) — todos usaban `'S/ '` fijo, ahora todos usan `resolverSimboloMoneda(context,
  state.moneda)` (`CobranzaFacturaState.moneda` ya existía, viajaba desde `CobranzaDetalleView`
  vía `goToFacturarCobranza`, solo no se usaba para pintar el monto).
- **Sin espacio entre símbolo y monto** (`'S/1200.00'`, no `'S/ 1200.00'`) — pedido explícito
  del usuario, "por el momento". Aplicado en los 4 archivos de arriba. **`CobranzaPlanView`
  (`widgets/plan/`) y el resto del flujo de plan de crédito NO se tocaron** — ya usaban
  `resolverSimboloMoneda` desde antes (no tenían el bug del literal) y mantienen su propio
  `'$simbolo $monto'.trim()` con espacio; si más adelante se pide unificar el formato sin
  espacio en todos lados, ahí quedan pendientes.
- **Separador de miles** — los 4 archivos usaban `.toStringAsFixed(2)` (sin separador,
  `1200.00` en vez de `1,200.00`). Se cambió a `NumberFormatUtils.formatMonto(valor)`
  (`core/utils/number/number_format_utils.dart`) — nuevo método agregado ahí, hermano de
  `formatMoneda(simbolo, valor)` (usado en `lead/`) pero **sin** el símbolo ni el espacio
  incluidos, para poder componerlo pegado al símbolo resuelto acá
  (`'${resolverSimboloMoneda(...)}${NumberFormatUtils.formatMonto(...)}'`) — reusa el mismo
  `NumberFormat('#,##0.00', 'es_PE')` interno, no un formateador nuevo.
- **El separador de miles también faltaba en todo el flujo de Plan de Crédito** (`widgets/plan/`,
  encontrado en una segunda pasada pedida por el usuario — "revisa en el detalle de cobranza" +
  "arréglalo todo junto") — 4 sitios más, todos con el mismo `.toStringAsFixed(2)` plano:
  `cobranza_plan_view.dart` (footer "Total cuotas", ya tenía símbolo vía `resolverSimboloMoneda`,
  solo le faltaba el separador), `cobranza_plan_resumen_card.dart` (los 3 campos de solo lectura
  "Importe Comprobante"/"Detracción (12%)"/"Importe a Crédito menos Detracción" — estos **no**
  llevan símbolo de moneda, a propósito no se les agregó acá, solo se corrigió el separador; si
  se pide símbolo ahí también es un cambio aparte) y `cobranza_plan_cronograma_card.dart`
  (footer "Total: X" del cronograma + el monto de cada fila de cuota, tampoco con símbolo). Los 4
  ahora usan `NumberFormatUtils.formatMonto(...)`, mismo patrón que arriba.

## `CobranzaAsesorPickerModal` — recarga al abrir + desglose por estado (2026-08-14)
**⚠️ La recarga al abrir se revirtió por completo el 2026-08-21 — ver "Revert —
`CobranzaAsesorPickerModal` ya no recarga nada al abrir" arriba.** El desglose por `idEstado`
(la otra mitad de esta entrada) sigue vigente sin cambios.

Pedido explícito del usuario: el picker de asesor mostraba un total plano por asesor
(`conteosPorAsesor`, `Map<String,int>`) calculado sobre lo que `CobranzaListBloc` ya tenía
cargado desde la última vez que se entró a la pantalla — y el universo de asesores
(`CatalogsBloc.asesores`) solo se carga una vez al iniciar sesión, así que ambos podían estar
desactualizados sin que el asesor lo notara (antes solo había un ícono de refrescar manual).

- **Recarga automática al abrir** — `_CobranzaAsesorPickerModalState.initState()` dispara
  `CatalogsLoadRequested()` **y** `CobranzaListRefresh()` apenas se monta el modal (el ícono
  manual de refrescar sigue ahí, ahora dispara ambos eventos también, antes solo el de
  catálogos). Como `CobranzaListBloc` es el mismo que ya usa la pantalla de lista (provisto por
  `CobranzaListPage`, accesible desde el modal porque `showModalBottomSheet` inserta la ruta
  dentro del mismo árbol de providers), refrescar acá también refresca la lista de fondo — no
  es un side-effect no deseado, es justo lo que se pidió ("cada que abra eso, cargue la data").
- **Reactivo de verdad, no solo al abrir** — el widget ya no recibe `conteosPorAsesor` como
  snapshot fijo para pintar; `build()` hace `context.watch<CobranzaListBloc>().state` y usa ese
  valor si es `CobranzaListSuccess` (cae al snapshot recibido por parámetro solo mientras el
  refresh disparado en `initState` sigue en vuelo, para no mostrar la lista vacía un instante).
- **Conteo desglosado por `idEstado`, no un total plano** — `CobranzaListBloc.
  _buildConteosPorAsesor()` pasó de `Map<String,int>` a `Map<String, Map<int,int>>` (codUser →
  {idEstado: cantidad}). `_AsesorTile` sigue mostrando el total en negrita a la derecha (mismo
  lugar de siempre) y agrega una fila de chips chicos debajo del nombre/código — uno por estado
  con cantidad > 0, ícono + color de `colorEstadoGes`/mismos íconos que
  `CobranzaDetalleStepper` (`fileOutlined`/`receipt`/`time`/`checkCircle`), con el label
  completo en un `Tooltip` (no hay espacio horizontal para texto largo en la fila).

## Color por estado unificado — `colorEstadoGes` (2026-08-14)
Pedido explícito del usuario: los colores de las 4 tarjetas-filtro de la lista
(`CobranzaSummaryCards`), el badge de cada registro (`CobranzaCard`) y el badge del detalle
(`CobranzaDetalleInfoCard`) no coincidían entre sí — cada uno tenía su propio `switch`
duplicado y se habían ido desincronizando (ej. idEstado `3` Cancelado era verde en tarjetas/
detalle pero naranja en la lista; idEstado `2` Facturar era azul en tarjetas/detalle pero
verde en la lista — el mismo tipo de bug que ya había pasado con el texto del badge, ver
sección de abajo). Unificado en `colorEstadoGes(int idEstado)`
(`presentation/utils/cobranza_estado_utils.dart`, exportado en `index_cobranza.dart`) — único
lugar con la tabla de colores, los 3 widgets la llaman en vez de tener su propio `switch`:
`0`→`AppColors.warning` · `2`→`AppColors.primary` · `5`→`AppColors.secondary` ·
`3`→`AppColors.success` · cualquier otro (`1` FreePass, `4` Anulado) → `AppColors.textDisabled`.
`CobranzaSummaryCards._TarjetaDef` perdió su campo `color` (antes un literal `const` por
tarjeta) — ahora es un getter (`Color get color => colorEstadoGes(idEstado)`), así ya no puede
volver a desincronizarse solo. **No se tocó `CobranzaDetalleStepper`** — su color no es "el
color del estado actual" sino un lenguaje visual de progreso (activo=warning,
completado=primary, pendiente=gris/borde), un concepto distinto al de badge/tarjeta que no
tiene sentido unificar con esta tabla.

## Ajuste — check verde antes de retroceder + fix del texto de estado stale (2026-08-14)
Dos correcciones sobre el mecanismo de arriba, mismo día, tras probarlo en vivo:

- **Bug real — el badge de la lista quedaba en verde con el texto "Pendiente de Documento"
  después de facturar.** `CobranzaListBloc._onItemActualizado` (ver abajo) solo parcheaba
  `idEstado` (int) — pero tanto `_EstadoBadge` de `cobranza_card.dart` como el de
  `cobranza_detalle_info_card.dart` pintan el **color** desde `idEstado` y el **texto** desde
  `Cobranza.estado`/`CobranzaDetalle.estado` (`String`, separado, la descripción cruda que
  manda el backend) — con `idEstado` ya en `2` (Facturar → verde en la lista, `AppColors.
  success`) pero `estado` todavía en el texto viejo ("Pendiente de Documento"), quedaba el
  color nuevo con el label viejo. Corregido con `cobranzaEstadoLabel(int idEstado)`
  (`lib/core/utils/cobranza_update_notifier.dart`, mismo archivo del notifier) — mapea
  `0/2/5/3` a los mismos labels cortos que ya usan `CobranzaSummaryCards`/
  `CobranzaDetalleStepper` ("Pend. de Documento"/"Facturar"/"Pend. de Pago"/"Cancelado") —
  ambos `_onItemActualizado` (lista y detalle) ahora patchean `estado` junto con `idEstado`
  (si el id no matchea ninguno de los 4, `label` queda vacío y se conserva el texto anterior
  vía `estado: label.isNotEmpty ? label : null`).
- **`CobranzaFacturaBloc` ahora también muestra el check verde antes de retroceder** — antes
  (ver "Overlay de carga al facturar", más abajo) el flujo saltaba directo de "Facturando..."
  al pop, sin paso de éxito. Pedido explícito del usuario: mismo patrón de 2 pasos que
  `EditLeadPortrait`/`TemplateFormView` (`core/CLAUDE.md` → `AppProcessOverlay`).
  `CobranzaFacturaView` ahora también muestra el overlay (con `AppProcessStatus.exito` y
  `successMessage: 'Factura generada correctamente'`) cuando `state.status ==
  CobranzaFacturaStatus.facturadoOk` (antes solo durante `loading`); `CobranzaFacturaPage`
  espera `Future.delayed(1500ms)` con ese status antes de `context.goBack()` — sin snackbar
  redundante (el check + mensaje del overlay ya comunican el éxito, mismo criterio que
  `EditLeadPortrait`, que tampoco snackbarea encima del check).

## Facturar ya no limpia el stack — pop + refresco en tiempo real vía `CobranzaUpdateNotifier` (2026-08-14)
Pedido explícito del usuario: al facturar, ya no navegar con `context.goToCobranza()`
(`clearAndPush`, reconstruye una `CobranzaListPage` nueva desde cero) — ahora
`CobranzaFacturaPage` simplemente hace `context.goBack()` (pop normal, vuelve a
`CobranzaDetallePage`, que sigue vivo debajo en el stack porque `goToFacturarCobranza` usa
`_push` normal, no `clearAndPush`). Como ni `CobranzaListBloc` ni `CobranzaDetalleBloc` se
recrean con un simple pop (ambos son per-página, siguen vivos con los datos de ANTES de
facturar), hacía falta un mecanismo explícito de aviso — igual patrón que
`LeadUpdateNotifier` (`lead/`, ver `core/CLAUDE.md`), nuevo `CobranzaUpdateNotifier`
(`lib/core/utils/cobranza_update_notifier.dart`, exportado en `index_core.dart`):

- **`CobranzaFacturaBloc._onFacturarPressed`** — en el caso `CrudOk()` de `_cambiarEstadoFacturar`
  (task `'UE'`, `estado='2'`), antes de emitir `facturadoOk`, llama
  `CobranzaUpdateNotifier.instance.notify(state.idCobranza, idEstado: 2)`.
- **`CobranzaListBloc`** se suscribe en el constructor — al recibir el aviso, dispara el evento
  nuevo `CobranzaListItemActualizado(numSol, idEstado)` (`_onItemActualizado`), que parchea el
  `idEstado` de esa fila en `_allCobranzas` (mismo patrón `.map()` que
  `LeadListBloc._onLeadUpdated`) y vuelve a emitir `_emitFiltered` — la tarjeta de la lista,
  `conteosPorEstado` (`CobranzaSummaryCards`) y el badge (ver abajo) quedan al día sin volver a
  pedir nada al backend.
- **`CobranzaDetalleBloc`** también se suscribe — guarda el `numSol` que tiene abierto
  (`_idCobranza`, seteado en `_onStarted`) y, si el aviso matchea, dispara
  `CobranzaDetalleItemActualizado(idEstado)` — parchea `idEstado`/`estado` del
  `CobranzaDetalle` en memoria (mismo patrón que la lista, `CobranzaDetalle.copyWith`, nuevo)
  **sin volver a pedir nada al backend ni pasar por `CobranzaDetalleLoading`** — pedido
  explícito del usuario, no quería ver la pantalla de detalle "recargar" (flash de loading) al
  volver de facturar. `_BottomActionButton`/`CobranzaDetalleStepper` ya reaccionan solos al
  nuevo `idEstado` (ambos leen directo de `detalle.idEstado`, sin estado propio que
  resincronizar).
- **`goToFacturarCobranza`/`goToDetalleCobranza` no cambiaron** — siguen siendo `_push` normal
  (apilan), el fix fue solo cambiar `goToCobranza()` por `goBack()` en el listener de
  `CobranzaFacturaPage` y agregar el notifier para que lo que queda debajo en el stack se entere.

## Badge de Cobranza en el drawer — `pendientesDocumento`, no `conteosPorEstado[0]` (2026-08-14)
`CobranzaListSuccess` ganó un campo dedicado, `pendientesDocumento` (idEstado 0, sobre
`_allCobranzas` completo) — **no reusar `conteosPorEstado[0]`** para el badge, ese mapa se
calcula sobre `porChip` (ya filtrado por Contado/Crédito/Asesores), así que el número cambiaría
según qué chip esté activo en la pantalla — mismo bug que ya se corrigió en el badge de
Conversaciones (`chat/`, ver `home/CLAUDE.md`). `CobranzaListPage` empuja
`context.updateBadge(cobranza: state.pendientesDocumento)` en cada `CobranzaListSuccess` —
mismo criterio que `TOT_COBRANZA` del SP de home (`ID_ESTADO_GES = 0`, ver `home/CLAUDE.md`).

## La última cuota del plan de crédito absorbe el centavo de redondeo (2026-08-05)
Mismo pedido y mismo criterio que el revert de participantes de `solicitudes/` (ver
`solicitudes/CLAUDE.md`, "Revert — el último participante vuelve a absorber el centavo de
redondeo del importe") — acá aplicado al cronograma de cuotas, que tenía el mismo problema de
fondo y nunca había tenido ningún ajuste: `CobranzaPlanBloc._onVistaPrevia` generaba las N
cuotas con `montoTotal / n` sin redondear ni reconciliar — si esa división no caía en un número
exacto de 2 decimales, la suma de las cuotas (cada una mostrada/enviada al backend con
`toStringAsFixed(2)`, ver `cobranza_plan_cronograma_card.dart`/`guardarPlanCredito`) quedaba por
debajo o por encima de `montoTotal`, visible en el footer "Total: X" (`state.totalCuotas`,
`cobranza_plan_state.dart`) sin calzar contra el monto del comprobante mostrado arriba
(`CobranzaPlanResumenCard`).

- **`_onVistaPrevia`** ahora redondea `montoPorCuota` a 2 decimales antes de usarlo, y la
  **última** cuota (`i == n - 1`) recibe `montoTotal - montoPorCuota * (n - 1)` en vez del mismo
  valor que las demás — así `state.totalCuotas` cierra exacto contra `state.montoTotal`. Las
  primeras `n - 1` cuotas no cambiaron (división simple redondeada).
- **No se tocó** `_onModificarCuota` (edición manual de una cuota, ver "Regla de negocio del
  cronograma" más abajo) — si el usuario edita el monto de una cuota a mano (hoy `_onModificarCuota`
  solo permite editar Días/Fecha, no Monto — el monto no es editable en el formulario actual),
  este ajuste no aplica; es exclusivo de "Vista previa" (regenerar todo el cronograma).
- **Con 1 sola cuota** (`n == 1`), la fórmula cae en `montoTotal - montoPorCuota * 0 =
  montoTotal` — sin cambio de comportamiento respecto a antes.

## Overlay de carga al facturar — `AppProcessOverlay` (2026-08-09)
`CobranzaFacturaView` (`widgets/factura/`) envuelve su `Form` en un `Stack` y muestra
`AppProcessOverlay(status: AppProcessStatus.cargando, ...)` mientras
`state.status == CobranzaFacturaStatus.loading` — mismo widget reusable que ya usan
`EditLeadPortrait` (`lead/`) y `TemplateFormView` (`chat/`, ver sus CLAUDE.md). Antes, mientras
corrían las 2 llamadas secuenciales de `_onFacturarPressed` (crédito: `RC` guardar plan + `UE`
cambiar estado; contado: solo `UE`), el único feedback era el botón "Facturar" deshabilitado —
sin overlay ni spinner. A diferencia de `EditLeadPortrait`/`TemplateFormView`, acá **no** se
agregó el paso "check verde" (`AppProcessStatus.exito`) — el listener de `CobranzaFacturaPage`
ya maneja `facturadoOk` con snackbar + navegación inmediata (`context.goToCobranza()`), así que
alcanza con mostrar el overlay solo durante `loading`; al pasar a `facturadoOk` el overlay
desaparece solo (deja de cumplir la condición `if`) y el listener toma el control.

## `CobranzaCard` compactada (2026-07-14)
`CobranzaCard` (`presentation/widgets/lista/cobranza_card.dart`) se redujo de escala — mismo
criterio aplicado antes a `SolicitudCard` (`solicitudes/`): padding general `md` → `sm`, avatar
`avatarRadiusMd` (24) → `avatarRadiusSm` (21, sigue con iniciales, no se tocó a ícono), nombre
`bodyMedium` → `bodySmall`, el resto de textos (evento, datos de monto/ejecutivo/condición,
fecha/vencimiento, botón "Ver") de `bodySmall`/`labelMedium` → `labelSmall`. Botón de WhatsApp
de `buttonHeightSmall` (36) a `buttonHeightCompact` (32). El radio de la card (`radiusSm`) y el
layout no cambiaron.

**Fecha de la card — formato compacto en vez del texto largo.** `_CobranzaFechaVer._textoFecha()`
mostraba `cobranza.fecha` con `longDate + hourMinute` concatenados a mano ("27 de marzo 2025 -
01:07") — se cambió a `cobranza.fecha.formatConDia()` (core, `DateFormatter`), que da "Hoy 10:22"
/ "Ayer 10:22" / "miércoles 10:22" / "26/03/2025" según qué tan reciente sea, mismo tipo de
formato compacto que ya usan otras listas de la app (ej. `solicitud_card.dart` con
`.formatWhatsApp()`). **La rama `'Vence: ${cobranza.fechaVencimiento}'` NO se tocó** — ese campo
llega ya pre-formateado como `dd/MM/yyyy` desde el flujo de plan de crédito (`AppDateFormat.
shortDate`, ver nota más abajo sobre `parseFechaCorta`), así que pasarlo por
`.formatConDia()`/`.formatDate()` lo rompería (`DateFormatter.parseDate` no entiende `dd/MM/yyyy`,
devolvería vacío). Hoy esa rama es código muerto en la lista de todos modos — el SP `'LS'` nunca
trae `fechaVencimiento`/`diasVencimiento` (quedan `null`).

## `CobranzaDetalleView` compactada + fecha con formato compacto (2026-07-14)
Mismo criterio de achique aplicado a los widgets del detalle (`presentation/widgets/detalle/`):
`CobranzaDetalleInfoCard` (avatar `avatarRadiusMd`→`avatarRadiusSm`, nombre/valor de
`titleSmall`/`bodySmall`→`bodySmall`/`labelSmall`, monto `headlineSmall`→`titleMedium`),
`CobranzaDetalleDatosClave`/`CobranzaDetalleHistorial`/`CobranzaDetalleAcciones` (título
`titleSmall`→`bodySmall`, filas/textos a `labelSmall`, círculo del historial `avatarSm`→
`avatarXs`, botones de acción `buttonHeight`(48)→`buttonHeightSmall`(36)),
`CobranzaDetalleStepper` (círculo `avatarSm`→`avatarXs`). Padding general de las cards y del
scroll del detalle bajó de `AppSpacing.md` a `AppSpacing.sm`.

**"Fecha de solicitud" en `CobranzaDetalleInfoCard`** tenía el mismo problema que la card de
lista — `longDate + hourMinute` concatenados a mano. Se cambió a
`detalle.fechaSolicitud.formatConDia()`, igual que en `CobranzaCard`, para que lista y detalle
se vean consistentes.

## Propósito
Gestiona el flujo completo de facturación: lista de cobranzas, detalle, facturación al contado y plan de crédito.

## Pantallas
- `CobranzaListPage` → lista de cobranzas con chips de filtro (Todos / Asesores* / Contado / Crédito — *Asesores solo lo ve el moderador)
- `CobranzaDetallePage` → detalle de cobranza con historial, acciones y stepper de estados
- `CobranzaFacturaPage` → formulario para facturar (contado o crédito), condición de pago, O/C, descripción
- `CobranzaPlanPage` → configuración y cronograma del plan de crédito

## BLoCs / Cubits
- `CobranzaListBloc` (lista/) → carga y filtra la lista; conteos por filtro; conteos por asesor
  (`conteosPorAsesor`, calculado en el cliente sobre `_allCobranzas`) para alimentar el picker
- `CobranzaDetalleBloc` (detalle/) → carga detalle + historial de una cobranza
- `CobranzaFacturaBloc` (factura/) → maneja el formulario de facturación; `PlanValidarPressed`
  (crédito, navega al plan) y `FacturarPressed` (contado y crédito, finaliza). Ya no existe
  "Guardar borrador" (`GuardarBorradorPressed`/`GuardarBorradorUseCase` se eliminaron por completo
  — el usuario pidió quitar esa función)
- `CobranzaPlanBloc` (plan/) → configura cuotas, cronograma y validación de plan de crédito.
  `NumCuotasDeseadasChanged` solo actualiza el número deseado; `VistaPreviaPressed` regenera
  **todo** el cronograma (N cuotas, monto = importe comprobante ÷ N, días por defecto `7*i`);
  `CuotaSeleccionada` (tap en una fila) carga esa cuota en el formulario; `DiasChanged`/
  `FechaCuotaChanged` editan el formulario; `ModificarCuotaPressed` aplica esos cambios **solo**
  a la cuota seleccionada (no recalcula las demás); `LimpiarPressed` vacía todo el cronograma
  (no solo el formulario)

## Widgets principales
- `CobranzaFacturaView` (factura/) → vista principal del formulario de factura con campos
  comunes. Footer: **solo** "Cancelar" (pop) y "Facturar" (siempre el mismo label, contado y
  crédito) — ya no hay "Guardar borrador"/"Continuar"/"Facturar ahora"
- `CobranzaFacturaHeader` (factura/) → header fijo con nombre, curso, monto y chip de condición
- `CobranzaCamposExtra` (factura/) → campos que cambian según condición de pago (crédito/contado).
  En crédito, "Fecha de vencimiento" siempre nace con la fecha de hoy (editable vía date picker)
  y "Validar plan de crédito" navega a `CobranzaPlanPage` (ya no es un simple flag local)
- `CobranzaResumenCard` (factura/) → resumen calculado del cobro (crédito o contado).
  `detraccion` ya es real (`montoTotal * 0.12`, antes hardcodeado a 0)
- `CobranzaDetalleStepper` (detalle/) → stepper con estados (por `idEstado` int): 0 → 2 → 5 → 3.
  Círculos y labels van en filas separadas (no en la misma Column por paso) para que un label de
  2 líneas ("Pend.\ndocumento") no desalinee los círculos de los demás pasos
- `CobranzaDetalleAcciones` (detalle/) → WhatsApp/Llamar usan `detalle.celular` (el de
  facturación) vía `LauncherUtils.abrirWhatsApp`/`abrirTelefono`; "Adjuntar voucher"/"Facturar"
  siguen sin wire (`onTap: () {}`)
- `CobranzaSummaryCards` (lista/) → 4 tarjetas resumen (Pend. documento / Facturar / Pend. pago /
  Cancelado) con conteos de `CobranzaListBloc`; mismo tamaño en las 4 (`IntrinsicHeight` +
  `CrossAxisAlignment.stretch`, igual que `LeadListStatsRow`)
- `CobranzaFilterChips` (lista/) → chips de filtro horizontal (Todos/Asesores/Contado/Crédito);
  el chip "Asesores" solo se muestra si `SessionService().isModerador`
- `CobranzaAsesorPickerModal` (lista/) → bottom sheet con buscador (nombre o `codUser`), snapshot
  estático — no recarga nada al abrirse (revertido 2026-08-21, ver sección propia arriba,
  "Revert — ya no recarga nada al abrir"); usa `CatalogsBloc.state` tal cual y
  `widget.conteosPorAsesor` tal cual llega por parámetro. Cada fila muestra avatar (iniciales +
  color), nombre, código, punto verde si `disponible`, el total de cobranzas en negrita y una
  fila de chips por estado (`conteosPorAsesor`, calculado en `CobranzaListBloc` sobre la lista
  pintada, no en el backend). Retorna el `codUser`
  elegido o `null` — `CobranzaListPortrait` interpreta `null` como "volver a Todos"

## SPs que consume
- `[CRM].[CSV_COBRANZAS_LST_APP]` (task `'LS'`, body `codUser¦isModerador`) → lista de
  cobranzas (`CobranzaModel.fromRawString`, 21 campos posicionales — ver mapeo abajo).
  **Ojo:** este SP solo tiene rama `@L_TASK = 'LS'` y esa rama ignora cualquier `numSol` —
  siempre trae el `TOP 100` completo.
- `[CRM].[CSV_COBRANZAS_LST_APP]` (task `'DT'`, body `numSol¯DT`, **mismo endpoint**
  `urlCobranzasLst` que `'LS'`) → `CobranzaRemoteDatasource.getDetalleCobranza()`
  (`CobranzaDetalleModel.parse`). Versión **recortada** — solo trae lo que usa Flutter hoy (sin
  datos de solicitante/facturación completos ni participantes, a diferencia de la plantilla de
  detalle de Solicitud de la que salió). Joins: `EVT.T_TECMSOLINSCRIPCION01` + `_FACTURACION`
  (celular/correo/moneda/comprobante/condición vienen de facturación, no del solicitante),
  oportunidad/ejecutivo/estado igual que `'LS'` (`CRM.T_LEAD_TECMSOLINSCRIPCION01`→
  `CRM.T_LEAD`→`CRM.T_OPORTUNIDAD`, `DBO.SYSMUSER01`, `DBO.[edu.TIP_ESTADO_GES]`), más un
  `OUTER APPLY` de historial (`CRM.T_LEAD_SEGUIMIENTO` + `CRM.T_LEAD_ACTIVIDAD`, correlacionado
  por `LD.ID_LEAD`). Formato de respuesta: 3 secciones separadas por `sepListas` — `[0]` campos
  principales (`sepCampos`, 17 posiciones) · `[1]` archivos · `[2]` historial.
- `[CRM].[CSV_COBRANZAS_CUD_APP]` (task `'UE'`, body `data¯¯UE`) →
  `CobranzaRemoteDatasource.cambiarEstadoFacturar()`. Único endpoint para cambiar el estado de
  una cobranza — **hoy solo hace algo si `estado='2'`** (Facturar): guarda los campos de
  facturación (`CONDICION_PAGO`/`FCH_VENCIMIENTO_COMPROBANTE`/`ORDEN_COMPRA`/
  `DESCRIPCION_SUGERIDA`/`HOJA_ACEPTACION`) y recién ahí hace `UPDATE ID_ESTADO_GES`. Cualquier
  otro valor de estado no hace nada (ni siquiera cambia `ID_ESTADO_GES`) — por eso `estado` se
  manda hardcodeado en `'2'` desde el bloc, es el único valor útil hoy. Se usa tanto para
  contado como para crédito (en crédito, después de `guardarPlanCredito`). `CONDICION_PAGO`
  usa `'1'`=Crédito/`'2'`=Contado (**no** `'CR'`/`'C'`, esos son solo la convención interna de
  la app — `CobranzaFacturaBloc._condicionPagoBackend` traduce). Body (10 campos, `sepCampos`):
  `NUMSOL¦ESTADO¦CONDICION_PAGO¦FCH_VENCIMIENTO_COMPROBANTE¦ORDEN_COMPRA¦DESCRIPCION_SUGERIDA¦
  HOJA_ACEPTACION¦ID_USUARIO¦IP_USUARIO¦LL_USUARIO` (sin detalle — `dataDet` va vacío).
- `[CRM].[CSV_COBRANZAS_CUD_APP]` (task `'RC'`, body `data¯dataDet¯RC`) →
  `CobranzaRemoteDatasource.guardarPlanCredito()`. Inserta el cronograma completo en
  `EVT.T_TECMSOLINSCRIPCION01_FACTURACION_CREDITO_CRM`. Header (`data`, 5 campos):
  `NUMSOL¦MONEDA¦ID_USUARIO¦IP_USUARIO¦LL_USUARIO` — moneda va **general**, no por cuota.
  Detalle (`dataDet`, una fila por cuota, `sepRegistros` entre filas): `CORRELATIVO¦
  CORRELATIVO_DESC("CuotaXXX")¦DIAS¦FC_VENCIMIENTO¦DIA_VENCIMIENTO(siempre vacío)¦IMPORTE` — el
  importe va **con IGV incluido**, el SP lo divide entre `(1+igv)` para sacar neto+IGV. Ambos
  campos `NUMSOL` e `IP`/`LL_USUARIO` por fila que traía la plantilla original se sacaron
  porque el SP los ignoraba (usa los del header).
  **Flujo real** (confirmado con la web de referencia, no exactamente el mismo SP pero mismo
  patrón): guardar el plan de crédito es un **paso intermedio**, no un guardado final — el RC
  recién se manda cuando el usuario presiona **"Facturar"** en `CobranzaFacturaPage`
  (`CobranzaFacturaBloc._onFacturarPressed`: si es crédito, `RC` primero y solo si sale
  `CrudOk` continúa con `UE`; si es contado, solo `UE`). El botón "Guardar plan" de
  `CobranzaPlanPage` **no** llama al backend — solo valida que haya cuotas, confirma
  localmente y hace `pop` con `PlanCreditoResultado(fechaVencimiento, cuotas)` de vuelta a
  Factura (`CobranzaPlanBloc` ya no depende de `GuardarPlanCreditoUseCase`/`CobranzaRepository`
  en absoluto)

### Mapeo de campos — `CobranzaModel.fromRawString` (`CSV_COBRANZAS_LST_APP`, task `'LS'`)
Campos posicionales separados por `¦` (0-indexados): `0` numSol · `1` nombres · `2` apePaterno ·
`3` apeMaterno · `4` nomEmpresa · `5` cargo · `6` celular (→ `telefono`) · `7` correo ·
`8` codTipoRegistro crudo (`J`/`N`, → `codTipoPersona`) · `9` label (`Natural`/`Juridica`, →
`tipoPersona`) · `10` fchCreacion (→ `fecha`) · `11` impTotal (→ `montoTotal`) · `12`
idCondicion (`C`/`CR`) · `13` condicion (label) · `14` nomUser (→ `ejecutivo`) · `15`
idOportunidad (→ `idEvento`) · `16` nombre de la oportunidad (→ `evento`) · `17` **idEstadoGes
crudo** (→ `idEstado`, se guarda tal cual, sin traducir a código corto — ver nota abajo) · `18`
descripción del estado (→ `estado`) · `19` `ibValidado` (bit, siempre `1` porque el SP ya filtra
`IB_VALIDADO != 0`) · `20` `idUsuarioEjec` (→ `asignadoA`) · `21` `MN.descorta` (→ `moneda`,
agregado 2026-08-14 junto con el join a `SYSTABEXTER02 MN` — ver sección "Monto de la lista con
símbolo de moneda real" arriba). Este SP **no** trae `fechaVencimiento`/`diasVencimiento` —
quedan `null` en la lista (sí vienen en el detalle si el comprobante es a crédito, una vez
conectado el plan).

### Mapeo de campos — `CobranzaDetalleModel.parse` (`CSV_COBRANZAS_LST_APP`, task `'DT'`)
Sección `[0]` (`sepCampos`, 0-indexada, 17 campos): `0` numSol · `1/2/3` nombres/apePaterno/
apeMaterno · `4` celular de **facturación** (no del solicitante) · `5` correo de facturación ·
`6` moneda · `7` tipo de comprobante elegido (Boleta/Factura) · `8/9` idCondicion/condicion
(CASE sobre `TC.CONDICION_PAGO`) · `10` montoTotal (`DC_IMPORTE_TOTAL`) · `11/12` idEstadoGes
crudo/descripción · `13` ejecutivo (`NOMUSER`) · `14/15` idOportunidad/oportunidad · `16` fecha
de solicitud (`FC_USUARIO_C`). Sección `[1]` (archivos, `sepRegistros`):
`TIPO¦ARCHIVO_ID¦NOMBRE¦EXT` → `ArchivoCobranzaModel`. Sección `[2]` (historial, `sepRegistros`):
`idLead¦LS.DESCRIPCION¦LA.ORIGEN¦LA.NOMBRE¦LA.DESCRIPCION¦fecha` → `HistorialCobranzaModel`
(usa `LS.DESCRIPCION` como `descripcion`, con `LA.DESCRIPCION` de respaldo si el seguimiento no
trae texto). Si más adelante hace falta algún dato de solicitante/facturación/participantes que
no está aquí (documento, RUC, dirección, canal...), agregarlo a este mismo `SELECT` — no crear
un task nuevo.

### Estado — `ID_ESTADO_GES` (`idEstado`, `int`, sin traducir)
`DBO.[edu.TIP_ESTADO_GES]`: `0`=Pend. de Documento · `1`=FreePass · `2`=Facturar ·
`3`=Cancelado · `4`=Anulado · `5`=Pend.factura. **`idEstado` se guarda tal cual (int crudo,
0-5)** en `Cobranza`/`CobranzaDetalle` — no hay tabla de traducción a código corto ('PD'/'F'/...);
todo el código (stepper, badges, tarjetas, filtros de lista) compara directamente contra estos
6 números. Solo `0/2/5/3` son parte del flujo de 4 etapas (stepper/`CobranzaSummaryCards`/chips
de lista); `1` (FreePass) y `4` (Anulado) no tienen tarjeta/bucket propio hoy — caen al color/
label por defecto pero sí aparecen en la lista sin filtro de tarjeta activo.

## Dependencias externas
- `CobranzaRepository` (RepositoryProvider global)
- `SessionService` → solo para rol de moderador (visibilidad del chip "Asesores"). El backend
  (`SP_CobranzaLst`) ya limita el dataset del no-moderador a sus propios casos, así que "Todos"
  ya representa "mis casos" para un no-moderador — no hay filtro de "mis casos" en el cliente
- `CatalogsBloc` (global) → fuente de `List<AsesorItem>` para `CobranzaAsesorPickerModal`,
  cargado una sola vez al iniciar sesión

## Notas importantes
- `idEstado` es `int` de punta a punta (`Cobranza`, `CobranzaDetalle`, `CobranzaListBloc`
  — `Set<int> estadosSeleccionados`/`Map<int,int> conteosPorEstado`/`CobranzaEstadoToggled(int)`,
  `CobranzaSummaryCards` — `idEstado` de cada tarjeta es `int`). No comparar contra strings tipo
  `'PD'`/`'F'` en ningún lado nuevo — usar los números crudos (ver sección "Estado" arriba)
- `CobranzaDetalle.correo`/`celular` vienen de la **facturación** (`TC.CORREO_ENVIO`/
  `TC.CELULAR`), no del solicitante — y ya no son nullable (el join `TC` es `INNER`)
- `CobranzaDetalle.observacion` no existe — el backend no la persiste (confirmado con negocio),
  no mostrarla hasta que exista una columna real
- La carpeta de widgets para facturación es `widgets/factura/` (no `fractura/`)
- `CobranzaCamposExtra` usa `esArriba` para controlar qué campos aparecen arriba/abajo del formulario según la condición
- **`O/C`, Descripción sugerida y Hoja de aceptación son todos opcionales** (contado y crédito)
  — ninguno tiene `validator` en `_CampoCompartido`/`CobranzaFacturaView`. Lo único obligatorio
  siempre es la condición de pago (combo, siempre trae un valor); en crédito, además, validar/
  guardar el plan de crédito (ver más abajo)
- **`_CampoCompartido` (O/C, Descripción, Hoja) usa `textInputAction: TextInputAction.done`** +
  `onSubmitted` que hace `unfocus()` — sin esto, al ser multilinea (`maxLines: 3`) el teclado
  mostraba flecha de "nueva línea" en vez de check, y no había forma de cerrarlo
- **`_ExtraCreditoState` necesita `didUpdateWidget`** para resincronizar `_fechaCtrl.text` con
  `widget.state.fechaVencimiento` — como vive con `ValueKey('credito')` estable mientras la
  condición sea crédito, `initState` solo corre una vez; sin el `didUpdateWidget` el campo se
  quedaba mostrando la fecha vieja después de `PlanGuardado` (bug real ya corregido). La
  asignación a `_fechaCtrl.text` dentro de `didUpdateWidget` va envuelta en
  `WidgetsBinding.instance.addPostFrameCallback` — hacerlo síncrono dispara el listener del
  controller, que llama `Form.of(context)!._fieldDidChange()` → `setState()` en el `FormState`
  de `CobranzaFacturaView` en medio de su propio build (`FlutterError: setState() or
  markNeedsBuild() called during build` — reproducible configurando varias cuotas y validando
  el plan, que dispara `PlanGuardado` con una `fechaVencimiento` nueva)
- **`CobranzaFacturaState.numCuotas`** ya no es el stub `=> 1` — es `cuotasCredito.length`
  (con fallback a 1 si está vacío), así el resumen de crédito muestra el número real configurado
- **`CobranzaPlanBloc` recuerda el plan ya configurado al reentrar** — `cuotasIniciales` viaja
  por navegación (`goToPlanCredito(cuotasIniciales: state.cuotasCredito)` →
  `CobranzaPlanPage.cuotasIniciales` → `CobranzaPlanBloc._estadoInicial`); si viene no vacío se
  usa tal cual (y `numCuotasDeseadas` = su largo) en vez de resetear siempre a 1 cuota por
  defecto. Antes, presionar "Validar" una segunda vez perdía todo lo ya configurado
- **Adjuntar voucher (contado) — pendiente a propósito.** `_ExtraContado` (`cobranza_campos_extra.dart`)
  sigue siendo un stub visual (`onTap: () {}`, sin picker ni endpoint de subida) — no implementar
  hasta que se defina el flujo con backend
- **Moneda del plan de crédito**: `TC.MONEDA` guarda el **id** (varchar) de `MonedaItem`, no el
  símbolo — viaja como ese id de punta a punta (`CobranzaDetalle.moneda` →
  `goToFacturarCobranza(moneda: ...)` → `CobranzaFacturaState.moneda` →
  `goToPlanCredito(moneda: ...)` → `CobranzaPlanState.moneda`) y se resuelve a símbolo recién
  al pintarlo, con `resolverSimboloMoneda(context, idMoneda)` (`presentation/utils/
  resolver_moneda.dart`) contra `CatalogsBloc.monedas` (parte [7] de `lstListas`). Si el
  catálogo no cargó o el id no matchea, devuelve el id crudo como fallback. Se muestra **una
  sola vez** en `CobranzaPlanResumenCard` y en el footer del plan — no hay columna de moneda
  por cuota en el cronograma. Mismo resolver se usa en "Datos clave" del detalle
- **Regla de negocio del cronograma**: `CobranzaPlanBloc._onModificarCuota` no deja que una
  cuota venza antes que la cuota anterior (compara `formFecha` contra `numeroCuota - 1`) — no
  valida contra la cuota siguiente, solo hacia atrás, porque es lo único que pidió el usuario
- `PlanValidarPressed` y `CuotaSeleccionada`/`ModificarCuotaPressed` emiten su status y lo
  resetean a `idle` en el mismo handler (dos `emit` seguidos) — si el status se quedara fijo
  (`continuarPlan`/`error`), `listenWhen` (que compara contra el status previo) no volvería a
  notificar si el usuario repite la misma acción dos veces seguidas
- **Guardar el plan de crédito es un paso extra antes de facturar, no el final del flujo** —
  `context.goToPlanCredito(...)` devuelve `Future<PlanCreditoResultado?>` (fecha de vencimiento
  más alta + la lista de cuotas, o `null` si el usuario volvió con la flecha sin guardar). Al
  guardar, `CobranzaPlanPage` hace `context.goBack(PlanCreditoResultado(...))` — **no**
  `context.goToCobranza()` (eso limpiaría el stack y no volvería a Facturar).
  `CobranzaFacturaPage` espera ese resultado (`listener` async) y, si no es null, dispara
  `PlanGuardado(fecha, cuotas)` — **recién ahí** `CobranzaFacturaBloc` marca `planValidado =
  true`, guarda las cuotas en `state.cuotasCredito` y actualiza `fechaVencimiento`.
  `PlanValidarPressed` (el botón "Validar") **ya no** marca `planValidado` — solo navega; si
  el usuario entra al plan y vuelve sin guardar, el badge "Plan de crédito validado" no debe
  aparecer, y tampoco se puede facturar (`_onFacturarPressed` exige `planValidado` en crédito)
- **Validación de "Facturar"**: en contado no hay ningún campo obligatorio aparte de la
  condición de pago (que ya viene con valor); en crédito son obligatorios haber validado/
  guardado el plan y tener fecha de vencimiento. O/C, Descripción sugerida y Hoja de aceptación
  son opcionales en ambos casos. Se valida dentro de `CobranzaFacturaBloc._onFacturarPressed`
  (no en el `Form` de la vista — el `Form` solo existe por el `maxLength` de los 3 campos
  compartidos, no aplica ninguna regla de obligatoriedad)
- **El botón "Continuar facturación" del detalle solo aparece si `idEstado == 0`** (Pend. de
  documento) — `_CobranzaDetalleBody.tieneAccion` en `cobranza_detalle_view.dart`. Antes se
  mostraba (con otro label) para cualquier estado salvo Cancelado, pero el `UE` real solo hace
  algo con `estado='2'`; para los demás estados (2, 5, 1, 4) no hay ninguna acción de backend
  definida todavía, así que no tiene sentido ofrecer un botón que no hace nada. Si más adelante
  se define una acción real para otro estado (ej. "Confirmar pago" en estado 5), agregar su
  propio caso ahí en vez de reusar este botón genérico
- **Nunca usar `DateFormatter.parseDate` (core) sobre fechas del plan de crédito** — solo
  entiende ISO o formato SQL Server, no `'dd/MM/yyyy'` (que es justo lo que produce
  `AppDateFormat.shortDate`, usado en todo `fechaVencimiento`). Da `null` en silencio y los
  cálculos de días quedan siempre en 0. Usar `parseFechaCorta`/`diasDesdeHoy`
  (`presentation/utils/fecha_corta_utils.dart`) en su lugar — ya está aplicado en el bloc del
  plan, el cronograma, `CobranzaPlanState.fechaMasAlta` y el date picker de `CobranzaCamposExtra`
- **Todos los inputs del plan de crédito (editables o de solo lectura) usan `CustomTextField`**
  (los de solo lectura con `enabled: false` y un `TextEditingController` armado inline) — nunca
  un `Container` a mano intentando igualar la altura/estilo del `CustomTextField` real; se
  desalinean visualmente porque `CustomTextField` es `isDense` con padding compacto propio, no
  el alto estándar `AppSizing.inputHeight`
- Separadores del backend: `AppConstants.sepListas` (`¯`), `AppConstants.sepCampos` (`¦`), `AppConstants.sepRegistros` (`¬`)
- Chip "Asesores" (antes "Mis casos") solo lo ve el moderador. Nunca filtra directo — `CobranzaListPortrait`
  intercepta su tap y abre `CobranzaAsesorPickerModal`; filtra por `asignadoA == codUser` del asesor
  elegido ahí (evento `CobranzaAsesorSeleccionado`, guardado en `_asesorSeleccionado`/`state.asesorSeleccionado`)
