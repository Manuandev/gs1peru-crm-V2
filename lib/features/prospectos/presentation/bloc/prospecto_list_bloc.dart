// // lib\features\prospectos\presentation\bloc\prospecto_list_bloc.dart

// import 'package:app_crm/index_dependencies.dart';

// import 'package:app_crm/features/prospectos/index_prospectos.dart';

// class ProspectoListBloc extends Bloc<ProspectoListEvent, ProspectoListState> {
//   final GetProspectosUseCase _getProspectos;

//    ProspectoListBloc(this._getProspectos) : super(const ProspectoListInitial()) {
//     on<ProspectoListStarted>(_onStarted);
//     on<ProspectoListRefresh>(_onRefresh);
//   }

//   Future<void> _onStarted(
//     ProspectoListStarted event,
//     Emitter<ProspectoListState> emit,
//   ) async {
//     emit(const ProspectoListLoading());
//     await _loadData(emit);
//   }

//   Future<void> _onRefresh(
//     ProspectoListRefresh event,
//     Emitter<ProspectoListState> emit,
//   ) async {
//     emit(const ProspectoListLoading());
//     await _loadData(emit);
//   }

//   Future<void> _loadData(Emitter<ProspectoListState> emit) async {
//     try {
//       final prospectosF = _getProspectos();

//       final prospectos = await prospectosF.catchError((_) => <Prospecto>[]);

//       emit(ProspectoListLoaded(prospectos: prospectos));
//     } catch (e, stackTrace) {
//       addError(e, stackTrace);

//       emit(ProspectoListError(e.toString()));
//     }
//   }
// }
