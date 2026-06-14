# Lead Feature

## Propósito
Gestiona la lista y detalle de leads en dos modos: Seguimientos (`PO`) y Propuestas (`PA`).

## Pantallas
- `LeadListPage` → lista de leads con chips de filtro; recibe `LeadType` como argumento
- `LeadDetallePage` → detalle completo del lead con comentarios y stepper de estado

## BLoCs / Cubits
- `LeadListBloc` (list/) → carga leads por tipo, filtra en memoria; conteos por filtro
- `LeadDetalleBloc` (detail/) → carga detalle + comentarios de un lead por `idLead`

## Widgets principales
- `LeadListView` (list/) → vista principal con AppBar + BlocBuilder
- `LeadListPortrait` (list/) → lista scrollable con `LeadCard`s y filtros
- `LeadCard` (list/) → tarjeta de lead con avatar, info, timestamp y botones de acción
- `LeadCardActions` (list/) → fila de botones (chat, favorito) en la parte inferior de cada card
- `LeadListFilterChips` (list/) → chips horizontales de filtro con badges de conteo
- `LeadDetalleView` (detalle/) → layout principal del detalle con todas las secciones
- `LeadDetalleStepper` (detalle/) → stepper visual de estado del lead
- `LeadDetalleInfoCard` (detalle/) → tarjeta con datos clave del lead
- `LeadDetalleComentarios` (detalle/) → lista de comentarios del lead
- `LeadDetalleActions` (detalle/) → botones de acción del detalle

## SPs que consume
- `[CRM].[SP_LeadsLst]` → lista de leads por tipo ('PO' o 'PA') y agente/moderador

## Dependencias externas
- `LeadRepository` (RepositoryProvider global)
- `SessionService` → para filtro `misCasos` y rol de moderador

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
enum LeadListFiltro { todos, misCasos, nuevos, enDesarrollo }
```
- Moderador: filtro inicial `todos`; agente: `misCasos`
- Propuestas: no muestra chips `nuevos` ni `enDesarrollo`
- Conteos se calculan sobre `_allLeads` (lista completa), no sobre la lista filtrada

### Navegación
- Seguimiento/Propuestas → `clearAndPush` (limpia stack; se abre desde Drawer)
- Detalle de chat desde lead → `context.goToDetalleChat(idLead: lead.idLead)` (apila)

### Campos principales de Lead
```dart
lead.idLead      // int — identificador único
lead.idEstado    // String — '00'–'15' (ver AppIconsSocial etapas)
lead.idCanal     // int — canal de origen (ver AppIconsSocial canales)
lead.asignadoA   // String — codUser del agente asignado
lead.nombreCompleto // String
lead.fechaHora   // String — usar .formatSinHoy() para mostrar
```
