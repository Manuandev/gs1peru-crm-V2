# Cobranza Feature

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
- `CobranzaAsesorPickerModal` (lista/) → bottom sheet con buscador (nombre o `codUser`), reactivo
  a `CatalogsBloc` (`BlocBuilder<CatalogsBloc, CatalogsState>`, no recibe la lista como snapshot
  estático); cada fila muestra avatar (iniciales + color), nombre, código, punto verde si
  `disponible` y el conteo de cobranzas (`conteosPorAsesor`, calculado en el bloc, no en el
  backend). Ícono de refrescar en el header dispara `CatalogsLoadRequested`. Retorna el `codUser`
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
`IB_VALIDADO != 0`) · `20` `idUsuarioEjec` (→ `asignadoA`). Este SP **no** trae
`fechaVencimiento`/`diasVencimiento` — quedan `null` en la lista (sí vienen en el detalle si el
comprobante es a crédito, una vez conectado el plan).

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
