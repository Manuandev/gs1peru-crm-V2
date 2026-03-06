// lib/features/settings/presentation/pages/settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/settings/index_settings.dart';

/// Envuelve la vista con su propio BlocProvider — igual que LoginPage
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit()..checkPermissions(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Configuración',
      drawerSide: DrawerSide.left,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // ── APARIENCIA ──────────────────────────────────
          _SectionHeader(icon: Icons.palette_rounded, title: 'Apariencia'),
          const SizedBox(height: AppSpacing.md),
          const _ThemeSelector(),
          const SizedBox(height: AppSpacing.xl),

          // ── PERMISOS ────────────────────────────────────
          _SectionHeader(icon: Icons.security_rounded, title: 'Permisos'),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Toca un permiso denegado para solicitarlo. '
            'Si está bloqueado serás redirigido a los ajustes del sistema.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          const _PermissionsList(),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => context.read<SettingsCubit>().checkPermissions(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Actualizar estado'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SELECTOR DE TEMA — usa ThemeCubit (global, desde AppWidget)
// ============================================================
class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, currentMode) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Column(
              children: [
                _ThemeOption(
                  icon: Icons.light_mode_rounded,
                  label: 'Claro',
                  subtitle: 'Siempre usa el tema claro',
                  selected: currentMode == ThemeMode.light,
                  onTap: () =>
                      context.read<ThemeCubit>().setTheme(ThemeMode.light),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _ThemeOption(
                  icon: Icons.dark_mode_rounded,
                  label: 'Oscuro',
                  subtitle: 'Siempre usa el tema oscuro',
                  selected: currentMode == ThemeMode.dark,
                  onTap: () =>
                      context.read<ThemeCubit>().setTheme(ThemeMode.dark),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _ThemeOption(
                  icon: Icons.brightness_auto_rounded,
                  label: 'Sistema',
                  subtitle: 'Sigue el tema del dispositivo',
                  selected: currentMode == ThemeMode.system,
                  onTap: () =>
                      context.read<ThemeCubit>().setTheme(ThemeMode.system),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final color = selected
        ? primary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: selected ? primary : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(
        selected
            ? Icons.check_circle_rounded
            : Icons.radio_button_unchecked_rounded,
        color: color,
      ),
    );
  }
}

// ============================================================
// LISTA DE PERMISOS — usa SettingsCubit (local, desde SettingsPage)
// ============================================================
class _PermissionsList extends StatelessWidget {
  const _PermissionsList();

  static const _items = [
    _PermInfo(
      permission: Permission.location,
      icon: Icons.location_on_rounded,
      label: 'Ubicación',
      description: 'Necesaria para registrar tu acceso',
    ),
    _PermInfo(
      permission: Permission.camera,
      icon: Icons.camera_alt_rounded,
      label: 'Cámara',
      description: 'Para adjuntar fotos en reportes',
    ),
    _PermInfo(
      permission: Permission.microphone,
      icon: Icons.mic_rounded,
      label: 'Micrófono',
      description: 'Para notas de voz en el chat',
    ),
    _PermInfo(
      permission: Permission.notification,
      icon: Icons.notifications_rounded,
      label: 'Notificaciones',
      description: 'Alertas de leads y recordatorios',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return Column(
          children: _items.map((item) {
            final status =
                state.permissions[item.permission] ?? PermissionStatus.denied;
            return _PermissionCard(
              item: item,
              status: status,
              onTap: () => context
                  .read<SettingsCubit>()
                  .requestPermission(item.permission),
            );
          }).toList(),
        );
      },
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final _PermInfo item;
  final PermissionStatus status;
  final VoidCallback onTap;

  const _PermissionCard({
    required this.item,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isGranted = status == PermissionStatus.granted ||
        status == PermissionStatus.limited;
    final isBlocked = status == PermissionStatus.permanentlyDenied ||
        status == PermissionStatus.restricted;

    final color =
        isGranted ? Colors.green : isBlocked ? Colors.red : Colors.orange;
    final label =
        isGranted ? 'Concedido' : isBlocked ? 'Bloqueado' : 'Denegado';
    final icon = isGranted
        ? Icons.check_circle_rounded
        : isBlocked
            ? Icons.block_rounded
            : Icons.cancel_rounded;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        onTap: isGranted ? null : onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          ),
          child: Icon(item.icon, color: color, size: 22),
        ),
        title: Text(item.label,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(item.description),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── SECTION HEADER ───────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Icon(icon, size: 20, color: primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: primary,
              ),
        ),
      ],
    );
  }
}

// ── MODELO INTERNO ───────────────────────────────────────────
class _PermInfo {
  final Permission permission;
  final IconData icon;
  final String label;
  final String description;
  const _PermInfo({
    required this.permission,
    required this.icon,
    required this.label,
    required this.description,
  });
}