import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/analyze_response.dart';
import '../../data/repositories/detection_repository.dart';

part 'detection_state.dart';

class DetectionCubit extends Cubit<DetectionState> {
  final DetectionRepository repository;

  DetectionCubit({required this.repository}) : super(const DetectionInitial());

  Future<void> analyze(String url) async {
    emit(const DetectionLoading());
    final result = await repository.analyze(url);
    result.fold(
      (failure) => emit(DetectionError(failure.message)),
      (response) => emit(DetectionLoaded(response)),
    );
  }

  void reset() => emit(const DetectionInitial());
}
