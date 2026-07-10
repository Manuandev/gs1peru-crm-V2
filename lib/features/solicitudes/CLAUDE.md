# Solicitudes Feature

## Propósito
Gestiona el flujo de solicitudes de inscripción: lista con filtros, detalle, y un wizard de
4 pasos para completar una solicitud (Solicitante → Participantes → Facturación → Resumen).

## Estado general — ⚠️ datos hardcodeados, pendiente conectar al backend real
Todo el feature funciona hoy con data en memoria (sin SP real conectado):
- `SolicitudRemoteDatasource` retorna una lista hardcodeada (`_solicitudesHardcoded`) — ver
  comentario en el archivo con el mapeo de estados/canales. Falta conectar al SP real.
- El wizard (`SolicitudFormCubit` + `ParticipantesCubit`) guarda todo en memoria durante la
  sesión de navegación; no hay persistencia ni envío al backend. Los botones "Guardar
  borrador" y "Generar solicitud" (paso Resumen) no están conectados a ningún caso de uso.
- "Carga masiva" (Excel) solo valida la extensión del archivo seleccionado — no procesa ni
  sube el archivo.
- **Campaña y Evento ya NO forman parte del paso 1** — se removieron por completo (campos,
  combos, validación y del modelo `DatosSolicitante`) porque este wizard ya no los usa.
- Combos con catálogo real ya conectado a `CatalogsBloc` (no hardcodear de nuevo si se
  tocan estos campos): **Canal** (chips single-select en paso 1, `CanalItem`), **Moneda**
  (paso 3, `MonedaItem`), **Tipo documento** (pasos 1/3 y formulario de participante,
  `TipoDocumentoItem` — `id` es **String**, no parsear con `toInt`), **Nacionalidad**
  (pasos 1/3 y formulario de participante, `NacionalidadItem` — gentilicio, no confundir
  con `PaisItem`), **código telefónico del celular** (todos los campos de celular del
  wizard, `PaisItem.codigoTelefono` — ver `SolicitudCampoCelular` abajo). Combos sin
  catálogo de backend (se mantienen como lista fija local porque no existe otro origen):
  Sexo (paso 1), Comprobante y País (paso 3), Tipo de participante (formulario de
  participante).

## Pantallas
- `SolicitudListPage` → lista de solicitudes con chips de filtro (Todas / Asesores /
  Sin validar / Enviar a cobranza)
- `SolicitudDetallePage` → detalle de una solicitud (solo lectura)
- `SolicitudCompletarPage` (paso 1/4) → datos del solicitante
- `SolicitudParticipantesPage` (paso 2/4) → lista de participantes (agregar/editar/eliminar)
- `SolicitudCargaMasivaPage` → carga de participantes vía Excel (abre desde paso 2)
- `SolicitudFacturacionPage` (paso 3/4) → datos de facturación (quién paga)
- `SolicitudResumenPage` (paso 4/4) → resumen final de los 3 pasos + adjuntos
- `SolicitudGeneradaPage` → pantalla de confirmación tras "Generar solicitud"

## BLoCs / Cubits
- `SolicitudListBloc` (list/) → carga y filtra la lista; conteos por estado; agrupa
  asesores disponibles para el picker
- `SolicitudFormCubit` (form/) → guarda `DatosSolicitante` y `DatosFacturacion` capturados
  en los pasos 1 y 3. Se crea **una sola vez** en `SolicitudCompletarPage` (paso 1) y se
  reenvía como argumento (`formCubit`) a través de todo el wizard vía `BlocProvider.value`
- `ParticipantesCubit` (participantes/) → lista de `ParticipanteLocal` (agregar / editar /
  eliminar / eliminarTodos), inicia **vacía** (ya no trae participantes ficticios
  hardcodeados). `sincronizarSolicitante(DatosSolicitante)` agrega/actualiza un
  `ParticipanteLocal` marcado `esSolicitante: true` con los datos del solicitante cuando
  el switch "El solicitante será participante" está activo (o lo retira si se desactiva) —
  se llama junto con `guardarSolicitante` al presionar "Continuar" en el paso 1, es
  idempotente (no duplica en sucesivos "Continuar"). Se crea **junto con**
  `SolicitudFormCubit` en el paso 1 y se reenvía igual (`participantesCubit`) hasta el
  Resumen — mismo patrón que `formCubit`

## Patrón de navegación del wizard — IMPORTANTE
Los 4 pasos comparten los mismos dos cubits durante todo el recorrido. Cada método
`goToFichaXxxSolicitud` en `navigation_extensions.dart` recibe `formCubit` y
`participantesCubit` como argumentos obligatorios y los reenvía; cada `Page` del wizard los
recibe y los provee hacia abajo con `BlocProvider.value` (nunca `BlocProvider(create: ...)`,
eso crearía una instancia nueva y se perderían los datos ya ingresados). Ver
`lib/config/CLAUDE.md` → "Pasar un Cubit ya creado a una ruta" para el patrón base.

Al agregar un paso nuevo al wizard:
1. Agregar el parámetro `formCubit`/`participantesCubit` al método de navegación correspondiente
2. En el `Page` del paso, recibirlos y envolver con `MultiBlocProvider` + `BlocProvider.value`
3. Nunca crear una instancia nueva de estos cubits fuera del paso 1

## Validación de "Continuar" (pasos 1, 2 y 3)
Cada paso deshabilita su botón `CustomPrimaryButton` de "Continuar" (pasando
`onPressed: null`) hasta que los campos obligatorios (marcados con `*` en la UI) estén
completos:
- **Paso 1** (`_formCompleto` en `solicitud_completar_view.dart`) — tipo/número documento,
  nacionalidad, sexo, nombres, apellido paterno, cargo, celular, correo. Opcionales:
  apellido materno, RUC/razón social, canal.
- **Paso 2** — basta con tener al menos 1 participante en la lista.
- **Paso 3** (`_formCompleto` en `solicitud_facturacion_view.dart`) — comprobante, país,
  moneda, tipo/número documento, nacionalidad, nombres/razón social, apellido paterno,
  celular, correo, dirección. Opcionales: apellido materno, actividad económica, NIT,
  observaciones.

Los campos de texto usan `TextEditingController.addListener` para recalcular la validez en
vivo; los combos que antes no emitían su selección hacia el padre (Nacionalidad, Sexo en
paso 1; Tipo documento, Nacionalidad en paso 3) ahora tienen `onChanged` conectado —
necesario para poder validarlos, ya que antes su valor no se propagaba a ningún lado.

## Widgets principales
- `SolicitudListView` / `SolicitudListPortrait` (list/) → lista + chips + `SolicitudCard`
- `SolicitudAsesorPickerModal` (list/) → modal del chip "Asesores", mismo patrón que
  `LeadAsesorPickerModal` mismo patrón que en `lead/`
- `SolicitudDetalleView` (detail/) → detalle de solo lectura
- `SolicitudPasosIndicador` / `SolicitudBadgePaso` (completar/) → indicador de paso 1-4
  compartido por las 4 vistas del wizard
- `SolicitudCompletarView` (completar/) → formulario paso 1 (datos del solicitante)
- `SolicitudParticipantesView` (completar/) → lista de participantes del paso 2; agregar
  abre `participante_form_sheet.dart` (bottom sheet); eliminar (individual o "todos") pide
  confirmación vía `context.showConfirmDialog`
- `SolicitudCargaMasivaView` (completar/) → selector de archivo Excel para carga masiva
- `SolicitudFacturacionView` (completar/) → formulario paso 3 (datos de facturación)
- `SolicitudResumenView` (completar/) → resumen de los 3 pasos; secciones Solicitante y
  Facturación leen `SolicitudFormCubit`, sección Participantes lee `ParticipantesCubit`
  (todas con datos reales, ya no hardcodeados). "Resumen comercial" (Inversión/IGV/Total)
  **sigue hardcodeado** — pendiente conectar a `ParticipantesCubit.state.totalInversion`
- `SolicitudGeneradaView` (generada/) → pantalla de éxito tras generar la solicitud
- `solicitud_inputs.dart` (completar/) → **solo** los widgets del wizard sin equivalente
  en `lib/core/presentation/widgets` (`SolicitudToggleTipoPersona`, `SolicitudCampoCelular`,
  `SolicitudBadgePaso`). Para texto/combos/botones usar siempre los widgets generales del
  core — `CustomTextField`, `CustomComboField<T extends Comboable>` (catálogos reales),
  `CustomComboSearchField` (listas fijas locales tipo `"id¦desc"`), `CustomPrimaryButton`,
  `CustomSecondaryButton`, `CustomOutlinedButton`. No crear wrappers `SolicitudXxx` nuevos
  para estos — si falta una variante, extender el widget core correspondiente.
  `SolicitudCampoCelular` recibe `paises: List<PaisItem>` + `paisSeleccionado` +
  `onPaisChanged` (y un `validator` opcional) — el recuadro cerrado solo muestra el código
  (`+51`), el nombre del país solo aparece en el selector (`_SelectorPaisTelefono`, bottom
  sheet con buscador) para poder ubicarlo. Se usa en las 3 pantallas con campo de celular:
  paso 1 (solicitante), paso 3 (facturación) y el formulario de participante — default
  Perú (`codigoTelefono == '51'`) cuando el catálogo ya cargó

## Modelos relevantes
- `Solicitud` (domain/entities) → entidad de la lista/detalle
- `DatosSolicitante` / `DatosFacturacion` (bloc/form/solicitud_form_state.dart) → snapshots
  inmutables de los pasos 1 y 3, capturados al presionar "Continuar". `DatosSolicitante`
  incluye `nacionalidad` (descripción del combo), `canalId`/`canalNombre` (del `CanalItem`
  seleccionado en los chips — reemplazó al antiguo `canales: List<String>` multi-select) y
  `celularCodigoTelefono` (código telefónico del `PaisItem` elegido, ej. `'51'`). **Ya no
  tiene** `campana`/`evento` — se removieron del flujo. `DatosFacturacion` también tiene su
  propio `celularCodigoTelefono` (independiente del de `DatosSolicitante`)
- `ParticipanteLocal` (bloc/participantes/participantes_state.dart) → participante en
  memoria; `id` autogenerado por el cubit (`_nextId`), no viene del backend. Campos:
  `tipoDoc`, `numDoc`, `nacionalidad`, `nombres`/`apellidoPaterno`/`apellidoMaterno`
  (`nombreCompleto` los junta), `correo`, `cargo`, `celular`, `celularCodigoTelefono`
  (código telefónico del `PaisItem` elegido), `tipoParticipante` (Pagante / Invitado /
  Invitado auspicio / Online), `importe` (sin moneda), `esSolicitante` (marca el registro
  autogenerado por el switch "El solicitante será participante" — ver abajo)

## SPs que consume
- Ninguno todavía — ver "Estado general" arriba. `SolicitudRemoteDatasource` es 100% mock.

## Dependencias externas
- `SolicitudRepository` (RepositoryProvider — implementación hardcodeada)

## Notas importantes
- `SolicitudFiltro` (`todas`, `asesores`, `sinValidar`, `enviarACobranza`) — `sinValidar` =
  `idEstado == '01'`, `enviarACobranza` = `idEstado == '03'`
- `SolicitudAccionTipo` decide qué botones muestra `SolicitudCard` según el filtro activo:
  `ninguna` (solo ver), `sinValidar` (Ver + Validar), `cobranza` (Ver + Completar)
- Estados de la solicitud: `'00'` Por Completar · `'01'` Por Validar · `'02'` Con
  Documentos · `'03'` Lista p/Cobranza
- Separadores del backend: `AppConstants.sepListas` (`¯`), `AppConstants.sepCampos` (`¦`),
  `AppConstants.sepRegistros` (`¬`) — aún sin uso real aquí porque no hay SP conectado
