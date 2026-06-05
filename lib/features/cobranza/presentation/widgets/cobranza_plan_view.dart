// lib/features/cobranza/presentation/widgets/cobranza_plan_view.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaPlanView extends StatefulWidget {
  const CobranzaPlanView({super.key});

  @override
  State<CobranzaPlanView> createState() => _CobranzaPlanViewState();
}

class _CobranzaPlanViewState extends State<CobranzaPlanView> {
  late final TextEditingController _numCuotaCtrl;
  late final TextEditingController _diasCtrl;
  late final TextEditingController _fechaCtrl;
  late final TextEditingController _montoCtrl;

  @override
  void initState() {
    super.initState();
    final estado = context.read<CobranzaPlanBloc>().state;
    _numCuotaCtrl = TextEditingController(text: '${estado.formNumeroCuota}');
    _diasCtrl = TextEditingController(text: '${estado.formDias}');
    _fechaCtrl = TextEditingController(text: estado.formFecha);
    _montoCtrl = TextEditingController(
      text: estado.formMonto.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _numCuotaCtrl.dispose();
    _diasCtrl.dispose();
    _fechaCtrl.dispose();
    _montoCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final estado = context.read<CobranzaPlanBloc>().state;

    DateTime inicial;
    try {
      final partes = estado.formFecha.split('/');
      inicial = DateTime(
        int.parse(partes[2]),
        int.parse(partes[1]),
        int.parse(partes[0]),
      );
    } catch (_) {
      inicial = DateTime.now();
    }

    final seleccionada = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (seleccionada != null && mounted) {
      final formateada = seleccionada.format(AppDateFormat.shortDate);
      context.read<CobranzaPlanBloc>().add(FechaCuotaChanged(formateada));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CobranzaPlanBloc, CobranzaPlanState>(
      listenWhen: (prev, curr) =>
          prev.formFecha != curr.formFecha ||
          curr.status == CobranzaPlanStatus.limpiado,
      listener: (context, state) {
        if (_fechaCtrl.text != state.formFecha) {
          _fechaCtrl.text = state.formFecha;
        }
        if (state.status == CobranzaPlanStatus.limpiado) {
          _numCuotaCtrl.text = '${state.formNumeroCuota}';
          _diasCtrl.text = '${state.formDias}';
          _montoCtrl.text = state.formMonto.toStringAsFixed(2);
        }
      },
      builder: (context, state) {
        final estaCargando = state.status == CobranzaPlanStatus.loading;

        return BasePage(
          title: 'Plan de crédito',
          drawerSide: DrawerSide.none,
          bodyPadding: EdgeInsets.zero,
          appBarLeadingButtons: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.goBack(),
            ),
          ],
          footer: _FooterPlan(state: state, estaCargando: estaCargando),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Text(
                  state.nombre,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: AppTextStyles.weightSemiBold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  state.oportunidad,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                CobranzaPlanResumenCard(state: state),
                const SizedBox(height: AppSpacing.md),
                CobranzaPlanConfigurarCard(
                  state: state,
                  numCuotaCtrl: _numCuotaCtrl,
                  diasCtrl: _diasCtrl,
                  fechaCtrl: _fechaCtrl,
                  montoCtrl: _montoCtrl,
                  onFechaTap: _seleccionarFecha,
                ),
                const SizedBox(height: AppSpacing.md),
                CobranzaPlanCronogramaCard(state: state),
                // Espacio extra para que el footer no tape el último elemento
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Footer fijo: Total + botón Guardar ────────────────────────────────────────

class _FooterPlan extends StatelessWidget {
  final CobranzaPlanState state;
  final bool estaCargando;

  const _FooterPlan({required this.state, required this.estaCargando});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total cuotas',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'S/ ${state.totalCuotas.toStringAsFixed(2)}',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: AppTextStyles.weightBold,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: CustomPrimaryButton(
              text: 'Guardar plan',
              isLoading: estaCargando,
              onPressed: state.cuotas.isEmpty
                  ? null
                  : () => context.read<CobranzaPlanBloc>().add(
                      const GuardarPlanPressed(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
