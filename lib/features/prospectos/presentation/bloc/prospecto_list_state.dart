// // lib\features\prospectos\presentation\bloc\prospecto_list_state.dart

// import 'package:app_crm/features/prospectos/index_prospectos.dart';
// import 'package:equatable/equatable.dart';

// abstract class ProspectoListState  extends Equatable {
//   const ProspectoListState ();

//   @override
//   List<Object?> get props => [];
// }

// class ProspectoListInitial extends ProspectoListState  {
//   const ProspectoListInitial();
// }

// class ProspectoListLoading extends ProspectoListState  {
//   const ProspectoListLoading();
// }

// class ProspectoListLoaded extends ProspectoListState  {
//   final List<Prospecto> prospectos; // Prospectos cargados exitosamente

//   const ProspectoListLoaded({ required this.prospectos});

// }

// class ProspectoListError extends ProspectoListState  {
//   final String message;
//   const ProspectoListError(this.message);

//   @override
//   List<Object?> get props => [message];
// }
