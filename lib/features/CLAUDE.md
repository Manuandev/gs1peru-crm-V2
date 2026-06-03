# Features — Estructura general

Cada feature sigue Clean Architecture. Un `index_xxx.dart` re-exporta todo — usarlo siempre.

## Estructura obligatoria

```
features/mi_feature/
├── index_mi_feature.dart
├── data/
│   ├── datasources/
│   │   ├── remote/mi_feature_remote_datasource.dart
│   │   └── local/mi_feature_local_datasource.dart  ← solo si persiste
│   ├── models/mi_model.dart          ← extiende entidad + parseo raw
│   └── repositories/mi_repository_impl.dart
├── domain/
│   ├── entities/mi_entidad.dart      ← modelo puro, extiende Equatable
│   ├── repositories/mi_repository.dart  ← interfaz abstracta
│   └── usecases/get_mi_entidad_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── mi_bloc.dart
    │   ├── mi_event.dart
    │   └── mi_state.dart
    ├── pages/mi_page.dart            ← solo crea BlocProvider
    └── widgets/mi_view.dart          ← UI pura
```

## Providers globales — `app_widget.dart`

Solo repositorios y Blocs que sobreviven a cambios de pantalla:

| Provider | Tipo |
|---|---|
| `AuthRepository` | RepositoryProvider |
| `CatalogsRepository` | RepositoryProvider |
| `HomeRepository` | RepositoryProvider |
| `LeadRepository` | RepositoryProvider |
| `ChatRepository` | RepositoryProvider |
| `AuthBloc` | BlocProvider — árbitro de sesión |
| `ThemeCubit` | BlocProvider — modo claro/oscuro |
| `DrawerBloc` | BlocProvider |
| `CatalogsBloc` | BlocProvider |

El resto de Blocs se crean en su propia Page y mueren con ella.

## Patrones compartidos — ver archivos específicos

| Feature | CLAUDE.md con detalle |
|---|---|
| `auth/` | Sesión, login, logout, SQLite, AuthBloc global |
| `chat/` | SignalR, WhatsApp, chunks, templates, multimedia |
| `lead/` | Filtros, estados, tipos, LeadListBloc |
| `home/` | Dashboard, parseo multi-sección, prioridades |
| `settings/` | ThemeCubit, preferencias |