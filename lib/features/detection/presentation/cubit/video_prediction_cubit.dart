import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/video_prediction_response.dart';
import '../../data/datasources/video_prediction_datasource.dart';

part 'video_prediction_state.dart';

class VideoPredictionCubit extends Cubit<VideoPredictionState> {
  final VideoPredictionDataSource dataSource;

  VideoPredictionCubit({required this.dataSource})
      : super(const VideoPredictionInitial());

  Future<void> predict(String filePath) async {
    emit(const VideoPredictionLoading());
    try {
      final response = await dataSource.predict(filePath);
      emit(VideoPredictionLoaded(response));
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] as String? ??
          e.message ??
          'Failed to analyze video';
      emit(VideoPredictionError(message));
    } catch (e) {
      emit(VideoPredictionError(e.toString()));
    }
  }

  void reset() => emit(const VideoPredictionInitial());
}
