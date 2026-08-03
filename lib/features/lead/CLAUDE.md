# Lead Feature

## Propósito
Gestiona la lista y detalle de leads en dos modos: Seguimientos (`PO`) y Propuestas (`PA`).

## Pantallas
- `LeadListPage` → lista de leads con chips de filtro; recibe `filtroInicial` opcional (`LeadListFiltro?`) para preseleccionar un chip al entrar (ej. desde `CardTotalesHome` en el dashboard)
- `LeadDetallePage` → detalle completo del lead con comentarios y stepper de estado
- `EditContactoSimplePage` (ruta `AppRoutes.editarContactoSimple`,
  `context.goToEditarContactoSimple(idNumero:)`) → versión reducida de `EditContactoPage`, ver
  sección dedicada más abajo ("EditContactoSimple — pantalla reducida...")
- `EditContactoPage` (ruta `AppRoutes.editarContacto`, `context.goToEditarContacto(idNumero:)`) →
  crear/editar contacto. Recibe **solo `idNumero`** — `ContactoFormCubit` (bloc/contacto_form/)
  carga el `ContactoDetalle` completo (identidad + documento + nacionalidad + ubicación +
  listas de celulares/correos/empresas) al entrar. Título dinámico en `EditContactoView`:
  `idContacto != 0` → "Editar contacto", `idContacto == 0` → "Editar número". Sin límite de
  celulares/correos (pedido explícito de negocio, 2026-07-23). Estructura: `EditContactoPage` →
  `EditContactoView` (BasePage + AppBar dinámico + guardandoNotifier) → `EditContactoPortrait`
  (StatefulWidget con todo el estado local: combos de catálogo + listas dinámicas de
  `NumeroFormRow`/`CorreoFormRow`/`EmpresaFormRow`, ver `contacto_form_rows.dart`) → 4 secciones
  Stateless (`EditContactoDatosSection`/`CelularSection`/`CorreoSection`/`EmpresaSection`).
  **Backend — SPs reales, confirmados 2026-07-23**:
  `D:\Proyectos\NatCodee\NC.SQLChangeLock\DBEAN\StoredProcedures\`
  (repo aparte, con su propio git — .sql en UTF-16LE con BOM, cualquier edición futura debe
  preservar esa codificación o SSMS los muestra corruptos, ver nota de `solicitudes/CLAUDE.md`).
  - `CRM.CSV_CONTACTO_CUD_APP` — task `'U'` (crear/actualizar). Rama CREATE (`@ID_CONTACTO` nulo/0)
    funciona; rama UPDATE existe pero con reglas de negocio pendientes de definir con negocio:
    validación de DNI duplicado no distingue "el usuario ya confirmó continuar" (siempre bloquea
    si `@IB_VALIDACION=1`), el check de "números en otro usuario" no excluye los que ya son del
    mismo contacto, y no hay tope de 3 números/3 correos todavía (decisión pendiente: bloquear con
    alerta + devolver data actual, o permitir sin límite como hoy).
  - `CRM.CSV_CONTACTO_LST_APP` — task `'D'` (detalle por idNumero), escrito desde cero 2026-07-23
    (el archivo anterior era un placeholder — copia sin terminar de `CSV_LEADS_LST_APP`, nunca
    desplegado). Resuelve `@ID_CONTACTO` vía `T_CONTACTO_NUMERO` activo más reciente para el
    `idNumero` recibido; si no hay contacto, `SELECT ''` → `ApiEmpty` en Flutter → pantalla arranca
    en blanco (modo "crear"). Formato de respuesta documentado en el header de
    `contacto_detalle_model.dart` (Flutter) — los índices de campo ya calzan 1:1, no requirió
    tocar el parser. **UBIGEO** en `T_CONTACTO` es `VARCHAR(6)` (dpto+prov+dis, 2 dígitos c/u) —
    el SP lo parte en 3 al leer; `lead_remote_datasource.dart.guardarContacto` concatena los 3
    niveles de vuelta a 6 caracteres al guardar (`ubigeo` local var).
  - **Área/Cargo de Empresa — combo con sugerencias + texto libre (actualizado 2026-08-03).**
    `AreaItem`/`CargoItem` (`core/models/catalog_item.dart`, partes [18]/[19] del SP
    `CSV_LISTAS_LST_APP`) siguen existiendo y alimentan `CatalogsBloc.areas`/`.cargos`, pero
    **solo como sugerencias** — el valor real que se guarda/muestra es texto libre, nunca un id.
    Pedido explícito de negocio: el combo ayuda al asesor a ver qué ya usaron otros, pero si el
    cargo/área no está en la lista, tipearlo y confirmar con el check del teclado (botón "done")
    lo guarda tal cual. `EmpresaFormRow.area`/`.cargo` (`contacto_form_rows.dart`) son `String`
    (no `AreaItem?`/`CargoItem?`) — mismo tipo que `EmpresaContacto.area`/`.cargo` y
    `ContactoSimple.cargo`, así que no hace falta matchear nada contra el catálogo al cargar
    (`EditContactoPortrait._inicializarCombos`/`EditContactoSimplePortrait._inicializarCombos`
    copian el valor directo). `EditContactoEmpresaSection`/`EditContactoSimplePortrait` usan
    `CustomComboSearchField(allowFreeText: true, initialText: ...)` (ver `core/CLAUDE.md` →
    CustomComboSearchField) en vez de `initialValue`/id.
  - **Backend — bug real corregido 2026-08-03.** El SP de guardado
    (`CRM.CSV_CONTACTO_CUD_APP`, tasks `'U'`/`'US'`) hace tiempo ya escribía en
    `T_EMPRESA_CONTACTO.NOM_AREA`/`NOM_CARGO` (VARCHAR, texto libre) — las columnas
    `ID_AREA`/`ID_CARGO` (enteras) quedaron sin uso en ese SP. Pero el SP de lectura
    (`CRM.CSV_CONTACTO_LST_APP`, tasks `'D'`/`'DS'`) seguía leyendo `ID_AREA`/`ID_CARGO` — dos
    columnas completamente distintas — así que **nada de lo guardado volvía a aparecer al
    reabrir el contacto**. Corregido: ambos tasks ahora leen `NOM_AREA`/`NOM_CARGO` directo (ya
    son texto, sin `CONVERT`). Si en algún momento se reintroduce un catálogo estricto para
    Área/Cargo, hay que decidir de nuevo qué columna es la fuente de verdad — no dejar que
    lectura y escritura apunten a columnas distintas otra vez.
  - `T_EMPRESA` solo tiene una columna `NOMBRE` (no hay "razón social" separada) — el campo
    `razonSocial` del formulario/entidad Flutter es a efectos prácticos un espejo de
    `nombreEmpresa`, ambos se guardan en la misma columna.
  **Catálogos/combos con búsqueda — actualizado 2026-07-23**:
  - Prefijo (saludo Estimado/Estimada) ya usa catálogo real, `PrefijoContactoItem` (parte [20] del
    SP lstListas, hardcodeado del lado del SP igual que Sexo/TipoParticipante — formato plano, un
    solo valor por fila, sin separar id/label). Combo simple (`CustomComboField`, no búsqueda) —
    solo 2-5 opciones fijas, pedido explícito de negocio.
  - Prefijo de celular ya NO usa el paquete `country_picker` (era un modal) — usa
    `CustomComboSearchField` sobre `PaisItem.codigoTelefono`, mismo patrón que
    `SolicitudCampoCelularBusqueda` (`solicitudes/`). `NumeroFormRow.pais` es `PaisItem?`, no
    `Country?`. `agregar_numero_panel.dart` (`edit_lead/`, sin usar) sigue con `country_picker` —
    no se tocó, es código muerto aparte.
  - País (Datos de contacto) y Área/Cargo (Empresa) también pasaron de `CustomComboField` a
    `CustomComboSearchField` — se puede escribir para filtrar en vez de solo desplegar la lista.
  - **Tipo de documento excluye "Sin documento" y RUC** (`valoresDefecto.idTipoDocSnd`/
    `idTipoDocRuc`, filtrados juntos en `build()`) — un contacto es persona natural
    (DNI/CE/Pasaporte/Otros); RUC vive solo en la sección Empresa, con su propio campo y
    autocompletado (pedido de negocio 2026-07-23).
  - **Autocompletado por documento** — mismo servicio que `solicitudes/`
    (`DocumentoExternoService`/`DocumentoExterno`, ver `core/CLAUDE.md`), dispara al perder foco
    el campo Número de documento (`EditContactoPortrait._buscarDocumento`). Prellena
    Nombres/Apellidos/Dirección/País/Nacionalidad solo si vienen vacíos (nunca pisa lo ya
    tipeado), y agrega una fila nueva a la lista de Correos si el documento trae uno que todavía
    no está en la lista.
  - Nacionalidad (Datos de contacto) también pasó a `CustomComboSearchField` (antes
    `CustomComboField`), y se autocompleta a "Peruano" (`valoresDefecto.idNacionalidad`) si el
    contacto no trae una (`_inicializarCombos`), igual que ya hacía País.
  - **Todo texto libre se guarda en MAYÚSCULAS** (pedido de negocio 2026-07-23) — Nombres/
    Apellidos/Dirección (contacto), Correo, Razón social/Dirección (empresa). Doble capa: los
    `CustomTextField` llevan `isUpperCase: true` (feedback visual mientras se tipea) Y
    `EditContactoPortrait._construirContacto()` fuerza `.toUpperCase()` de nuevo al armar el
    payload (helper `_mayus()`) — necesario porque el autocompletado por documento/RUC asigna
    texto directo al controller (`row.nombreCtrl.text = ...`), sin pasar por el formatter del
    widget; sin este segundo forzado, un valor traído por autocompletado se guardaría con el
    casing que devuelva RENIEC/SUNAT. RUC y N° de documento NO llevan mayúscula (numéricos);
    LinkedIn tampoco (URL, sensible a mayúsculas/minúsculas).

  **Empresa — RUC autocompletado, País con búsqueda + default Perú, Ubigeo completo — 2026-07-23.**
  - Orden final de campos en `EditContactoEmpresaSection` (pedido explícito de negocio): País+RUC
    → Razón social → Área+Cargo → Departamento+Provincia → Distrito → Dirección.
  - **RUC** (`EmpresaFormRow.rucCtrl`) usa el mismo patrón de autocompletado por foco que Número
    de documento — `EmpresaFormRow.rucFocus`/`ultimoRucBuscado` (nuevos campos) +
    `EditContactoPortrait._wireRucFocus()`/`_buscarRuc()`, mismo `DocumentoExternoService`.
    Prellena `nombreCtrl`/`razonSocialCtrl` (ambos desde `resultado.nomEmpresa` — recordar que
    `T_EMPRESA` solo tiene una columna `NOMBRE`) y `direccionCtrl`, solo si vienen vacíos.
    Overlay propio `_buscandoRuc` (`AppLoadingOverlay`, mensaje "Buscando datos del RUC...").
  - **País** (antes `TextEditingController` libre) es ahora `EmpresaFormRow.pais` (`PaisItem?`),
    combo `CustomComboSearchField` (mismo `_ComboBusquedaCatalogo<PaisItem>` que ya usa la sección
    Datos). Default a Perú (`valoresDefecto.idPais`) tanto en `_agregarEmpresa()` (fila nueva)
    como en `_inicializarCombos()` (fila cargada del backend con `idPais` vacío).
  - **Ubigeo de empresa** (`EmpresaFormRow.departamento`/`provincia`/`distrito`, `UbigeoItem?`) —
    combos en cascada (`_ComboBusquedaUbigeo`, mismo patrón que la sección Datos), calculados por
    fila dentro de `_EmpresaCard.build()` filtrando `catalogState.ubigeo` por `dpto`/`prov` del
    padre. **Ahora se persiste de verdad** (antes se mandaba `''` fijo al guardar): `T_EMPRESA`
    también es `UBIGEO VARCHAR(6)` (dpto+prov+dis, igual que `T_CONTACTO`) —
    `CSV_CONTACTO_LST_APP` lo parte en 3 al leer (empresa pasó a 12 campos:
    `...¦idDpto¦idProv¦idDis`, ver `empresa_contacto_model.dart`) y
    `lead_remote_datasource.dart.guardarContacto()` lo concatena de vuelta al guardar
    (`'${e.idDepartamento}${e.idProvincia}${e.idDistrito}'`, mismo criterio que `ubigeo` del
    contacto).
  - **Empresas existentes SÍ se actualizan — cambio de negocio 2026-07-24.** Detectado en vivo
    2026-07-23 (reportado como "no sale el ubigeo en la empresa"): el patrón
    `idEmpresaContacto=0`→insert que ya usan números/correos (esos SÍ se dejan intactos si ya
    existen, sigue igual) se había aplicado tal cual a empresas, así que completar País/RUC/
    Ubigeo/Área/Cargo en una empresa que el contacto ya tenía se perdía en silencio al guardar.
    Corregido en `CRM.CSV_CONTACTO_CUD_APP` (bloque "EMPRESAS", `StoredProcedures/` fuera de
    este repo): `idEmpresaContacto=0` sigue insertando (igual que antes); `idEmpresaContacto≠0`
    ahora hace `UPDATE` directo — sobreescribe `T_EMPRESA` (ID_PAIS/RUC/NOMBRE/DIRECCION/UBIGEO)
    y `T_EMPRESA_CONTACTO` (ID_AREA/ID_CARGO) con lo que llega, mismo criterio "de frente el
    update" que ya usa `T_CONTACTO`. Asume columnas `FC_USUARIO_M`/`IP_USUARIO_M`/
    `ID_USUARIO_M`/`LL_USUARIO_M` en ambas tablas — si alguna no las tiene, avisar para
    agregarlas o quitar esas columnas del UPDATE. Todavía sin desplegar a la base real (sigue
    solo en el archivo `.sql` local, como el resto de cambios de esta sesión).
  - **Autocompletado por RUC — le faltaba el `AppLoadingOverlay`, corregido 2026-07-23.**
    `_buscandoRuc` ya existía en el `State` pero el `Stack` de `build()` no tenía la rama
    correspondiente — la búsqueda ocurría pero no bloqueaba la pantalla ni daba feedback visual
    (bug real, mismo patrón que `_buscandoDocumento`, ya corregido).
  - **`ContactoUpdateNotifier`** (`core/utils/contacto_update_notifier.dart`, mismo patrón que
    `LeadUpdateNotifier` pero keyed por `idNumero`) — refresca "Datos" en Conversaciones tras
    editar, agregado 2026-07-23. Bug real detectado en vivo: `ChatDetailPage` resolvía el `Chat`
    (nombre/apellido/empresa/cargo) UNA sola vez en `initState`; al editar el contacto desde
    `DatosTab` y volver, la pestaña seguía mostrando los datos viejos hasta salir de la
    conversación y reentrar. Fix: `EditContactoPortrait._guardar()` llama
    `ContactoUpdateNotifier.instance.notify(idNumero)` en el caso `CrudOk()`;
    `_ChatDetailPageState` (`chat/presentation/pages/chat_detail_page.dart`) se suscribe en
    `initState()` y, si el aviso es del mismo `idNumero` que su `Chat` actual, lo vuelve a pedir
    (`_cargarChat(silencioso: true)`) sin pasar por el loading de pantalla completa — solo
    reemplaza `_chat`, así `ChatDetailView`/`ChatLeadPanel`/`DatosTab` (que leen
    `widget.conversacion` directo, sin cachearlo aparte) quedan con datos frescos sin perder
    scroll ni el estado de los BLoCs de mensajes. Si se agrega otra pantalla que cachee datos de
    contacto derivados de `Chat`/`ContactoDetalle` fuera de un cubit reactivo, suscribirse al
    mismo notifier en vez de inventar uno nuevo.

## EditContactoSimple — pantalla reducida "Editar contacto" (pedido de negocio 2026-07-27)

Alternativa a `EditContacto` (arriba) — **no la reemplaza, sigue existiendo intacta** (queda
sin caller hoy, pero se conserva por si negocio la vuelve a pedir). El jefe del usuario pidió
una pantalla con muchos menos campos y sin la lógica de listas N-celulares/N-correos/N-empresas:
solo tipo/número documento, nacionalidad, **prefijo** (saludo Estimado/Estimada — campo que ya
existía en la pantalla completa, `PrefijoContactoItem`/`CRM.T_CONTACTO.PREFIJO`; se confundió
al armar la primera versión con "Sexo" porque la imagen de referencia venía de
`SeccionDatosSolicitante` en `solicitudes/`, que sí tiene un combo Sexo — corregido 2026-07-27,
esta pantalla nunca tuvo ni necesitó una columna nueva), nombres, apellidos, **un** celular (el
anclado en `idNumero`, no una lista), **un** correo, **una** empresa (RUC/razón social/cargo).
Estructura calcada de `SeccionDatosSolicitante` pero como pantalla propia de `lead/` — no se
reusó el widget de `solicitudes/` (features no comparten widgets de UI entre sí en este
proyecto).

- Ruta `AppRoutes.editarContactoSimple`, `context.goToEditarContactoSimple(idNumero:)`. Recibe
  **solo `idNumero`**, igual que `EditContacto`. Estructura: `EditContactoSimplePage` →
  `EditContactoSimpleView` (BasePage + AppBar dinámico + guardandoNotifier, mismo patrón que
  `EditContactoView`) → `EditContactoSimplePortrait` (`presentation/widgets/edit_contacto_simple/`).
  Título dinámico igual que la pantalla completa. El combo Prefijo usa el mismo
  `CustomComboField<PrefijoContactoItem>`/`CatalogsBloc.prefijosContacto` que ya usa
  `EditContactoDatosSection` — no es un catálogo nuevo, es el mismo campo con el mismo widget.
- **Entidad propia `ContactoSimple`** (`domain/entities/contacto_simple.dart`) — no se tocó
  `ContactoDetalle` ni sus sub-entidades (`NumeroContacto`/`CorreoContacto`/`EmpresaContacto`).
  Campos: `idContacto`, `idNumero` (ancla), `idTipoDocumento`, `numeroDocumento`,
  `idNacionalidad`, `prefijoContacto` (saludo, `String` — igual que en `ContactoDetalle`, sin
  id/label separado), `nombre`, `apellidoPaterno`, `apellidoMaterno`, `prefijoCelular` +
  `celular` (uno solo), `idCorreo` + `correo` (uno solo), `idEmpresaContacto` + `ruc` +
  `razonSocial` + `cargo` (texto libre, una sola empresa — renombrado desde `idCargo` el
  2026-08-03, nunca fue un id). **No tiene** país/ubigeo/dirección/linkedin/
  sexo/área — esos campos son exclusivos de la pantalla completa y no se muestran acá.
- **`ContactoSimpleFormCubit`** (`bloc/contacto_simple_form/`) — mismo patrón exacto que
  `ContactoFormCubit` (cargar por `idNumero` / guardar), pero contra el repositorio nuevo.
- **Backend — mismos 2 SPs de siempre, tasks nuevos, agregados el 2026-07-27**
  (`D:\Proyectos\NatCodee\NC.SQLChangeLock\DBEAN\StoredProcedures\`, repo aparte — `.sql` de
  CUD en UTF-16LE con BOM, el de LST en UTF-8; cualquier edición futura debe preservar la
  codificación de cada uno o SSMS los muestra corruptos):
  - `CRM.CSV_CONTACTO_LST_APP` — nuevo task `'DS'` (detalle simple por `idNumero`). Devuelve
    9 campos de contacto (incluye `PREFIJO`, columna que ya existía) + a lo más 1 fila de
    celular (el que matchea el `idNumero` ancla)/correo(el primero activo)/empresa(la primera
    vinculada). Mismo criterio que `'D'` para resolver `@ID_CONTACTO` desde
    `T_CONTACTO_NUMERO`; si no hay contacto, `SELECT ''` → `ApiEmpty` → pantalla en blanco
    (modo "crear"), igual que `'D'`.
  - `CRM.CSV_CONTACTO_CUD_APP` — nuevo task `'US'` (crear/actualizar simple). Mismo endpoint
    (`urlContactoCud`, es el mismo SP) que `'U'` — solo cambia la letra de task. Reusa las
    mismas tablas temporales (`@T_NUMEROS`/`@T_CORREOS`/`@T_EMPRESAS`/etc.) y la misma lógica de
    alta-si-no-existe para número/correo, y alta-o-`UPDATE` para empresa (mismo criterio "de
    frente el update" agregado a `'U'` el 2026-07-24) — con listas de a lo más 1 fila, la
    lógica genérica de N filas ya funciona sin cambios. Sí escribe `PREFIJO` (columna que ya
    existía, `@PREFIJO_US`) tanto al crear como al actualizar — **nunca toca**
    `ID_PAIS`/`DIRECCION`/`UBIGEO`/`LINKEDIN`/`ID_AREA` de un contacto o empresa ya existente
    (esos sí son exclusivos de la pantalla completa) — un guardado desde acá no debe borrar lo
    que el usuario ya tenía cargado desde ahí.
  - **No se agregó ninguna columna nueva a la base** — la primera versión (misma sesión)
    intentó agregar `SEXO` a `T_CONTACTO` con un `ALTER TABLE` guardado, pero era un error de
    interpretación de la imagen de referencia (ver arriba); se quitó por completo de ambos SPs
    antes de que nadie llegara a ejecutarlos contra la base real.
  - Task `'D'`/`'U'` (pantalla completa) **no se modificaron**.
  - **Único call site real movido a la pantalla simple**: el botón "Crear/Editar contacto" de
    `DatosTab` (`chat/`, panel de Conversaciones) — antes `context.goToEditarContacto`, ahora
    `context.goToEditarContactoSimple`. Es el único lugar de toda la app que llamaba a
    `goToEditarContacto` — la pantalla completa queda sin ningún caller por ahora (a propósito,
    el usuario pidió conservarla para el futuro), pero la ruta/página/bloc siguen intactos y
    navegables si se agrega otro punto de entrada.
  - **Pendiente** — no se agregó autocompletado de RUC por documento/viceversa entre pantallas
    — cada una tiene su propio flujo de `DocumentoExternoService` independiente, sin compartir
    el último documento buscado. Los `.sql` de esta pantalla siguen sin desplegarse a la base
    real (igual que el resto de cambios pendientes documentados en este archivo).

  - **Celular/Prefijo bloqueados — 2026-07-28.** `EditContactoSimplePortrait` ahora renderiza
    "Prefijo"/"Celular" con `enabled: false` (antes editables, sin bloqueo real). Decisión
    explícita de negocio: `idNumero` es el ancla de toda la pantalla — ese celular nunca se
    edita desde acá (para eso está la lista de N celulares de `EditContacto`, pantalla
    completa). Motivo real: el SP (`CSV_CONTACTO_CUD_APP`, task `'US'`) resuelve el bloque
    NÚMERO por (prefijo, número) contra `T_NUMERO`, no por id — si el texto cambiaba, insertaba
    un `T_NUMERO`/`T_CONTACTO_NUMERO` nuevo **sin desactivar el anterior**, dejando al contacto
    con 2 celulares activos y el `idNumero` ancla huérfano. No se tocó el SP para esto — con el
    campo bloqueado, el valor enviado siempre es el mismo que se cargó, así que ese bloque del
    SP queda como no-op seguro.

  - **Correo — actualiza en sitio en vez de duplicar, corregido 2026-07-28.** El bloque CORREO
    de `CSV_CONTACTO_CUD_APP` task `'US'` comparaba por **texto** (`CO.CORREO = TC.CORREO`) para
    decidir si insertar — si el usuario cambiaba el texto del correo, no matcheaba con el
    guardado, así que insertaba una fila nueva **dejando la anterior activa también** (bug real
    reportado en vivo: el contacto terminaba con 2 correos activos). Corregido: ahora decide por
    `ID_CONTACTO_CORREO` (0/NULL = fila nueva, se inserta; con valor = ya existe, se hace
    `UPDATE ... SET CORREO = ...` en sitio) — mismo criterio de "id decide, no texto" que ya usa
    el resto del SP. Distinto del task `'U'` (pantalla completa), que sigue congelando correos
    ya guardados sin tocarlos (decisión de negocio previa, 2026-07-23, no se modificó).

  - **Empresa — el RUC decide "misma empresa" vs "empresa distinta", corregido 2026-07-28.**
    Bug real reportado en vivo: con `idEmpresaContacto<>0` (empresa ya vinculada), el SP hacía
    `UPDATE` directo sobre `T_EMPRESA` con lo que llegara, **sin comparar el RUC**. Si el asesor
    cambiaba el RUC a una empresa distinta (ej. de "NATCODE" a "GC1"), el SP sobreescribía en
    sitio la fila compartida de `T_EMPRESA` — como esa tabla es una sola fila por empresa
    referenciada por todos sus contactos, el cambio afectaba a cualquier otro contacto vinculado
    a la empresa anterior, no solo al que se estaba editando.
    Corregido en `CRM.CSV_CONTACTO_CUD_APP` (task `'US'`, bloque EMPRESA): ahora compara el RUC
    que llega contra el RUC de la empresa que ya tenía la conexión — **RUC igual** → sigue
    actualizando en sitio (razón social/cargo, mismo criterio "de frente el update" de siempre).
    **RUC distinto** (o conexión nueva, `idEmpresaContacto=0`) → resuelve la empresa por RUC
    (reusa si ya existe una `T_EMPRESA` con ese RUC — nunca pisa su `NOMBRE`, es fila compartida
    — o la crea si no existe) y crea una conexión `T_EMPRESA_CONTACTO` **nueva**, desactivando
    (`IB_ACTIVO=0`) la conexión anterior — la empresa anterior en sí nunca se toca. Ajustado en
    conjunto con `CRM.CSV_CONTACTO_LST_APP` (task `'DS'`): la consulta de empresa ahora filtra
    `EC.IB_ACTIVO = 1` y ordena `DESC` (antes no filtraba activo y ordenaba ascendente — con la
    conexión anterior desactivada pero no eliminada, sin este fix habría seguido devolviendo la
    empresa vieja en vez de la nueva). Mismo criterio "vínculo activo más reciente" que ya usan
    número/correo y la resolución de `@ID_CONTACTO` del propio SP. Task `'U'`/`'D'` (pantalla
    completa) **no se tocaron** — tienen el mismo patrón de UPDATE-sin-comparar-RUC ahí también
    (el flujo de lista de N empresas no tiene el mismo concepto de "conexión anterior" a
    desactivar), pero esa pantalla no tiene caller hoy, así que no era el foco de este fix;
    queda pendiente si se reactiva.
    Los 3 archivos (`edit_contacto_simple_portrait.dart`, `CSV_CONTACTO_CUD_APP.sql`,
    `CSV_CONTACTO_LST_APP.sql`) siguen sin desplegarse a la base real, como el resto de cambios
    de `EditContactoSimple` documentados en este archivo.

## BLoCs / Cubits
- `LeadListBloc` (list/) → carga leads por tipo, filtra en memoria; conteos por filtro (usa `idEstadoPadre` para agrupar sub-estados bajo su padre)
- `LeadDetalleBloc` (detail/) → carga detalle + comentarios de un lead por `idLead`

## Widgets principales
- `LeadListView` (list/) → vista principal: AppBar simple (solo drawer + título, sin buscar ni popup) + banner de subtítulo "Gestiona el avance de tus casos"; muestra `LeadListSkeleton` en loading
- `LeadListSkeleton` (list/) → skeleton de carga de la lista: chips placeholder + 7 cards placeholder
- `LeadListPortrait` (list/) → StatelessWidget: chips + `LeadListStatsRow` + lista de `LeadCard`s en el orden que entrega el bloc (sin selector de orden — descartado por decisión de negocio)
- `LeadListStatsRow` (list/) → 3 tarjetas resumen (Nuevos / En gestión / Listos para propuesta) con conteos de `LeadListBloc`; mismo tamaño en las 3 (`IntrinsicHeight` + `CrossAxisAlignment.stretch`), orden interno: ícono → etiqueta → número (coloreado azul/verde/morado) → palabra "casos" fija
- `LeadCard` (list/) → compacta, borde izquierdo por estado efectivo. Avatar chico (`avatarRadiusSm`, mismo estilo que `ChatTile` de Conversaciones — color por nombre + `AppIcons.user`, sin iniciales ni badge de canal) a la izquierda; a su derecha 3 líneas: (1) nombre + ícono de canal inline (sin texto/pill, `AppSocialUtils.widgetCanalById`) ... fecha alineada a la derecha; (2) oportunidad (`lead.evento`, negrita chica) ... "Hace X" + chip de estado (el chip siempre comparte esta fila con hace-X, nunca va solo en su propia línea); (3) empresa (`lead.nombreEmpresa`, sin negrita). Debajo, `LeadCardActions` en fila.
  **"Hace X" (arriba, junto al chip de estado)** — ya no muestra la fecha/hora
  (`fechaHoraInteraccion.formatConDia()`) encima; esa línea se quitó por pedido
  explícito de negocio. En su lugar, `AppIcons.tap` (ícono chico,
  `AppSizing.iconInline` = 12dp, mismo color que el texto vía
  `ElapsedTimeUtils.colorFromElapsed`) precede al texto "Hace X" — insinúa que
  la card es tappable, sin agregar un gesto propio (la card completa ya
  navega a detalle con `onTap`).
- `LeadCardActions` (list/) → 2 botones chicos en fila (`AppSizing.miniActionButton` = 32dp): WhatsApp cuadrado (ícono only) + "Ver detalle" con borde y texto en `colorScheme.primary`. El menú "⋯" (favorito / abrir chat) se quitó — `ToggleFavoritoPressed` sigue viva en `LeadListBloc` pero sin trigger de UI en la lista por ahora.
  **Botón WhatsApp — 3 estados, calculados en `_LeadDateAndActions._tiempoChatAbiertoVencido()` (`lead_card.dart`) y pasados como props (`mostrarWhatsApp`/`whatsAppVencido`):**
  - Oculto (`mostrarWhatsApp: false`) si `lead.numero.idChatCab == 0` — el número nunca tuvo conversación, no solo deshabilitado, no se renderiza.
  - Verde (`AppSocialUtils.colorCanal('whatsapp')`) si tiene `idChatCab` y todavía no se superó la ventana de chat abierto (TDE) medida desde `lead.numero.fechaPrimerMensajeCliente` (fecha del primer mensaje del CLIENTE en esa conversación — **no** es el mismo dato que el "Hace X" de arriba, que usa `fechaHoraInteraccion`/última interacción).
  - Gris (`AppColors.textDisabled`, `whatsAppVencido: true`) si tiene `idChatCab` pero ya se superó esa ventana.
  El cálculo (`_tiempoChatAbiertoVencido()`) es una copia exacta de `ChatInputBar._tiempoChatAbiertoVencido()` en `chat/`: mismo límite `ConfiguracionService().tiempoChatAbierto` (grupo TDE, horas, default 15h si no carga) — no hardcodear el valor. Si no hay fecha (`fechaPrimerMensajeCliente` vacío), se considera no vencido (igual que en `ChatInputBar`).
  `Numero.fechaPrimerMensajeCliente` viene del SP `[CRM].[CSV_LEADS_LST_APP]` task `'LS'` — campo agregado al final (índice 37) vía `OUTER APPLY` sobre `CRM.T_CONVERSACION_DET` (`DIRECCION='CLI'`, `MIN(FC_USUARIO_C)`) keyed por `CCU.ID_CONVERSACION_CAB`. Solo se agregó a `'LS'`; el task `'DT'` (detalle de un lead puntual) no lo trae — si algún día se necesita ahí también, replicar el mismo `OUTER APPLY` y actualizar `NumeroModel.fromFields`/`NegociacionModel.fromDetalleRawString`.
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
- Task `'LHN'` (`obtenerHistorialSeguimientoPorContacto(idContacto)`) → seguimiento de **todos los
  leads activos del mismo contacto** (`LD.ID_CONTACTO`, ver migración abajo — antes era
  `T_NUMERO_LEAD`/`ID_NUMERO`). Es el único llamado que usa `HistorialTab`
  (`presentation/widgets/lead_detail_sheet/tabs/historial_tab.dart`, único parámetro `idContacto`,
  requerido) — mismo call en `ContactoDetalleView` (`HistorialTab(idContacto: lead.idContacto)`,
  Seguimiento) y en `ChatLeadPanel` (`HistorialTab(idContacto: widget.chat.idContacto)`,
  Conversaciones). Unificado 2026-07-20 a pedido explícito de negocio: "ambos son lo mismo" — antes
  Conversaciones usaba `'LH'` (por lead puntual) y Seguimiento pasó primero por `'LCG'` y luego por
  `'LH'` también, hasta terminar acá los dos. `'LH'` (por lead) y `'LCG'` (por contacto, agrupando
  `T_LEAD_COMENTARIO` con ícono/color de actividad y usuario nominal) se eliminaron por completo del
  cliente — sin caller, no había motivo para mantenerlos. El SP real conserva ambos tasks (`'LH'` y
  `'LCG'`) por si se vuelven a necesitar del lado del backend, pero el cliente Flutter ya no los
  invoca.
- `HistorialComentarioModel.parseListSeguimiento`/`fromRawStringSeguimiento` parsean la respuesta de
  `'LHN'` (7 campos posicionales — ver comentario en el modelo).

## Migración de ancla ID_NUMERO → ID_CONTACTO (2026-08-03, completa)

Decisión de negocio: un lead ya no se conecta por `ID_NUMERO` (el número de teléfono podía
cambiar/duplicarse) — ahora ancla en `ID_CONTACTO`, porque **un lead siempre tiene un contacto**.
`CRM.T_LEAD` tiene columna `ID_CONTACTO` directa (usada por `CSV_LEADS_CUD_APP` task `'U'` desde
antes de esta fecha; el viejo INSERT a `T_NUMERO_LEAD` en creación ya estaba comentado ahí).

- **Bug real corregido (escritura)**: `Negociacion` no tenía campo `idContacto` — `EditLeadPortrait`/
  `InfoLeadCubit.updateLead` mandaban `idNumero` como `field1` a `CSV_LEADS_CUD_APP` task `'U'`,
  que lo parsea como `@ID_CONTACTO` y lo graba directo en `T_LEAD.ID_CONTACTO`: se estaba
  guardando el id del NÚMERO donde la tabla espera el id de CONTACTO. Corregido de punta a punta:
  `Negociacion.idContacto` (nuevo campo) → `InfoLeadCubit.updateLead` ahora recibe `idContacto` (no
  `idNumero`) → `UpdateLeadInfoUseCase`/`LeadRepository.updateNegociacion`/
  `LeadRemoteDatasource.updateNegociacion` renombrados en cadena, mandan `idContacto` como `field1`.
  El SP no necesitó cambios (ya esperaba `@ID_CONTACTO` ahí).
- **Lectura, migrada también** — `CSV_LEADS_LST_APP` (`NC.SQLChangeLock`, fuera de este repo):
  tasks `'LS'`, `'LN'`, `'LHN'`, `'LCG'` y `'DN'` ahora anclan en `CT.ID_CONTACTO`/`LD.ID_CONTACTO`
  en vez de `T_NUMERO`/`T_NUMERO_LEAD` (que dejó de recibir INSERTs al crear un lead). `'DT'`
  también se corrigió: resolvía el contacto vía `T_NUMERO_LEAD`/`T_NUMERO` (tabla ya sin datos
  nuevos), ahora usa `LD.ID_CONTACTO` directo. `T_NUMERO`/`T_CONTACTO_NUMERO` se siguen usando solo
  para mostrar "el número del contacto" (dato secundario, resuelto por el vínculo activo más
  reciente), nunca para resolver el lead.
  - `Negociacion.idContacto` se parsea de `CT.ID_CONTACTO` en `NegociacionModel.
    fromDetalleRawString` (tasks `'DT'`/`'DN'`) y en `ContactoNegociacionModel.fromRawString`
    (task `'LS'`); en `'LN'` se agregó como literal `@ID_CONTACTO` al final de la fila (columna 25,
    sin JOIN — el SP ya conoce el valor porque es el parámetro de entrada de ese task).
  - Cliente Flutter renombrado en cadena: `LeadRepository.getLeadDetallePorContacto`/
    `obtenerNegociaciones`/`obtenerHistorialSeguimientoPorContacto` (antes `...PorNumero`) →
    `GetLeadDetallePorContactoUseCase`/`GetNegociacionesLead`/`GetHistorialSeguimientoPorContacto`
    → `InfoLeadCubit.cargarPorIdContacto`/`NegociacionesCubit.cargarNegociaciones`/
    `HistorialLeadCubit.cargarHistorialPorContacto` → widgets `HistorialTab`/`NegociacionesTab`/
    `ContactoNegociacionesTab` (prop `idContacto`, antes `idNumero`) → `ContactoDetallePage`/
    `ContactoDetalleView` (prop `idContacto`) → ruta `AppRoutes.detalleContacto`
    (`context.goToDetalleContacto(idContacto:)`, antes `idNumero`) → único caller real,
    `lead_list_portrait.dart` (`lead.contacto.idContacto`, antes `lead.numero.idNumero`).
    `ChatLeadPanel` (Conversaciones) usa `widget.chat.idContacto` para `NegociacionesTab`/
    `HistorialTab` — `Chat` ya traía `idContacto` propio, sin necesidad de threading extra.
  - **No tocado a propósito** — `ContactoFormCubit`/`ContactoSimpleFormCubit.cargarPorIdNumero`
    (`EditContacto`/`EditContactoSimple`) siguen ancladas en `idNumero`: son otro SP por completo
    (`CSV_CONTACTO_LST_APP`/`CUD_APP`), donde `idNumero` sigue siendo el ancla correcta de esa
    pantalla (edita el contacto vinculado a ESE número puntual) — no forma parte de esta migración.
- **Bug real corregido de paso (mismo SP, mismo pase 2026-08-03) — Cargo dejó de ser
  `CT.ID_CARGO`.** Al reestructurar los JOINs de empresa (`LS`/`DT`/`DN`) para anclar en
  `CT.ID_CONTACTO`, se detectó que el cargo del contacto se leía de `T_CONTACTO.ID_CARGO` — una
  columna entera (id crudo sin catálogo) — cuando el cargo real es texto libre y vive en
  `T_EMPRESA_CONTACTO.NOM_CARGO` (mismo criterio que ya se corrigió en `CSV_CONTACTO_LST_APP`, ver
  nota "Área/Cargo de Empresa" más arriba en este archivo) — un contacto puede tener cargos
  distintos en empresas distintas, no tiene sentido que el cargo viva en el contacto mismo.
  Corregido: la resolución de empresa (antes `LEFT JOIN T_EMPRESA EM ON EM.ID_EMPRESA = (subquery
  TOP 1 EM2.ID_EMPRESA)`) pasó a `OUTER APPLY` (alias `ECX`) que trae `EM2.ID_EMPRESA` +
  `CE2.NOM_CARGO` juntos, y el campo de salida (columna 32, sin cambiar el índice) ahora es
  `ISNULL(ECX.NOM_CARGO,'')` en vez de `CT.ID_CARGO`. Del lado Flutter, el índice no cambió
  (`NegociacionModel.fromDetalleRawString`/`cargo: fields[32]` sigue igual) — solo se corrigió el
  comentario (decía "ya es texto libre" de forma incorrecta/adelantada) y se habilitó
  `ContactoModel.cargo` (antes deliberadamente sin parsear "para no mostrar un número donde se
  espera un puesto" — ya es seguro parsearlo). `Negociacion.cargo` no cambió de tipo (ya era
  `String`), solo la fuente real del dato.

## Revisión de CRM.CSV_CONTACTO_LST_APP / CUD_APP (2026-08-03) — ya estaban bien

A diferencia de `CSV_LEADS_LST_APP`/`CUD_APP`, acá **no había bug de conector** — se revisaron ambos
SPs completos (`NC.SQLChangeLock`, fuera de este repo) y `idContacto` ya es el ancla real en los
dos. Solo se dejó documentado, sin tocar el formato de campos (decisión explícita: cero riesgo de
desincronizar cliente/SP mientras no haya un motivo real para tocarlo):

- **LST (tasks `'D'`/`'DS'`)** — correcto por diseño: `idNumero` se usa **una sola vez**, al
  principio de cada task, para resolver `@ID_CONTACTO` vía `T_CONTACTO_NUMERO` (vínculo activo más
  reciente). Todo lo demás (`T_CONTACTO`, `T_CONTACTO_CORREO`, `T_EMPRESA_CONTACTO`, la lista
  completa de números) ya resuelve por `@ID_CONTACTO`. Tiene sentido que sea así: `EditContacto`/
  `EditContactoSimple` siempre se abren DESDE un número (una conversación de WhatsApp), nunca desde
  un contacto ya identificado — `idNumero` como punto de entrada es intencional, no legacy.
- **CUD (tasks `'U'`/`'US'`)** — `idContacto` ya ancla crear/actualizar (`0` = crear). Se encontró
  **código muerto** (marcado con `⚠️`, no eliminado): `@ID_NUMERO` (`field1` de `datosContacto` en
  ambos tasks) se parsea pero nunca se usa en el cuerpo del SP — ni para identificar el contacto
  (eso es `@ID_CONTACTO`) ni el número (eso es `PREFIJO_PAIS`+`NUMERO`, texto, no id). En `'US'` el
  propio SP ya comentaba esto ("`idNumero(sin uso acá)`") para el `idNumero` de la fila de número
  también (`field1` de `datosNumero`). El cliente Flutter (`guardarContacto`/
  `guardarContactoSimple`, `lead_remote_datasource.dart`) sigue mandando esos campos por
  compatibilidad de formato con el SP — quitarlos correría los índices de los campos siguientes en
  2 tasks del SP + 2 métodos Dart en paralelo, más riesgo que beneficio sin un motivo real para
  hacerlo ahora.

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

- **Moneda**, **Precio base** y **Descuento** nunca son editables por el usuario, en ningún origen
  ni pantalla — `EditLeadFinancieraSection` los renderiza siempre `enabled: false`. Moneda y Precio
  base se autocompletan al elegir Oportunidad (`item.idMoneda`/`item.importeGeneral`, ambos en
  `_onOportunidadChanged`); Descuento se autocalcula como `subtotal - costoFinal`. El único campo
  editable de esa fila es **Costo final** (`_costoFinalCtrl`) — ya no existe el toggle
  `costoFinalEditable`, es el comportamiento único. `EditLeadFinancieraSection` ya no recibe
  `onMonedaChanged` — al quedar siempre `enabled: false` el combo nunca dispara `onChanged`, así
  que el callback quedaba muerto y se eliminó.
- **`_onOportunidadChanged` también resetea Costo final al subtotal** (`precioBase × cantidad`),
  no solo Precio base — bug real detectado en vivo: al cambiar de Oportunidad, Costo final se
  quedaba en su valor anterior (0/vacío en negociación nueva), y como Descuento = subtotal -
  costoFinal, el Descuento mostrado terminaba siendo igual al precio base completo en vez de 0.
  Con el fix, al elegir Oportunidad Costo final arranca igual al subtotal (Descuento = 0) y el
  usuario lo baja manualmente si corresponde un descuento real.
- **Mismo reset de Costo final al cambiar Cantidad** — `_cantidadCtrl` tiene un listener
  (`_onCantidadChanged`, agregado en `initState()`) que recalcula Costo final = `precioBase ×
  nuevaCantidad` cada vez que cambia el texto de Cantidad. Bug real detectado en vivo: al editar
  una negociación con Costo final ya puesto a mano (ej. 100) y luego subir Cantidad, el subtotal
  crecía pero Costo final se quedaba congelado en 100, así que Descuento (subtotal - costoFinal)
  se inflaba solo por el cambio de cantidad, sin que hubiera un descuento real. El reset solo se
  dispara por cambios del usuario en el campo (el valor inicial cargado desde la negociación, con
  su descuento real ya guardado, no se toca — el listener se registra después de setear el texto
  inicial en `initState()`).
- El combo de Moneda sigue actualizando su **valor visible** cuando cambia `_monedaItem` (aunque
  esté deshabilitado) gracias al fix de `CustomComboField.didUpdateWidget` en `core/CLAUDE.md` —
  sin ese fix, un combo con `enabled:false` y `initialValue` cambiante quedaría visualmente
  congelado en el primer valor que tuvo.
- **Campaña/Oportunidad** solo son editables al **crear** (`negociacion.idLead == 0`), sin
  importar el origen — al editar una negociación ya existente quedan siempre bloqueadas
  (`campaniaOportunidadBloqueada: !_esNuevo` en `_EditLeadPortraitState.build()`).
- **Cantidad** arranca en `1` por defecto al crear (antes quedaba en 0/blanco) — ver
  `initState()._cantidadInicial`.
- Para **crear** una negociación son obligatorios Estado, Campaña, Oportunidad, Canal, Moneda y
  Cantidad (Subestado nunca) — el botón Guardar no se habilita hasta tenerlos completos
  (`_puedeGuardar` / `_camposObligatoriosCompletos`, reemplaza a `_hayCambios` como gate del
  `FormSaveBar` cuando `_esNuevo`). Los labels llevan `(*)` en
  `EditLeadNegociacionSection`/`EditLeadFinancieraSection`.
- **Estado/Subestado SIEMPRE fijos en "Nuevo" (id `'00'`) al crear** (`negociacion.idLead == 0`),
  **en cualquier origen** — no solo desde conversación, y el combo queda **bloqueado**
  (`enabled: false`), no editable. Decisión explícita de negocio: toda negociación nace en Nuevo
  y el usuario no la puede mover de estado hasta guardarla (recién al editar se puede mover de
  estado). Bug real detectado en vivo antes de este fix: la negociación en blanco
  (`InfoLeadCubit.prepararNuevaNegociacion()`) trae `idEstado: ''`, y fuera de conversación
  (`ContactoNegociacionesTab` de Seguimiento, que no manda `desdeConversacion`) el combo Estado
  quedaba sin seleccionar y editable en vez de fijo en Nuevo. El valor vive en
  `_inicializarCombos()` (`if (_esNuevo)`) y el bloqueo en `build()`
  (`estadoBloqueado: _esNuevo`) — ninguno de los dos depende ya de `desdeConversacion` (ver flag
  abajo, que ahora solo controla Canal).
- **Redirect automático a "Generar solicitud"** — en `_guardar()`: si el guardado deja la
  negociación en sub-estado `'05'` bajo estado padre `'04'` (Ganada) **por primera vez** (no si ya
  estaba ahí antes de este guardado) y todavía no tiene solicitud (`negociacion.accionSolicitud ==
  SolicitudAccion.generar`), y el servidor confirmó el guardado (`InfoLeadCubit.updateLead` ahora
  retorna `bool`, `true` solo en el caso `CrudOk`), se navega directo a
  `context.goToFichaCompletarSolicitud(...)` con una `Solicitud` en blanco — mismo patrón exacto
  que el botón manual "Generar solicitud" de `NegociacionCard`/`ContactoNegociacionCard` (ver
  comentario en `negociaciones_tab.dart._generarSolicitud`): `idSolicitud: ''`, el `Solicitud` en
  sí sigue con todos sus campos de contacto vacíos (`idLead` es el único que sí lleva un valor
  real, tomado del estado del cubit tras guardar — importante si la negociación se creó recién en
  este mismo guardado), pero desde 2026-07-15 se agregaron **12 parámetros más** a
  `goToFichaCompletarSolicitud` que sí llevan datos reales de `Negociacion` para sembrar el
  wizard (`SolicitudFormCubit.sembrarDatosNegociacion`, ver `solicitudes/CLAUDE.md` → "Más datos
  de la negociación se prellenan en el paso 1" y "RUC de la negociación + fix real de
  arquitectura"): los 4 que ya bloquean edición (`cantidadNegociacion`/`precioBaseNegociacion`/
  `descuentoNegociacion`/`idMonedaNegociacion`) más 8 nuevos que solo prellenan sin bloquear
  (`nombresNegociacion`/`apellidoPaternoNegociacion`/`apellidoMaternoNegociacion`/
  `nombreEmpresaNegociacion`/`correoNegociacion`/`celularNegociacion`/
  `celularCodigoTelefonoNegociacion`/`rucNegociacion`) y uno más solo para validación de
  consistencia (`precioTotalNegociacion`, nunca se muestra ni bloquea nada). **Cargo quedó
  fuera** — llega como id crudo sin catálogo (`CT.ID_CARGO`), nunca parseado; resolverlo de
  verdad necesita un catálogo nuevo, no solo threading del lado del cliente. **RUC sí se agregó**
  (`Negociacion.ruc`, `CRM.T_EMPRESA.RUC` — ver `solicitudes/CLAUDE.md`).
  **Ojo — `Negociacion.ruc`/`nombres`/`apellidoPaterno`/`apellidoMaterno`/`nombreEmpresa`/
  `correo` solo los trae el SP de detalle (`'DT'`/`'DN'`) — el de historial (`'LN'`, el que
  alimenta `NegociacionesCubit`) no hace join con `T_CONTACTO`/`T_EMPRESA`/`T_CONTACTO_CORREO`,
  esos campos quedan `''` en cualquier `Negociacion` que venga de ahí.** Por eso
  `ContactoNegociacionCard`/`NegociacionesTab` (los 2 orígenes que usan `NegociacionesCubit`) NO
  usan el objeto `Negociacion` que ya tienen en memoria para armar estos parámetros — antes de
  navegar, hacen una llamada fresca a `GetLeadDetalleUseCase(idLead)` (task `'DT'`, mismo que ya
  usa `_irAEditar`) y usan ESE resultado para todo (contacto + financiero), mostrando
  `AppLoadingOverlay` mientras tanto (`ContactoNegociacionCard` se convirtió de
  `StatelessWidget` a `StatefulWidget` solo para esto). `EditLeadPortrait`'s `widget.negociacion`
  ya viene de `InfoLeadCubit` (`'DT'`/`'DN'`) en todos sus caminos, así que ese origen no
  necesita la llamada extra — usa `n.*` directo.

### Flag `desdeConversacion`

Viaja `context.goToEditarLead(desdeConversacion: true)` → `AppRoutes.detalleEditarLead` →
`EditLeadPage` → `EditLeadView` → `EditLeadPortrait`, y se activa solo cuando se entra desde el
AppBar de `ChatDetailView` (Conversaciones). Restringe además:

- **Canal** siempre bloqueado, fijo en WhatsApp — tanto al crear como al editar.
- **Interés** siempre editable.

**Ojo — Estado/Subestado fijos en "Nuevo" al crear ya NO depende de este flag** — es una regla
universal (`estadoBloqueado: _esNuevo` en `build()`, ver "Reglas universales" arriba), se aplica
en cualquier origen. `desdeConversacion` hoy solo controla Canal (siempre) e Interés (siempre
editable, listado más por completitud que por restricción real).

**Ojo — Estado/Canal bloqueados se renderizan con el MISMO `CustomComboField` que el resto de
combos, solo con `enabled: false`** (`estadoBloqueado`/`canalBloqueado` en
`EditLeadNegociacionSection`) — ya no existe una rama con `CustomTextField` y texto hardcodeado
("Nuevo"/"WhatsApp" como literal). Se probó y se descartó esa rama especial: el temor original era
que `CustomComboField` solo lee `initialValue` en su propio `initState()`
(`custom_combo_field.dart`), así que si el valor forzado se calculaba después del primer build del
combo quedaría vacío pese a `enabled: false` — pero en la práctica `_inicializarCombos` corre en
`didChangeDependencies`, **antes** de que `EditLeadPortrait.build()` construya por primera vez
`EditLeadNegociacionSection` (el propio `build()` retorna `AppLoadingView` mientras
`CatalogsLoaded` no esté listo), así que el combo siempre nace con el `initialValue` ya matcheado.
El VALOR que se guarda **siempre sale de matchear por id contra el catálogo en
`_inicializarCombos`** — nunca un literal hardcodeado en `_guardar()`:

- Canal: `_canal = state.canales.where((e) => e.id == _idCanalWhatsApp).firstOrNull` — SOLO por id
  (const privada del archivo, valor **5**, confirmado en vivo; NUNCA matchear por nombre —
  decisión explícita del usuario, "por algo te estoy dando los IDs").
- Estado: `_estado = state.estados.where((e) => e.id == '00').firstOrNull` (sin exigir `esPadre` en
  `_inicializarCombos`, pero el combo de Estado sí filtra `data` por `esPadre` — si '00' no viniera
  marcado `esPadre` en el catálogo, el combo se vería vacío pese a `_estado` estar seteado; no
  detectado en vivo, asumido correcto por ahora).
- Si el id no matchea (dato de catálogo raro), `_estado`/`_canal` quedan `null`, el combo se ve
  vacío (comportamiento nativo de `CustomComboField` cuando `initialValue` no matchea ningún item
  de `data`) y Guardar se deshabilita (`_camposObligatoriosCompletos`) — nunca se guarda con un
  valor vacío o inventado.

**Ojo — el `1=WhatsApp` que documenta la tabla de Canales más abajo en este mismo archivo (sección
`core/CLAUDE.md`) está desactualizado/es incorrecto** — el id real es `5`. Solo se corrigió en
`edit_lead_portrait.dart` (`_idCanalWhatsApp`); otros usos del literal `1` para WhatsApp en el resto
de la app (ej. `AppSocialUtils.colorCanalById(1)` en `contacto_acciones_footer.dart`, `LeadCardActions`)
**no se tocaron todavía** — quedan pendientes de auditar/corregir en una tarea aparte.

Si se agrega un nuevo origen que también deba usar el modo restringido de conversación, reusar el
flag `desdeConversacion` — no crear uno paralelo.

**Ojo — todos los puntos de entrada dentro de `ChatLeadPanel` (Conversaciones) deben propagar el
flag, no solo el tap del AppBar.** `ChatLeadPanel` (`chat/presentation/widgets/chat_detail/`)
monta 3 tabs — `DatosTab`, `NegociacionesTab`, `HistorialTab` — y **las dos primeras navegan a
`EditLeadPage` por su cuenta**, sin pasar por `ChatDetailView`. Bug real detectado en vivo: esos
dos tabs olvidaban `desdeConversacion: true` y el usuario podía editar Estado/Subestado/Canal
libremente al crear/editar desde ahí, pese a que el AppBar de `ChatDetailView` sí lo bloqueaba
correctamente. Corregido en los 3 sitios — si se toca cualquiera de estos archivos, verificar que
siga mandando el flag:

- `lead_detail_sheet/tabs/datos_tab.dart` → botón "Crear/Editar lead" —
  `NavigationService.navigateTo(AppRoutes.detalleEditarLead, arguments: {..., 'desdeConversacion': true})`
- `lead_detail_sheet/tabs/negociaciones_tab.dart` → `_crearNegociacion()` —
  `context.goToEditarLead(idLead: 0, cubit: cubit, desdeConversacion: true)`
- `lead_detail_sheet/negociacion_card.dart` → `_irAEditar()` —
  `NavigationService.navigateTo(AppRoutes.detalleEditarLead, arguments: {..., 'desdeConversacion': true})`

Todas estas clases (`DatosTab`, `NegociacionesTab`, `NegociacionCard`) solo se instancian dentro de
`ChatLeadPanel` — no comparten código con `ContactoNegociacionesTab`/`ContactoNegociacionCard`
(Seguimiento), que a propósito **no** mandan el flag porque ese origen no es conversación.

### Back del AppBar bloqueado mientras se guarda — `guardandoNotifier`

Bug real detectado en vivo (2026-07-20): al crear/editar una negociación, `_guardar()`
(`edit_lead_portrait.dart`) hace `context.goBack()` automático 1.5s después de mostrar el check
verde (`_ExitoOverlay`), pero el botón back del AppBar (`edit_lead_view.dart`, State distinto,
sin acceso a `_isLoading`/`_mostrandoExito`) seguía tocable durante todo ese tiempo — incluso
mientras el guardado seguía en vuelo. Si el usuario, al ver que "no pasa nada" (el título ya
cambió a "Editar negociación" apenas el backend confirma el `idLead`, antes del check verde),
tocaba el back manualmente, ese pop manual competía con el automático: la pantalla se cerraba a
mitad del flujo de `_guardar()`, el caller (`NegociacionesTab`/`ContactoNegociacionesTab`)
refrescaba la lista antes de tiempo, y entrando desde Conversación el `ChatLeadPanel` (contenedor
con tabs Datos/Negociaciones/Historial) quedaba cerrado de encima al volver.

Fix: `EditLeadPortrait` recibe `guardandoNotifier` (`ValueNotifier<bool>?`), creado y poseído por
`EditLeadView`. `_setGuardando()` (reemplaza los `setState` sueltos de `_isLoading`/
`_mostrandoExito`) actualiza ese notifier cada vez que cambia cualquiera de los dos flags;
`EditLeadView` envuelve el `IconButton` de back en un `ValueListenableBuilder` y deshabilita
`onPressed` mientras `guardando == true`. `FormSaveBar.isLoading` también pasó de `_isLoading` a
`_isLoading || _mostrandoExito`, para que "Cancelar" quede igual de bloqueado. Si se agrega otro
punto de salida manual a esta pantalla (otro botón, gesto, etc.), debe leer el mismo notifier —
no inventar un guard paralelo.

### Causa real (Seguimiento) — InfoLeadCubit compartido se auto-interrumpía al crear

El guard de arriba (`guardandoNotifier`) evita el pop manual prematuro, pero en Seguimiento
(`ContactoDetalleView`) había una causa más profunda para el mismo síntoma, más otro bug
("me manda a Información/Contacto en vez de quedarme en Negociaciones"), los dos en
`contacto_detalle_view.dart` (2026-07-20):

`ContactoDetallePage` crea UN solo `InfoLeadCubit` compartido entre `ContactoDetalleView` y
`ContactoNegociacionesTab._crearNegociacion()` (a propósito — ver comentario ahí, necesita el
mismo cubit para `prepararNuevaNegociacion()`/restaurar si el usuario cancela). Al guardar,
`InfoLeadCubit.updateLead()` ya se auto-actualiza (`emit(InfoLeadSuccess(leadFinal))`) y avisa por
`LeadUpdateNotifier` — pero `_ContactoDetalleViewState._updateSub` escuchaba TODOS los avisos que
matcheaban `idNumero`, sin filtrar por `source`, así que su propio guardado volvía a entrar por
ahí y disparaba `_refrescar()` → `cargarPorIdNumero()` → `InfoLeadLoading()` sobre el MISMO cubit
compartido. Eso producía dos daños en cadena:
1. `EditLeadView.build()` (que también escucha ese cubit) reemplazaba `EditLeadPortrait` por
   `AppLoadingView()` a mitad del check verde de éxito, disponiendo el `State` que tenía pendiente
   el `Future.delayed` del pop automático — el `if (mounted) context.goBack()` quedaba sin efecto
   y la pantalla se quedaba varada en "Editar negociación".
2. `_ContactoDetalleViewState.build()` reemplazaba `_ContactoScaffold` completo (con su
   `DefaultTabController`) por `ContactoDetalleSkeleton()` mientras duraba el `InfoLeadLoading`;
   al volver a `InfoLeadSuccess` se reconstruía un `DefaultTabController` nuevo, con índice
   siempre en 0 ("Información") — perdiendo la pestaña "Negociaciones" en la que estaba el
   usuario.

Fix, ambos en `_ContactoDetalleViewState`:
- `_updateSub` ahora ignora el aviso si `identical(update.source, _cubit)` (mismo guard que ya
  usa `InfoLeadCubit` internamente contra sí mismo) — su propio guardado nunca vuelve a
  recargarse solo, porque el cubit compartido ya quedó con el dato fresco.
- Se guarda `_ultimoLead` (la última `Negociacion` de un `InfoLeadSuccess`) y el `builder` lo
  sigue mostrando (`_ContactoScaffold` con datos "viejos" mientras llega el nuevo) durante
  cualquier `InfoLeadLoading` posterior al primer load — solo el load inicial (sin datos previos)
  muestra `ContactoDetalleSkeleton()`. Esto también arregla el pull-to-refresh
  (`RefreshIndicator.onRefresh: _refrescar`), que antes tenía el mismo problema de tumbar toda la
  pantalla en vez de solo mostrar el spinner nativo del gesto.

Editar una negociación YA EXISTENTE desde Seguimiento (`ContactoNegociacionCard._irAEditar`) usa
un `InfoLeadCubit` aislado (no el compartido), así que su aviso SÍ tiene un `source` distinto y
`_refrescar()` sigue corriendo ahí — correcto, es el único punto donde `ContactoDetalleView`
necesita enterarse desde afuera. El segundo fix (`_ultimoLead`) cubre igual ese caso, para que
tampoco pierda la pestaña activa.

En Conversación (`ChatDetailView`/`ChatLeadPanel`) no aplica ninguno de los dos bugs: nadie ahí
escucha `LeadUpdateNotifier` directo (solo el propio `InfoLeadCubit.updateLead()` se auto-emite,
sin loop), y `_panelTabController` vive en `_ChatDetailViewState` (creado una sola vez en
`initState`, no dentro del árbol que se reconstruye con el estado del cubit) — la pestaña activa
del panel sobrevive sola a cualquier rebuild.
