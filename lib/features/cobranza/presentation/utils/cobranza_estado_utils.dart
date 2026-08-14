// lib/features/cobranza/presentation/utils/cobranza_estado_utils.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';

// ID_ESTADO_GES crudo (DBO.[edu.TIP_ESTADO_GES]): 0=Pend.deDocumento
// 2=Facturar 5=Pend.factura 3=Cancelado. 1=FreePass y 4=Anulado no tienen
// tarjeta/bucket propio (ver CobranzaSummaryCards/CobranzaDetalleStepper),
// caen al color por defecto.
//
// Único lugar con esta tabla de colores — CobranzaSummaryCards (filtros de
// la lista), CobranzaCard (badge de cada registro) y CobranzaDetalleInfoCard
// (badge del detalle) la comparten para que los 3 siempre pinten el mismo
// color por estado (antes cada uno tenía su propio switch, y se
// desincronizaron — bug real reportado en vivo, 2026-08-14).
Color colorEstadoGes(int idEstado) => switch (idEstado) {
  0 => AppColors.warning,
  2 => AppColors.primary,
  5 => AppColors.secondary,
  3 => AppColors.success,
  _ => AppColors.textDisabled,
};
