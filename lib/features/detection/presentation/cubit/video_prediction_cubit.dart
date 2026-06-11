import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/api/token_storage.dart';
import '../../data/models/video_prediction_response.dart';
import '../../data/datasources/video_prediction_datasource.dart';

part 'video_prediction_state.dart';

class VideoPredictionCubit extends Cubit<VideoPredictionState> {
  final VideoPredictionDataSource dataSource;
  final TokenStorage tokenStorage;

  VideoPredictionCubit({
    required this.dataSource,
    required this.tokenStorage,
  }) : super(const VideoPredictionInitial());

  Future<void> predict(String filePath) async {
    emit(const VideoPredictionLoading());
    try {
      final response = await dataSource.predict(filePath);

      // Best-effort persistence to the backend.
      final email = tokenStorage.getUserEmail();
      if (email != null && email.isNotEmpty) {
        // Upload the raw video, then record the analysis result. Both are
        // best-effort: a backend hiccup must not block showing the result.
        try {
          await dataSource.uploadVideo(filePath);
        } catch (_) {
          // Ignore upload failures.
        }
        await dataSource.saveVideoContent(
          userEmail: email,
          // `violence` is a 0–1 fraction; the backend expects a percentage.
          violentPercent: response.violence * 100,
        );
      }

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
