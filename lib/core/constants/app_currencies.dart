// lib/core/constants/app_currencies.dart

import 'package:app_crm/core/models/moneda_item.dart';

/// Monedas disponibles en el sistema.
/// Ampliar aquí para agregar nuevas monedas sin tocar los formularios.
class AppCurrencies {
  AppCurrencies._();

  static const List<MonedaItem> all = [
    MonedaItem(codigo: 'PEN', nombre: 'Sol Peruano',        simbolo: 'S/'),
    MonedaItem(codigo: 'USD', nombre: 'Dólar Americano',    simbolo: '\$'),
    MonedaItem(codigo: 'EUR', nombre: 'Euro',               simbolo: '€'),
    MonedaItem(codigo: 'COP', nombre: 'Peso Colombiano',    simbolo: 'COP'),
    MonedaItem(codigo: 'MXN', nombre: 'Peso Mexicano',      simbolo: 'MX\$'),
    MonedaItem(codigo: 'BRL', nombre: 'Real Brasileño',     simbolo: 'R\$'),
    MonedaItem(codigo: 'ARS', nombre: 'Peso Argentino',     simbolo: '\$'),
    MonedaItem(codigo: 'CLP', nombre: 'Peso Chileno',       simbolo: 'CLP'),
    MonedaItem(codigo: 'BOB', nombre: 'Boliviano',          simbolo: 'Bs.'),
    MonedaItem(codigo: 'PYG', nombre: 'Guaraní Paraguayo',  simbolo: '₲'),
    MonedaItem(codigo: 'UYU', nombre: 'Peso Uruguayo',      simbolo: '\$U'),
    MonedaItem(codigo: 'GBP', nombre: 'Libra Esterlina',    simbolo: '£'),
    MonedaItem(codigo: 'JPY', nombre: 'Yen Japonés',        simbolo: '¥'),
    MonedaItem(codigo: 'CAD', nombre: 'Dólar Canadiense',   simbolo: 'CA\$'),
    MonedaItem(codigo: 'CHF', nombre: 'Franco Suizo',       simbolo: 'CHF'),
    MonedaItem(codigo: 'CNY', nombre: 'Yuan Chino',         simbolo: '¥'),
  ];

  static MonedaItem get pen => all.first;

  static MonedaItem byCode(String codigo) =>
      all.firstWhere((m) => m.codigo == codigo, orElse: () => pen);
}
