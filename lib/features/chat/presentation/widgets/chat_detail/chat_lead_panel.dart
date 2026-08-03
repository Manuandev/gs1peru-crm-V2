// lib/features/chat/presentation/widgets/chat_detail/chat_lead_panel.dart
//
// Panel deslizable inline que aparece sobre el ChatInputBar.
// Muestra las tabs Datos / Negociaciones / Historial del lead activo.

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ChatLeadPanel extends StatefulWidget {
  final Chat chat;
  final Negociacion negociacion;
  final int idNumero;
  final TabController tabController;
  final InfoLeadCubit cubit;
  final VoidCallback onClose;

  const ChatLeadPanel({
    super.key,
    required this.chat,
    required this.negociacion,
    required this.idNumero,
    required this.tabController,
    required this.cubit,
    required this.onClose,
  });

  @override
  State<ChatLeadPanel> createState() => _ChatLeadPanelState();
}

class _ChatLeadPanelState extends State<ChatLeadPanel> {
  double _height = 0;
  bool _cerrando = false;

  static const double _fraccionDefecto = 0.40;
  static const double _fraccionMax = 0.52;
  static const double _alturaMinCierre = 100.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _height = MediaQuery.of(context).size.height * _fraccionDefecto;
        });
      }
    });
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_cerrando) return;
    setState(() {
      _height -= d.delta.dy;
      final max = MediaQuery.of(context).size.height * _fraccionMax;
      _height = _height.clamp(0.0, max);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    if (_cerrando) return;
    final velocidadAbajo = d.velocity.pixelsPerSecond.dy > 400;
    if (_height < _alturaMinCierre || velocidadAbajo) {
      _cerrar();
    } else {
      final defecto = MediaQuery.of(context).size.height * _fraccionDefecto;
      setState(() => _height = defecto);
    }
  }

  Future<void> _cerrar() async {
    _cerrando = true;
    setState(() => _height = 0);
    await Future.delayed(const Duration(milliseconds: 220));
    if (mounted) widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      height: _height,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // ── Handle draggable ──────────────────────────────────────────────
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onVerticalDragUpdate: _onDragUpdate,
            onVerticalDragEnd: _onDragEnd,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Center(
                child: Container(
                  width: AppSizing.sheetHandleWidth,
                  height: AppSizing.sheetHandleHeight,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
                  ),
                ),
              ),
            ),
          ),

          // ── TabBar compacto ───────────────────────────────────────────────
          TabBar(
            controller: widget.tabController,
            labelStyle: AppTextStyles.labelSmall.copyWith(
              fontWeight: AppTextStyles.weightSemiBold,
            ),
            unselectedLabelStyle: AppTextStyles.labelSmall,
            tabs: const [
              Tab(
                icon: Icon(AppIcons.datosLead, size: AppSizing.iconSm),
                text: 'Datos',
              ),
              Tab(
                icon: Icon(AppIcons.negociacion, size: AppSizing.iconSm),
                text: 'Negociaciones',
              ),
              Tab(
                icon: Icon(AppIcons.historial, size: AppSizing.iconSm),
                text: 'Historial',
              ),
            ],
          ),

          // ── Contenido de cada tab ─────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: widget.tabController,
              children: [
                DatosTab(
                  chat: widget.chat,
                  negociacion: widget.negociacion,
                  idNumero: widget.idNumero,
                  cubit: widget.cubit,
                  onCerrar: _cerrar,
                ),
                NegociacionesTab(
                  leadId: widget.negociacion.idLead,
                  // idContacto, no idNumero — ver migración 2026-08-03 en
                  // lead/CLAUDE.md. Chat ya trae idContacto propio.
                  idContacto: widget.chat.idContacto,
                  onCerrar: _cerrar,
                ),
                HistorialTab(idContacto: widget.chat.idContacto),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
