// lib/features/lead/presentation/pages/edit_lead_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class EditLeadPage extends StatefulWidget {
  final InfoLead lead;

  const EditLeadPage({super.key, required this.lead});

  @override
  State<EditLeadPage> createState() => _EditLeadPageState();
}

class _EditLeadPageState extends State<EditLeadPage> {
  late final TextEditingController _empresaCtrl;
  late final TextEditingController _cargoCtrl;
  late final TextEditingController _telefonoCtrl;
  late final TextEditingController _correoCtrl;
  late final TextEditingController _notasCtrl;

  late String _estado;
  late String _subestado;
  late String _campania;
  late String _evento;
  late String _canal;
  late String _interes;
  late String _pais;
  bool _atendidoPorBot = false;

  @override
  void initState() {
    super.initState();
    _empresaCtrl = TextEditingController(text: widget.lead.nombreEmpresa);
    _cargoCtrl = TextEditingController();
    _telefonoCtrl = TextEditingController(text: widget.lead.telefono);
    _correoCtrl = TextEditingController();
    _notasCtrl = TextEditingController();

    _estado = widget.lead.estado;
    _subestado = widget.lead.subEstado;
    _campania = widget.lead.campania ?? '';
    _evento = widget.lead.evento ?? '';
    _canal = widget.lead.canal ?? '';
    _interes = widget.lead.interes ?? '';
    _pais = 'Perú';
  }

  @override
  void dispose() {
    _empresaCtrl.dispose();
    _cargoCtrl.dispose();
    _telefonoCtrl.dispose();
    _correoCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  void _guardarCambios() {
    // TODO: llamar al cubit/bloc correspondiente para guardar en BD
    // context.read<EditarLeadCubit>().guardar(...)
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(colorScheme),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Información del prospecto',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: AppTextStyles.weightSemiBold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildFieldGrid(),
                  const SizedBox(height: AppSpacing.md),
                  _buildNotasRapidas(),
                  const SizedBox(height: AppSpacing.sm),
                  _buildCheckbox(colorScheme),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
          _buildBottomButtons(colorScheme),
        ],
      ),
    );
  }

  AppBar _buildAppBar(ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: colorScheme.primary,
      foregroundColor: AppColors.textOnDark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: AppSizing.avatarRadiusAppBar,
            backgroundColor: AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxs),
              child: SvgPicture.asset(
                AppImages.logoGs1Peru,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Editar lead',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textOnDark,
              fontWeight: AppTextStyles.weightSemiBold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(AppIcons.more),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: AppSizing.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizing.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              radius: AppSizing.avatarRadiusXl,
              backgroundColor: widget.lead.nombreCompleto.avatarColor,
              child: Text(
                widget.lead.nombreCompleto.initials,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textOnDark,
                  fontWeight: AppTextStyles.weightBold,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lead.nombreCompleto,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: AppTextStyles.weightBold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      if (widget.lead.idCanal != null) ...[
                        CanalHelper.icon(
                          widget.lead.idCanal!,
                          size: AppSizing.iconSm,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      Flexible(
                        child: Text(
                          widget.lead.canal ?? '',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppIconsSocial.chipEstado(
                        widget.lead.idEstado,
                        label: widget.lead.estado,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Última respuesta hace 42 min',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _DropdownField(
                icon: Icons.flag_outlined,
                iconColor: AppColors.success,
                label: 'Estado *',
                value: _estado,
                onTap: () {},
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _DropdownField(
                icon: Icons.checklist_outlined,
                iconColor: AppColors.info,
                label: 'Subestado *',
                value: _subestado,
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _DropdownField(
                icon: Icons.campaign_outlined,
                iconColor: AppColors.warning,
                label: 'Campaña *',
                value: _campania,
                onTap: () {},
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _DropdownField(
                icon: Icons.event_outlined,
                iconColor: AppColors.warning,
                label: 'Evento *',
                value: _evento,
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _DropdownField(
                icon: Icons.facebook_outlined,
                iconColor: AppColors.info,
                label: 'Canal *',
                value: _canal,
                onTap: () {},
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _DropdownField(
                icon: Icons.group_outlined,
                iconColor: Colors.purple,
                label: 'Interés *',
                value: _interes,
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _TextField(
                icon: Icons.business_outlined,
                label: 'Empresa',
                controller: _empresaCtrl,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _TextField(
                icon: Icons.work_outline,
                label: 'Cargo',
                controller: _cargoCtrl,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _TextField(
                icon: Icons.phone_outlined,
                label: 'Teléfono',
                controller: _telefonoCtrl,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _TextField(
                icon: Icons.email_outlined,
                label: 'Correo',
                controller: _correoCtrl,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _DropdownField(
          icon: Icons.language_outlined,
          iconColor: AppColors.info,
          label: 'País',
          value: _pais,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildNotasRapidas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notas rápidas', style: AppTextStyles.bodyMedium),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _notasCtrl,
          maxLines: 5,
          maxLength: 500,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.all(AppSpacing.sm),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizing.radiusMd),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizing.radiusMd),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizing.radiusMd),
              borderSide: const BorderSide(
                color: AppColors.borderFocused,
                width: AppSizing.borderFocusWidth,
              ),
            ),
            counterStyle: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox(ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(
          Icons.smart_toy_outlined,
          color: colorScheme.primary,
          size: AppSizing.iconSm,
        ),
        Checkbox(
          value: _atendidoPorBot,
          onChanged: (v) => setState(() => _atendidoPorBot = v ?? false),
          activeColor: AppColors.success,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(
          'Cliente atendido por bot previamente',
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildBottomButtons(ColorScheme colorScheme) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: AppSizing.buttonHeight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Guardar cambios'),
                onPressed: _guardarCambios,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: AppColors.textOnDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizing.radiusLg),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              height: AppSizing.buttonHeight,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.chevron_left),
                label: const Text('Volver al chat'),
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizing.radiusLg),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets privados ─────────────────────────────────────────────────────────

class _DropdownField extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DropdownField({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: AppSizing.iconActionSm),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    value.isEmpty ? '—' : value,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
              size: AppSizing.iconActionSm,
            ),
          ],
        ),
      ),
    );
  }
}

class _TextField extends StatefulWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;

  const _TextField({
    required this.icon,
    required this.label,
    required this.controller,
  });

  @override
  State<_TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<_TextField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.only(
        left: AppSpacing.sm,
        right: AppSpacing.xs,
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            widget.icon,
            color: AppColors.textSecondary,
            size: AppSizing.iconActionSm,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                TextField(
                  controller: widget.controller,
                  style: AppTextStyles.bodyMedium,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          if (hasText)
            GestureDetector(
              onTap: () => widget.controller.clear(),
              child: const Icon(
                AppIcons.close,
                color: AppColors.textSecondary,
                size: AppSizing.iconActionSm,
              ),
            ),
        ],
      ),
    );
  }
}
