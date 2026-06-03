# Feature: Lead

Gestiona la lista de leads en dos modos: Seguimientos y Propuestas.

## Archivos clave

| Archivo | Qué hace |
|---|---|
| `data/datasources/remote/lead_remote_datasource.dart` | Consulta leads por tipo |
| `data/models/lead_model.dart` | Parseo de lista de leads |
| `domain/entities/lead.dart` | Entidad pura |
| `domain/repositories/lead_repository.dart` | Interfaz |
| `data/repositories/lead_repository_impl.dart` | Implementación |
| `domain/usecases/get_leads_usecase.dart` | Caso de uso |
| `presentation/bloc/lead_list_bloc.dart` | Estado de la lista |
| `presentation/pages/lead_list_page.dart` | Crea el BlocProvider |
| `presentation/widgets/lead_list_view.dart` | UI pura |

---

## LeadType — tipos de lista

```dart
enum LeadType {
  seguimientos,  // código SP: 'PO' → ruta AppRoutes.seguimiento
  propuestas,    // código SP: 'PA' → ruta AppRoutes.propuestas
}
```

Siempre pasar el tipo al crear el Bloc:
```dart
LeadListBloc(GetLeadsUseCase(...))..add(LeadListStarted(type))
```

---

## LeadListFiltro — filtros de lista

```dart
enum LeadListFiltro {
  todos,          // todos los leads
  misCasos,       // lead.asignadoA == session.codUser
  nuevos,         // lead.idEstado == '00'
  enDesarrollo,   // lead.idEstado == '01'
}
```

**Filtro inicial según rol:**
```dart
_filtroActivo = _session.isModerador
    ? LeadListFiltro.todos      // moderador ve todo
    : LeadListFiltro.misCasos;  // agente solo ve los suyos
```

---

## LeadListBloc

```dart
// Estados
LeadListInitial
LeadListLoading
LeadListSuccess(leads, filtro, conteos, type)
LeadListError(message)

// Eventos
LeadListStarted(type)   // carga inicial
LeadListRefresh(type)   // recarga (botón refresh en AppBar)
LeadListFiltered(filtro) // cambio de filtro — no recarga red, filtra en memoria
```

**Conteos disponibles en `LeadListSuccess`:**
```dart
state.conteos[LeadListFiltro.todos]
state.conteos[LeadListFiltro.misCasos]
state.conteos[LeadListFiltro.nuevos]
state.conteos[LeadListFiltro.enDesarrollo]
```

Los conteos siempre se calculan sobre `_allLeads` (lista completa sin filtrar),
no sobre la lista filtrada visible.

---

## GetLeadsUseCase

```dart
class GetLeadsUseCase {
  Future<List<Lead>> call(String tipo) async {
    return _repository.getLeads(tipo);
    // tipo: 'PO' = seguimientos | 'PA' = propuestas
  }
}
```

---

## Entidad Lead — campos principales

```dart
lead.idLead      // int — identificador único
lead.idEstado    // String — '00'–'15' (ver AppIconsSocial etapas)
lead.idCanal     // int — canal de origen (ver AppIconsSocial canales)
lead.asignadoA   // String — codUser del agente asignado
lead.nombre      // String
lead.telefono    // String
lead.fechaHora   // String — usar .formatWhatsApp() para mostrar
```

---

## Páginas y rutas

| Página | Ruta | Tipo |
|---|---|---|
| `LeadListPage(type: LeadType.seguimientos)` | `AppRoutes.seguimiento` | clearAndPush |
| `LeadListPage(type: LeadType.propuestas)` | `AppRoutes.propuestas` | clearAndPush |

Ambas rutas limpian el stack (se navega desde el Drawer).

---

## Navegación a detalle de chat desde un lead

Desde cualquier lead se puede ir al chat del lead:
```dart
context.goToDetalleChat(idLead: lead.idLead)
// apila ChatDetailPage sobre LeadListPage
```