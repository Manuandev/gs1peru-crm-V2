# Cobranza Feature

## Propósito
Gestiona el flujo completo de facturación: lista de cobranzas, detalle, facturación al contado y plan de crédito.

## Pantallas
- `CobranzaListPage` → lista de cobranzas con chips de filtro (Todos / Mis casos / Contado / Crédito)
- `CobranzaDetallePage` → detalle de cobranza con historial, acciones y stepper de estados
- `CobranzaFacturaPage` → formulario para facturar (contado o crédito), condición de pago, O/C, descripción
- `CobranzaPlanPage` → configuración y cronograma del plan de crédito

## BLoCs / Cubits
- `CobranzaListBloc` (lista/) → carga y filtra la lista; conteos por filtro
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
- `CobranzaFilterChips` (lista/) → chips de filtro horizontal

## SPs que consume
- `[CRM].[SP_CobranzaLst]` → lista de cobranzas por agente/moderador
- `[CRM].[SP_CobranzaDet]` → detalle + historial de una cobranza
- `[CRM].[SP_FacturarContado]` → facturación al contado
- `[CRM].[SP_GuardarBorrador]` → guardar borrador de factura
- `[CRM].[SP_GuardarPlanCredito]` → guardar plan de crédito

## Dependencias externas
- `CobranzaRepository` (RepositoryProvider global)
- `SessionService` → para filtrar "mis casos"

## Notas importantes
- `idEstado` en `CobranzaDetalle` es `int`. Los códigos de estado en `CobranzaDetalleStepper` son String: `'PD'`, `'F'`, `'PP'`, `'CA'` → usar campo `estado` (String) para comparaciones de texto, no `idEstado`
- La carpeta de widgets para facturación es `widgets/factura/` (no `fractura/`)
- `CobranzaCamposExtra` usa `esArriba` para controlar qué campos aparecen arriba/abajo del formulario según la condición
- El plan de crédito requiere validar fecha de vencimiento antes de poder facturar (`planValidado`)
- Separadores del backend: `AppConstants.sepListas` (`¯`), `AppConstants.sepCampos` (`¦`), `AppConstants.sepRegistros` (`¬`)
