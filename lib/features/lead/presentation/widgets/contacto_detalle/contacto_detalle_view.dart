// lib/features/lead/presentation/widgets/contacto_detalle/contacto_detalle_view.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ContactoDetalleView extends StatefulWidget {
  // 2026-08-03 — migrado de idNumero a idContacto (T_LEAD.ID_CONTACTO).
  final int idContacto;

  const ContactoDetalleView({super.key, required this.idContacto});

  @override
  State<ContactoDetalleView> createState() => _ContactoDetalleViewState();
}

class _ContactoDetalleViewState extends State<ContactoDetalleView> {
  StreamSubscription<LeadUpdate>? _updateSub;
  StreamSubscription<ContactoUpdate>? _contactoSub;
  late final InfoLeadCubit _cubit;
  // Última negociación cargada con éxito — se sigue mostrando mientras el
  // cubit pasa por InfoLeadLoading en un refresh (ver builder más abajo), en
  // vez de tumbar todo _ContactoScaffold (y su DefaultTabController, que
  // resetea la pestaña activa a "Información") por cada recarga en segundo
  // plano. Solo el primer load real (sin datos previos) muestra el skeleton.
  Negociacion? _ultimoLead;

  // true en cuanto llega el primer InfoLeadSuccess real de este contacto
  // (tenga o no negociación). Distingue "contacto sin negociación recién
  // cargado" (idLead 0, _cargaHecha false) del placeholder transitorio de
  // prepararNuevaNegociacion() (idLead 0, _cargaHecha true).
  bool _cargaHecha = false;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<InfoLeadCubit>();
    _cubit.cargarPorIdContacto(widget.idContacto);
    context.read<RecordatoriosLeadCubit>().cargarRecordatoriosPorContacto(
      widget.idContacto,
    );

    // ContactoNegociacionesTab edita leads históricos con SU PROPIO
    // InfoLeadCubit (ver contacto_negociacion_card.dart) — esta pantalla no
    // se entera por ahí, así que escucha directo el mismo bus que usa
    // LeadListBloc, filtrando por idContacto (no por idLead: cualquier lead
    // de este contacto que cambie puede alterar cuál es "el más reciente"
    // que muestra Información, o afectar el historial de Negociaciones).
    //
    // Ojo — "Crear negociación" (ContactoNegociacionesTab._crearNegociacion)
    // SÍ usa este mismo InfoLeadCubit compartido (a diferencia de editar una
    // card existente), porque necesita prepararNuevaNegociacion()/restaurar
    // sobre el mismo estado. Bug real detectado en vivo: sin el filtro de
    // abajo, el aviso que ese mismo guardado dispara (updateLead ya hizo su
    // propio emit con el idLead real) volvía a entrar acá y llamaba
    // _refrescar(), que reemite InfoLeadLoading sobre el cubit compartido —
    // eso tumbaba _ContactoScaffold completo (cayendo en "Información" en
    // vez de quedarse en "Negociaciones") y, si EditLeadPortrait todavía
    // estaba mostrando el check verde, EditLeadView lo reemplazaba por
    // AppLoadingView a mitad de camino, cancelando su pop automático.
    _updateSub = LeadUpdateNotifier.instance.stream.listen((update) {
      if (identical(update.source, _cubit)) return;
      final negociacion = update.updatedLead;
      if (negociacion is Negociacion &&
          negociacion.idContacto == widget.idContacto) {
        _refrescar();
      }
    });

    // Editar contacto (botón de ContactoInfoTab, EditContactoSimple) no pasa
    // por LeadUpdateNotifier — es otro SP/flujo por completo (CSV_CONTACTO_*,
    // no CSV_LEADS_*). Mismo patrón que ChatDetailPage: se suscribe al bus
    // dedicado, keyed por idNumero (ancla de EditContactoSimple), y refresca
    // en silencio (_refrescar() ya evita el skeleton mientras haya
    // _ultimoLead, ver comentario de esa variable).
    _contactoSub = ContactoUpdateNotifier.instance.stream.listen((update) {
      if (_ultimoLead != null && update.idNumero == _ultimoLead!.idNumero) {
        _refrescar();
      }
    });
  }

  @override
  void dispose() {
    _updateSub?.cancel();
    _contactoSub?.cancel();
    super.dispose();
  }

  Future<void> _refrescar() => Future.wait([
    _cubit.cargarPorIdContacto(widget.idContacto),
    context.read<NegociacionesCubit>().cargarNegociaciones(
      widget.idContacto,
    ),
    context.read<RecordatoriosLeadCubit>().cargarRecordatoriosPorContacto(
      widget.idContacto,
    ),
  ]);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InfoLeadCubit, InfoLeadState>(
      // NegociacionesCubit.cargarNegociaciones necesita idContacto, que solo
      // se conoce una vez que InfoLeadCubit resuelve el lead — por eso se
      // dispara acá y no en initState (ahí solo se tiene idLead).
      //
      // idLead == 0 es el placeholder en blanco que deja
      // prepararNuevaNegociacion() (ContactoNegociacionesTab._crearNegociacion)
      // para sembrar el form de "Crear negociación" en el mismo cubit
      // compartido — no es un lead real cargado. Sin este filtro, cada tap en
      // "+ Crear negociación" pisaba _ultimoLead con datos en blanco y
      // disparaba una recarga innecesaria de NegociacionesCubit (mismo
      // idContacto, ya correcto), que de puro async pasaba por
      // NegociacionesLoading y hacía parpadear la lista a "Sin negociaciones"
      // un instante antes de navegar a Editar.
      listener: (context, state) {
        if (state is! InfoLeadSuccess) return;
        final n = state.negociacion;
        if (n.idContacto != widget.idContacto) return;
        // idLead 0 + ya hubo carga real = placeholder de
        // prepararNuevaNegociacion() (transitorio, al tocar "Crear
        // negociación"): no pisar _ultimoLead ni recargar la lista. Un
        // contacto SIN negociación (primera carga real) sí se toma.
        if (n.idLead == 0 && _cargaHecha) return;
        _cargaHecha = true;
        _ultimoLead = n;
        context.read<NegociacionesCubit>().cargarNegociaciones(n.idContacto);
      },
      builder: (context, state) {
        if (state is InfoLeadFailure) {
          return BasePage(
            title: 'Detalle de contacto',
            drawerSide: DrawerSide.none,
            appBarLeadingButtons: [
              IconButton(
                icon: const Icon(AppIcons.backIos),
                onPressed: () => context.goBack(),
              ),
            ],
            body: AppErrorView(
              message: state.message,
              onRetry: () => _cubit.cargarPorIdContacto(widget.idContacto),
            ),
          );
        }
        // InfoLeadLoading de un refresh, o el placeholder de
        // prepararNuevaNegociacion() (idLead 0 con _cargaHecha): se sigue
        // mostrando _ultimoLead. Un contacto sin negociación (idLead 0 en la
        // primera carga) sí se muestra tal cual — el _ContactoScaffold pinta
        // estado/campaña/oportunidad vacíos y deja crear una.
        final lead = (state is InfoLeadSuccess &&
                state.negociacion.idContacto == widget.idContacto &&
                !(state.negociacion.idLead == 0 && _cargaHecha))
            ? state.negociacion
            : _ultimoLead;
        if (lead == null) {
          return const ContactoDetalleSkeleton();
        }
        return _ContactoScaffold(lead: lead, onRefresh: _refrescar);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scaffold real — datos cargados
// ─────────────────────────────────────────────────────────────────────────────

class _ContactoScaffold extends StatelessWidget {
  final Negociacion lead;
  final Future<void> Function() onRefresh;

  const _ContactoScaffold({required this.lead, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: BasePage(
        bodyPadding: EdgeInsets.zero,
        titleWidget: _ContactoHeaderTitle(lead: lead),
        drawerSide: DrawerSide.none,
        appBarLeadingButtons: [
          IconButton(
            icon: const Icon(AppIcons.backIos),
            onPressed: () => context.goBack(),
          ),
        ],
        footer: ContactoAccionesFooter(lead: lead),
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: onRefresh,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardSection(
                margin: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: ChatDetailFases(
                  idEstadoActual: lead.idEstado,
                  idEstadoPadre: lead.idEstadoPadre,
                ),
              ),
              _CardSection(
                margin: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: TabBar(
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: AppSizing.borderFocusWidth,
                    ),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: AppColors.transparent,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxs,
                  ),
                  // Achicado (antes labelMedium/iconXs) — con 4 tabs
                  // (se agregó "Recordatorios") ya no entraban cómodos,
                  // mismo criterio compacto que ya usa ChatLeadPanel.
                  labelStyle: AppTextStyles.labelSmall.copyWith(
                    fontWeight: AppTextStyles.weightBold,
                  ),
                  unselectedLabelStyle: AppTextStyles.labelSmall,
                  tabs: const [
                    Tab(
                      icon: Icon(AppIcons.datosLead, size: AppSizing.iconInline),
                      text: 'Información',
                    ),
                    Tab(
                      icon: Icon(
                        AppIcons.negociacion,
                        size: AppSizing.iconInline,
                      ),
                      text: 'Negociaciones',
                    ),
                    Tab(
                      icon: Icon(AppIcons.historial, size: AppSizing.iconInline),
                      text: 'Historial',
                    ),
                    Tab(
                      icon: Icon(
                        AppIcons.recordatorio,
                        size: AppSizing.iconInline,
                      ),
                      text: 'Recordatorios',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<NegociacionesCubit, NegociacionesState>(
                  builder: (context, negState) {
                    final negociaciones = negState is NegociacionesSuccess
                        ? negState.negociaciones
                        : const <Negociacion>[];

                    return TabBarView(
                      children: [
                        ContactoInfoTab(
                          lead: lead,
                          negociaciones: negociaciones,
                        ),
                        ContactoNegociacionesTab(
                          idContacto: lead.idContacto,
                          negociaciones: negociaciones,
                        ),
                        HistorialTab(idContacto: lead.idContacto),
                        RecordatoriosTab(idContacto: lead.idContacto),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card flotante — envuelve stepper y tab bar sobre el fondo gris de la página
// ─────────────────────────────────────────────────────────────────────────────

class _CardSection extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry margin;

  const _CardSection({required this.child, required this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: AppSizing.shadowBlurMd,
            offset: const Offset(0, AppSizing.shadowOffsetCardY),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        child: ColoredBox(color: AppColors.surface, child: child),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Título del AppBar — avatar con badge de estado + nombre
// ─────────────────────────────────────────────────────────────────────────────

class _ContactoHeaderTitle extends StatelessWidget {
  final Negociacion lead;

  const _ContactoHeaderTitle({required this.lead});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final nombreCompleto = lead.nombreCompleto.isNotEmpty
        ? lead.nombreCompleto
        : '${lead.prefijoPais} ${lead.numero}';

    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: AppSizing.avatarRadiusAppBar,
              backgroundColor: AvatarUtils.color(nombreCompleto),
              child: Icon(
                AppIcons.user,
                size: AppSizing.iconSm,
                color: AppColors.textOnDark,
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                width: AppSizing.avatarCanalBadge,
                height: AppSizing.avatarCanalBadge,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surface,
                    width: AppSizing.canalBadgeBorder,
                  ),
                ),
                child: Center(
                  child: AppSocialUtils.widgetEstado(
                    lead.idEstadoEfectivo,
                    size: AppSizing.iconCanalBadge,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: AppSpacing.smPlus),
        Expanded(
          child: Text(
            nombreCompleto,
            style: AppTextStyles.titleMedium.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: AppTextStyles.weightBold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
