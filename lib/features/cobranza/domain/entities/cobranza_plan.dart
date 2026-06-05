// lib/features/cobranza/domain/entities/cobranza_plan.dart

/// Representa una cuota individual dentro del plan de crédito.
class CuotaPlan {
  final int numeroCuota;
  final String fechaVencimiento;
  final double monto;

  const CuotaPlan({
    required this.numeroCuota,
    required this.fechaVencimiento,
    required this.monto,
  });

  CuotaPlan copyWith({
    int? numeroCuota,
    String? fechaVencimiento,
    double? monto,
  }) {
    return CuotaPlan(
      numeroCuota: numeroCuota ?? this.numeroCuota,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      monto: monto ?? this.monto,
    );
  }
}
