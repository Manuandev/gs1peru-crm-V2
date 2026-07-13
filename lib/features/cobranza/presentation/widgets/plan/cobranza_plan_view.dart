// lib/features/cobranza/presentation/widgets/plan/cobranza_plan_view.dart

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
  late final TextEditingController _numCuotasCtrl;
  late final TextEditingController _diasCtrl;
  late final TextEditingController _fechaCtrl;

  @override
  void initState() {
    super.initState();
    final estado = context.read<CobranzaPlanBloc>().state;
    _numCuotasCtrl = TextEditingController(text: '${estado.numCuotasDeseadas}');
    _diasCtrl = TextEditingController(text: '${estado.formDias}');
    _fechaCtrl = TextEditingController(text: estado.formFecha);
  }

  @override
  void dispose() {
    _numCuotasCtrl.dispose();
    _diasCtrl.dispose();
    _fechaCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final estado = context.read<CobranzaPlanBloc>().state;
    final inicial = parseFechaCorta(estado.formFecha) ?? DateTime.now();

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
          prev.formDias != curr.formDias ||
          prev.formNumeroCuota != curr.formNumeroCuota ||
          prev.numCuotasDeseadas != curr.numCuotasDeseadas ||
          (curr.status == CobranzaPlanStatus.error &&
              curr.status != prev.status),
      listener: (context, state) {
        if (_fechaCtrl.text != state.formFecha) {
          _fechaCtrl.text = state.formFecha;
        }
        final diasTexto = '${state.formDias}';
        if (_diasCtrl.text != diasTexto) _diasCtrl.text = diasTexto;
        final numCuotasTexto = '${state.numCuotasDeseadas}';
        if (_numCuotasCtrl.text != numCuotasTexto) {
          _numCuotasCtrl.text = numCuotasTexto;
        }
        if (state.status == CobranzaPlanStatus.error) {
          AppSnackBar.error(context, state.mensajeError ?? 'Ocurrió un error');
        }
      },
      builder: (context, state) {
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
          footer: _FooterPlan(state: state),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                CobranzaPlanResumenCard(
                  state: state,
                  numCuotasCtrl: _numCuotasCtrl,
                ),
                const SizedBox(height: AppSpacing.md),
                CobranzaPlanConfigurarCard(
                  state: state,
                  diasCtrl: _diasCtrl,
                  fechaCtrl: _fechaCtrl,
                  onFechaTap: _seleccionarFecha,
                ),
                const SizedBox(height: AppSpacing.sm),
                _BotonesVistaPrevia(estaCargando: state.status == CobranzaPlanStatus.loading),
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

// ── Vista previa / Limpiar Todo — su propia fila, entre Configurar cuota y Cronograma ──

class _BotonesVistaPrevia extends StatelessWidget {
  final bool estaCargando;
  const _BotonesVistaPrevia({required this.estaCargando});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CobranzaPlanBloc>();
    return Row(
      children: [
        Expanded(
          child: CustomPrimaryButton(
            text: 'Vista previa',
            onPressed: estaCargando
                ? null
                : () => bloc.add(const VistaPreviaPressed()),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: CustomSecondaryButton(
            text: 'Limpiar Todo',
            onPressed: estaCargando
                ? null
                : () => bloc.add(const LimpiarPressed()),
          ),
        ),
      ],
    );
  }
}

// ── Footer fijo: Total + botón Guardar ────────────────────────────────────────

class _FooterPlan extends StatelessWidget {
  final CobranzaPlanState state;

  const _FooterPlan({required this.state});

  @override
  Widget build(BuildContext context) {
    final estaCargando = state.status == CobranzaPlanStatus.loading;

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
                '${resolverSimboloMoneda(context, state.moneda)} ${state.totalCuotas.toStringAsFixed(2)}'
                    .trim(),
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
