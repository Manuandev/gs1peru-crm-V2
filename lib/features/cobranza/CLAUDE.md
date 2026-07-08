# Cobranza Feature

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
- `CobranzaFacturaBloc` (factura/) → maneja el formulario de facturación; `FacturarPressed` y `GuardarBorradorPressed`
- `CobranzaPlanBloc` (plan/) → configura cuotas, cronograma y validación de plan de crédito

## Widgets principales
- `CobranzaFacturaView` (factura/) → vista principal del formulario de factura con campos comunes
- `CobranzaFacturaHeader` (factura/) → header fijo con nombre, curso, monto y chip de condición
- `CobranzaCamposExtra` (factura/) → campos que cambian según condición de pago (crédito/contado)
- `CobranzaResumenCard` (factura/) → resumen calculado del cobro (crédito o contado)
- `CobranzaDetalleStepper` (detalle/) → stepper con estados: PD → F → PP → CA
- `CobranzaDetalleAcciones` (detalle/) → botones de acción según estado
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
  cobranzas (`CobranzaModel.fromRawString`, 20 campos posicionales — ver mapeo abajo).
  **Ojo:** este SP solo tiene rama `@L_TASK = 'LS'` y esa rama ignora cualquier `numSol` —
  siempre trae el `TOP 100` completo. `CobranzaDetalleBloc`/`getDetalleCobranza()` todavía no
  tiene un SP real conectado (usa el mismo endpoint con un 3er parámetro `numSol` que este SP
  no procesa) — pendiente de que backend defina cómo se resuelve el detalle de un solo registro
- `[CRM].[SP_CobranzaDet]` → detalle + historial de una cobranza (pendiente, ver nota arriba)
- `[CRM].[SP_FacturarContado]` → facturación al contado
- `[CRM].[SP_GuardarBorrador]` → guardar borrador de factura
- `[CRM].[SP_GuardarPlanCredito]` → guardar plan de crédito

### Mapeo de campos — `CobranzaModel.fromRawString` (`CSV_COBRANZAS_LST_APP`)
Campos posicionales separados por `¦` (0-indexados): `0` numSol · `1` nombres · `2` apePaterno ·
`3` apeMaterno · `4` nomEmpresa · `5` cargo · `6` celular (→ `telefono`) · `7` correo ·
`8` tipoPersona (`Natural`/`Juridica`) · `9` fchCreacion (→ `fecha`) · `10` impTotal (→
`montoTotal`) · `11` idCondicion (`C`/`CR`) · `12` condicion (label) · `13` nomUser (→
`ejecutivo`) · `14` idEvento · `15` descripción evento · `16` **idEstadoGes crudo** · `17`
descripción del estado (→ `estado`, se usa tal cual del backend) · `18` `idEstadoSol` (otra
dimensión de estado, de la solicitud — no se usa hoy) · `19` `idUsuarioEjec` (→ `asignadoA`).
Este SP **no** trae `fechaVencimiento`/`diasVencimiento` — quedan `null` en la lista (solo
detalle los tendría, cuando exista ese SP).

### Mapeo de estado — `ID_ESTADO_GES` → código interno
`DBO.[edu.TIP_ESTADO_GES]` (parte [6] de `lstListas`, `EstadoGestionItem` en core) trae:
`0`=Pend. de Documento · `1`=FreePass · `2`=Facturar · `3`=Cancelado · `4`=Anulado ·
`5`=Pend.factura. Solo `0/2/3/5` son parte del flujo de 4 etapas del stepper/chips; se
traducen con una tabla fija en `CobranzaModel._mapaIdEstado` (`0→PD 2→F 3→CA 5→PP`), **no**
consultando el catálogo en tiempo de ejecución. `1` (FreePass) y `4` (Anulado) no tienen
bucket propio hoy — una cobranza con esos ids no cae en ninguna de las 4 tarjetas de
`CobranzaSummaryCards` pero sí aparece en la lista sin filtro de tarjeta activo.

## Dependencias externas
- `CobranzaRepository` (RepositoryProvider global)
- `SessionService` → solo para rol de moderador (visibilidad del chip "Asesores"). El backend
  (`SP_CobranzaLst`) ya limita el dataset del no-moderador a sus propios casos, así que "Todos"
  ya representa "mis casos" para un no-moderador — no hay filtro de "mis casos" en el cliente
- `CatalogsBloc` (global) → fuente de `List<AsesorItem>` para `CobranzaAsesorPickerModal`,
  cargado una sola vez al iniciar sesión

## Notas importantes
- `idEstado` en `CobranzaDetalle` es `int`. Los códigos de estado en `CobranzaDetalleStepper` son String: `'PD'`, `'F'`, `'PP'`, `'CA'` → usar campo `estado` (String) para comparaciones de texto, no `idEstado`
- La carpeta de widgets para facturación es `widgets/factura/` (no `fractura/`)
- `CobranzaCamposExtra` usa `esArriba` para controlar qué campos aparecen arriba/abajo del formulario según la condición
- El plan de crédito requiere validar fecha de vencimiento antes de poder facturar (`planValidado`)
- Separadores del backend: `AppConstants.sepListas` (`¯`), `AppConstants.sepCampos` (`¦`), `AppConstants.sepRegistros` (`¬`)
- Chip "Asesores" (antes "Mis casos") solo lo ve el moderador. Nunca filtra directo — `CobranzaListPortrait`
  intercepta su tap y abre `CobranzaAsesorPickerModal`; filtra por `asignadoA == codUser` del asesor
  elegido ahí (evento `CobranzaAsesorSeleccionado`, guardado en `_asesorSeleccionado`/`state.asesorSeleccionado`)
