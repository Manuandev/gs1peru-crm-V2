# Solicitudes Feature

## Propósito
Gestiona el flujo de solicitudes de inscripción: lista con filtros, detalle, y un wizard de
4 pasos para completar una solicitud (Solicitante → Participantes → Facturación → Resumen).

## Estado general — ⚠️ wizard aún hardcodeado, lista ya conectada al SP real
- `SolicitudRemoteDatasource.getSolicitudes()` ya está conectado a
  `[CRM].[CSV_SOLICITUDES_LST_APP]` (task `'LS'`, body `codUser¦isModerador`) — mismo patrón
  que `CobranzaRemoteDatasource`. Ver mapeo posicional completo en el comentario de
  `SolicitudModel.fromRawString` y en "SPs que consume" abajo.
- **Bug pendiente en el SP — campo Canal**: la sección comentada `-- CANAL` del SP repite las
  mismas columnas que `-- ESTADO SOLICITUD` (`EG.ID_ESTADO_GES`/`EG.DESCRIPCION` dos veces) en
  vez de seleccionar `CN.ID_CANAL`/`CN.DESCRIPCION` (la tabla `CN` = `CRM.T_CANAL` se une con
  `LEFT JOIN` pero sus columnas nunca se seleccionan). El parser en Flutter (`SolicitudModel`)
  ya está escrito asumiendo la posición **corregida** (`idCanal`/`canal` en los índices 16/17
  del raw, antes del bloque de estado en 18/19) — no hace falta tocar Flutter de nuevo cuando
  se corrija el SP, solo hay que cambiar esas dos columnas en el `SELECT` para que apunten a
  `CN` en vez de repetir `EG`. Hasta entonces, `idCanal`/`canal` en la lista llegan con el
  mismo valor que `idEstado`/`estado` (dato incorrecto, no usar para nada crítico).
- El wizard (`SolicitudFormCubit` + `ParticipantesCubit`) guarda todo en memoria durante la
  sesión de navegación. **`SolicitudRemoteDatasource.guardarSolicitud()` ya existe y está
  conectado** al SP real (task `'U'`, ver "SPs que consume") — pero **todavía no está
  llamado desde ningún botón**. Los botones "Guardar" (pasos 1/2/3) y "Guardar
  borrador"/"Generar solicitud" (paso Resumen) siguen sin `onPressed` real — eso es lo que
  falta para terminar de conectar el CUD, ver "Pendiente" abajo.
- "Carga masiva" (Excel) solo valida la extensión del archivo seleccionado — no procesa ni
  sube el archivo.
- **Archivos (voucher/OC) van en una llamada aparte** (task `'AR'`, aún no implementado en
  Flutter) — necesitan el `NUMSOL` que devuelve la llamada de `guardarSolicitud()` (task
  `'U'`), así que el flujo real es: 1) guardar cabecera+participantes → 2) con el `NUMSOL`
  de la respuesta, subir archivos por chunks a `SPSolicitudCUDAppArchivos`.

## Pendiente (roadmap del CUD) — leer esto primero si retomas el feature
1. ~~`SolicitudRemoteDatasource.guardarSolicitud()` (task `'U'`)~~ — hecho.
2. ~~`SolicitudRemoteDatasource.guardarArchivo()` (task `'AR'`)~~ — hecho, ver abajo.
3. **Falta conectar los botones** — ningún widget llama a `guardarSolicitud()` ni
   `guardarArchivo()` todavía. Esto es lo próximo:
   - "Generar solicitud" (Resumen, `solicitud_resumen_view.dart`) → `GuardarSolicitudUseCase`
     con `esBorrador: false`. Primera prioridad, acordado con el usuario.
   - Botones "Guardar" (pasos 1/2/3/Resumen, hoy `onPressed: () {}`) → mismo usecase con
     `esBorrador: true`.
   - Flujo completo al presionar "Generar solicitud": 1) `GuardarSolicitudUseCase.call(...)`
     con `numSol: solicitud.idSolicitud` (o `''` si es creación — hoy no hay ese caso, ver
     punto 6) → 2) leer el `NUMSOL` de `CrudOk.data` → 3) si `_archivoVoucher`/`_archivoOC`
     (`PlatformFile` capturados en paso 1, `solicitud_completar_view.dart`) no son null, por
     cada uno llamar `GuardarArchivoSolicitudUseCase.call(numSol: ese NUMSOL, tipo:
     'voucher'|'oc', fileName/fileExt/fileBytes: del `PlatformFile`) → 4) navegar a
     `SolicitudGeneradaPage`. Los archivos se mandan DESPUÉS de confirmar el `NUMSOL`, nunca
     antes (por eso está separado en dos tasks — ver "SPs que consume").
4. ~~Ajuste en `guardarSolicitud()`: el SP dejó de recibir `ID_CONTACTO`~~ — hecho. La
   cabecera ahora manda 41 campos (`ID_LEAD` es field1) en vez de 42.
5. `ID_LEAD` se manda vacío porque **no existe ninguna pantalla que cree una
   solicitud nueva desde un Lead** — el único punto de entrada al wizard hoy es
   "Editar ficha"/"Continuar" desde una solicitud ya existente
   (`SolicitudDetalleView.goToFichaCompletarSolicitud`). Cuando se construya ese flujo, hay
   que pasar el `idLead` real.
6. "Carga masiva" (Excel) y el resto de los botones "Guardar borrador" siguen sin SP.
- **Campaña y Evento ya NO forman parte del paso 1** — se removieron por completo (campos,
  combos, validación y del modelo `DatosSolicitante`) porque este wizard ya no los usa.
- Combos con catálogo real ya conectado a `CatalogsBloc` (no hardcodear de nuevo si se
  tocan estos campos): **Canal** (chips single-select en paso 1, `CanalItem`), **Moneda**
  (paso 3, `MonedaItem`), **Tipo documento** (pasos 1/3 y formulario de participante,
  `TipoDocumentoItem` — `id` es **String**, no parsear con `toInt`), **Nacionalidad**
  (pasos 1/3 y formulario de participante, `NacionalidadItem` — gentilicio, no confundir
  con `PaisItem`), **Comprobante** (paso 3, `ComprobanteItem`), **País** (paso 3,
  `CustomComboField<PaisItem>` — el mismo catálogo `CatalogsBloc.paises` que alimenta el
  selector de código telefónico, ver abajo), **código telefónico del celular** (todos los
  campos de celular del wizard, `PaisItem.codigoTelefono` — ver `SolicitudCampoCelular`
  abajo). Combos sin catálogo de backend (se mantienen como lista fija local porque no
  existe otro origen — **son los únicos que pueden seguir hardcodeados**): Sexo (paso 1),
  Tipo de participante (formulario de participante).
- Los chips de Canal usan `AppSocialUtils.widgetCanalById(canal.id)` (no
  `widgetCanal(canal.iconoApp)`) — el string `iconoApp` que trae el SP no siempre calza
  con las keys internas de `AppSocialUtils` y termina mostrando un ícono de interrogación;
  `widgetCanalById` usa el mapa id→iconoApp mantenido en la app (mismo que usa el combo de
  canal de `lead/edit_lead_negociacion_section.dart`), más confiable que el dato crudo.
- **"Tipo de persona" (Jurídica/Natural) es un solo valor compartido** — vive en
  `SolicitudFormCubit.state.tipoPersona` (no en `DatosSolicitante`/`DatosFacturacion`,
  que antes tenían cada uno su propia copia y se desincronizaban). Solo se puede cambiar
  en el paso 1; en el paso 3 el toggle se muestra pero con `habilitado: false` siempre.
- **Regla de negocio — saltar Facturación**: si TODOS los participantes tienen
  `tipoParticipante` en {`Invitado`, `Invitado auspicio`} (nadie paga), el paso 2 navega
  directo a Resumen (`goToFichaResumenSolicitud`) sin pasar por Facturación. El Resumen
  detecta esto porque `formState.facturacion` queda `null` y oculta la sección
  "3. Facturación" (y su separador) — no renderizarla si `datos == null` en ese caso.
- **Validación de email real** en los 3 lugares con campo Correo (paso 1, paso 3,
  formulario de participante) — usa la extensión `String?.emailValidator` (core,
  `utils/string/string_utils.dart`), no un simple `isNotEmpty`/`contains('@')` casero.
- El contador de caracteres bajo los campos con `maxLength` (`CustomTextField`, core) está
  suprimido (`buildCounter` → null) — decisión de diseño para todo el wizard, no solo aquí.
- **`TipoDocumentoItem.abreviatura`** (core, `catalog_item.dart`) — el SP solo trae la
  descripción larga ("DOC. NACIONAL DE IDENTIDAD"); la UI necesita la forma corta
  (DNI/CE/RUC/Pasaporte/...). Es un getter client-side (mapa fijo por id, no viene del
  backend) expuesto como `fields[2]`. Dondequiera que se muestre un combo de Tipo
  documento (paso 1, paso 3, formulario de participante) usar
  `CustomComboField<TipoDocumentoItem>(labelIndex: 2, ...)` y guardar `item.abreviatura`
  (no `item.nombre`) como el label persistido — así es consistente en todos lados.
- **Regla de negocio — Comprobante ↔ Tipo documento (paso 3)**: el combo Comprobante solo
  muestra Factura/Boleta (se filtra `CatalogsBloc.comprobantes` a los ids `'01'`/`'03'`,
  aunque el catálogo real también trae N. Crédito/N. Débito). Si se elige **Factura**, el
  combo Tipo documento se filtra a **solo RUC** (id `'6'`) y se fuerza esa selección
  automáticamente; si se elige **Boleta**, se muestran todos los tipos de documento. La
  etiqueta del campo Correo también cambia según el comprobante ("Correo para envío de
  boleta" / "... de factura").
- **Paso 3 — campos condicionados a RUC vs persona natural**: cuando el Tipo documento
  elegido es RUC, se muestran los campos **RUC** + **Razón Social** (reusando
  `ctrlNumDoc`/`ctrlNombresRazon`); para cualquier otro tipo de documento se muestran
  **Número documento** + **Nombres** + **Apellido paterno** + **Apellido materno**
  (opcional). Ya no existen las etiquetas híbridas ("Apellido paterno / razón legal") que
  había antes — `_SeccionDatosFacturacion` recibe un `esRuc: bool` y renderiza un set de
  campos u otro.
- **Prefill de Facturación desde el Solicitante**: si en el paso 1 se activó "Facturar al
  solicitante" y el usuario llega al paso 3 por primera vez (sin `DatosFacturacion` previo
  guardado), `solicitud_facturacion_view.dart` autocompleta tipo/número documento,
  nacionalidad, nombres/apellidos, celular (+ código de país) y correo con los mismos
  datos ya capturados en `DatosSolicitante` — el usuario puede seguir editándolos.
- **Botón "Continuar" siempre habilitado** (pasos 1 y 3) — ya no se deshabilita
  (`onPressed: null`) cuando faltan campos obligatorios; ahora siempre tiene `onPressed`,
  y al presionarlo evalúa `_formCompleto`: si falta algo, muestra
  `AppSnackBar.error(context, 'Completa todos los campos obligatorios (*) para continuar')`
  y no navega; si está completo, guarda y avanza como antes. El usuario ya no se pregunta
  "¿por qué no puedo continuar?" sin explicación.
- **Documentos adjuntos (Resumen) ya no están hardcodeados** — `DatosSolicitante` guarda
  `archivoVoucherNombre`/`archivoOCNombre` (el nombre del PDF elegido en el paso 1, o `''`
  si no se adjuntó nada) y `solicitud_resumen_view.dart` los muestra tal cual, con un
  estado "Sin adjuntar" (gris) cuando están vacíos en vez de un nombre de archivo inventado.

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
- `SolicitudListBloc` (list/) → carga y filtra la lista; conteos por estado; calcula
  `conteosPorAsesor` (`Map<String,int>`, sobre `_allSolicitudes`) para alimentar el picker —
  el universo de asesores ya no sale de las solicitudes cargadas, viene de
  `CatalogsBloc.asesores` (ver `SolicitudAsesorPickerModal` abajo)
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
**Todo lo de esta sección aplica solo cuando `modoEdicion == true`.** Cuando
`modoEdicion == false` (se entró por "Continuar" desde `SolicitudDetalleView`, no por
"Editar ficha"), los 3 pasos son un recorrido de **solo lectura**: el pie muestra
únicamente el botón "Continuar" (ancho completo, sin "Cancelar"/"Guardar"/"Atrás") y su
`onPressed` navega directo al siguiente paso sin evaluar `_formCompleto` ni el gate de
participantes — no tiene sentido bloquear a alguien que solo quiere ver una solicitud ya
cargada. Los 3 pasos factorizan esto igual: la lógica de "construir el snapshot y navegar"
vive en un método `_onContinuar(...)` que el botón llama siempre; la validación
(`if (widget.modoEdicion && !_formCompleto) { ... return; }` o, en el paso 2,
`onPressed: state.participantes.isEmpty ? null : ...` solo dentro de la rama
`modoEdicion`) solo se ejecuta cuando `modoEdicion` es `true`. El resto de esta sección
describe el comportamiento en modo edición.

El botón `CustomPrimaryButton` de "Continuar" en los pasos 1 y 3 **siempre está
habilitado** — al presionarlo se evalúa `_formCompleto`; si falta algo obligatorio (`*`)
se muestra un `AppSnackBar.error` y no navega, en vez de deshabilitar el botón sin
explicar por qué (ver "Estado general"). El paso 2 sigue con su gate simple
(`participantes.isEmpty`) ya que solo exige tener al menos un participante:
- **Paso 1** (`_formCompleto` en `solicitud_completar_view.dart`) — tipo/número documento,
  nacionalidad, sexo, nombres, apellido paterno, cargo, celular, correo (formato real vía
  `.emailValidator`, no solo `isNotEmpty`). Opcionales: apellido materno, RUC/razón social,
  canal. El N° de solicitud ya no se muestra en este paso (solo el toggle Jurídica/Natural).
- **Paso 2** — basta con tener al menos 1 participante en la lista. Cada participante ya
  pasó su propia validación al guardarse en el modal (`participante_form_sheet.dart`), así
  que no hace falta re-validar aquí.
- **Paso 3** (`_formCompleto` en `solicitud_facturacion_view.dart`) — comprobante, país,
  moneda, tipo/número documento, nacionalidad, nombres/razón social, celular, correo
  (formato real), dirección. Apellido paterno solo es obligatorio si el tipo de documento
  **no** es RUC (`_esRuc`). Opcionales: apellido materno, actividad económica, NIT,
  observaciones.

En el formulario de participante (`participante_form_sheet.dart`), todo es obligatorio
excepto apellido materno — Importe es la única excepción "blanda": se puede dejar vacío y
se guarda como `0` por defecto (no bloquea el guardado).

Los campos de texto usan `TextEditingController.addListener` para recalcular la validez en
vivo; los combos que antes no emitían su selección hacia el padre (Nacionalidad, Sexo en
paso 1; Tipo documento, Nacionalidad en paso 3) ahora tienen `onChanged` conectado —
necesario para poder validarlos, ya que antes su valor no se propagaba a ningún lado.

## Widgets principales
- `SolicitudListView` / `SolicitudListPortrait` (list/) → lista + chips + `SolicitudCard`
- `SolicitudFilterChips` (list/) → chips de filtro horizontal (Todas/Asesores/Sin
  validar/Enviar a cobranza); el chip "Asesores" solo se muestra si
  `SessionService().isModerador` — mismo patrón que `CobranzaFilterChips`. Antes de este
  cambio el chip "Asesores" siempre estaba visible, incluso para un asesor no-moderador
- `SolicitudAsesorPickerModal` (list/) → modal del chip "Asesores", mismo patrón que
  `CobranzaAsesorPickerModal`: reactivo a `CatalogsBloc` (`BlocBuilder<CatalogsBloc,
  CatalogsState>`, no un snapshot estático), ícono de refrescar dispara
  `CatalogsLoadRequested`. Cada fila muestra avatar, nombre, código, punto verde si
  `disponible` y el conteo (`SolicitudListSuccess.conteosPorAsesor`, calculado en el bloc
  sobre las solicitudes cargadas — el backend no lo trae). Retorna el `codUser` elegido o
  `null` — `SolicitudListPortrait` interpreta `null` como "volver a Todas". **Antes** este
  modal armaba la lista de asesores agrupando las propias solicitudes cargadas
  (`AsesorResumen`, sin catálogo real) — se reemplazó porque para un asesor no-moderador el
  SP solo trae sus propias solicitudes, así que en la práctica solo se veía a sí mismo
- `SolicitudDetalleView` (detail/) → detalle de solo lectura
- `SolicitudPasosIndicador` / `SolicitudBadgePaso` (completar/) → indicador de paso 1-4
  compartido por las 4 vistas del wizard
- `SolicitudCompletarView` (completar/) → formulario paso 1 (datos del solicitante). Pie de
  3 botones: **Cancelar** (izquierda, raspberry, pide confirmación "¿Desea cancelar el
  proceso de solicitud?" antes de salir) / **Guardar** (medio) / **Continuar** (derecha) —
  mismo layout que el paso 3, solo cambia la etiqueta/función del botón izquierdo.
  Dividido en varios archivos para no pasar de ~900 líneas — al tocar el paso 1, el widget
  que corresponde puede estar en cualquiera de estos (todos en `completar/`):
  - `solicitud_completar_view.dart` → `SolicitudCompletarView` (el State y el `build`
    principal: toggle tipo persona, canal, adjuntos, switches, botón "Continuar")
  - `solicitud_completar_adjuntos.dart` → `BotonAdjuntar` / `TarjetaArchivoAdjunto`
  - `solicitud_completar_secciones.dart` → `TooltipPartesSolicitud`, `SeccionSwitches` +
    `ItemSwitch`, `SeccionInfoComercial` (RUC/razón social)
  - `solicitud_completar_datos_solicitante.dart` → `SeccionDatosSolicitante` (tipo/número
    doc, nacionalidad, sexo, nombres, apellidos, cargo, celular, correo)
  - `solicitud_chips_canales.dart` → `ChipsCanales`
  Se importan directamente en `solicitud_completar_view.dart` (no vía el barrel
  `index_solicitudes.dart`), mismo patrón que `solicitud_pasos_indicador.dart`. Regla
  general del feature: ningún archivo debería pasar de ~900-1000 líneas — si uno se acerca,
  extraer secciones a un archivo nuevo así en vez de seguir creciendo el mismo
- `SolicitudParticipantesView` (completar/) → lista de participantes del paso 2; agregar
  abre `participante_form_sheet.dart` (bottom sheet); eliminar (individual o "todos") pide
  confirmación vía `context.showConfirmDialog`. Pie: Cancelar / Guardar / Continuar (mismo
  orden que los demás pasos). "Continuar" aplica la regla de saltar Facturación (ver
  "Estado general"). El resumen de inversión (`_ResumenInversion`) usa el IGV real de
  `CatalogsBloc.igvPorcentaje` y muestra los montos sin símbolo de moneda
- `SolicitudCargaMasivaView` (completar/) → selector de archivo Excel para carga masiva
- `SolicitudFacturacionView` (completar/) → formulario paso 3 (datos de facturación). El
  toggle Jurídica/Natural es de solo lectura aquí (`habilitado: false`); "Facturar al
  solicitante" en el resumen del pie lee el valor real de
  `formState.solicitante?.facturarAlSolicitante` (ya no hardcodeado a `'No'`)
- `SolicitudResumenView` (completar/) → resumen de los 3 pasos; secciones Solicitante y
  Facturación leen `SolicitudFormCubit`, sección Participantes lee `ParticipantesCubit`.
  La sección "3. Facturación" se **oculta** si `formState.facturacion == null` (paso 3
  saltado). "Resumen comercial" (Inversión/IGV/Importe total) ya lee datos reales de
  `ParticipantesCubit.state.totalInversion` + `CatalogsBloc.igvPorcentaje`, sin símbolo de
  moneda — ya no está hardcodeado
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
- `Solicitud` (domain/entities) → entidad de la lista/detalle. `idSolicitud` es `String`
  (`NUMSOL`, no numérico garantizado — mismo patrón que `Cobranza.numSol`). `apellido` es un
  solo campo que junta `apePaterno` + `apeMaterno` del SP (el SP los trae separados, la
  entidad no). `idOportunidad`/`oportunidad` reemplazan al viejo `idTipoSolicitud`/
  `tipoSolicitud` (vienen de `OP.ID_OPORTUNIDAD`/`OP.NOMBRE` — la oportunidad/curso de la
  solicitud). Campos nuevos agregados al conectar el SP real: `cargo`, `tipoPersona`
  (`'Juridica'`/`'Natural'`), `idCondicionPago`/`condicionPago` (`'CR'`/`'C'` — crédito o
  contado), `canal` (label, ver bug de Canal en "Estado general"), `ibValidado` (bool). Ya
  **no tiene** `idContacto` ni `observaciones` — el SP no los trae y ninguna pantalla los
  usaba
- `DatosSolicitante` / `DatosFacturacion` (bloc/form/solicitud_form_state.dart) → snapshots
  inmutables de los pasos 1 y 3, capturados al presionar "Continuar". `DatosSolicitante`
  incluye `tipoDocId`/`nacionalidadId`/`sexoId` (ids de catálogo, no solo el label —
  necesarios tanto para el prefill de Facturación/preseleccionar combos como para el CUD),
  `nacionalidad` (descripción del combo), `canalId`/`canalNombre` (del `CanalItem`
  seleccionado en los chips — reemplazó al antiguo `canales: List<String>` multi-select),
  `celularCodigoTelefono` (código telefónico del `PaisItem` elegido, ej. `'51'`) y
  `archivoVoucherNombre`/`archivoOCNombre` (nombre del PDF adjuntado, o `''` — lo que
  muestra el Resumen en "Documentos adjuntos"). **Ya no tiene** `campana`/`evento` — se
  removieron del flujo. `DatosFacturacion` también tiene `tipoDocId` (agregado junto con
  `sexoId` al conectar el CUD — antes solo se guardaba `tipoDocLabel`, el SP necesita el id)
  y su propio `celularCodigoTelefono` (independiente del de `DatosSolicitante`)
- `ParticipanteLocal` (bloc/participantes/participantes_state.dart) → participante en
  memoria; `id` autogenerado por el cubit (`_nextId`), no viene del backend — pero **sí es el
  mismo id que se manda al SP** como `ID` de la fila (`T_TECMSOLINSCRIPCION02.ID` no es
  autoincremental, inserta literalmente lo que se le mande). Campos: `tipoDocId`/
  `nacionalidadId` (ids de catálogo, agregados junto con `sexoId`/`tipoDocId` de
  `DatosSolicitante`/`DatosFacturacion` al conectar el CUD — antes solo se guardaban
  `tipoDoc`/`nacionalidad`, la abreviatura/nombre), `numDoc`, `nombres`/`apellidoPaterno`/
  `apellidoMaterno` (`nombreCompleto` los junta), `correo`, `cargo`, `celular`,
  `celularCodigoTelefono` (código telefónico del `PaisItem` elegido), `tipoParticipante`
  (Pagante / Invitado / Invitado auspicio / Online — sin catálogo real, string libre),
  `importe` (sin moneda), `esSolicitante` (marca el registro autogenerado por el switch "El
  solicitante será participante" — ver abajo)

## SPs que consume
- `[CRM].[CSV_SOLICITUDES_LST_APP]` (task `'LS'`, body `codUser¦isModerador`) → lista de
  solicitudes (`SolicitudModel.fromRawString`, 23 campos posicionales — ver mapeo comentado
  en el archivo del modelo y el bug de Canal en "Estado general"). Este SP solo tiene rama
  `@L_TASK = 'LS'` y filtra en el WHERE por `IB_MOD_APP = 1 OR ID_USUARIO_EJEC = @ID_USUARIO`
  (mismo patrón que moderador/asesor de Cobranza) más `IB_VALIDADO != 0`.
- `[CRM].[CSV_SOLICITUD_CUD_APP]` (task `'U'`, body `cabecera¦...¯detalle¦...¬detalle¦...¯U`)
  → `SolicitudRemoteDatasource.guardarSolicitud()`. Crea (si `numSol` viene vacío) o
  actualiza (si ya existe) cabecera + facturación + participantes de una solicitud, todo en
  una transacción — ver el mapeo posicional completo comentado en el método (41 campos de
  cabecera, `ID_LEAD` es field1 — el SP ya no recibe `ID_CONTACTO`; 14 por participante).
  Devuelve `OK¯mensaje¯NUMSOL` (el `NUMSOL` es obligatorio
  leerlo de la respuesta en el flujo de creación — hace falta para la llamada de archivos
  después). **Todavía no está llamado desde ningún botón** — ver "Pendiente" arriba.
  - `IB_BORRADOR`: `1` cuando el usuario presiona "Guardar" (borrador), `0` cuando presiona
    "Generar solicitud" (final) — pasado como el parámetro `esBorrador` del usecase.
  - `IB_IGV` (por participante) siempre se manda `'1'` — no hay switch en la UI para
    desactivarlo. El monto de IGV por participante se calcula proporcional
    (`importe * igvPorcentaje / 100`), igual que el cálculo global del Resumen.
  - Campos de facturación RUC-vs-natural son mutuamente excluyentes, no duplicados: si es
    RUC, `RUCEMPRE_FAC`/`NOMEMPRE_FAC` se llenan y `NOMBRES_FAC`/apellidos quedan `''`; si no
    es RUC, es al revés. `NUM_DOC_FAC`/`ID_TIP_DOC_FAC`/`ID_NACION_FAC` (el SP reusa esta
    misma variable para `ID_NACIONALIDAD` e `ID_PAIS`) se llenan siempre.
  - `CARGO_FAC`/`UBIGEO_FAC` se mandan vacíos — el primero porque el SP no lo usa en ningún
    INSERT/UPDATE, el segundo porque no hay selector de ubigeo en la UI todavía.
- `[CRM].[CSV_SOLICITUD_CUD_APP]` (task `'AR'`, archivos) →
  `SolicitudRemoteDatasource.guardarArchivo()`, vía endpoint `SPSolicitudCUDAppArchivos`
  (`ApiConstants.urlSolicitudesCudArchivos`) — **no** `urlSolicitudesCud` (esa es solo para
  el task `'U'`, texto plano). Necesita el `NUMSOL` que devuelve el task `'U'` — nunca se
  sube un archivo sin ese `NUMSOL` confirmado. Chunks de 2MB por `postMultipart`, mismo
  patrón que `ChatRemoteDatasource.uploadAndSendFileMessage`, pero con una diferencia: acá
  el chunk final (`chunkActual == chunkTotal`, 1-indexado) dispara el merge **en la misma
  llamada** que trae los últimos bytes — no hay una llamada de merge separada con bytes
  vacíos como en `chat`. Body por chunk:
  `token¯cabecera¯detalle¯AR¯chunkActual¯chunkTotal`, donde
  `cabecera = NUMSOL¦ID_USUARIO¦IP_USUARIO¦LL_USUARIO` y `detalle = TIPO¦NOMBRE¦EXT` (`TIPO`
  = `'voucher'` o `'oc'`, sin id — el GUID del archivo lo genera el backend). Devuelve `bool`
  (no `CrudResult` — la respuesta del endpoint es `OK¦N` por chunk, no el formato
  `OK¯msg¯data`).
- "Carga masiva" (Excel) todavía no tiene SP conectado.

## Dependencias externas
- `SolicitudRepository` (RepositoryProvider — `getSolicitudes()` ya conectado al SP real)

## Notas importantes
- `SolicitudFiltro` (`todas`, `asesores`, `sinValidar`, `enviarACobranza`) — `sinValidar` =
  `!ibValidado`, `enviarACobranza` = `ibValidado`. **Ya no usan `idEstado`** — antes
  `sinValidar` era `idEstado == '01'` y `enviarACobranza` era `idEstado == '03'`; se cambió
  porque "sin validar" y "listo para cobranza" son, en realidad, los dos lados de
  `IB_VALIDADO` (0/false = pendiente de validar, 1/true = ya validado → listo para
  cobranza), no un estado de gestión. Ya no existe un filtro/contador "Por completar" — se
  consideraba lo mismo que "Sin validar" y se eliminó
- Indicadores del dashboard (`_IndicadoresRow`, `solicitud_list_view.dart`): **3** tarjetas
  — "Sin validar" (`cntSinValidar` = `!ibValidado`), "Con documentos" (`cntConDocumentos` =
  `idEstado == '02'`, sin cambios), "Listas para cobranza" (`cntListasCobranza` =
  `ibValidado`). Antes había una 4ta tarjeta "Por completar" (`idEstado == '00'`) — se quitó
  por ser redundante con "Sin validar"
- **Ojo — mismatch pendiente con `SolicitudCard`**: `SolicitudAccionTipo`/
  `SolicitudCard._accion()`/`colorEstado()` (widgets/list/solicitud_card.dart) todavía
  deciden qué botón mostrar (Validar/Completar) y de qué color es el chip de estado
  mirando `idEstado` (`'00'`/`'01'`/`'02'`/`'03'`, el estado de gestión crudo del SP — ver
  "SPs que consume"), **no** `ibValidado`. Por ahora es intencional (el usuario pidió dejar
  los estados de gestión para después), pero puede haber solicitudes que aparezcan en el
  filtro "Sin validar" (por `ibValidado`) mostrando el botón "Completar" en vez de
  "Validar" (porque su `idEstado` no es `'01'`), o viceversa. Pendiente de que se defina la
  relación real entre `idEstado` (estado de gestión) e `IB_VALIDADO` para unificar esto
- Estados de la solicitud (`idEstado`, estado de gestión — dimensión aparte de
  `ibValidado`): `'00'` Por Completar · `'01'` Por Validar · `'02'` Con Documentos · `'03'`
  Lista p/Cobranza
- Separadores del backend: `AppConstants.sepListas` (`¯`), `AppConstants.sepCampos` (`¦`),
  `AppConstants.sepRegistros` (`¬`) — usados por `SolicitudRemoteDatasource.getSolicitudes()`
  y `SolicitudModel.parseList`/`fromRawString`
