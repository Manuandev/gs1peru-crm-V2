# Solicitudes Feature

## Paso 3 (Facturación) — validación en línea + defaults por tipo de persona (2026-07-17)
Mismo pedido de negocio que el paso 1 (ver más abajo), aplicado a
`solicitud_facturacion_view.dart`: sin snackbar genérico, y Comprobante/Tipo documento con
default según Jurídica/Natural.

- **Validación en línea** — mismo patrón que el paso 1: nuevo `_formKey = GlobalKey<FormState>()`
  envolviendo el `Column` de `_SeccionDatosFacturacion` en un `Form` con
  `autovalidateMode: AutovalidateMode.onUserInteraction`; se eliminó el getter `_formCompleto` y
  el snackbar de `_onContinuar`, reemplazado por `_formKey.currentState?.validate()`. Todos los
  campos son obligatorios menos Apellido materno, Actividad económica, NIT y Observaciones —
  Apellido paterno solo aplica cuando el tipo de documento NO es RUC (la fila entera se oculta
  con RUC, ver `esRuc`, así que no hace falta que su validator lo sepa). `SolicitudCampoCelular`
  y `.emailValidator` reusan el mismo patrón que paso 1/formulario de participante.
- **Comprobante y Tipo documento arrancan según el tipo de persona del paso 1** (nunca antes
  tenían este default — Tipo documento siempre cayó en DNI sin mirar el tipo de persona, y
  Comprobante no tenía ningún default): **Jurídica → Factura + RUC**, **Natural → Boleta + DNI**.
  Aplica tanto si "Facturar al solicitante" está marcado como si no — es el default base en los
  dos casos, resuelto en `didChangeDependencies()` contra `CatalogsBloc.valoresDefecto.
  idTipoFactura/idTipoBoleta/idTipoDocRuc/idTipoDocDni`, nunca ids hardcodeados.
- **"Facturar al solicitante" ahora pinta los campos correctos según el tipo de persona** — bug
  real de la rama Jurídica: antes copiaba siempre `solicitante.tipoDocId`/`numDoc`/`nombres`
  (los datos **personales** del solicitante, paso 1 "Datos del solicitante"), sin importar que
  con Jurídica el dato que corresponde es el de la empresa (`DatosSolicitante.ruc`/`razonSocial`,
  paso 1 "Información comercial") — con Jurídica, el checkbox terminaba pintando el DNI/nombres
  del contacto en vez del RUC/razón social de la empresa. Corregido: la rama Jurídica ahora
  fuerza Tipo documento = RUC y pinta `_ctrlNumDoc`/`_ctrlNombresRazon` con
  `solicitante.ruc`/`solicitante.razonSocial`; la rama Natural sigue igual que antes (copia el
  documento/nombres/apellidos personales tal cual el solicitante los tiene, sin forzar DNI —
  a diferencia del default "sin datos", acá si el solicitante ya eligió otro tipo de documento
  en el paso 1 se respeta, no se pisa).

## Botón "Nuevo" (participantes) se deshabilita al llegar al máximo (2026-07-17)
Pedido de negocio (jefe del usuario) — con una solicitud que viene de una negociación con
cantidad ya definida (`SolicitudFormCubit.state.cantidadEsperada != null`), el botón "Nuevo"
del paso 2 ahora se deshabilita de verdad (`OutlinedButton.icon(onPressed: null, ...)`, se ve
gris — no solo un callback vacío que lo deja con pinta de habilitado) apenas
`participantes.length >= cantidadEsperada`. `_BotonSeccionSmall` ganó un parámetro `enabled`
(default `true`) que además cambia el color del ícono/texto/borde a `AppColors.textDisabled`
cuando está apagado — antes solo el botón "Eliminar todos" (cuando la lista está vacía) usaba
el patrón de callback vacío sin feedback visual; ese no se tocó, este caso pidió explícitamente
"no debe permitirme apretar el botón". Sin `cantidadEsperada` (solicitud no viene de negociación)
el botón nunca se deshabilita por este motivo — no hay máximo que respetar.

## Invitados no cuentan en el total facturado (2026-07-17)
Pregunta de negocio del usuario: con 3 participantes (2 Invitados + 1 Pagante), la división
sugerida por `_importeFijo()` sigue siendo pareja entre los 3 (sin cambios, ver más abajo por
qué), pero el total que se muestra y se factura no debe incluir el importe de los Invitados —
solo pagan los Pagantes.

- **Confirmado con el usuario y NO se tocó**: el importe que tenga puesto CUALQUIER participante
  (Pagante o Invitado) se queda tal cual se ingresó — sigue siendo obligatorio > 0 para los dos
  tipos (ver sección de abajo, "Importe obligatorio"). `_importeFijo()` (`solicitud_participantes_
  view.dart`) tampoco cambió — reparte `totalSinIgv / cantidadEsperada` entre TODOS los
  participantes esperados sin mirar el tipo, y ya usaba (confirmado, sin cambios) los importes
  REALES/editados de los participantes ya guardados (`actuales.fold`, no los sugeridos
  originales) para calcular lo que le toca al último — si editas el importe del participante 1 y
  luego agregas el 2, el sugerido del 2 ya se recalculaba con el valor real del 1.
- **Lo que sí cambió — de dónde sale el total mostrado/facturado**:
  `ParticipantesState.totalInversion` (sumaba TODOS los participantes sin filtrar) se reemplazó
  por `totalPagantes(List<TipoParticipanteItem>)` — filtra `esInvitado` contra el catálogo real
  (`CatalogsBloc.tiposParticipante`, nunca ids hardcodeados) y solo suma a los que NO son
  invitados. Esto alimenta 3 lugares que antes sumaban parejo:
  1. `_ResumenInversion` (footer del paso 2, "Inversión/IGV/Total")
  2. `_SeccionResumenComercial` (Resumen, paso 4)
  3. `SolicitudRemoteDatasource.guardarSolicitud()` — `dcImporte` (antes `participantes.fold(...)`
     sin filtro) ahora excluye invitados antes de calcular `dcIgv`/`dcImporteTotal`, que es lo
     que realmente se manda como `DC_IMPORTE`/`DC_IGV`/`DC_IMPORTE_TOTAL` al SP. Nuevo parámetro
     `tiposParticipante` threaded igual que `igvPorcentaje`/`pasoOrigen`:
     `guardarSolicitudDesdeWizard()` → `GuardarSolicitudUseCase` → `SolicitudRepository`/`Impl` →
     datasource.
  - **Ojo — el registro individual de cada participante (`EVT.T_TECMSOLINSCRIPCION02.IMPORTE`/
    `IGV`) no se tocó** — cada fila sigue mandando su propio importe/igv tal cual está en
    `ParticipanteLocal`, invitado o no. Solo el agregado de la cabecera (lo que se factura de
    verdad) excluye invitados.

## Formulario de participante — Importe obligatorio (>0) + tipo visible en la cartilla de la lista (2026-07-17)
Pedido de negocio (jefe del usuario), mismo espíritu que la validación del paso 1 de más abajo
pero aplicado a `participante_form_sheet.dart` (modal "Nuevo/Editar participante") y a la
cartilla de cada participante en la lista del paso 2 (`_ParticipanteCard`,
`solicitud_participantes_view.dart`).

- **Importe ahora es obligatorio y debe ser mayor a 0** — antes `validator` solo revisaba que,
  *si* se escribía algo, fuera un número válido; vacío pasaba silenciosamente (`ParticipanteLocal.
  importe` quedaba en `0.0`). Ahora: vacío → `'Requerido'`; no numérico → `'Número inválido'`;
  `<= 0` → `'Debe ser mayor a 0'`. Con esto ya no se puede guardar (`_formKey.currentState!.
  validate()` en `_guardar()`) un participante con importe en 0, con o sin `importeFijo`
  sugerido de la negociación.
- **`CustomComboField<TipoParticipanteItem>` (modal) se quedó en su posición original** — fila
  junto a Nacionalidad, antes de Nombres. **Ojo, intento fallido en esta misma sesión**: primero
  se movió a una fila propia debajo de Correo con ícono de persona — el pedido real no era mover
  el combo del formulario, era mostrar el tipo en la **cartilla de la lista** (ver abajo) para
  poder verificar los cálculos de un vistazo sin abrir el modal. Se revirtió la posición del
  combo; solo quedó el `validator` nuevo (antes no tenía, aunque siempre tuvo un valor por
  defecto así que nunca se notó la falta). Nacionalidad también ganó `validator` de paso (antes
  tampoco lo tenía, pese al `*` en su label).
- **`_ParticipanteCard` ahora muestra el tipo de participante** — nueva fila **debajo de
  Correo** (entre la fila Nac./Correo y Cargo, no al final — ajustado tras feedback del usuario),
  ícono `AppIcons.user` + descripción real del catálogo ("Pagante"/"Invitado"/"Invitado
  auspicio"/"Online", resuelta contra `CatalogsBloc.tiposParticipante` por el padre — la card es
  `StatelessWidget` sin acceso directo al catálogo, recibe `tipoParticipanteLabel` ya resuelto
  como parámetro nuevo). Objetivo explícito del usuario: poder confirmar a simple vista, en la
  lista, si el cálculo de la inversión (que desde el punto de arriba excluye a los Invitados,
  ver `ParticipantesState.totalPagantes`) está tomando el tipo correcto de cada uno.
- **Tipo doc.** (combo, misma fila que N° documento) sigue **sin** `validator` a propósito —
  siempre trae un valor por defecto (DNI al crear, o el que ya tenía el participante al editar,
  ver "Defaults al crear" más abajo), nunca queda vacío, y el catálogo filtrado incluye "Sin
  documento" como opción legítima — no confundir con un campo realmente opcional.

## Validación del paso 1 — de snackbar genérico a campos en rojo (2026-07-17)
Pedido de negocio (jefe del usuario) — al presionar "Siguiente" en el paso 1 con campos
obligatorios vacíos, ya no se muestra `AppSnackBar.error('Completa todos los campos
obligatorios...')`; cada campo/combo que falta se marca en rojo con su propio "Requerido"
debajo, como ya hacía `participante_form_sheet.dart` (mismo patrón `Form` + `GlobalKey<FormState>`
+ `validator` en cada `CustomTextField`/`CustomComboField`, reusado acá).

- **`solicitud_completar_view.dart`** — nuevo `_formKey = GlobalKey<FormState>()`; el `Column`
  que arma "Datos del solicitante" + "Información comercial" + canal + switches ahora vive
  dentro de un `Form(key: _formKey, autovalidateMode: AutovalidateMode.onUserInteraction)` —
  el `autovalidateMode` hace que un campo marcado en rojo se limpie solo al corregirlo, sin
  esperar a un nuevo "Siguiente". `_onContinuar()` cambió `if (!_formCompleto) { snackbar;
  return; }` por `if (!(_formKey.currentState?.validate() ?? false)) return;` — el getter
  `_formCompleto` se eliminó por completo, ya no hace falta.
- **`SeccionDatosSolicitante`** (`solicitud_completar_datos_solicitante.dart`) — se agregó
  `validator` a Tipo documento, N° documento, Nacionalidad, Sexo, Nombres, Apellido paterno,
  Cargo, Celular (`SolicitudCampoCelular` ya soportaba `validator`, mismo widget que usa
  `participante_form_sheet.dart`) y Correo (`.emailValidator`). Apellido materno sigue sin
  validator — es el único campo opcional de esta sección.
- **Bug real corregido de paso — RUC/Razón social nunca fueron obligatorios, ni siquiera con
  Jurídica.** `SeccionInfoComercial` (RUC + Razón social, solo se renderiza `if (tipoPersona ==
  'juridica')`) tenía el header con la etiqueta `"(opcional)"` y ningún `validator` — el usuario
  confirmó que con Jurídica **sí** son obligatorios (con Natural, ni se muestran ni aplican). Se
  quitó `"(opcional)"`, se agregó `*` a ambos labels y `validator: 'Requerido'` a los dos
  campos — como el widget entero solo existe cuando `tipoPersona == 'juridica'`, no hizo falta
  threadear el tipo de persona hacia adentro, basta con que esté montado.
- **`validarSolicitudParaGenerar()`** (`solicitud_guardar_helper.dart`, gate de "Generar
  solicitud" en Resumen) se actualizó con la misma regla —
  `(formState.tipoPersona != 'juridica' || (ruc/razonSocial no vacíos))` — para que una
  solicitud editada sin volver a pasar por el paso 1 en la sesión actual (ej. entrar directo a
  Resumen con `onEditarPaso`) tampoco pueda generarse sin RUC/razón social si es Jurídica.
- **Canal (chips) y archivos (voucher/O.C.) siguen 100% opcionales** — confirmado explícitamente
  por el usuario, sin cambios ahí. La única sub-regla que sigue aplicando dentro de "Canal
  opcional" es el detalle libre cuando se elige un canal con `esDetallado == true` (hoy,
  "Otros") — ese input también se pasó a `validator` (mismo patrón, "Requerido" si está vacío).

## Aviso de precio total desfasado — movido de "al entrar" a "solo al Generar" (2026-07-17)
Pedido de negocio (jefe del usuario) — `_avisarSiPrecioTotalNoCalza()` (paso 1,
`solicitud_completar_view.dart`) se disparaba automáticamente al prellenar el formulario desde
una negociación (`_prellenarDesdeNegociacion()`, vía `WidgetsBinding.addPostFrameCallback`) —
o sea, el snackbar de advertencia "El precio base × cantidad − descuento no coincide..." podía
aparecer con solo **entrar** a la página, y no había forma de evitarlo tampoco presionando
"Guardar" (borrador). El usuario pidió que este aviso deje de aparecer en ambos casos — "Guardar"
es un borrador que se termina de completar después, no debería frenar ni avisar nada — y que la
**única** validación de este tipo viva en "Generar solicitud".

- El método se eliminó de `solicitud_completar_view.dart` (junto con la llamada en
  `_prellenarDesdeNegociacion()`) y se reemplazó por `avisoPrecioTotalNoCalza(SolicitudFormState)`
  en `solicitud_guardar_helper.dart` — misma cuenta exacta (`precioBaseLead × cantidadEsperada −
  descuentoLead` vs `precioTotalLead`, tolerancia `0.01`), pero ahora es una función pura que
  retorna `String?` (mensaje o `null`) en vez de mostrar el snackbar ella misma.
- Se llama **solo** desde `solicitud_resumen_view.dart._onGenerarSolicitud()`, después de
  `validarSolicitudParaGenerar()` (que si falla, ya cortó con `return` antes de llegar acá) y
  antes de arrancar `generarSolicitudCompleta()` — sigue siendo **no bloqueante** (a diferencia
  de `validarSolicitudParaGenerar`, que si retorna una `SolicitudValidacion` sí impide generar):
  si hay mensaje se muestra con `AppSnackBar.warning` pero la generación continúa igual, mismo
  comportamiento no-bloqueante que tenía antes, solo que ahora el único momento en que puede
  aparecer es al presionar "Generar solicitud".

## Seguimiento con texto distinto por paso del wizard (2026-07-17)
Pedido de negocio (jefe del usuario) — como cada "Siguiente"/"Guardar"/"Generar solicitud" ya
guarda de verdad (ver sección de abajo), el registro que queda en `CRM.T_LEAD_SEGUIMIENTO`
(historial del lead, tab Historial de `ChatLeadPanel`/`ContactoDetalleView`) debería reflejar
qué paso se completó, no un mensaje genérico "se modificó" para cualquier guardado.

- **`CSV_SOLICITUD_CUD_APP.sql`** (`C:\DEV\BDNatCodee\NC.SQLChangeLock\DBEAN\StoredProcedures\`,
  repo aparte — UTF-16LE con BOM, cualquier edición futura debe preservar esa codificación o
  SSMS lo muestra corrupto) — nuevo campo `field44` (`@PASO_ORIGEN CHAR(1)`, valores
  `'1'`-`'4'`) en el task `'U'`. En la rama `UPDATE` (NUMSOL ya existe), el único `INSERT` a
  `T_LEAD_SEGUIMIENTO` que antes siempre decía "Se ha modificado una ficha de inscripción..."
  ahora arma `@DESC_SEGUIMIENTO` con un `CASE`: `@IB_BORRADOR = 0` (Generar solicitud, sin
  importar el paso) → "Se generó la solicitud de inscripción..."; si no, según `@PASO_ORIGEN`:
  `'1'` "Se registraron los datos del solicitante...", `'2'` "...los participantes de la
  solicitud...", `'3'` "...los datos de facturación...", `'4'` "Se guardó un avance de la
  solicitud..." (Resumen, "Guardar" sin generar); cualquier otro valor (apps viejas sin
  `field44`, llega `NULL`) cae al mensaje genérico de siempre como fallback. La rama `CREATE`
  (NUMSOL vacío, primer guardado) no se tocó — sigue con su mensaje fijo "Se ha generado una
  ficha de inscripción...".
- **Flutter** — nuevo parámetro `pasoOrigen` (`String`, `'1'`-`'4'`) threaded de punta a punta:
  `SolicitudRemoteDatasource.guardarSolicitud()` (lo manda como field44) →
  `SolicitudRepository`/`SolicitudRepositoryImpl` → `GuardarSolicitudUseCase` →
  `guardarSolicitudDesdeWizard()`/`guardarBorradorCompleto()` (`solicitud_guardar_helper.dart`).
  `generarSolicitudCompleta()` siempre manda `'4'` hardcodeado (solo se llama desde Resumen);
  `guardarBorradorCompleto()` lo recibe como parámetro obligatorio porque lo llaman los 4
  pasos — cada `_onContinuar`/`_onGuardar` manda su propio número (`solicitud_completar_view.dart`
  → `'1'`, `solicitud_participantes_view.dart` → `'2'`, `solicitud_facturacion_view.dart` →
  `'3'`, `solicitud_resumen_view.dart` → `'4'` en su botón "Guardar").
- **⚠️ Hallazgo aparte al revisar el CUD para esto, sin tocar todavía** — `guardarSolicitud()`
  parece mandar **paisId y nacionalidadId de facturación invertidos**: field25
  (`facturacion?.nacionalidadId`) llega a `@ID_NACION_FAC`, que el SP usa para la columna
  `ID_PAIS`; field43 (`facturacion?.paisId`) llega a `@ID_NACIONALIDAD_FAC`, que puebla la
  columna `ID_NACIONALIDAD`. O sea el país que elige el asesor terminaría guardado en la
  columna de nacionalidad y viceversa. No confirmado con datos reales todavía, solo leyendo el
  `.sql` — revisar con el usuario antes de tocarlo, es un fix de datos sensible.

## Cada "Siguiente" ahora valida Y guarda de verdad — se quitó el botón "Guardar" del medio (2026-07-17)
Pedido de negocio (jefe/coordinadora del usuario) — **revierte** la sección "Validación movida a
'Generar solicitud'" de más abajo (2026-07-16): ya no basta con validar solo al generar, cada
paso tiene que quedar guardado en el backend apenas se avanza.

- **Pasos 1, 2 y 3 — "Continuar" se renombró a "Siguiente" y ahora, en cada uno**: (1) valida los
  campos obligatorios del paso (`_formCompleto`, restaurado tal cual estaba antes de quitarlo —
  mismos campos documentados en "Validación de 'Continuar'" más abajo — más, en el paso 2, al
  menos 1 participante); si falta algo, `AppSnackBar.error` y no avanza. (2) Si está completo,
  llama `guardarBorradorCompleto()` (el mismo helper que ya usaban los botones "Guardar" —
  `IB_BORRADOR=1` siempre, nunca `0`, eso solo lo pone "Generar solicitud") con el mismo
  `SolicitudProgreso`/`SolicitudProgresoOverlay` de siempre (spinner→check, "Guardando
  solicitud...", y en el paso 1 también "Subiendo voucher..."/"Subiendo O.C...." si hay archivos
  pendientes — el usuario pidió explícitamente que los archivos se suban desde el paso 1, no que
  esperen a Resumen). (3) Solo si el guardado sale `CrudOk` avanza al siguiente paso — si falla,
  se queda ahí mostrando el error, igual que antes.
- **El botón "Guardar" del medio (entre Cancelar/Atrás y Continuar) se eliminó de los pasos 1, 2
  y 3** — ya no hace falta, "Siguiente" cumple esa función en cada uno. `_onGuardar()` se
  eliminó de los 3 archivos (su lógica se fusionó dentro de `_onContinuar`). El Resumen (paso 4)
  **no cambió** — sigue con sus 2 botones "Guardar"/"Generar solicitud" tal cual, porque ahí no
  hay un paso siguiente al cual "avanzar" fusionando el guardado.
- **El NUMSOL de la primera llamada ya se reutilizaba correctamente** — no hizo falta construir
  nada nuevo para esto: `guardarSolicitudDesdeWizard()` ya capturaba el NUMSOL de la respuesta
  del backend en el primer guardado exitoso (`formCubit.actualizarNumSol(data)`) desde antes de
  este cambio — con "Siguiente" guardando en cada paso, este mecanismo simplemente se ejerce más
  seguido (potencialmente 3 veces antes de llegar a Resumen), pero es el mismo de siempre.
- **Volver "Atrás" y cambiar algo (ej. quitar un archivo adjunto) y presionar "Siguiente" de
  nuevo vuelve a guardar/re-subir todo** — comportamiento esperado, confirmado explícitamente por
  el usuario ("cambio un documento... pongo continuar, otra vez se tiene que volver a guardar").
- **Bug real detectado en vivo el mismo día — el primer intento de este cambio no distinguía
  `modoEdicion`, así que también validaba y guardaba en el recorrido de solo lectura ("Revisar
  solicitud" desde el detalle, `modoEdicion: false`).** Corregido: los 3 `_onContinuar` ahora
  arrancan revisando `widget.modoEdicion` — si es `false`, avanzan directo sin validar ni guardar
  nada (en el paso 2 igual se calcula `soloInvitados` para decidir a qué paso saltar, aunque no
  se guarde). El botón, en ese modo, sigue diciendo **"Continuar →"** (no "Siguiente →" — esa
  palabra queda reservada para cuando sí valida y guarda, en modo edición).
- **El botón del detalle que entra en modo solo-ver se renombró** — en `_BotonesDetalle`
  (`solicitud_detalle_view.dart`), el botón que llamaba `goToFichaCompletarSolicitud(modoEdicion:
  false)` decía "Continuar" con ícono de flecha; ahora dice **"Revisar solicitud"** con el mismo
  ícono de ojo (`AppIcons.visibility`) que ya usa "Ver" en la card — para que se note a simple
  vista que es un recorrido de solo lectura, distinto de "Editar ficha"/"Validar" (que si guardan).

## Bug real — "RUC ya existe" bloqueaba Guardar/Generar casi siempre (2026-07-16)
Reportado por la coordinadora del usuario ("el botón guardar no funciona, muestra alerta 'RUC YA
EXISTE'"). Confirmado en el SP (`CSV_SOLICITUD_CUD_APP`, task `'U'`), bug preexistente, no
introducido en esta sesión — la validación contra `dbo.CTAMEXTER01` (tabla de referencia
RUC↔razón social) tenía la comparación al revés:

```sql
-- ANTES (bug):
IF EXISTS(SELECT 0 FROM dbo.CTAMEXTER01 WHERE UPPER(RAZON) = UPPER(@RUCEMPRE_FAC))
```
Esto busca en la columna `RAZON` (razón social, texto) un valor igual a `@RUCEMPRE_FAC` (un RUC,
11 dígitos) — casi nunca matchea de verdad, **salvo que exista alguna fila con `RAZON` vacía/en
blanco** en `CTAMEXTER01`, en cuyo caso **cualquier solicitud de persona Natural** (que siempre
manda `RUCEMPRE_FAC = ''`, ver `esRuc` en `guardarSolicitud()`) matchea esa fila por accidente —
dispara el error casi siempre para ese caso. Corregido:
```sql
-- AHORA:
IF (@RUCEMPRE_FAC <> '' AND EXISTS(SELECT 0 FROM dbo.CTAMEXTER01 WHERE RUC = @RUCEMPRE_FAC))
BEGIN
    SELECT @RAZON_EXTER = RAZON FROM dbo.CTAMEXTER01 WHERE RUC = @RUCEMPRE_FAC
    IF(UPPER(@NOMEMPRE_FAC) <> UPPER(@RAZON_EXTER))
    BEGIN
        SELECT 'ERROR' + @sepListas + 'El RUC ya existe con otra razón social.'
        ROLLBACK; RETURN;
    END
END
```
Ahora: (1) se salta el chequeo entero si no hay RUC (persona Natural — nada que validar), (2)
busca por `RUC` (columna correcta) en vez de por `RAZON`, (3) compara la razón social que se
está mandando (`NOMEMPRE_FAC`) contra la que ya existe para ese RUC (`RAZON`, recién
encontrada) — antes comparaba `@RUCEMPRE_FAC` contra sí mismo vía un lookup que nunca tenía
sentido. Nueva variable `@RAZON_EXTER VARCHAR(250)` (antes solo existía `@RUC_EXTER`, que ya no
se usa para esto).

## Card simplificada + Validar vs Ver + eliminar solicitud (2026-07-16)
Rediseño pedido por el usuario de la lista y el detalle:

- **`SolicitudCard` — regla de acción simplificada, ya no mira `idEstado`.** `_accion()` ahora
  es solo `ibValidado ? ninguna : sinValidar` — validada → solo "Ver"; sin validar → "Ver" +
  "Validar". Se eliminó `SolicitudAccionTipo.cobranza` y el botón "Completar" (ya no existen).
  Qué se puede hacer dentro del detalle (editar vs. solo continuar) sigue siendo responsabilidad
  exclusiva de `Solicitud.puedeEditar` (`idEstado == 0`), no de la card.
- **El detalle ahora distingue si se entró por "Ver" o por "Validar"** — nuevo parámetro
  `origenValidar` (`goToDetalleSolicitud(solicitud, origenValidar: true)` desde el botón
  "Validar"; `false`/default desde "Ver"), threaded hasta `_BotonesDetalle` vía
  `SolicitudDetallePage`/`SolicitudDetalleView`. Con esto, `_BotonesDetalle` calcula
  `mostrarEditar = origenValidar || solicitud.puedeEditar`:
  - Entrada por **Ver**: "Continuar" siempre; "Editar ficha" solo si `puedeEditar` — sin cambios
    respecto al comportamiento de siempre.
  - Entrada por **Validar**: "Continuar" + el botón de editar **siempre**, con el texto
    "Validar" en vez de "Editar ficha" — mecánicamente es exactamente lo mismo (mismo
    `onPressed`, abre el wizard con `modoEdicion: true`), solo cambia el label.
- **Título del detalle** — el subtítulo "Revisa la información y continúa con el proceso" se
  movió al `titleWidget` del `BasePage` (bajo el título "Detalle de Solicitud", dentro del mismo
  AppBar) — se eliminó el banner azul separado `_DetalleHeader` que existía antes.
- **Eliminar solicitud** — tacho de basura en `appBarTrailingButtons`, visible **solo si
  `!ibValidado`** (mismo criterio que el botón "Validar" de la card — una vez validada, no se
  puede eliminar). Flujo: confirmar (`context.showConfirmDialog`) → `SolicitudProgreso`/
  `SolicitudProgresoOverlay` (el mismo widget que ya usa el wizard para Guardar/Generar, ver
  sección de arriba — reusado tal cual, un solo paso "Eliminando solicitud..." → check → pausa
  500ms) → `context.goToSolicitudes()` (`clearAndPush`, recarga la lista fresca sola, no hace
  falta lógica extra para "refrescar").
  - **Nuevo task `'DEL'` en `CSV_SOLICITUD_CUD_APP`** (no existía ningún mecanismo de borrado de
    solicitud completa antes de esto) — borra en cascada, en este orden (por FKs):
    `T_TECMSOLINSCRIPCION02_ASISTENCIA` → `T_TECMSOLINSCRIPCION02` (participantes) →
    `T_TECMSOLINSCRIPCION01_ARCHIVOS` → `T_TECMSOLINSCRIPCION01_FACTURACION` →
    `T_LEAD_TECMSOLINSCRIPCION01` (link al lead de origen) → `T_TECMSOLINSCRIPCION01` (cabecera).
    El SP mismo rechaza el borrado si `IB_VALIDADO != 0` (última línea de defensa, redundante con
    que el botón ya no se muestra en ese caso en la UI). Mismo endpoint que `guardarSolicitud()`
    (`urlSolicitudesCud`, texto plano) — el controller (`SPSolicitudCUDApp`) es un passthrough
    genérico al SP, no necesitó cambios.
  - **Pendiente, no tocado**: el/los archivo(s) físicos en disco
    (`ARCHIVOS_FACTURACION\<NUMSOL>\...`) no se borran — solo el registro en
    `T_TECMSOLINSCRIPCION01_ARCHIVOS`. Si hace falta limpiar disco también, es un cambio aparte
    en el controller/backend de archivos.
  - Nuevos: `SolicitudRemoteDatasource.eliminarSolicitud()`, `SolicitudRepository.eliminarSolicitud()`/
    `SolicitudRepositoryImpl`, `EliminarSolicitudUseCase` (exportado en `index_solicitudes.dart`).

## Auditoría completa de anchos de columna del CUD (2026-07-16)
El usuario corrió `INFORMATION_SCHEMA.COLUMNS` sobre las 8 tablas reales que toca
`CSV_SOLICITUD_CUD_APP` (identificadas leyendo el SP completo:
`EVT.T_TECMSOLINSCRIPCION01`/`_FACTURACION`/`_ARCHIVOS`, `EVT.T_TECMSOLINSCRIPCION02`/
`_ASISTENCIA`, `CRM.T_LEAD_TECMSOLINSCRIPCION01`, `CRM.T_LEAD_SEGUIMIENTO`, `CRM.T_LEAD`) y se
cruzó contra los anchos de variable ya conocidos del SP. Hallazgos, de mayor a menor gravedad:

- **Columnas que SÍ necesitan `ALTER TABLE` — no se pueden arreglar solo en el SP:**
  - `EVT.T_TECMSOLINSCRIPCION01.ID_NACIONALIDAD` `VARCHAR(2)` — mismo problema que `ID_PAIS`
    (país=165 truncado a 16, ver sección de abajo). Ya se amplió la variable del SP
    (`@ID_NACION_SOL` → `VARCHAR(10)`), pero si la nacionalidad real también usa códigos de 3
    dígitos, la **columna** lo sigue truncando.
  - `EVT.T_TECMSOLINSCRIPCION02.ID_NACIONALIDAD` `VARCHAR(2)` — mismo riesgo, y sin variable
    intermedia en el SP que se pueda ensanchar (el dato de cada participante pasa directo de
    Flutter a la columna vía la tabla de split) — 100% depende de la columna.
  - `EVT.T_TECMSOLINSCRIPCION01.NRO_DOCUMENTO` `VARCHAR(11)` — Carnet de extranjería y Pasaporte
    pueden ser de 12 caracteres (`DocumentoValidationUtils`, ver `core/CLAUDE.md`) — un
    solicitante con ese tipo de documento se trunca 1 carácter.
  - `EVT.T_TECMSOLINSCRIPCION01.SEXO` `CHAR(1)` — confirmado (no solo sospecha): el catálogo
    real de Sexo usa `'PD'` (Por Definir, 2 caracteres — hardcodeado en el SP de catálogos,
    documentado en `core/CLAUDE.md` → `SexoItem`). Se trunca a `'P'`, que no matchea ningún id
    real del catálogo al releer — el combo Sexo queda vacío al reabrir una solicitud donde se
    eligió "Por definir".
  - `ALTER TABLE` sugeridos (el usuario los corre, tiene el acceso):
    ```sql
    ALTER TABLE EVT.T_TECMSOLINSCRIPCION01 ALTER COLUMN ID_NACIONALIDAD VARCHAR(10);
    ALTER TABLE EVT.T_TECMSOLINSCRIPCION02 ALTER COLUMN ID_NACIONALIDAD VARCHAR(10);
    ALTER TABLE EVT.T_TECMSOLINSCRIPCION01 ALTER COLUMN NRO_DOCUMENTO VARCHAR(20);
    ALTER TABLE EVT.T_TECMSOLINSCRIPCION01 ALTER COLUMN SEXO VARCHAR(2);
    ```
- **Arreglado en el SP (la variable era el cuello de botella, la columna ya estaba bien):**
  - `@NUM_DOC_FAC VARCHAR(11)` → `VARCHAR(15)` — la columna
    `T_TECMSOLINSCRIPCION01_FACTURACION.NRO_DOCUMENTO` ya era `VARCHAR(15)`, la variable era la
    que truncaba antes de llegar ahí.
  - `@NUM_DOC_SOL VARCHAR(11)` → `VARCHAR(20)` — ojo, esto **no** arregla del todo el problema de
    NRO_DOCUMENTO en `T_TECMSOLINSCRIPCION01` (la columna sigue en `VARCHAR(11)`, ver arriba),
    solo quita uno de los 2 puntos de truncamiento.
  - `@ID_SEXO_SOL CHAR(1)` → `VARCHAR(2)` — mismo caso, la columna `SEXO` también necesita el
    `ALTER TABLE` de arriba para que el fix sea completo de punta a punta.
- **Menor prioridad, no tocado — confirmar con negocio si vale la pena:**
  - `EVT.T_TECMSOLINSCRIPCION01_FACTURACION.CELULAR` es `VARCHAR(12)`, pero en Solicitante/
    Participante es `VARCHAR(15)` — inconsistente entre tablas para el mismo tipo de dato. Solo
    importa si algún número internacional supera 12 dígitos.
- **Confirmado sin problema — anchos ya coinciden bien entre columna/variable/dato real**:
  `NUMSOL` (8), `RUCEMPRE`/`RUC` (11), `NOMEMPRE`/razón social (250), `NOMBRES` (100),
  `APE_PATERNO`/`APE_MATERNO` (50), `CORREO`/`CORREO_ENVIO` (150), `DIRECCION` (100),
  `UBIGEO` (6), `ID_PAIS` en Facturación (`VARCHAR(8)` — este SÍ alcanzaba para "165", el
  problema ahí era 100% la variable del SP, ya arreglada), `MONEDA`/`ID_MONEDA` (8),
  `TIPO_COMPROBANTE` (2, calza exacto con ids '01'/'03'/'07'/'08'), `NRO_DOCUMENTO` en
  Participante (`VARCHAR(20)`, generoso).

## Bug real de fondo — ID_PAIS se truncaba (VARCHAR(2) en el SP, id real de 3 dígitos) (2026-07-16)
El bug de "país no se guarda" de la sección de abajo tenía una causa más profunda que la falta
de default: el usuario confirmó que el id de Perú en el catálogo real es `165` (3 dígitos), pero
`CSV_SOLICITUD_CUD_APP` declaraba `@ID_NACION_FAC VARCHAR(2)` — SQL Server trunca en silencio al
asignar un valor más largo que el ancho declarado de una variable (sin error, sin warning), así
que `165` quedaba guardado como `16`. Mismo problema, mismo patrón de declaración, en 2 variables
más de la misma familia (nacionalidad/país, ids de `SYSTABEXTER02`):
`@ID_NACION_SOL` (nacionalidad del solicitante, paso 1) y `@ID_NACIONALIDAD_FAC` (nacionalidad de
facturación, agregada en el fix de arriba del 2026-07-16 — se declaró igual de angosta por
seguir el patrón ya existente, sin darme cuenta del riesgo hasta que apareció el síntoma real).
Las 3 se ampliaron a `VARCHAR(10)` — margen amplio y sin costo real (son variables locales del
SP, no columnas de tabla).
**Ojo — pendiente de verificar, no lo pude confirmar yo**: esto arregla el truncamiento del lado
de la variable del SP, pero si la **columna real** (`ID_PAIS`/`ID_NACIONALIDAD` en
`EVT.T_TECMSOLINSCRIPCION01_FACTURACION`, `ID_NACIONALIDAD` en `EVT.T_TECMSOLINSCRIPCION01`) es
también más angosta que el id más largo del catálogo, el truncamiento seguiría pasando ahí en
vez de en la variable — no tengo acceso a `sp_help`/diseño de tabla para confirmarlo. El usuario
tiene acceso a la base y puede verificarlo/ampliarlo si hace falta.

## País de facturación sin default + SUNAT pisaba Dirección/Razón social + pantalla "Solicitud generada" (2026-07-16)
Tres cambios más de la misma sesión — el usuario reportó "el id país y la dirección no se están
guardando" y aprovechó para pedir ajustes de UI en la pantalla post-generar:

- **Bug real — "País" (paso 3, Facturación) nunca tenía un valor por defecto.** A diferencia de
  Tipo documento/Nacionalidad (que arrancan en DNI/Perú, ver "Defaults al crear" más abajo),
  `_paisId` se quedaba en `''` en las 2 ramas de `didChangeDependencies()` que no restauran datos
  ya guardados: la rama "sin datos previos" (ahora sí default a `valoresDefecto.idPais`, igual que
  Tipo doc/Nacionalidad) y la rama "Facturar al solicitante" (`DatosSolicitante` no tiene campo
  País, solo Nacionalidad — antes simplemente no se seteaba nada, ahora también cae al mismo
  default). Sin esto, si el asesor nunca tocaba el combo País a mano, `ID_PAIS`/`ID_NACION_FAC`
  llegaba vacío al SP y punto.
- **Bug real del SP — datos de SUNAT pisaban lo que el asesor tipeaba a mano.**
  `CSV_SOLICITUD_CUD_APP` (task `'U'`) tenía (desde antes, no introducido en esta sesión) un
  bloque `IF(@COD_TIP_REGISTRO = 'J') BEGIN SELECT @UBIGEO_FAC = UBIGEO, @DIRECCION_FAC = TIP_VIA
  + NOM_VIA, @NOMEMPRE_FAC = RAZON_SOCIAL FROM DBSUNAT.dbo.Contribuyente WHERE RUC =
  @RUCEMPRE_FAC END` — para persona Jurídica, si el RUC coincidía con esa tabla externa de SUNAT,
  **sobrescribía Dirección/Razón social sin importar lo que el asesor ya había tipeado en el
  formulario**. Confirmado con el usuario: SUNAT solo debe rellenar si el campo llega vacío,
  nunca pisar un valor ya ingresado a mano. Corregido con `CASE WHEN ISNULL(@CAMPO,'') = '' THEN
  <valor de SUNAT> ELSE @CAMPO END` en los 3 campos (`UBIGEO_FAC`/`DIRECCION_FAC`/`NOMEMPRE_FAC`)
  — mismo patrón "no pisar lo ya tipeado" que ya usan los 4 autocompletados por documento del
  wizard (ver "Autocompletado por documento" más abajo).
- **`SolicitudGeneradaView` (pantalla post-"Generar solicitud")** — 4 ajustes de UI pedidos:
  - Título del `BasePage` (AppBar): `'CRM Perú'` → `'Solicitud lista'` (el header azul interno
    de la pantalla, `_HeaderGenerada`, ya decía "Solicitud lista" seguido de "Tu solicitud ha
    sido generada..." — eso no se tocó, solo el título de la barra superior).
  - Se quitó `appBarLeadingButtons` (el ícono de volver) por completo — esta pantalla es un
    punto final del flujo, no tiene sentido un botón manual de retroceso. Como
    `drawerSide: DrawerSide.none` + sin `leadingButtons`, `CustomAppBar` no agrega un back button
    automático (`automaticallyImplyLeading` solo es `true` con `DrawerSide.left`, ver
    `custom_app_bar.dart`) — no hizo falta `automaticallyImplyLeading: false` explícito.
  - `onPop` (intercepta el botón/gesto de retroceso físico del celular, ver `BasePage` en
    `core/CLAUDE.md`) cambió de `context.goBack()` a `context.goToSolicitudes()` — si el usuario
    igual intenta volver con el back nativo, lo manda a la lista de solicitudes en vez de hacer
    pop normal (que ya no tiene a dónde volver útilmente, dado que no hay botón visible).
  - Se quitó la fila "Origen" (canal) de `_CardInfoSolicitud` — junto con la variable `canalInfo`
    (`CanalHelper.get(...)`), que quedó sin otro uso en el archivo.

## Reconciliación de centavos + bug de importe editado que se perdía al reabrir (2026-07-16)
Seguimiento del punto de abajo — el usuario probó con números reales (negociación: precio total
425.00, precio base 225.50, 2 participantes) y encontró que "Importe total" en el footer daba
**424.99**, no 425.00. Dos causas, ambas corregidas:

- **Redondeo acumulado al repartir el total entre participantes.** 425 / 2 / 1.18 = 180.0847...
  — al redondear cada participante a 2 decimales por separado (180.08 c/u), la suma real
  (360.16) queda por debajo de la suma exacta sin redondear (360.1695...), y ese faltante se
  arrastra hasta el total final. Es un problema clásico de repartir un monto con decimales entre
  varias partes — cada parte necesita un valor exacto de 2 decimales (moneda), pero la suma de
  esos valores redondeados no siempre calza con el total original.
  **Fix**: `_importeFijo()` (duplicado en `solicitud_participantes_view.dart` y
  `solicitud_completar_view.dart`, mismo patrón de siempre) ahora distingue si el participante que
  se está por crear es el **último** de los `cantidadEsperada` esperados
  (`context.read<ParticipantesCubit>().state.participantes.length == cantidadEsperada - 1`) — si
  lo es, en vez de la división simple recibe **lo que falta** para que la suma calce exacto:
  `totalSinIgv - sum(importes ya guardados)`. Con el ejemplo real: participante 1 → 180.08
  (división simple), participante 2 (último) → 360.1695... − 180.08 = 180.09 → suma 360.17 → +18%
  = 64.83 → total **425.00** exacto. El resto de participantes (no el último) sigue usando la
  división simple sin reconciliar — solo el último absorbe el centavo de diferencia, patrón
  estándar de reparto de montos en sistemas de facturación.
- **Bug real encontrado de paso, en el mismo archivo (`participante_form_sheet.dart`) — editar un
  participante ya guardado mostraba el importe SUGERIDO recalculado, no el que el asesor
  realmente había guardado.** El prellenado del campo Importe hacía
  `widget.importeFijo != null ? importeFijo : p?.importe` — `importeFijo` (no nulo siempre que
  `cantidadEsperada` esté seteado, o sea cualquier solicitud con negociación de origen) tenía
  prioridad sobre el importe real del participante, incluso al **editar** uno ya guardado. Si el
  asesor bajaba el importe de "Norma" 10 soles a mano y volvía a abrir su ficha, veía el sugerido
  recalculado, no los 10 soles menos que había puesto — y si volvía a presionar "Guardar" ahí sin
  darse cuenta, se perdía el ajuste manual. Corregido: la prioridad ahora es importe ya guardado
  del participante (edición) → importe sugerido (`importeFijo`, solo al crear uno nuevo) → vacío.

## Importe de participante ya no bloqueado + nueva fórmula sin IGV + recuperar negociación al editar (2026-07-16)
Pedido de negocio (jefe del usuario) sobre cómo debería comportarse el importe por participante —
cambio grande, toca desde el SP hasta la UI:

- **Importe siempre editable** — `participante_form_sheet.dart` ya no tiene `_importeBloqueado`
  (se eliminó el campo por completo, antes siempre `true`). El asesor puede ajustar el importe de
  cualquier participante libremente, venga o no de una negociación — decisión explícita: **no** se
  valida el importe de la solicitud contra el precio de la negociación, son cosas distintas.
- **Nueva fórmula del importe sugerido** (`_importeFijo()`, duplicado a propósito en
  `solicitud_participantes_view.dart` y `solicitud_completar_view.dart`, mismo patrón que ya
  documentaba este archivo): ya no es `precioBaseLead` (precio por unidad ANTES del descuento,
  autocompletado al elegir Oportunidad en `lead/`) — ahora es
  `(precioTotalLead / cantidadEsperada) / (1 + igvPorcentaje/100)`. `precioTotalLead`
  (`Negociacion.precio`, "Costo final") ya viene neto del descuento
  (`precioBase × cantidad − descuento = precio`, confirmado con números reales del usuario:
  150.55 × 2 − 21.10 = 280.00), así que el descuento **no** se vuelve a restar acá — ya está
  repartido implícitamente al dividir entre `cantidadEsperada`. Ejemplo real: precio total 280,
  cantidad 2 → 140 c/u con IGV → 118.64 sin IGV, ese es el valor que se sugiere (el asesor lo
  puede cambiar). `precioBaseLead`/`descuentoLead` siguen existiendo en `SolicitudFormState` pero
  **solo** para `_avisarSiPrecioTotalNoCalza` (el aviso de consistencia) — ya no para el importe.
  El divisor es siempre `cantidadEsperada` (la cantidad fija de la negociación), nunca la cantidad
  actual de participantes ya agregados — así el sugerido no cambia según cuántos lleves metidos.
- **El footer de totales vuelve a SUMAR el IGV, no a extraerlo** — revierte el fix del
  2026-07-14 ("IGV invertido en Resumen/Participantes"), que asumía que el importe YA incluía
  IGV. Con la nueva definición (importe = base sin IGV, por diseño), sumar es lo correcto:
  `_ResumenInversion` (`solicitud_participantes_view.dart`) y `_SeccionResumenComercial`
  (`solicitud_resumen_view.dart`) ahora hacen `inversion = sum(importes)`,
  `igv = inversion × igv%`, `importeTotal = inversion + igv` — antes hacían la división inversa
  (`inversion = total / (1+igv%)`). Si todo calza (cantidad de participantes = cantidadEsperada,
  nadie editó el importe sugerido), `importeTotal` debería coincidir con `precioTotalLead` (el
  costo final de la negociación) — esa es justo la validación que pidió el usuario.
- **Bug real encontrado al verificar la cuenta — el descuento se restaba dos veces en el
  guardado.** `SolicitudRemoteDatasource.guardarSolicitud()` hacía
  `dcImporte = sum(participantes.importe) - descuento` — correcto con la fórmula VIEJA (donde el
  importe de cada participante era el precio base completo, sin descuento repartido), pero con la
  fórmula nueva el descuento YA está repartido dentro de cada `importe` (via `precioTotalLead`,
  que ya es neto). Restarlo de nuevo a nivel agregado inflaba el descuento al doble y el
  `DC_IMPORTE_TOTAL` final ya NO coincidía con el precio total de la negociación (con los números
  del ejemplo: 216.19 en vez de 280.00). Se quitó el parámetro `descuento` de toda la cadena
  (`SolicitudRemoteDatasource.guardarSolicitud()` → `SolicitudRepository`/`SolicitudRepositoryImpl`
  → `GuardarSolicitudUseCase` → `guardarSolicitudDesdeWizard`) — ya no se usa para nada, el
  descuento ya viene aplicado en cada `importe`. `dcImporte` ahora es directo
  `sum(participantes.importe)`, sin resta ni `.clamp()` (la suma de importes no-negativos nunca
  puede ser negativa).
- **El cálculo de IGV por participante en el guardado (`igv = p.importe * igvPorcentaje / 100`,
  mismo archivo, sección de participantes/detalle) ya estaba escrito asumiendo `importe` como
  base** — con la fórmula nueva esto queda correcto tal cual, sin tocarlo; de hecho resuelve un
  pendiente viejo que este mismo archivo tenía anotado ("IGV invertido... pendiente, no tocado")
  en vez de crear uno nuevo.
- **Recuperar la negociación de origen al EDITAR una solicitud ya guardada** — antes esto era
  imposible: `Solicitud.idLead` solo viajaba como parámetro de navegación al crear, nunca se podía
  recuperar después (el SP no lo traía de vuelta), así que `cantidadEsperada`/`precioTotalLead`
  siempre quedaban `null` al editar, y agregar un participante nuevo ahí no sugería nada. Motivo
  real por el que esto importa (dado por el usuario): "Guardar" (borrador) permite guardar
  incomplete — incluso sin participantes — así que no basta con que el dato viva solo en memoria
  durante la sesión de creación.
  - **`CSV_SOLICITUD_LST_APP.sql`, task `'DT'`**: se agregó un `LEFT JOIN` nuevo a
    `CRM.T_LEAD_TECMSOLINSCRIPCION01` (tabla que ya existía, ya vincula `NUMSOL`↔`ID_LEAD` — el
    `INSERT` a esa tabla ya pasaba en la rama de creación del task `'U'`, desde siempre, en
    CUALQUIER primer guardado sea borrador o no) y se seleccionó `LI.ID_LEAD` como campo nuevo al
    final (`campos[39]`).
  - **Flutter**: `SolicitudDetalleModel.idLeadOrigen` (nuevo campo, parseado con guard
    `campos.length > 39` por si el SP no está desplegado todavía). En
    `solicitud_completar_view.dart._cargarDetalle()`, después de cargar participantes, si
    `detalle.idLeadOrigen` es un id válido se llama `GetLeadDetalleUseCase` (mismo patrón que ya
    usan `ContactoNegociacionCard`/`NegociacionesTab` en `lead/`) para traer la negociación
    **fresca** (no un snapshot congelado — usa el precio/cantidad/descuento ACTUALES de la
    negociación, que pueden haber cambiado desde que se creó la solicitud, decisión explícita del
    usuario) y llama `SolicitudFormCubit.sembrarDatosNegociacion(...)` con
    `cantidad`/`precioBase`/`descuento`/`idMoneda`/`precioTotal` (sin los campos de
    contacto/prellenado — esos solo aplican en la rama de creación, `_prellenarDesdeNegociacion()`,
    que nunca se llama en el flujo de edición). Envuelto en su propio `try/catch` silencioso — si
    falla (ej. lead borrado, sin conexión), la solicitud igual carga normal, solo sin sugerencia de
    importe para participantes nuevos.

## Reemplazar voucher/O.C. ya subidos + "Máximo" de participantes (2026-07-16)
Seguimiento del punto anterior — el usuario probó el flujo completo (crear con voucher, guardar
borrador, reabrir días después para generar, querer reemplazar el voucher viejo por uno actual y
agregar el O.C.) y encontró 2 gaps más:

- **Bug real — el nombre del archivo ya subido se perdía apenas se editaba cualquier otro
  campo.** `_construirDatosSolicitante()` (`solicitud_completar_view.dart`, llamado en **cada**
  sync — cualquier tecla en cualquier campo del paso 1) armaba
  `archivoVoucherNombre: archivos.archivoVoucher?.name ?? ''` — `archivos` es
  `SolicitudFormCubit.state`, o sea el `PlatformFile?` de **esta sesión**, nunca el nombre que
  trajo el backend. El fix de la sesión anterior (mostrar `nombreExistente` en `BotonAdjuntar`)
  solo se veía bien hasta el primer campo editado — después `DatosSolicitante.archivoVoucherNombre`
  quedaba en `''` de nuevo (el `nombreExistente` que se le pasaba al widget venía de ahí). Se
  corrigió sacando el nombre "ya guardado" de `DatosSolicitante`/`SolicitudFormCubit` por
  completo para este propósito — ahora vive en 2 campos propios del `State`
  (`_archivoVoucherExistente`/`_archivoOCExistente`, `String`), poblados una sola vez en
  `_cargarDetalle()` desde `detalle.archivos` (antes se armaban inline solo para el constructor
  de `DatosSolicitante`). `_construirDatosSolicitante()` ahora hace
  `archivos.archivoVoucher?.name ?? _archivoVoucherExistente` (sesión actual primero, si no hay
  cae al ya guardado) — con esto `DatosSolicitante.archivoVoucherNombre` (usado en el "Documentos
  adjuntos" del Resumen) ya no se pierde con cada tecla.
- **"Quitar" ahora funciona también sobre un archivo ya guardado — no borra nada del backend,
  solo habilita elegir uno nuevo.** No existe una operación de borrado-sin-reemplazo en el SP
  (`CSV_SOLICITUD_CUD_APP`, task `'AR'`) — lo único que hay es "subir un archivo de ese tipo",
  que por el fix del `DELETE FROM ... WHERE NUMSOL=@NUMSOL AND TIPO=@TIPO_ARCHIVO` (ver sección de
  arriba) reemplaza limpiamente al anterior del mismo tipo. Entonces `_quitarArchivo(esVoucher)`
  (`solicitud_completar_view.dart`) ahora revisa cuál de los 2 casos aplica: si hay un
  `PlatformFile` de esta sesión, lo quita del cubit (comportamiento de siempre); si no, pero sí
  hay un `_archivoVoucherExistente`/`_archivoOCExistente` no vacío, solo lo limpia con `setState`
  (sin llamar al backend) — eso re-habilita el botón "Adjuntar" para elegir el archivo nuevo, que
  al presionar "Guardar"/"Generar solicitud" sube y reemplaza al anterior en la misma llamada
  `'AR'`. `BotonAdjuntar` (`solicitud_completar_adjuntos.dart`) se simplificó — ya no distingue
  "archivo de sesión" vs "archivo existente" con 2 ramas de render, solo calcula
  `nombreMostrado = archivo?.name ?? nombreExistente` y muestra "quitar" siempre que haya un
  nombre que mostrar (ambos casos llaman el mismo callback `onQuitar`, que del lado del padre ya
  sabe cuál de los 2 escenarios resolver).
- **Confirmado sin cambios — "Guardar" sin restricción de cantidad, "Generar solicitud" exige
  cantidad exacta.** Ya estaba implementado (ver sección de abajo, "Validación movida a..." —
  `validarSolicitudParaGenerar` compara `participantes.length != cantidadEsperada`); el usuario lo
  pidió de nuevo como confirmación, no había nada que corregir acá.
- **"Máximo: N" junto al conteo de participantes** — el encabezado de la sección Participantes
  (paso 2, `solicitud_participantes_view.dart`) ahora muestra
  `"$cantidad participante/s · Máximo: $cantidadEsperada"` cuando la solicitud viene de una
  negociación con cantidad ya definida (`SolicitudFormCubit.state.cantidadEsperada != null`) — si
  no viene de una negociación, se queda solo con `"$cantidad participante/s"` como antes.

## Validación movida a "Generar solicitud" + stepper de progreso + fix de archivos ya subidos (2026-07-16)
**⚠️ Revertido el 2026-07-17** — ver "Cada 'Siguiente' ahora valida Y guarda de verdad" arriba:
"Continuar" (ahora "Siguiente") volvió a validar y además guarda de verdad en cada paso, por
pedido de negocio. El stepper de progreso y el fix de archivos ya subidos de esta sección siguen
vigentes tal cual — solo el punto "'Continuar' ya no valida ni bloquea" de acá abajo quedó
obsoleto.

Pedido por el usuario en la misma sesión que los bugs de Comprobante/Nacionalidad (ver sección de
abajo) — cuatro cambios relacionados con guardar/generar y subir archivos:

- **"Continuar" (pasos 1, 2, 3) ya no valida ni bloquea** — se eliminaron los getters
  `_formCompleto` (pasos 1 y 3, en `solicitud_completar_view.dart`/`solicitud_facturacion_view.dart`)
  y el gate `participantes.isEmpty ? null : ...` (paso 2, `solicitud_participantes_view.dart`). El
  botón siempre avanza, sin snackbar de error. Motivo (decisión explícita del usuario): antes cada
  paso exigía estar completo para poder seguir, lo cual no tenía sentido para "Guardar" (borrador,
  nunca debería exigir nada) y tampoco dejaba moverse libremente por el wizard. La lógica de
  "saltar Facturación" (todos invitados) del paso 2 **no se tocó** — es routing entre pasos, no
  validación bloqueante.
- **Toda la validación de campos obligatorios se centralizó en "Generar solicitud"** —
  `validarSolicitudParaGenerar(BuildContext)` (`solicitud_guardar_helper.dart`) revisa, en este
  orden: solicitante completo (mismos campos que el viejo `_formCompleto` del paso 1), al menos 1
  participante, cantidad exacta de participantes si viene de una negociación con
  `cantidadEsperada` (ya existía, se movió acá), y facturación completa (mismos campos que el
  viejo `_formCompleto` del paso 3) **solo si algún participante no es invitado** (mismo criterio
  `esInvitado` que ya usaba el paso 2 para saltar Facturación). Retorna `null` si todo está
  completo, o un `SolicitudValidacion(paso, mensaje)` — `solicitud_resumen_view.dart._onGenerarSolicitud()`
  usa ese `paso` para navegar directo ahí (`widget.onEditarPaso(paso)`) antes de mostrar el
  mensaje, en vez de solo fallar en Resumen sin decir dónde falta algo. **"Guardar" (borrador)
  nunca llama esta función — sigue sin validar nada, deja pasar cualquier estado a medio llenar.**
- **Stepper de progreso paso a paso en los 5 botones Guardar/Generar** — nuevo
  `SolicitudProgreso` (`ValueNotifier<List<PasoProgresoItem>>`) + `SolicitudProgresoOverlay`
  (`solicitud_progreso_guardado.dart`, mismo patrón visual que `AppLoadingOverlay` de core pero
  con una lista de pasos en vez de un mensaje único). Cada paso aparece con spinner al iniciar
  (`progreso.iniciarPaso(texto)`) y pasa a check al completarse (`progreso.completarPasoActual()`)
  — los pasos que no aplican (sin archivo adjunto) ni se agregan a la lista. Textos: "Guardando
  solicitud..."/"Generando solicitud..." (según `esBorrador`), "Subiendo voucher...", "Subiendo
  O.C....". `generarSolicitudCompleta()`/`guardarBorradorCompleto()` (esta última nueva, espejo de
  `generarSolicitudCompleta` pero con `esBorrador: true` y sin validación previa — reemplaza el
  chaining manual `guardarSolicitudDesdeWizard` + `subirArchivosPendientes` que tenían los 4
  botones "Guardar") reciben un `progreso` opcional y, si viene, dejan el último check visible
  ~500ms antes de retornar (para que se alcance a ver antes de navegar/cerrar). Cada uno de los 5
  `State` (`solicitud_completar_view.dart`, `solicitud_participantes_view.dart`,
  `solicitud_facturacion_view.dart`, `solicitud_resumen_view.dart` ×2) tiene su propio
  `SolicitudProgreso` (`dispose()` lo libera) y lo resetea (`_progreso.reset()`) apenas termina el
  flujo, antes de mostrar el snackbar o navegar.
- **Bug real corregido — paso 1 no mostraba un voucher/O.C. ya subido al reabrir la solicitud.**
  `BotonAdjuntar` (`solicitud_completar_adjuntos.dart`) solo miraba `archivo` (`PlatformFile?`, el
  adjuntado *en esta sesión*) — el nombre que sí trae bien el backend
  (`DatosSolicitante.archivoVoucherNombre`/`archivoOCNombre`, parseado desde `detalle.archivos`
  en `_cargarDetalle()`) nunca se conectaba a este widget, solo se usaba en el Resumen (paso 4).
  Se agregó el parámetro `nombreExistente` (default `''`) — si `archivo` es `null` pero
  `nombreExistente` no está vacío, se muestra la misma `TarjetaArchivoAdjunto` (sin botón
  "quitar" — no hay una operación de borrado de archivo ya subido, solo reemplazo subiendo uno
  nuevo del mismo tipo) y el botón "Adjuntar" se deshabilita — un archivo por tipo, igual que con
  `archivo`. `solicitud_completar_view.dart` pasa
  `formState.solicitante?.archivoVoucherNombre/archivoOCNombre` a los 2 `BotonAdjuntar` del
  paso 1.
- **Confirmado (sin cambios) — `subirArchivosPendientes()` nunca llama el task `'AR'` si no hay
  nada que subir.** Los `if (voucher != null)`/`if (oc != null)` ya evitaban esto — si el asesor
  no adjunta nada en la sesión (o reabre una solicitud que ya tiene un archivo y no lo toca, caso
  en que el `PlatformFile` local sigue `null` porque no hay bytes que reconstruir desde el
  backend), ninguno de los 2 se llama. Esto también evita re-subir un archivo ya guardado sin que
  el usuario haya hecho nada.

## Bugs reales — Comprobante y Nacionalidad de facturación no sobrevivían a reabrir la solicitud (2026-07-16)
Reportados por el usuario ("el tipo de comprobante no sé por qué al volver a entrar no carga, y
lo de nacionalidad de facturación tampoco") y confirmados contra el `.sql` real de los 2 SPs que
usa el wizard (`D:\Proyectos\NatCodee\NC.SQLChangeLock\DBEAN\StoredProcedures\`, repo aparte del
CRM — hasta ahora nunca se habían podido cruzar los cambios de Flutter contra el SP real, todo
lo pendiente de abajo se basaba en suposiciones). Dos bugs distintos, corregidos en Flutter +
ambos SPs:

- **Comprobante — campo faltante en el POST, no un problema del SP.**
  `CSV_SOLICITUD_CUD_APP` (task `'U'`) siempre esperó **42 campos** de cabecera —
  `@ID_TIPO_COMPROBANTE_FAC = field42` — pero `SolicitudRemoteDatasource.guardarSolicitud()`
  solo armaba 41 (terminaba en `LL_USUARIO`). `facturacion.comprobanteId` se capturaba bien en
  la UI y se leía bien de vuelta (`facComprobanteId`, task `'DT'`) — el dato se perdía justo en
  el guardado, por eso el SP siempre grababa `TIPO_COMPROBANTE = NULL` sin importar lo elegido.
  Corregido agregando `facturacion?.comprobanteId ?? ''` como field42 — no requirió tocar el SP,
  ya estaba listo para recibirlo.
- **Nacionalidad de facturación — bug de 3 partes, sí requirió tocar ambos SPs.** El combo
  Nacionalidad del paso 3 (`DatosFacturacion.nacionalidadId`, gentilicio — distinto de País) se
  capturaba bien en la UI pero: (1) el datasource nunca lo mandaba — el único dato de
  país/nacionalidad que viajaba era `facturacion.paisId` (field25, `ID_NACION_FAC`); (2) el SP
  reusaba esa misma variable para **dos columnas** de `T_TECMSOLINSCRIPCION01_FACTURACION`
  (`ID_NACIONALIDAD` **y** `ID_PAIS`, mismo valor en ambas) — no había forma de guardar un valor
  de nacionalidad distinto del de país aunque Flutter lo mandara; (3) el `'DT'` de lectura nunca
  traía `TC.ID_NACIONALIDAD` de vuelta, solo `TC.ID_PAIS` (→ `facPaisId`). Corregido:
  - **`CSV_SOLICITUD_CUD_APP`**: nueva variable `@ID_NACIONALIDAD_FAC` (field43, declarada junto
    a `@ID_TIPO_COMPROBANTE_FAC`), usada para la columna `ID_NACIONALIDAD` en el `INSERT`/
    `UPDATE` de `T_TECMSOLINSCRIPCION01_FACTURACION` — `ID_PAIS` sigue usando `@ID_NACION_FAC`
    (paisId), ya no comparten variable.
  - **`CSV_SOLICITUD_LST_APP`**, task `'DT'`: se agregó `ISNULL(TC.ID_NACIONALIDAD, '')` como
    campo nuevo al final del `SELECT` (`campos[38]`, después de `CANT_PARTICIPANTES`) — mismo
    patrón que el resto de campos agregados al final para no correr los índices existentes.
  - **Flutter**: `guardarSolicitud()` manda `facturacion?.nacionalidadId ?? ''` como field43;
    `SolicitudDetalleModel` agrega `facNacionalidadId` (`campos.length > 38 ? campos[38] : ''`
    — guard defensivo porque este campo es nuevo y el SP/Flutter podrían desplegarse en
    momentos distintos); `solicitud_completar_view.dart._cargarDetalle()` resuelve
    `facNacionalidad` contra el catálogo `nacionalidades` (mismo que ya usaba para el
    solicitante) y lo pasa al reconstruir `DatosFacturacion`.
- **Los `.sql` de ambos SPs viven en `NC.SQLChangeLock` (repo aparte, con su propio git)** — se
  editaron directo ahí (están en UTF-16LE con BOM, no UTF-8 — cualquier edición futura debe
  preservar esa codificación o SSMS los mostrará corruptos) y quedan pendientes de que alguien
  los despliegue a la base de datos real; los cambios de Flutter de este feature ya asumen que
  el SP desplegado tiene los 43 campos / el campo `ID_NACIONALIDAD` nuevo.

## Bug real — Dirección no se autocompletaba al buscar RUC en Facturación (2026-07-15)
`DocumentoExterno.direccion` (`core/models/documento_externo.dart`, campo [3] de
`Clientes/BuscarDocumento`) **sí trae dirección cuando el resultado viene de SUNAT/RUC**
(ej. `"SUNAT¦NATCODEE S.A.C.¦150135¦MZA. I1 LOTE 5 URB. SAN FRANCISCO DE CAYRAN¦ACTIVO¦..."` —
campo [3] = dirección) — DNI/RENIEC no la trae (queda vacío ahí, el backend solo devuelve
nombres/apellidos para ese caso). `_buscarDocumento()` en el paso 3
(`solicitud_facturacion_view.dart`) ya usaba `resultado.nomEmpresa`/`nombres`/`apePaterno`/
`apeMaterno`/`correo` para autocompletar, pero **nunca leía `resultado.direccion`** — el campo
Dirección se quedaba vacío incluso buscando un RUC que sí trae ese dato. Corregido: se agregó
`if (resultado.direccion.isNotEmpty) { _ctrlDireccion.text = resultado.direccion; }` al final del
mismo bloque, sin condicionarlo a `_esRuc` (para DNI simplemente llega vacío y el `if` no hace
nada, mismo patrón que ya usa `correo` ahí mismo).
**Ojo — esto es distinto del caso "Facturar al solicitante"**: cuando ese switch autocompleta el
paso 3 con los datos del paso 1, la Dirección se queda vacía por una razón totalmente distinta
— `DatosSolicitante` (paso 1) no tiene ningún campo de dirección, el solicitante nunca la
captura ahí. Ese caso se dejó como está a propósito (el usuario lo confirmó) — no agregar un
campo Dirección al paso 1 sin que lo pidan explícitamente.

## RUC de la negociación + fix real de arquitectura (2026-07-15)
Siguiendo la sección de abajo ("Más datos..."), se agregó RUC (`Negociacion.ruc`/`EM.RUC`) y de
paso se corrigió un problema más de fondo que esa primera pasada dejó sin detectar:

- **`'LN'` (task que alimenta `NegociacionesCubit`, historial de negociaciones en Conversaciones
  y Seguimiento) nunca trajo contacto** — solo `'DT'`/`'DN'` hacen join con `T_CONTACTO`/
  `T_EMPRESA`/`T_CONTACTO_CORREO`. Esto significaba que 2 de los 3 orígenes de "Generar
  solicitud" (`NegociacionCard`/Conversaciones y `ContactoNegociacionCard`/Seguimiento, ambos
  alimentados por `NegociacionesCubit` → `'LN'`) mandaban `nombresNegociacion`/
  `apellidoPaternoNegociacion`/etc. **siempre vacíos** — el wiring de la sección de abajo
  compilaba y no rompía nada, pero no prellenaba nada de verdad en esos 2 orígenes. Solo el
  auto-redirect de `EditLeadPortrait` (que sí usa un `Negociacion` sacado de `InfoLeadCubit`,
  `'DT'`/`'DN'`) prellenaba correctamente.
- **Se decidió NO agregar los joins de contacto a `'LN'`** (una opción real que se evaluó) —
  ese task se usa para listas (posible impacto de performance por fila) y ya es consumido en
  varios lugares. En su lugar: **al presionar "Generar solicitud" en los 2 orígenes de `'LN'`,
  se trae un detalle fresco por `idLead` (`GetLeadDetalleUseCase`, task `'DT'` — el mismo que ya
  usa `_irAEditar`/`InfoLeadCubit` en estos mismos archivos) antes de navegar**, y se usan
  TODOS los datos de ese detalle fresco (no solo contacto — también cantidad/precioBase/
  descuento/moneda/precioTotal) para armar los parámetros de `goToFichaCompletarSolicitud`, en
  vez de los del objeto `Negociacion` que ya estaba en memoria (potencialmente incompleto o
  desactualizado). `ContactoNegociacionCard` (antes `StatelessWidget`) se convirtió a
  `StatefulWidget` para poder mostrar `AppLoadingOverlay` mientras se trae el detalle (mismo
  patrón que `_ListaNegociacionesState` en `negociaciones_tab.dart`, que ya era Stateful).
- **`Negociacion.ruc`** (nuevo campo, default `''`) — parseado solo en
  `NegociacionModel.fromDetalleRawString` (índice 39, agregado al final del SP tras
  `LD.MODALIDAD`) — `fromRawString` (`'LN'`) no lo trae, queda en `''` para esos objetos (ya no
  importa, porque los 2 orígenes de `'LN'` ahora ignoran el objeto en memoria para generar
  solicitud, como se explicó arriba). `SolicitudFormCubit.sembrarDatosNegociacion`/
  `SolicitudFormState.rucLead` y el prellenado en `_cargarDetalle()` siguen el mismo patrón que
  el resto de datos de contacto (solo prellenado, no bloquea, el asesor lo puede corregir).
- **Columna real en la BD**: `CRM.T_EMPRESA.RUC` (alias `EM` en el SP `[CRM].[CSV_LEADS_LST_APP]`,
  tasks `'DT'`/`'DN'`) — agregada al `SELECT` de ambos tasks (son idénticos en forma) como el
  último campo, después de `LD.MODALIDAD`.

## Más datos de la negociación se prellenan en el paso 1 (2026-07-15)
Auditoría pedida por el usuario: de 11 datos de la negociación que la encargada quería ver
reflejados en el paso 1 al generar una solicitud (correo, RUC, nombre de empresa, nombres,
apellidos, precio base, cantidad de participantes, cargo, celular, precio total, descuento),
antes solo **3** llegaban de verdad al wizard (precio base, cantidad, descuento — vía
`SolicitudFormCubit.sembrarDatosNegociacion`). El resto se mandaba `''`/`0` a propósito en los 3
call sites de "Generar solicitud" (`ContactoNegociacionCard`/`NegociacionesTab`/
`EditLeadPortrait` auto-redirect), y aunque `_solicitudDesdeNegociacion()` (usado solo para
editar/ver, no para generar) sí copiaba varios de estos campos a un `Solicitud`, **nunca se leían
de vuelta** — `_cargarDetalle()` (paso 1) solo lee `idSolicitud` del `Solicitud` de navegación,
ignora todo lo demás (mismo patrón que documenta "SolicitudDetalleView ya no confía en el
Solicitud de navegación" más abajo).

- **RUC y Cargo quedan sin resolver — no es un problema de threading, el dato no existe en
  ningún lado todavía.** `Negociacion` (`lead/domain/entities/negociacion.dart`) no tiene campo
  RUC (ninguna columna del SP lo trae). `Cargo` sí llega como un id crudo sin catálogo
  (`CT.ID_CARGO`, parte del SP `'DT'`/`'DN'` de negociación) pero nunca se parsea a la entidad,
  y `Contacto.cargo` (otro modelo, lista de contactos) tampoco se parsea nunca
  (`ContactoModel.fromFields` lo deja en blanco a propósito, comentario "llega como id crudo sin
  catálogo — no se parsea todavía"). La única sección que alguna vez mostró un campo "Cargo" de
  contacto (`EditLeadContactoSection`) está comentada/muerta en `EditLeadPortrait` desde antes.
  **Conclusión: quedan vacíos como hoy** — el asesor los completa a mano en el paso 1; resolver
  esto de verdad requiere trabajo de backend (nueva columna RUC en el SP, catálogo para
  `ID_CARGO`) que no existe todavía.
- **Correo, Nombres, Apellidos, Nombre de empresa, Celular** — sí existen en `Negociacion` y
  ahora sí llegan al paso 1, pero **solo como prellenado, no como bloqueo** (a diferencia de
  precio base/cantidad/descuento/moneda, que sí bloquean edición): el asesor puede corregirlos
  libremente si algo cambió desde que se registró la negociación. Flujo completo:
  1. Los 3 call sites de "Generar solicitud" (`contacto_negociacion_card.dart._generarSolicitud`,
     `negociaciones_tab.dart._generarSolicitud`, `edit_lead_portrait.dart._guardar()` auto-redirect)
     ahora pasan 7 parámetros nuevos a `goToFichaCompletarSolicitud`:
     `nombresNegociacion`/`apellidoPaternoNegociacion`/`apellidoMaternoNegociacion`/
     `nombreEmpresaNegociacion`/`correoNegociacion`/`celularNegociacion`/
     `celularCodigoTelefonoNegociacion` (celular y su prefijo separados —
     `Negociacion.numero`/`.prefijoPais` — mismo formato que `PaisItem.codigoTelefono`, no el
     getter `telefonoCompleto` que ya los junta en un string).
  2. `SolicitudCompletarPage` los recibe y se los pasa a
     `SolicitudFormCubit.sembrarDatosNegociacion()` (extendido con los mismos 7 params +
     `precioTotal`), que ahora también los guarda en `SolicitudFormState` (`nombresLead`,
     `apellidoPaternoLead`, `apellidoMaternoLead`, `nombreEmpresaLead`, `correoLead`,
     `celularLead`, `celularCodigoTelefonoLead`).
  3. `_SolicitudCompletarViewState._prellenarDesdeNegociacion()` (nuevo método,
     `solicitud_completar_view.dart`) — llamado junto a `_sembrarValoresPorDefecto()` en la rama
     de creación de `_cargarDetalle()` — copia lo que venga no-vacío a
     `_ctrlNombres`/`_ctrlApellidoPaterno`/`_ctrlApellidoMaterno`/`_ctrlCorreo`/`_ctrlCelular`, y
     resuelve `_paisCelular` contra `CatalogsBloc.paises` por `codigoTelefono`. **Nombre de
     empresa va a Razón Social** (`_ctrlRazonSocial`, sección "Información comercial" — el RUC
     sigue vacío, el asesor lo busca con `DocumentoExternoService` o lo tipea).
  4. Si `formState.cantidadEsperada == null` (no vino de negociación), el método no hace nada —
     mismo candado que ya usa `cantidadEsperada` para todo lo demás.
- **Precio total** (`Negociacion.precio`) — el usuario pidió pasarlo, pero confirmó que es
  **solo para validación/consistencia**, no para mostrarlo ni bloquear nada (el Resumen del
  wizard ya calcula su propio total sumando el importe de cada participante). Se guarda en
  `SolicitudFormState.precioTotalLead` y `_avisarSiPrecioTotalNoCalza()` (mismo archivo) compara
  `precioBaseLead × cantidadEsperada − descuentoLead` contra ese valor — si difieren en más de
  `0.01`, muestra un `AppSnackBar.warning` una sola vez al entrar (vía
  `WidgetsBinding.instance.addPostFrameCallback`, porque `_cargarDetalle()` corre en
  `initState()` antes del primer frame — mostrar el snackbar directo ahí no funciona). No
  bloquea nada, solo avisa — señal de que la negociación se desfasó (se editó el precio después
  de fijar precio base/cantidad/descuento).

## Sincronización switch ↔ lista de participantes + renumeración de ids (2026-07-15)
Dos ajustes sobre la relación entre el switch "El solicitante será participante" (paso 1) y la
lista de participantes (paso 2), pedidos con ejemplos concretos por el usuario:

- **Borrar el participante-solicitante apaga el switch solo** — antes, si el asesor activaba el
  switch en paso 1 (crea un `ParticipanteLocal` con `esSolicitante: true` en paso 2) y luego
  borraba ese participante a mano desde la lista, el switch en paso 1 se quedaba encendido sin
  ningún participante real detrás — el próximo "Continuar"/"Guardar" en paso 1 lo recreaba de la
  nada (`ParticipantesCubit.sincronizarSolicitante` solo mira `datos.solicitanteEsParticipante`,
  no sabe que el usuario lo borró manualmente en otro paso). Corregido con un
  `BlocListener<ParticipantesCubit, ParticipantesState>` envolviendo el `build()` de
  `SolicitudCompletarView` (`solicitud_completar_view.dart`) — `listenWhen` solo dispara en la
  transición exacta "había un participante `esSolicitante`" → "ya no hay ninguno" (no en la
  carga inicial, que nunca tuvo uno). Si eso pasa y el switch seguía en `true`, lo apaga
  (`setState` + `_sincronizarCubit()`) para que quede consistente con lo que el asesor hizo en
  paso 2.
- **Volver al paso 1 con el switch todavía activo no debe cambiar nada** — esto ya lo cubre el
  fix de "Bug real" de abajo (`sincronizarSolicitante` preserva `id`/`importe` del registro
  existente) — se deja explícito acá porque fue parte del mismo ejemplo que dio el usuario.

## Renumeración de ids al eliminar un participante (2026-07-15)
`ParticipantesCubit.eliminar(id)` ahora **renumera** el resto de la lista para que los ids
sigan siendo un correlativo sin huecos (`1, 2, 3...`) — ejemplo real del usuario: participante
`1` y `2` en la lista, se borra el `1` → el `2` pasa a ser `1`. `eliminarTodos()` también resetea
`_nextId` a `1` (antes solo vaciaba la lista, dejando el contador de ids adelantado sin razón).
Ambos casos recalculan `_nextId` al vuelo (`_renumerar()`, mismo archivo) para que el próximo
`agregar()` continúe el correlativo justo después del último id vigente, nunca choque ni deje
huecos.
**Por qué esto es seguro con ids que ya vinieron del backend** (`cargarParticipantes()`, al
editar una solicitud existente, preserva el id real de `T_TECMSOLINSCRIPCION02.ID` en vez de
asignar uno nuevo — ver "Bug real" abajo): la solicitud completa se reenvía en **cada**
guardado (`SolicitudRemoteDatasource.guardarSolicitud()`, `detalle` = la lista completa de
participantes actual, con sus ids tal cual están en ese momento) — mismo patrón que ya usa el
task `'AR'` de archivos, que borra todo lo existente para ese NUMSOL antes de volver a insertar
lo nuevo. No hay una operación de "actualizar solo la fila que cambió" que dependa de que el id
se mantenga estable entre guardados — cualquier id que se mande en el próximo guardado es, en
los hechos, el id definitivo de esa fila desde ese momento. **Sin confirmar 100% con el SP real
(no hay `.sql` versionado en el repo)** — si en el futuro se descubre que el backend sí hace
upsert por id en vez de reemplazar todo, esta renumeración dejaría de ser segura para
participantes ya guardados (podría duplicar filas) y habría que limitarla a participantes
agregados en la sesión actual, no a los cargados desde el backend.

## Bug real — importe/id del participante-solicitante se perdían al re-sincronizar (2026-07-15)
`ParticipantesCubit.sincronizarSolicitante()` (llamado desde el paso 1 en cada "Continuar"/
"Guardar" cuando el switch "El solicitante será participante" está activo — ver
`solicitud_completar_view.dart`) **regeneraba un `ParticipanteLocal` completamente nuevo cada
vez que se llamaba**, con `id: _nextId++` (un id nuevo, sin relación con el anterior) e
`importe: 0` hardcodeado — sin importar que ya existiera un registro de ese mismo solicitante-
participante de una llamada anterior. Efecto real: cada vez que el asesor volvía al paso 1
(desde paso 2/3/4 con "Atrás") y presionaba "Continuar"/"Guardar" de nuevo, el importe fijado
para ese participante se perdía (volvía a `0`) — el bug que reportó el usuario ("el importe de
participantes no se guarda al retroceder"). Además, como `ParticipanteLocal.id` se manda tal
cual como `ID` de fila al SP (`CSV_SOLICITUD_CUD_APP`, ver más abajo), regenerar el id en cada
re-sync también arriesgaba filas duplicadas en el backend al editar una solicitud ya guardada
(el id real que vino de `getSolicitudDetalle()` se perdía y se reemplazaba por uno inventado
del lado del cliente).

Corregido: `sincronizarSolicitante()` ahora busca el registro `esSolicitante` anterior antes de
reemplazarlo — si existe, **preserva su `id`** (no llama `_nextId++` de nuevo) y su `importe`
(salvo que se pase un `importeFijo` nuevo — ver abajo), en vez de recrearlo desde cero cada vez.
También ahora acepta `importeFijo` (`double?`, mismo valor que ya calcula "Nuevo participante"
vía `SolicitudFormState.precioBaseLead`/`cantidadEsperada`) — `solicitud_completar_view.dart`
tiene su propio `_importeFijo()` (mismo cálculo duplicado a propósito, ya que
`sincronizarSolicitante` genera su `ParticipanteLocal` sin pasar por el modal de participante) y
lo pasa en ambas llamadas (`_onContinuar`/`_onGuardar`).

## Botones "Atrás" vs "Cancelar" del wizard (2026-07-15)
**Solo el paso 1 tiene un botón "Cancelar"** (`SolicitudCompletarView`, sale del wizard entero
con confirmación — "¿Desea cancelar el proceso de solicitud?"). Los pasos 2, 3 y 4 **nunca**
cancelan nada — solo retroceden un paso dentro del mismo wizard, sin perder datos (todo vive en
los cubits compartidos, ver "Wizard de una sola page" más abajo) — por eso su botón dice
**"Atrás"** (`AppIcons.back`, mismo `backgroundColor: AppColors.brandRaspberryAccessible` que
antes tenía el botón mal llamado "Cancelar"), no "Cancelar". Antes los pasos 2 y 4 mostraban
"Cancelar" aunque su `onPressed` solo hacía `_irAPaso(paso - 1)`/pop simple — nunca salían del
wizard, la etiqueta del botón no coincidía con lo que realmente hacía. Se corrigió el texto Y se
renombró el parámetro `onCancelar` → `onAtras` en `SolicitudParticipantesView` (paso 2) y
`SolicitudResumenView` (paso 4) para que el nombre ya no sea engañoso — mismo patrón que
`SolicitudFacturacionView.onAtras` (paso 3), que ya estaba bien desde el inicio.
`solicitud_wizard_view.dart` wireaba el paso 4 con `onCancelar: () => context.goBack()` (salía
del wizard entero) — ahora es `onAtras: () => _irAPaso(3)` (retrocede a Facturación, igual que
los demás).

## Guardar desde el Resumen navega al detalle de la solicitud (2026-07-15)
El botón "Guardar" del paso 4 (`SolicitudResumenView._onGuardar()`) antes solo mostraba un
snackbar de éxito/error y dejaba al asesor parado en el mismo paso — ahora, si el guardado sale
`CrudOk`, sale del wizard (`Navigator.of(context).pop()`) y navega directo al detalle de esa
misma solicitud (`context.goToDetalleSolicitud(solicitud: widget.solicitud.copyWith(idSolicitud:
numSol))`, `numSol` leído de `SolicitudFormCubit.state.numSol` — ya actualizado por
`guardarSolicitudDesdeWizard()` si esta fue la primera vez que se creó). El `Solicitud` que se
pasa es solo un placeholder de navegación (mismo patrón que en toda la lista/negociaciones,
ver "SolicitudDetalleView ya no confía en el Solicitud de navegación" más abajo) —
`SolicitudDetalleBloc` trae los datos frescos por `NUMSOL` apenas se abre esa pantalla. En caso
de error/alerta (`CrudAlert`/`CrudError`/etc.) sigue mostrando el snackbar de siempre y se queda
en Resumen, sin navegar — **no** se tocó `_onGenerarSolicitud()` (Generar solicitud sigue yendo
a `SolicitudGeneradaPage`, un flujo distinto y ya correcto).

## Defaults al crear — Tipo documento DNI + Nacionalidad Perú (2026-07-15)
Al **crear** (nunca al editar/restaurar un registro ya guardado), 3 lugares del wizard
preseleccionan Tipo documento = DNI y Nacionalidad = Perú (ids reales de
`CatalogsBloc.valoresDefecto.idTipoDocDni`/`idNacionalidad`, parte [13] del SP — nunca
hardcodear el id), para que el asesor no tenga que elegirlos a mano en el caso más común:
- **Datos del solicitante** (paso 1) — `_SolicitudCompletarViewState._sembrarValoresPorDefecto()`
  (`solicitud_completar_view.dart`), llamado desde `_cargarDetalle()` solo en la rama
  `numSol.isEmpty` (creación nueva). **Sexo se deja sin seleccionar a propósito** — a
  diferencia de documento/nacionalidad no hay un valor por defecto razonable, el asesor debe
  elegirlo siempre.
- **Nuevo participante** (`participante_form_sheet.dart`) — mismo cálculo en
  `initState()`, dentro del `if (p == null)` (solo al crear, nunca al editar un participante
  existente). Tipo de participante (Pagante) y prefijo de celular (Perú) ya tenían su propio
  default de antes (`esInvitado == false` / `valoresDefecto.idPais`), sin cambios acá.
- **Facturación** (paso 3, `solicitud_facturacion_view.dart`) — mismo cálculo al final de
  `didChangeDependencies()`, en la rama donde ni hay `datos` guardados (venir de "Atrás") ni
  `solicitante.facturarAlSolicitante` aplicó su propio prefill — o sea, solo cuando de verdad
  no hay ningún dato previo que restaurar.

## Validación de N° documento centralizada — `DocumentoValidationUtils` (2026-07-15)
Datos del solicitante (paso 1) ya calculaba longitud máxima + solo-dígitos según el tipo de
documento elegido (`_maxLengthPorTipoDoc`/`_soloDigitosPorTipoDoc`, ambos privados de
`SeccionDatosSolicitante`), pero Facturación (paso 3) y Nuevo participante no tenían esta regla
— sus campos de documento aceptaban cualquier longitud/carácter sin restricción (Facturación
además tenía el teclado hardcodeado a `TextInputType.number`, incorrecto para Carnet de
extranjería/Pasaporte que llevan letras). Se extrajo la regla a
`DocumentoValidationUtils` (`core/utils/documento_validation_utils.dart`, ver `core/CLAUDE.md`)
— único lugar con el mapeo tipo→longitud/teclado, comparado contra los ids reales de
`CatalogsBloc.valoresDefecto` (parte [13] del SP, nunca hardcodeados). Los 3 lugares con un
campo de documento propio ahora lo usan:
- **`SeccionDatosSolicitante`** (`solicitud_completar_datos_solicitante.dart`) — se eliminaron
  los 2 métodos privados, ahora llama al utilitario directo en `build()`.
- **`_SeccionDatosFacturacion`** (`solicitud_facturacion_view.dart`) — recibe
  `numDocMaxLength`/`numDocKeyboardType`/`numDocInputFormatters` ya calculados por
  `_SolicitudFacturacionViewState` (mismo patrón que `correoLabel`, calculado por el padre y
  pasado como prop) — cuando el tipo de documento es RUC, el resultado natural del utilitario ya
  da 11 dígitos solo-números, no hizo falta un caso especial además de `esRuc` (que solo decide
  el label "RUC \*" vs "Número documento \*").
- **`participante_form_sheet.dart`** — mismo cálculo en `build()`, usando `_tipoDocId` propio del
  formulario. También se agregó `_numDocCtrl.clear()` al cambiar el combo Tipo doc. (mismo
  patrón que ya tenían paso 1 y paso 3) — evita dejar texto que no calza con el nuevo tipo (ej.
  letras de Pasaporte al cambiar a DNI).

## Autocompletado por documento — Solicitante, RUC comercial, Facturación y Participante (2026-07-15)
Los 4 lugares del wizard con un campo de documento propio (Número documento del solicitante,
RUC de Información comercial, Número documento/RUC de Facturación, N° documento del formulario
de participante) buscan contra `DocumentoExternoService` (`Clientes/BuscarDocumento` — ver
`core/CLAUDE.md` → `DocumentoExternoService`/`DocumentoExterno`) al perder foco o presionar el
check del teclado (`TextInputAction.done` + `onSubmitted`, más un `FocusNode` local que dispara
en la misma acción al perder foco — doble gatillo, mismo patrón en los 4):

- **Número documento** (`SeccionDatosSolicitante`,
  `solicitud_completar_datos_solicitante.dart`) — busca el documento (DNI 8 dígitos o RUC 11) y
  autocompleta Nombres/Apellido paterno/Apellido materno/Correo del solicitante.
- **RUC** (`SeccionInfoComercial`, `solicitud_completar_secciones.dart`, sección "Información
  comercial", solo visible con tipo de persona Jurídica) — busca siempre como RUC (11 dígitos)
  y solo llena **Razón Social** — no toca Nombres/Apellidos del solicitante, son dos campos y
  dos búsquedas independientes.
- **Número documento/RUC de Facturación** (`_SeccionDatosFacturacion`,
  `solicitud_facturacion_view.dart`, paso 3) — mismo mecanismo; si el tipo de documento elegido
  es RUC (`_esRuc`) solo llena **Razón Social** (`ctrlNombresRazon`, campo compartido con
  Nombres); si no, llena Nombres/Apellido paterno/Apellido materno igual que el solicitante.
  Correo se llena en ambos casos si el resultado lo trae.
- **N° documento del formulario de participante** (`participante_form_sheet.dart`) — ya existía
  desde antes (es el que se copió para los demás puntos); autocompleta Nombres/Apellido
  paterno/Apellido materno/Correo del participante. Si el resultado viene de SUNAT (RUC sin
  persona natural — ya no debería pasar en la práctica porque el combo Tipo doc. excluye RUC,
  ver "Tipo documento de participante" abajo, pero el fallback queda por si el usuario pega un
  número de 11 dígitos con otro tipo de documento seleccionado), el nombre de empresa cae en el
  campo Nombres.
- La lógica de cada uno (llamar `DocumentoExternoService`, parsear `DocumentoExterno`, decidir
  qué controller llenar) vive en el State dueño de esos `TextEditingController` —
  `_SolicitudCompletarViewState._buscarDocumentoSolicitante()`/`_buscarRucComercial()`
  (`solicitud_completar_view.dart`), `_SolicitudFacturacionViewState._buscarDocumento()`
  (`solicitud_facturacion_view.dart`) y `_ParticipanteFormSheetState._buscarDocumento()`
  (`participante_form_sheet.dart`) — no en los widgets de sección, que solo exponen
  `onBuscar*: VoidCallback?`/`onBuscarDocumento: VoidCallback?` (el `FocusNode` vive dentro de
  cada sección/formulario, no en el padre — solo dispara el callback). Cada uno guarda el
  último documento buscado (`_ultimoDocSolicitanteBuscado`/`_ultimoRucBuscado`/
  `_ultimoDocBuscado`, uno por lugar) para no repetir la misma búsqueda dos veces seguidas
  (típico si se dispara tanto por `onSubmitted` como por pérdida de foco en el mismo evento).
- **El indicador de carga es `AppLoadingOverlay`** (`core/presentation/widgets/`, ver
  `core/CLAUDE.md`) — overlay de pantalla completa reutilizable, no un spinner local al campo.
  Los 4 lugares envuelven su `build()` en un `Stack` y agregan
  `AppLoadingOverlay(message: 'Buscando datos del documento...')` como último hijo cuando su
  flag de búsqueda está en `true` — bloquea toda interacción de esa pantalla/formulario mientras
  se espera la respuesta, para que el asesor no siga tocando otros campos/botones a mitad de la
  búsqueda. En `SolicitudCompletarView` es `_buscandoDocSolicitante || _buscandoRuc` (un solo
  overlay para los 2 campos de esa página); en `solicitud_facturacion_view.dart` es
  `_buscandoDocumento`; en `participante_form_sheet.dart` también `_buscandoDocumento` (variable
  propia de ese bottom sheet, mismo nombre pero cada State tiene la suya).
- Los controllers de `SolicitudCompletarView` ya tenían `addListener(_onCampoTexto)`
  (sincroniza en vivo al cubit, ver "Wizard de una sola page" más abajo) — asignar `.text` desde
  el resultado de la búsqueda ya dispara esa sincronización sola, no hace falta llamar
  `_sincronizarCubit()` de nuevo ahí.

## Tipo documento de participante — sin RUC (2026-07-15)
El combo "Tipo doc." de `participante_form_sheet.dart` mostraba las 5 opciones completas del
catálogo real (`CatalogsBloc.tiposDocumento`, incluyendo RUC) — un participante es siempre una
persona natural (nunca una empresa), así que se filtró a solo **Sin documento, DNI, Carnet de
extranjería y Pasaporte**, comparando contra los ids de `CatalogsBloc.valoresDefecto`
(`idTipoDocSnd`/`idTipoDocDni`/`idTipoDocCde`/`idTipoDocPas` — parte [13] del SP, ver
`core/CLAUDE.md` → `ValoresCRMItem`), nunca contra el id de RUC. RUC queda reservado para
Datos del solicitante (paso 1) y Facturación (paso 3), los únicos 2 lugares del wizard donde
puede haber una razón social en vez de una persona.

## Catálogo real reemplaza ids hardcodeados — Sexo, Tipo participante, RUC, Factura/Boleta (2026-07-15)
Auditoría encontró varios ids de catálogo (SYSTABEXTER02) hardcodeados en 5+ archivos del wizard,
algunos duplicados en 3-4 lugares independientes (riesgo de desincronización si el id real
cambiara en el backend). Se conectaron todos a `CatalogsBloc`, que ya traía los datos parseados
(`ListasGenericasModel.parse`, `core/models/catalog_item_model.dart`) pero **no los exponía** —
`CatalogsState`/`CatalogsLoaded` (`core/presentation/bloc/catalog/catalog_state.dart`) no tenía
getters para `valoresDefecto`/`sexos`/`tiposParticipante`/`ubigeo` hasta este fix; sin eso ningún
widget podía leerlos aunque el parseo ya funcionara.

- **Sexo (paso 1)** — `_sexos` (lista fija `['M¦Masculino', 'F¦Femenino', 'PD¦Por definir']` en
  `solicitud_completar_datos_solicitante.dart`) se reemplazó por `CatalogsBloc.sexos`
  (`SexoItem`, parte [14] del SP) vía `CustomComboField<SexoItem>` (antes
  `CustomComboSearchField`). `SeccionDatosSolicitante.onSexoChanged` cambió de
  `ValueChanged<String>?` a `ValueChanged<SexoItem?>?` — el caller extrae `item?.id ?? ''`.
- **Tipo de participante** (formulario de participante) — `_tiposParticipante`/
  `_idTipoParticipantePagante` (lista fija en `participante_form_sheet.dart`) se reemplazaron por
  `CatalogsBloc.tiposParticipante` (`TipoParticipanteItem`, parte [15] del SP) vía
  `CustomComboField<TipoParticipanteItem>`. El id de "Pagante" (default al crear un participante
  nuevo, y el que usa el participante que autogenera el switch "El solicitante será
  participante") ahora se resuelve como el primer ítem con `esInvitado == false` — nunca
  hardcodear `'1'`. `ParticipantesCubit.sincronizarSolicitante()` ahora recibe
  `idTipoParticipantePagante` como parámetro obligatorio (el Cubit no tiene `BuildContext` para
  leer `CatalogsBloc` solo) — lo resuelve `solicitud_completar_view.dart` y se lo pasa.
- **Regla "saltar Facturación"** (paso 2) — `solicitud_participantes_view.dart._onContinuar` ya
  no compara `tipoParticipante == '2' || == '3'`; resuelve cada `TipoParticipanteItem` por id
  contra `CatalogsBloc.tiposParticipante` y usa `.esInvitado` (default `false` si el catálogo
  no tiene el id, para no saltarse Facturación por error).
- **Id de RUC (`'6'`)** — vivía duplicado en 3 archivos independientes
  (`solicitud_completar_view.dart._idTipoDocRucCompletar`,
  `solicitud_facturacion_view.dart._idTipoDocRuc`,
  `solicitud_remote_datasource.dart._idTipoDocRuc`, este último con un comentario que advertía
  "si cambia allá, cambiar también aquí"). Los 3 ahora leen
  `CatalogsBloc.valoresDefecto.idTipoDocRuc` (`ValoresCRMItem`, parte [13] del SP). Como el
  datasource (capa data) no puede depender de `CatalogsBloc` (capa presentación), se agregó
  `idTipoDocRuc` como parámetro `required` en toda la cadena
  `SolicitudRemoteDatasource.guardarSolicitud()` → `SolicitudRepository`/`SolicitudRepositoryImpl`
  → `GuardarSolicitudUseCase` — mismo patrón que ya existía para `igvPorcentaje`. El único caller
  real, `guardarSolicitudDesdeWizard()` (`solicitud_guardar_helper.dart`), lo resuelve del
  `CatalogsBloc` igual que ya hacía con `igvPorcentaje`.
- **Ids de Comprobante Factura (`'01'`)/Boleta (`'03'`)** — en `solicitud_facturacion_view.dart`,
  reemplazados por `valoresDefecto.idTipoFactura`/`idTipoBoleta`.
- **País por defecto del celular/"País"** — los 3 lugares que hacían fallback a
  `codigoTelefono == '51'` (paso 1, paso 3, formulario de participante) ahora buscan el
  `PaisItem` cuyo `id` coincide con `valoresDefecto.idPais`.
- **Pendiente/gap real, no resuelto**: el conteo "Participantes pagantes" del footer de
  Facturación (`_ItemResumen` en `solicitud_facturacion_view.dart`) sigue comparando
  `p.tipoParticipante == '1'` (Pagante específicamente, no Online) — el catálogo solo expone
  `esInvitado` (booleano), no un id "es Pagante específicamente" ni un flag equivalente en
  `ValoresCRMItem`. No se tocó por no tener claro si ese conteo debería incluir también a
  "Online" — confirmar con negocio antes de decidir si se agrega un campo nuevo al catálogo o
  si se deja como está.
- `CatalogsState`/`CatalogsLoaded` ahora expone `valoresDefecto`/`sexos`/`tiposParticipante`/
  `ubigeo` (antes solo hasta `nacionalidades`) — ver `core/CLAUDE.md` → `CatalogsBloc`.

## Wizard de los 4 pasos fusionado en una sola page (2026-07-15)
Los 4 pasos (Solicitante/Participantes/Facturación/Resumen) dejaron de ser 4 rutas empujadas por
separado (`goToFichaCompletarSolicitud` → `goToFichaParticipantesSolicitud` →
`goToFichaFacturacionSolicitud` → `goToFichaResumenSolicitud`) y ahora viven **dentro de una sola
página** — motivado por dos problemas reales del diseño anterior: (1) cada "Continuar"/"Atrás"
disparaba una transición completa de pantalla (AppBar, `SolicitudPasosIndicador` y footer se
reconstruían/animaban en cada paso, aunque son casi idénticos entre pasos) y (2) los campos
tipeados en un paso (ej. "Tipo de comprobante" en Facturación) se perdían si el usuario retrocedía
sin haber presionado "Continuar"/"Guardar" primero, porque cada paso solo escribía su draft al
cubit compartido en esos dos botones, nunca en vivo.

- **`SolicitudWizardView`** (`presentation/widgets/completar/view/solicitud_wizard_view.dart`) es
  el nuevo widget orquestador — mantiene `_pasoActual` (1-4) como estado local y arma **un solo**
  `BasePage` (AppBar con `SolicitudBadgePaso(paso: _pasoActual)` + `SolicitudPasosIndicador`) que
  nunca se reconstruye entre pasos; el body es un `IndexedStack` que muestra el paso activo.
  `SolicitudCompletarPage` (la única page/ruta que queda del wizard, `fichaCompletarSolicitud`)
  sigue creando `SolicitudFormCubit`/`ParticipantesCubit` igual que antes, pero ahora monta
  `SolicitudWizardView` en vez de `SolicitudCompletarView` directo.
- **`SolicitudParticipantesPage`/`SolicitudFacturacionPage`/`SolicitudResumenPage` y sus rutas
  (`fichaParticipantesSolicitud`/`fichaFacturacionSolicitud`/`fichaResumenSolicitud`) se
  eliminaron por completo** — ya no existen como pushes independientes. `SolicitudCompletarView`/
  `SolicitudParticipantesView`/`SolicitudFacturacionView`/`SolicitudResumenView` (las 4 vistas de
  `widgets/completar/view/`) dejaron de armar su propio `BasePage`/AppBar/`SolicitudPasosIndicador`
  — ahora son solo body+footer, y reciben callbacks (`onContinuar`, `onAtras`, `onCancelar`,
  `onEditarPaso`) en vez de llamar `context.goToFichaXxxSolicitud(...)`/`context.goBack()` para
  moverse entre pasos. `SolicitudWizardView` les pasa esos callbacks, que solo hacen
  `setState(() => _pasoActual = n)`. El botón "Editar" del Resumen (antes
  `Navigator.popUntil(ModalRoute.withName(...))`) ahora es `onEditarPaso(1)`/`onEditarPaso(3)`.
  El "Continuar" final del Resumen en modo solo-ver sigue siendo
  `Navigator.of(context).popUntil(ModalRoute.withName(AppRoutes.detalleSolicitud))` **sin
  cambios** — el wizard entero sigue siendo una sola ruta empujada sobre `SolicitudDetalleView`.
- **Construcción perezosa dentro del `IndexedStack` — no usar `IndexedStack` a secas con los 4
  hijos completos**: `SolicitudWizardView` mantiene `Set<int> _pasosConstruidos` (arranca con
  `{1}`) y solo instancia el widget de un paso la primera vez que se navega a él (`_irAPaso`
  agrega el número al set); antes de eso, ese slot del `IndexedStack` es un `SizedBox.shrink()`.
  Esto importa porque `SolicitudFacturacionView` tiene un prellenado de una sola vez en
  `didChangeDependencies` (`_prefillDone`) que depende de que el paso 1 ya haya guardado al
  solicitante (autocompletar Facturación si se activó "Facturar al solicitante") — si
  `IndexedStack` construyera los 4 pasos de una sola vez al abrir el wizard, ese
  `didChangeDependencies` correría de inmediato con el solicitante todavía vacío y el
  autocompletado se perdería para el resto de la sesión. Una vez construido, un paso **nunca** se
  destruye al cambiar de índice (así es como `IndexedStack` preserva su estado) — es el mecanismo
  real detrás de "ya no se pierden los datos tipeados al moverse entre pasos".
- **Sincronización en vivo al cubit — ya no se escribe solo en "Continuar"/"Guardar"**: los pasos
  1 y 3 (los que tienen campos de texto/combos propios; el paso 2 ya vivía 100% en
  `ParticipantesCubit`) ahora llaman `SolicitudFormCubit.guardarSolicitante`/`guardarFacturacion`
  en **cada cambio de campo** — cada listener de `TextEditingController` y cada `onChanged` de
  combo llaman `_sincronizarCubit()` después del `setState` local. Esto persiste ids de combo +
  texto de inputs (incluso vacíos) en el cubit compartido en todo momento, no solo cuando se
  presiona "Continuar"/"Guardar" — es la razón principal por la que ahora es seguro moverse entre
  pasos sin perder nada, incluso si en el futuro algún paso dejara de mantenerse vivo en el
  `IndexedStack`. `_sincronizarCubit()` en el paso 1 se frena mientras `_cargando` es `true`
  (evita pisar el draft con datos a medio poblar durante el fetch de `_cargarDetalle()`); en el
  paso 3 se frena hasta que `_prefillDone` sea `true` (mismo motivo, durante el prellenado de
  `didChangeDependencies`).
- **"Carga masiva" (paso 2, Excel) sigue siendo una ruta aparte** (`SolicitudCargaMasivaPage`,
  `AppRoutes.cargaMasivaParticipantes`) — no se tocó, es un sub-flujo con su propio selector de
  archivo, no un paso del wizard. El botón que lo abre sigue comentado en
  `solicitud_participantes_view.dart` (sin conectar, ver "Pendiente" más abajo).

## Bugs reportados por QA — Resumen sin modoEdicion, IGV invertido, nacionalidad huérfana (2026-07-14)
Varios bugs reportados juntos en una sesión; se corrigieron los que eran puramente de Flutter y se
dejaron señalados los que necesitan confirmación de backend/SP (no hay `.sql` versionado en el
repo — los SPs solo viven en la BD, cualquier cambio ahí necesita que alguien pegue el texto real).

- **`SolicitudResumenView` (paso 4) no miraba `modoEdicion`** — a diferencia de los pasos 1-3
  (ver "Validación de 'Continuar'" abajo), el footer del Resumen siempre mostraba
  Guardar/Generar solicitud/Cancelar, incluso en modo solo-ver (entrando por "Continuar" desde
  `SolicitudDetalleView`, no por "Editar ficha"). Corregido: en modo solo-ver el footer ahora
  muestra un único botón "Continuar" (ancho completo) que hace
  `Navigator.of(context).popUntil(ModalRoute.withName(AppRoutes.detalleSolicitud))` — vuelve
  directo al detalle, no reintenta guardar/generar nada.
- **"Tipo de comprobante" hardcodeado a `'Factura'`** en `_CardInfoSolicitud`
  (`widgets/generada/solicitud_generada_view.dart`) — mostraba siempre "Factura" sin importar si
  el paso 3 eligió Boleta. Corregido pasando el comprobante real:
  `goToSolicitudGenerada({solicitud, comprobante})` → `SolicitudGeneradaPage` →
  `SolicitudGeneradaView` → `_CardInfoSolicitud` (muestra `'—'` si viene vacío, caso "todos
  invitados" donde se saltó Facturación).
- **IGV invertido en Resumen/Participantes — el importe de participante YA incluye IGV, no es
  base**: cuando el precio viene de la negociación/lead (`precioBaseLead`), ese monto ya trae el
  18% incluido — Inversión e IGV se **extraen** del total (`inversion = total / (1 +
  igv%/100)`, `igv = total - inversion`), no se le suman encima. Antes `_SeccionResumenComercial`
  (`solicitud_resumen_view.dart`) y `_ResumenInversion` (`solicitud_participantes_view.dart`)
  hacían `igv = inversion * igv% / 100; total = inversion + igv` — inflaba el importe total por
  encima de lo que realmente sumaban los participantes. Corregido en **ambas pantallas** —
  ambas leen `ParticipantesCubit.state.totalInversion` como el total ya-con-IGV.
  **OJO — pendiente, no tocado todavía**: `SolicitudRemoteDatasource.guardarSolicitud()` (task
  `'U'`) sigue calculando `dcIgv`/`IGV` por participante de la misma forma vieja (sumando, no
  extrayendo) — no se tocó porque no hay forma de confirmar sin ver el SP si las columnas
  `IMPORTE`/`IGV`/`DC_IMPORTE`/`DC_IGV` esperan el monto base o el total. Si se decide extender
  el fix al guardado, hay que cambiar `dcImporte`/`dcIgv`/`dcImporteTotal` y el `igv` por
  participante en ese archivo para que también extraigan en vez de sumar — coordinar con
  backend antes, un error acá corrompe montos reales que usa Cobranzas.
- **`DatosFacturacion` no tenía campo de nacionalidad** — el combo Nacionalidad del paso 3 se
  capturaba en el estado local del widget (`_nacionalidadId`) pero nunca se guardaba en el
  modelo compartido, así que se perdía al volver con "Atrás" y reentrar al paso. Se agregó
  `nacionalidadId`/`nacionalidad` a `DatosFacturacion` y se restaura junto con el resto de campos
  en `didChangeDependencies()` — junto con `_paisCelular` (el código de teléfono tampoco se
  restauraba, mismo bloque). **OJO — pendiente, no tocado todavía**: esto solo arregla la
  persistencia *dentro de la sesión del wizard*. El SP nunca tuvo una columna para nacionalidad
  de facturación — `guardarSolicitud()` manda `facturacion.paisId` como `ID_NACION_FAC` (columna
  compartida con País, ver comentario en el datasource) y `SolicitudDetalleModel` (task `'DT'`)
  no trae ningún `facNacionalidadId` de vuelta. O sea: la nacionalidad de facturación no
  sobrevive a cerrar y reabrir la solicitud, ni queda guardada en la BD — para eso hace falta
  una columna nueva en el SP (o decidir que ese campo no debería existir en el paso 3, ya que
  "País" ya cubre algo parecido).

## `SolicitudCard` compactada + fix de ícono de Origen (2026-07-14)
`SolicitudCard` (`presentation/widgets/list/solicitud_card.dart`) era demasiado grande frente al
resto de listas de la app — se redujo de escala tomando como referencia `LeadCard` (`lead/`,
lista de Seguimiento), sin cambiar el layout (sigue siendo header + grid 2 columnas + botones):
- **Avatar** — ya no muestra iniciales; ahora es solo `Icon(AppIcons.user)` sobre el círculo de
  color (`AvatarUtils.color`), mismo patrón que `_LeadAvatar` en `lead_card.dart`. Radio bajó de
  `avatarRadiusMd` (24) a `avatarRadiusSm` (21) — no tan chico como Seguimiento
  (`avatarRadiusXs` = 14), porque esta card sigue mostrando más información.
- **Tipografía** — nombre bajó de `titleSmall` a `bodySmall` (semibold); empresa, fecha, textos
  del grid (oportunidad/origen/ejecutivo) bajaron de `bodySmall`/`labelMedium` a `labelSmall` —
  misma escala que usa `LeadCard`.
- **Botones** — de `buttonHeightSmall` (36) a `buttonHeightCompact` (32); íconos de
  `iconActionSm` (18) a `iconSm` (16); texto a `labelSmall` explícito en los 3 botones (antes el
  `FilledButton` no fijaba estilo de texto).
- **Card** — `radiusLg` → `radiusMd`, padding interno reducido (`AppSpacing.md/sm` → `sm/xs`).
- **Bug de Origen corregido** — el ícono de la fila "Origen: X" estaba hardcodeado a
  `Image.asset('assets/icons/whatsapp_icon.png')` sin importar el canal real (por eso se veía el
  ícono de WhatsApp junto a "Origen: Facebook" u otro canal). Ahora usa
  `CanalHelper.icon(solicitud.idCanal, size: AppSizing.iconSm)` — mismo `canalInfo` que ya se
  usaba para el texto, ahora también maneja el ícono. `CanalHelper` (`core/helpers/canal_helper.dart`)
  ya tenía el mapeo completo por `idCanal`, solo no se estaba usando para el ícono de esta card.

## Regla de negocio — cantidad/importe/moneda bloqueados desde la negociación (2026-07-14)
Solo aplica al **crear** una solicitud nueva desde "Generar solicitud" (una negociación con
`Negociacion.precio > 0` ya definido) — nunca al editar una ya guardada, porque el backend no
guarda de qué lead vino una solicitud existente (ver nota de `Solicitud.idLead` más abajo).

- **Gate del botón**: `NegociacionCard` (Conversaciones) y `ContactoNegociacionCard`
  (Seguimiento) deshabilitan "Generar solicitud" (`isEnabled`) si `negociacion.precio <= 0` —
  sin precio total no hay cantidad/importe que bloquear.
- **`SolicitudFormState.cantidadEsperada`/`precioBaseLead`/`descuentoLead`/
  `idMonedaBloqueada`** (`presentation/bloc/form/solicitud_form_state.dart`) — se siembran una
  sola vez con `SolicitudFormCubit.sembrarDatosNegociacion(...)`, llamado desde
  `SolicitudCompletarPage` al crear el cubit (`solicitud.idSolicitud.isEmpty && cantidadNegociacion
  != null`). Los 4 valores viajan por navegación desde `NegociacionCard`/`ContactoNegociacionCard`/
  `NegociacionesTab` → `goToFichaCompletarSolicitud(cantidadNegociacion:, precioBaseNegociacion:,
  descuentoNegociacion:, idMonedaNegociacion:)` → argumento de ruta → `SolicitudCompletarPage`.
- **Importe de participante SIEMPRE bloqueado** (`participante_form_sheet.dart`, cambiado
  2026-07-15) — antes solo se deshabilitaba si `importeFijo` venía no nulo (desde negociación);
  ahora `_importeBloqueado = true` sin condición, en cualquier escenario (creando o editando,
  con o sin negociación de origen) — el asesor nunca lo edita a mano ahí. El valor que se
  muestra sigue el mismo orden de prioridad de antes: `importeFijo` (si vino de negociación) →
  importe ya guardado del participante (edición) → vacío (participante nuevo sin negociación).
  **Pendiente real, avisado por el usuario**: el valor final (moneda, precio base, precio
  total, descuento) vendrá de otra lógica que todavía no se definió — no inventar de dónde
  sale el importe mientras esa lógica no llegue, este campo por ahora solo deja de ser
  editable, no calcula nada nuevo.
  **Ojo — `importeFijo` se pasa por parámetro, no se lee `SolicitudFormCubit` dentro del
  modal**: `mostrarFormularioParticipante` abre un `showModalBottomSheet`, que empuja una ruta
  **hermana** sobre el mismo `Navigator` global — no un descendiente del `BlocProvider.value`
  que envuelve la página de este paso. `context.read<SolicitudFormCubit>()` ahí adentro
  revienta en tiempo real. `solicitud_participantes_view.dart._importeFijo(context)` lee el
  cubit con el `context` correcto (el de la página, no el del modal) y lo pasa como parámetro.
  Mismo patrón que ya usaban los callbacks `onGuardar` (capturan el `context` del caller).
- **Moneda SIEMPRE bloqueada** (`solicitud_facturacion_view.dart`, cambiado 2026-07-15) — antes
  `monedaBloqueada: formState.idMonedaBloqueada != null` (solo si venía de negociación); ahora
  `_SeccionDatosFacturacion` recibe `monedaBloqueada: true` sin condición — el combo Moneda
  queda deshabilitado siempre (`enabled: habilitado && !monedaBloqueada`), independiente del
  resto de campos, mismo pendiente que Importe (arriba): de dónde sale el valor real de Moneda
  cuando no hay negociación de origen queda para una lógica futura, todavía no definida.
- **Descuento respetado en el total** — `SolicitudRemoteDatasource.guardarSolicitud()` recibe
  `descuento` (default 0, threaded por `GuardarSolicitudUseCase`/`SolicitudRepository`/
  `guardarSolicitudDesdeWizard`, que lo lee de `formState.descuentoLead`) y lo resta del importe
  bruto **antes** del IGV: `dcImporte = (sum(participantes.importe) - descuento).clamp(0, ∞)`,
  `dcIgv`/`dcImporteTotal` se calculan sobre ese neto. No viaja como columna propia al backend —
  el SP no tiene una, y no hace falta: el resultado ya neto se manda en `DC_IMPORTE`.
- **Validación de cantidad — solo al generar, nunca al guardar borrador**:
  `generarSolicitudCompleta()` (`solicitud_guardar_helper.dart`) compara
  `ParticipantesCubit.state.participantes.length` contra `cantidadEsperada` **antes** de llamar
  `guardarSolicitudDesdeWizard` — si no calzan, retorna `CrudError` sin guardar nada. Los 4
  botones "Guardar" (borrador) de los pasos 1-4 **no** validan esto, dejan guardar con
  cualquier cantidad.
- **`Solicitud.idLead` solo existe al crear** — una vez guardada, no hay forma de recuperar de
  qué lead vino una solicitud existente (el SP no lo trae de vuelta). Por eso esta regla entera
  es exclusiva del flujo de creación — no intentar extenderla a "editar una solicitud ya
  guardada" sin antes resolver esa limitación de backend.

## Propósito
Gestiona el flujo de solicitudes de inscripción: lista con filtros, detalle, y un wizard de
4 pasos para completar una solicitud (Solicitante → Participantes → Facturación → Resumen).

## Estado general — ⚠️ wizard aún hardcodeado, lista ya conectada al SP real
- `SolicitudRemoteDatasource.getSolicitudes()` ya está conectado a
  `[CRM].[CSV_SOLICITUD_LST_APP]` (task `'LS'`, body `codUser¦isModerador`) — mismo patrón
  que `CobranzaRemoteDatasource`. Ver mapeo posicional completo en el comentario de
  `SolicitudModel.fromRawString` y en "SPs que consume" abajo.
- ~~Bug pendiente en el SP — campo Canal~~ — **resuelto, confirmado el 2026-07-16 contra el
  `.sql` real** (`CSV_SOLICITUD_LST_APP` en `NC.SQLChangeLock`). El SP ya selecciona
  `CN.ID_CANAL`/`CN.NOMBRE` (posiciones 16/17 del raw, antes del bloque de estado
  `EG.ID_ESTADO_GES`/`EG.DESCRIPCION` en 18/19) — exactamente lo que
  `SolicitudModel.fromRawString` ya esperaba. No hizo falta ningún cambio, ni en el SP ni en
  Flutter — la nota anterior de este archivo (que describía el bug como pendiente, basada en
  una sección comentada de una versión vieja del SP que nunca se pudo confirmar) quedó
  desactualizada.
- El wizard (`SolicitudFormCubit` + `ParticipantesCubit`) ya está conectado al CUD real de
  punta a punta. Al entrar (por "Editar ficha"/"Continuar" o por "Generar solicitud" desde
  una negociación) el paso 1 llama `getSolicitudDetalle()` (task `'DT'`, ver abajo) y
  prellena los cubits — ver `solicitud_completar_view.dart._cargarDetalle()`. Los 4 botones
  "Guardar" (pasos 1/2/3/Resumen) llaman `guardarSolicitudDesdeWizard()` con
  `esBorrador: true`; "Generar solicitud" (Resumen) con `esBorrador: false` y navega a
  `SolicitudGeneradaPage` solo si el backend responde `CrudOk`. Ver
  `solicitud_guardar_helper.dart` (punto único que arma la llamada, compartido por los 5
  botones) y "Pendiente" abajo por lo que sigue faltando (archivos desde Resumen, carga
  masiva).
- **`SolicitudFormCubit.state.numSol`** — el wizard ya no lee `widget.solicitud.idSolicitud`
  para saber a qué NUMSOL guardar; lo lee del cubit. Se siembra una vez al entrar al paso 1
  (`_cargarDetalle()`, vacío si es creación) y `guardarSolicitudDesdeWizard()` lo actualiza
  solo con el NUMSOL que devuelve `CrudOk.data` tras el primer guardado exitoso — así
  cualquier "Guardar"/"Generar solicitud" posterior en la misma sesión actualiza esa misma
  solicitud en vez de crear una nueva cada vez (bug real: antes cada "Guardar" repetía la
  rama de creación del SP porque `numSol` seguía viajando vacío).
- **Voucher/O.C. viven en `SolicitudFormCubit.state.archivoVoucher/archivoOC`**
  (`PlatformFile?`, no en estado local de la vista) — así sobreviven todo el wizard, no
  solo el paso 1 donde se capturan (`solicitud_completar_view.dart._adjuntarArchivo()`,
  con `withData: true` en el picker para asegurar `.bytes` en todas las plataformas).
  `SolicitudFormCubit.guardarArchivoVoucher/OC` / `quitarArchivoVoucher/OC` los setean.
- **Subida de archivos** — `subirArchivosPendientes()` (`solicitud_guardar_helper.dart`)
  sube lo que haya en el cubit usando `GuardarArchivoSolicitudUseCase` +
  `SolicitudFormCubit.state.numSol` — no hace nada si `numSol` sigue vacío (creación nueva
  sin confirmar). La llaman los 4 botones "Guardar" (tras `CrudOk`) y el paso 1 también la
  dispara al "Continuar" (sin bloquear, solo si ya había NUMSOL de antes — edición).
  **"Generar solicitud" (Resumen) usa `generarSolicitudCompleta()`**, que encadena
  `guardarSolicitudDesdeWizard(esBorrador: false)` → si sale `CrudOk`, recién ahí
  `subirArchivosPendientes()` → solo si TODO sale bien navega a `SolicitudGeneradaPage`; si
  el CUD falla no sube nada; si el CUD sale bien pero un archivo falla, devuelve `CrudAlert`
  (la solicitud ya quedó creada/actualizada, el usuario puede volver a presionar "Generar
  solicitud" para reintentar solo la subida — es idempotente, `numSol` ya está fijo).
  **OJO — riesgo real en el SP**: el task `'AR'` de `CSV_SOLICITUD_CUD_APP` hace
  `DELETE FROM EVT.T_TECMSOLINSCRIPCION01_ARCHIVOS WHERE NUMSOL = @NUMSOL` (borra TODOS los
  archivos de esa solicitud, no solo el tipo que se está subiendo) antes de insertar el
  nuevo — si se suben voucher y O/C en la misma sesión, la segunda llamada borra a la
  primera. Sin confirmar con backend todavía si conviene mandarlos juntos en un solo `'AR'`.
- "Carga masiva" (Excel) solo valida la extensión del archivo seleccionado — no procesa ni
  sube el archivo.

## Pendiente (roadmap del CUD) — leer esto primero si retomas el feature
1. ~~`SolicitudRemoteDatasource.guardarSolicitud()` (task `'U'`)~~ — hecho.
2. ~~`SolicitudRemoteDatasource.guardarArchivo()` (task `'AR'`)~~ — hecho, ver abajo.
3. ~~Conectar los botones "Guardar"/"Generar solicitud"~~ — hecho, ver "Estado general".
   ~~Subir voucher/OC desde Resumen~~ — hecho, ver "Estado general" (`generarSolicitudCompleta()`).
4. ~~Ajuste en `guardarSolicitud()`: el SP dejó de recibir `ID_CONTACTO`~~ — hecho. La
   cabecera ahora manda 41 campos (`ID_LEAD` es field1) en vez de 42.
5. ~~`ID_LEAD` se manda vacío porque no existe ninguna pantalla que cree una solicitud nueva
   desde un Lead~~ — hecho. `ContactoNegociacionCard` (`lead/`, botón "Generar solicitud" en
   una negociación ganada) navega a `SolicitudCompletarPage` con un `Solicitud` en blanco
   (`idSolicitud: ''`, `idLead: negociacion.idLead.toString()`) — mismo patrón en el botón
   "Generar" de `NegociacionCard` (`lead/lead_detail_sheet/negociacion_card.dart`, pestaña
   Negociaciones de **Conversaciones** — `ChatLeadPanel`), wireado en
   `NegociacionesTab._generarSolicitud()`. A diferencia de `ContactoNegociacionCard`
   (Seguimiento, solo visible si la negociación está ganada), acá el botón "Generar" se
   muestra para toda negociación no cerrada (`idEstadoPadre != '04'`) — no valida que esté
   ganada antes de dejar crear la solicitud.
6. "Carga masiva" (Excel) y guardar el `DatosFacturacion.actividadEconomica`/`nit`/
   `observaciones` (capturados en el paso 3 pero el SP no tiene columna para
   `actividadEconomica`/`observaciones`, y `nit` no se manda en `guardarSolicitud()`) siguen
   sin SP/sin conectar.
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
  abajo). **Sexo** (paso 1, `SexoItem`) y **Tipo de participante** (formulario de
  participante, `TipoParticipanteItem`) también están conectados a `CatalogsBloc` desde
  2026-07-15 — ya no son listas fijas locales, ver "Catálogo real reemplaza ids
  hardcodeados" más abajo. **País por defecto** del selector de código telefónico (los 3
  campos de celular del wizard) y de "País" (paso 3) ya no cae a `codigoTelefono == '51'`
  hardcodeado — usa `CatalogsBloc.valoresDefecto.idPais` (parte [13] del SP).
- Los chips de Canal (`ChipsCanales`, paso 1, "¿Cómo se enteró del evento?") ya no usan el
  catálogo de canal del lead (`CanalItem`/`T_CANAL`) — desde que se agregó `canalesExpo`
  (`CanalExpoItem`/`dbo.EDU_CANAL_EXPO`, parte [17] del SP `lstListas`, ver `core/CLAUDE.md`
  → "Catálogos") usan ese catálogo aparte. `ChipsCanales` llama
  `AppSocialUtils.widgetCanalExpoById(canal.id)` — **nunca** `widgetCanalById` (mapa de
  canal de lead, con ids que significan otra cosa: id `2` en canal de lead es Instagram, en
  canal expo es LinkedIn) ni `widgetCanal(canal.iconoApp)` (el string crudo del SP no
  siempre calza con las keys internas de `AppSocialUtils`). Ver `core/CLAUDE.md` →
  `AppSocialUtils` para el mapa completo id→canal expo.
- **`CanalExpoItem.esDetallado` (2026-07-17)** — si el canal elegido en los chips tiene
  `esDetallado == true` (hoy, "Otros"), aparece un `CustomTextField` chico debajo de los
  chips ("¿Desde dónde se enteró? \*", `_ctrlCanalDetalle` en
  `solicitud_completar_view.dart`) — obligatorio en ese caso, sumado a `_formCompleto`. El
  texto libre que tipea el asesor ahí se manda como `NOMBRE_CANAL` **en vez de**
  `canal.descripcion` (`_construirDatosSolicitante()` — `ID_CANAL` sigue viajando normal,
  solo cambia el nombre). Al reabrir una solicitud ya guardada con un canal `esDetallado`,
  `_cargarDetalle()` prellena `_ctrlCanalDetalle` con `detalle.canalNombre` (que en ese caso
  es el texto libre guardado, no una descripción de catálogo).
- **"Tipo de persona" (Jurídica/Natural) es un solo valor compartido** — vive en
  `SolicitudFormCubit.state.tipoPersona` (no en `DatosSolicitante`/`DatosFacturacion`,
  que antes tenían cada uno su propia copia y se desincronizaban). Solo se puede cambiar
  en el paso 1; en el paso 3 el toggle se muestra pero con `habilitado: false` siempre.
- **`tipoParticipante` es el id, no el label** — `'1'` Pagante · `'2'` Invitado ·
  `'3'` Invitado auspicio · `'4'` Online son los valores reales que trae
  `CatalogsBloc.tiposParticipante` (`TipoParticipanteItem`, parte [15] del SP) — ya no una
  lista fija local (`_tiposParticipante` en `participante_form_sheet.dart` se eliminó el
  2026-07-15). Antes se mandaba el label completo como `ID_TIP_PARTICIPANTE` y truncaba esa
  columna en `EVT.T_TECMSOLINSCRIPCION02` (`'Invitado auspicio'` no entraba) — se cambió a
  ids el 2026-07-10. El id de "Pagante" (usado como default al crear un participante nuevo,
  y para el participante que autogenera el switch "El solicitante será participante") se
  resuelve como el primer `TipoParticipanteItem` con `esInvitado == false` — nunca
  hardcodear `'1'`.
- **Regla de negocio — saltar Facturación**: si TODOS los participantes tienen
  `esInvitado == true` (resuelto contra `CatalogsBloc.tiposParticipante` por
  `p.tipoParticipante`, no comparando ids `'2'`/`'3'` a mano), el paso 2 pasa directo al
  paso 4 (Resumen) sin pasar por Facturación — dentro del wizard de una sola page, ver
  "Wizard de una sola page" arriba (ya no es una navegación a otra ruta). El Resumen
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
- `SolicitudCompletarPage` → única page/ruta del wizard (`fichaCompletarSolicitud`) — crea
  `SolicitudFormCubit`/`ParticipantesCubit` y monta `SolicitudWizardView`, que internamente
  muestra los 4 pasos (Solicitante/Participantes/Facturación/Resumen) como una sola page — ya no
  son rutas separadas, ver "Wizard de una sola page" arriba
- `SolicitudCargaMasivaPage` → carga de participantes vía Excel (abre desde paso 2, sigue siendo
  ruta aparte — no forma parte del wizard fusionado)
- `SolicitudGeneradaPage` → pantalla de confirmación tras "Generar solicitud"

## BLoCs / Cubits
- `SolicitudListBloc` (list/) → carga y filtra la lista; conteos por estado; calcula
  `conteosPorAsesor` (`Map<String,int>`, sobre `_allSolicitudes`) para alimentar el picker —
  el universo de asesores ya no sale de las solicitudes cargadas, viene de
  `CatalogsBloc.asesores` (ver `SolicitudAsesorPickerModal` abajo)
- `SolicitudFormCubit` (form/) → guarda `DatosSolicitante` y `DatosFacturacion` capturados
  en los pasos 1 y 3, más `numSol` (ver "Estado general" — se actualiza solo tras crear) y
  `archivoVoucher`/`archivoOC` (`PlatformFile?`, capturados en paso 1 pero vivos acá para
  que "Generar solicitud" en Resumen también pueda subirlos). Se crea **una sola vez** en
  `SolicitudCompletarPage` (paso 1) y se reenvía como argumento (`formCubit`) a través de
  todo el wizard vía `BlocProvider.value`
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
Los 4 pasos comparten los mismos dos cubits durante todo el recorrido — `SolicitudFormCubit` y
`ParticipantesCubit` se crean **una sola vez** en `SolicitudCompletarPage` y se proveen a los 4
pasos vía `BlocProvider.value` en el árbol de `SolicitudWizardView` (nunca
`BlocProvider(create: ...)` dentro de un paso, eso crearía una instancia nueva y se perderían los
datos ya ingresados). Desde la fusión en una sola page (ver "Wizard de una sola page" arriba),
moverse entre pasos **ya no navega por rutas** — cada paso recibe callbacks
(`onContinuar`/`onAtras`/`onCancelar`/`onEditarPaso`) que `SolicitudWizardView` resuelve con
`setState(() => _pasoActual = n)`.

Al agregar un paso nuevo al wizard:
1. Crear la vista del paso en `widgets/completar/view/` sin `BasePage`/AppBar propios — solo
   body + footer, igual que las 4 actuales — recibiendo los callbacks de navegación que necesite
   como parámetros del widget (no `context.goToXxx`)
2. Agregarla a la lista de pasos de `SolicitudWizardView` (`_pasosConstruidos` + el `if` dentro
   del `IndexedStack`) y sumar el número de paso correspondiente a `SolicitudPasosIndicador._pasos`
3. Si el paso tiene campos propios que deban sobrevivir a moverse a otro paso, sincronizarlos al
   cubit en cada cambio (`_sincronizarCubit()` en cada listener/`onChanged`), no solo en
   "Continuar"/"Guardar" — mismo patrón que los pasos 1 y 3
4. Nunca crear una instancia nueva de `SolicitudFormCubit`/`ParticipantesCubit` fuera de
   `SolicitudCompletarPage`

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
- `SolicitudWizardView` (completar/view/) → orquestador del wizard de una sola page (ver "Wizard
  de una sola page" arriba) — arma el único `BasePage`/AppBar/`SolicitudPasosIndicador` y un
  `IndexedStack` con los 4 pasos; los 4 widgets de paso de abajo ya no arman su propio `BasePage`,
  solo devuelven body+footer y reciben callbacks de navegación por parámetro
- `SolicitudPasosIndicador` / `SolicitudBadgePaso` (completar/) → indicador de paso 1-4,
  renderizados una sola vez por `SolicitudWizardView` (ya no uno por cada paso/ruta)
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
  Perú resuelto contra `CatalogsBloc.valoresDefecto.idPais` (parte [13] del SP) cuando el
  catálogo ya cargó, no un `codigoTelefono == '51'` hardcodeado

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
  usaba. `idLead` (`String`, default `''`) es el único campo que **no** viene del SP de
  listado — lo setea a mano `ContactoNegociacionCard._generarSolicitud()` (`lead/`) al armar
  el `Solicitud` en blanco para crear una solicitud nueva desde una negociación ganada; en
  cualquier solicitud ya existente queda vacío y no se usa para nada más que ese INSERT
  inicial (`guardarSolicitud()` lo manda como `ID_LEAD`, field1 de la cabecera)
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
  (id `'1'`-`'4'`, sin catálogo real — lista fija en `participante_form_sheet.dart`, ver
  "Notas importantes"), `importe` (sin moneda), `esSolicitante` (marca el registro
  autogenerado por el switch "El solicitante será participante" — ver abajo)

## SPs que consume
- `[CRM].[CSV_SOLICITUD_LST_APP]` (task `'LS'`, body `codUser¦isModerador`) → lista de
  solicitudes (`SolicitudModel.fromRawString`, 23 campos posicionales — ver mapeo comentado
  en el archivo del modelo y el bug de Canal en "Estado general"). Este SP solo tiene rama
  `@L_TASK = 'LS'` y filtra en el WHERE por `IB_MOD_APP = 1 OR ID_USUARIO_EJEC = @ID_USUARIO`
  (mismo patrón que moderador/asesor de Cobranza) más `IB_VALIDADO != 0`.
- `[CRM].[CSV_SOLICITUD_LST_APP]` (task `'DT'`, body `numSol¯DT`, **mismo endpoint**
  `urlSolicitudesLst` que `'LS'`) → `SolicitudRemoteDatasource.getSolicitudDetalle()`
  (`SolicitudDetalleModel.fromRawString`). Trae solicitante + facturación + participantes +
  archivos de una solicitud ya guardada, dado su `NUMSOL` — sin wrapper `OK`/`ERROR`, solo el
  string crudo (mismo estilo que `'LS'`). Solo IDs de catálogo, sin descripciones —
  `solicitud_completar_view.dart._cargarDetalle()` resuelve los labels contra `CatalogsBloc`.
  Se llama una sola vez, al entrar al paso 1 (`modoEdicion` true o false); si `numSol` viene
  vacío (creación nueva desde una negociación) se salta el fetch y el wizard arranca en
  blanco. Desde el 2026-07-16 también trae `idLeadOrigen` (campos[39], `LEFT JOIN` nuevo a
  `CRM.T_LEAD_TECMSOLINSCRIPCION01`) — usado para recuperar la negociación de origen al editar
  una solicitud ya guardada (ver "Importe de participante ya no bloqueado..." arriba).
- `[CRM].[CSV_SOLICITUD_CUD_APP]` (task `'U'`, body `cabecera¦...¯detalle¦...¬detalle¦...¯U`)
  → `SolicitudRemoteDatasource.guardarSolicitud()`. Crea (si `numSol` viene vacío) o
  actualiza (si ya existe) cabecera + facturación + participantes de una solicitud, todo en
  una transacción — ver el mapeo posicional completo comentado en el método (43 campos de
  cabecera, `ID_LEAD` es field1 — el SP ya no recibe `ID_CONTACTO`; 14 por participante).
  `field42`/`field43` (comprobanteId/nacionalidadId de facturación) se agregaron el 2026-07-16,
  ver "Bugs reales — Comprobante y Nacionalidad de facturación" arriba.
  Devuelve `OK¯mensaje¯NUMSOL` (el `NUMSOL` es obligatorio
  leerlo de la respuesta en el flujo de creación — hace falta para la llamada de archivos
  después). Llamado desde los 5 botones "Guardar"/"Generar solicitud" vía
  `guardarSolicitudDesdeWizard()` (`solicitud_guardar_helper.dart`) — ver "Estado general".
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

## `SolicitudDetalleView` ya no confía en el `Solicitud` de navegación (2026-07-14)
`SolicitudDetalleView`/`_BotonesDetalle` mostraban el header y decidían `puedeEditar` con el
`Solicitud` que llegaba como argumento de navegación — que puede venir de la lista cacheada hace
rato (`SolicitudListPortrait`), o peor, de un `Solicitud` "de paso" casi vacío armado a mano
desde una `Negociacion` (`NegociacionCard`/`ContactoNegociacionCard._solicitudDesdeNegociacion()`
— sin `estado`, `ibValidado` siempre `false`, `monto` es el de la negociación no el de la
solicitud, etc.). Se corrigió trayendo todo fresco en el momento:
- `SolicitudDetalleBloc` ahora recibe también `GetSolicitudesUseCase` y, en
  `SolicitudDetalleStarted`, pide **en paralelo** (`Future.wait`) el detalle (`'DV'`) y la lista
  completa (`'LS'`) — de esta última saca el `Solicitud` que matchea el `NUMSOL` y lo manda en
  `SolicitudDetalleSuccess.solicitud` (nullable — `null` solo si esa solicitud ya no aparece en
  la lista recién traída, caso raro).
- `SolicitudDetalleView` calcula `solicitudActual = state.solicitud ?? solicitud` (el de
  navegación queda solo como último respaldo) y lo usa tanto para el header (`SolicitudCard`)
  como para `_BotonesDetalle` (que decide "Editar ficha" con `puedeEditar`, sensible a
  `idEstado`/`ibValidado` — con el `Solicitud` viejo podía mostrar "Editar ficha" cuando no
  correspondía). El `Solicitud` que llega por navegación (constructor de `SolicitudDetalleView`)
  ya casi no se usa — solo mientras `SolicitudDetalleLoading`/`Initial`, antes de que llegue la
  respuesta fresca.
- No se tocó el `Solicitud` "de paso" que arman `NegociacionCard`/`ContactoNegociacionCard` — ya
  no hace falta, este fix lo hace irrelevante para lo que se pinta en pantalla.

## `Solicitud.idEstado` es `int` (2026-07-14)
`ID_ESTADO_GES` es una columna INT en el SP (`CSV_SOLICITUDES_LST_APP`, task `'LS'`) — llega
crudo (`'0'`/`'1'`/`'2'`/`'3'`, sin padding). Antes `Solicitud.idEstado` era `String` y todo el
código (`colorEstado`, `_accion` de `SolicitudCard`, conteos de `SolicitudListBloc`,
`Solicitud.puedeEditar`) comparaba contra literales con padding (`'00'`-`'03'`) que nunca
matcheaban con el dato real → todas las solicitudes caían al valor por defecto (chip gris
`textDisabled`, sin botón de acción en la lista). Se corrigió cambiando el tipo del campo a
`int` de punta a punta — mismo patrón que `Negociacion.idEstadoSol` (`lead/`), que siempre fue
`int` y nunca tuvo este bug:
- `SolicitudModel.fromRawString` → `ParseUtils.toInt(fields, 18)` (antes `ParseUtils.str` +
  padding).
- `SolicitudCard.colorEstado(int)`/`_accion(int)`/`_EstadoChip.idEstado` (`int`) — switches
  ahora comparan `0`/`1`/`2`/`3`, no `'00'`/`'01'`/`'02'`/`'03'`.
- `SolicitudListBloc` → `cntConDocumentos` compara `idEstado == 2`.
- Los 4 lugares que arman un `Solicitud` a mano (`_generarSolicitud` en
  `ContactoNegociacionCard`/`NegociacionesTab`, `_solicitudDesdeNegociacion` en
  `NegociacionCard`/`ContactoNegociacionCard`) mandan `idEstado: 0` (blanco) o
  `idEstado: negociacion.idEstadoSol` directo — ya no hace falta
  `.toString().padLeft(2, '0')`.
- Si se vuelve a tocar este campo, **no** reintroducir un `String` con padding — comparar
  siempre como `int` (`0` Por Completar · `1` Por Validar · `2` Con Documentos · `3` Lista
  p/Cobranza, ver "Estados de la solicitud" más abajo).

## Regla de negocio — edición de una solicitud ya existente (2026-07-14, ajustada el mismo día)
Dos dimensiones independientes — `ibValidado` (¿ya la revisó/validó un supervisor?) e `idEstado`
(¿en qué paso del flujo va, `0`-`3`?) — deciden cosas distintas, no se combinan en un solo gate:

- **`Solicitud.puedeEditar`** (`domain/entities/solicitud.dart`) = `idEstado == 0` — punto,
  **no** mira `ibValidado`. Mientras la solicitud siga "Por Completar" se puede editar, esté o
  no validada; en cuanto avanza de estado deja de poder editarse. `_BotonesDetalle`
  (`presentation/widgets/detail/solicitud_detalle_view.dart`) solo muestra "Editar ficha" cuando
  `puedeEditar` es `true`; si no, el pie queda con un único botón "Continuar" (ancho completo,
  `modoEdicion: false` — recorrido de solo lectura, ver "Validación de 'Continuar'" arriba).
- **`SolicitudCard._accion()`** (lista, `presentation/widgets/list/solicitud_card.dart`) decide
  el segundo botón de la card (además de "Ver", que siempre está) combinando `ibValidado` **e**
  `idEstado` (no solo uno de los dos):
  1. `!ibValidado && idEstado == 0` → **"Validar"**.
  2. `ibValidado && idEstado > 0` → **ninguna acción**, solo "Ver" — ya avanzó más allá de "Por
     Completar", no hay nada que completar.
  3. `ibValidado && idEstado == 0` → **"Completar"** — al entrar al detalle, `puedeEditar` (que
     solo mira `idEstado`) da `true`, así que ahí sí puede elegir "Editar ficha" o "Continuar".
  4. Caso restante (`!ibValidado && idEstado > 0`, ej. "Por Validar" con `idEstado == 1`) **sin
     definir por negocio todavía** — cae al default conservador, `ninguna` (solo "Ver"). Si
     luego se define una acción real para este caso, agregarla como un 4to `if` explícito, no
     como el default silencioso.
  Esto **reemplaza** el mismatch que estaba documentado más abajo ("Ojo — mismatch pendiente")
  — ya no está pendiente, `_accion()` ahora recibe `(ibValidado, idEstado)` en vez de solo
  `idEstado`.

## Regla de negocio — negociación con solicitud ya generada (2026-07-13)
Una vez que una negociación tiene `NUMSOL` (campo `Negociacion.numSol`, `lead/`), deja de ser
editable **en cualquier flujo** (ni desde Seguimiento ni desde Conversación) — el botón deja de
decir "Generar solicitud" y pasa a reflejar el estado real de esa solicitud:
- `Negociacion.accionSolicitud` (getter en la entidad, `lead/domain/entities/negociacion.dart`)
  centraliza la regla: sin `numSol` → `SolicitudAccion.generar` (botón "Generar solicitud",
  arranca un `Solicitud` en blanco como antes); con `numSol` y `idEstadoSol == 0` (borrador, aún
  no procesada) → `SolicitudAccion.editar` (botón "Editar solicitud", abre el wizard en modo
  edición vía `goToFichaCompletarSolicitud(modoEdicion: true)` con `idSolicitud: numSol` para que
  el paso 1 prellene con `getSolicitudDetalle()`); con `numSol` y `idEstadoSol > 0` (ya procesada)
  → `SolicitudAccion.ver` (botón "Ver solicitud", `goToDetalleSolicitud` — solo lectura).
- `idEstadoSol` es `ID_ESTADO_GES` (`EVT.T_TECMSOLINSCRIPCION01`, tasks `'DT'`/`'DN'`/`'LS'` de
  `SP_LeadsLst`) — mismo dato y mismo tipo (`int`) que `Solicitud.idEstado` (del SP de
  Solicitudes); se pasa directo al armar el `Solicitud` de paso, sin conversión.
- La edición del **lead/negociación en sí** (no la solicitud) también se bloquea si
  `negociacion.tieneSolicitud`: `NegociacionCard` (Conversaciones) cambia "Editar negociación" por
  "Ver negociación", que navega a **la misma** `EditLeadPage` pero en modo solo lectura
  (`context.goToEditarLead(idLead: negociacion.idLead, soloLectura: true)`) — no a
  `ContactoDetallePage` (eso mandaba a una pantalla distinta y, encima, `negociacion.idNumero`
  siempre es `0` en este SP — ver nota abajo). `ContactoNegociacionCard` (Seguimiento) deja el
  `onTap` del card en `null` en el mismo caso (no tiene un botón "Ver negociación" propio, y ya
  está dentro de la pestaña Información de solo lectura de esa misma pantalla).
- **`EditLeadPage`/`EditLeadView`/`EditLeadPortrait` soportan `soloLectura: bool`** (default
  `false`) — se agregó específicamente para "Ver negociación". Con `soloLectura: true`: el
  título pasa a "Ver negociación", `EditLeadPortrait._bloqueado` (`_isLoading ||
  widget.soloLectura`) se pasa como `isLoading` a las 2 secciones (`EditLeadNegociacionSection`/
  `EditLeadFinancieraSection`, que ya deshabilitan todos sus campos/combos con
  `enabled: !isLoading` — se reusa ese mecanismo, no uno nuevo) y
  `FormSaveBar` (Cancelar/Guardar) se reemplaza por `SizedBox.shrink()` — no debe quedar ningún
  botón de acción al pie. El flag viaja `goToEditarLead(soloLectura: ...)` →
  `AppRoutes.detalleEditarLead` (argumento `'soloLectura'`, default `false` si no viene) →
  `EditLeadPage` → `EditLeadView` → `EditLeadPortrait`.
  **Ojo — usar siempre `negociacion.idLead`, nunca `negociacion.idNumero`, para navegar desde
  una `Negociacion` cargada por el SP `'LN'`** (historial de negociaciones,
  `NegociacionModel.fromRawString`): ese task nunca trae `idNumero`, siempre queda en `0` (bug
  real ya corregido, 2026-07-14 — navegar con `idNumero: 0` no cargaba nada).
- Ambas cards arman un `Solicitud` "de paso" con los campos disponibles en `Negociacion`
  (`_solicitudDesdeNegociacion()`, duplicado a propósito en los 2 archivos — es corto y cada
  card vive en features distintas) — campos que `Negociacion` no trae (`cargo`, `tipoPersona`,
  `idCondicionPago`, `asesor`, etc.) quedan vacíos; no afecta la carga real del detalle, que
  siempre viene de `getSolicitudDetalle()`/`GetDetalleSolicitudUseCase` por `NUMSOL`.

## Dependencias externas
- `SolicitudRepository` (RepositoryProvider — `getSolicitudes()` ya conectado al SP real)

## Notas importantes
- `SolicitudFiltro` (`todas`, `asesores`, `sinValidar`, `enviarACobranza`) — `sinValidar` =
  `!ibValidado`, `enviarACobranza` = `ibValidado`. **Ya no usan `idEstado`** — antes
  `sinValidar` era `idEstado == 1` y `enviarACobranza` era `idEstado == 3`; se cambió
  porque "sin validar" y "listo para cobranza" son, en realidad, los dos lados de
  `IB_VALIDADO` (0/false = pendiente de validar, 1/true = ya validado → listo para
  cobranza), no un estado de gestión. Ya no existe un filtro/contador "Por completar" — se
  consideraba lo mismo que "Sin validar" y se eliminó
- Indicadores del dashboard (`_IndicadoresRow`, `solicitud_list_view.dart`): **2** tarjetas
  — "Sin validar" (`cntSinValidar` = `!ibValidado`) y "Validados" (`cntValidados` =
  `ibValidado`). Ya no existe la tarjeta "Con documentos" (`idEstado == 2`) ni el campo
  `cntConDocumentos` en `SolicitudListState`/`SolicitudListBloc` — se eliminaron por
  completo, no solo se ocultaron (2026-07-14). El chip de filtro `enviarACobranza`
  (`SolicitudFiltro`) se mantiene sin cambios de lógica, solo se le cambió el label a
  "Validados" (antes "Enviar a cobranza") para que combine con el indicador.
- ~~Ojo — mismatch pendiente con `SolicitudCard`~~ — resuelto, ver "Regla de negocio — edición
  de una solicitud ya existente" arriba: `_accion()` ahora combina `ibValidado` + `idEstado`
  (`colorEstado()` sigue mirando solo `idEstado`, para el color del chip — eso no cambió).
- Estados de la solicitud (`idEstado`, `int`, estado de gestión — dimensión aparte de
  `ibValidado`): `0` Por Completar · `1` Por Validar · `2` Con Documentos · `3` Lista
  p/Cobranza
- Separadores del backend: `AppConstants.sepListas` (`¯`), `AppConstants.sepCampos` (`¦`),
  `AppConstants.sepRegistros` (`¬`) — usados por `SolicitudRemoteDatasource.getSolicitudes()`
  y `SolicitudModel.parseList`/`fromRawString`
