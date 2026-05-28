import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/history_item_model.dart';
import '../../data/models/history_details_model.dart';
import '../../data/repositories/history_repository.dart';

part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRepository repository;

  HistoryCubit({required this.repository}) : super(const HistoryInitial());

  Future<void> loadHistory({String type = 'All'}) async {
    emit(const HistoryLoading());
    final result = await repository.getHistory(type: type);
    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (items) => emit(HistoryLoaded(items)),
    );
  }

  Future<void> deleteHistory(String id) async {
    final result = await repository.deleteHistory(id);
    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (_) => loadHistory(),
    );
  }
}

class HistoryDetailsCubit extends Cubit<HistoryDetailsState> {
  final HistoryRepository repository;

  HistoryDetailsCubit({required this.repository})
      : super(const HistoryDetailsInitial());

  Future<void> loadDetails(String id) async {
    emit(const HistoryDetailsLoading());
    final result = await repository.getHistoryDetails(id);
    result.fold(
      (failure) => emit(HistoryDetailsError(failure.message)),
      (details) => emit(HistoryDetailsLoaded(details)),
    );
  }
}
