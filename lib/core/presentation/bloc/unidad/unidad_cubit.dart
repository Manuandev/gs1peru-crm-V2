// lib/core/presentation/bloc/unidad/unidad_cubit.dart
// ============================================================
// UNIDAD CUBIT — GLOBAL (singleton, mismo patrón que FiltroCubit)
// ============================================================
//
// Unidad de negocio activa del asesor. Toda la data de la app (listas,
// contadores, combos) se filtra por esta unidad: la cadena es
// negociación → campaña → unidad.
//
// - Login (normal o Google)  → la primera del login (asignación más reciente).
// - Restaurar sesión (Splash) → la última elegida en el drawer, si todavía
//   la tiene asignada; si no, la primera del login.
// - Drawer                    → cambiarUnidad().
// - Logout                    → limpiar().
//
// La unidad elegida se guarda en la tabla `settings` de SQLite junto con el
// codUser, así otra cuenta en el mismo dispositivo no hereda la selección.
// Además se copia a SessionService para que los datasources la manden en el
// body de cada SP sin depender de la capa de presentación.
// ============================================================

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';

class UnidadCubit extends Cubit<UnidadState> {
  static final UnidadCubit instance = UnidadCubit._();

  UnidadCubit._() : super(const UnidadState());

  // Clave en la tabla `settings` — valor: codUser ¦ idUnidad.
  static const String _claveUnidadActiva = 'unidad_activa';

  final _session = SessionService();
  final _db = LocalDatabase();

  /// Fija la unidad activa tras autenticarse. Llamar ANTES de emitir
  /// AuthAuthenticated, para que la primera carga de Home ya salga filtrada.
  ///
  /// [restaurar] `true` al restaurar la sesión guardada (Splash) → respeta la
  /// última unidad elegida; `false` en un login manual → la más reciente.
  Future<void> inicializar({required bool restaurar}) async {
    final unidades = _session.unidades;
    int? activa = unidades.isEmpty ? null : unidades.first;

    if (restaurar && unidades.isNotEmpty) {
      final guardada = await _leerGuardada();
      if (guardada != null && unidades.contains(guardada)) activa = guardada;
    }

    await _aplicar(unidades, activa);
  }

  /// Cambio desde el drawer. No hace nada si ya es la activa o si no está
  /// entre las unidades asignadas.
  Future<void> cambiarUnidad(int idUnidad) async {
    if (idUnidad == state.idUnidadActiva) return;
    if (!state.unidades.contains(idUnidad)) return;
    await _aplicar(state.unidades, idUnidad);
  }

  /// Logout — el próximo login vuelve a la unidad más reciente.
  Future<void> limpiar() async {
    _session.setUnidadActiva(null);
    try {
      await _db.deleteSetting(_claveUnidadActiva);
    } catch (_) {}
    emit(const UnidadState());
  }

  // ── Privado ───────────────────────────────────────────────

  Future<void> _aplicar(List<int> unidades, int? activa) async {
    _session.setUnidadActiva(activa);
    if (activa != null) {
      try {
        await _db.setSetting(
          _claveUnidadActiva,
          [_session.codUser, activa].join(AppConstants.sepCampos),
        );
      } catch (_) {}
    }
    emit(UnidadState(unidades: List.unmodifiable(unidades), idUnidadActiva: activa));
  }

  /// Unidad guardada para el usuario actual, o `null` si no hay o es de otro
  /// codUser.
  Future<int?> _leerGuardada() async {
    try {
      final valor = await _db.getSetting(_claveUnidadActiva);
      if (valor == null) return null;
      final campos = valor.split(AppConstants.sepCampos);
      if (campos.length < 2 || campos[0] != _session.codUser) return null;
      return int.tryParse(campos[1]);
    } catch (_) {
      return null;
    }
  }
}
