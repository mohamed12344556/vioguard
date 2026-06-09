import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/api/token_storage.dart';
import '../../data/models/text_prediction_response.dart';
import '../../data/datasources/text_prediction_datasource.dart';

part 'text_prediction_state.dart';

class TextPredictionCubit extends Cubit<TextPredictionState> {
  final TextPredictionDataSource dataSource;
  final TokenStorage tokenStorage;

  TextPredictionCubit({
    required this.dataSource,
    required this.tokenStorage,
  }) : super(const TextPredictionInitial());

  Future<void> predict(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    emit(const TextPredictionLoading());
    try {
      final response = await dataSource.predict(trimmed);

      // Best-effort persistence to the backend history.
      final email = tokenStorage.getUserEmail();
      if (email != null && email.isNotEmpty) {
        await dataSource.saveTextContent(
          text: trimmed,
          result: response.sentimentLabel,
          userEmail: email,
        );
      }

      emit(TextPredictionLoaded(response));
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['detail']?.toString() ??
              e.message ??
              'Failed to analyze text')
          : (e.message ?? 'Failed to analyze text');
      emit(TextPredictionError(message));
    } catch (e) {
      emit(TextPredictionError(e.toString()));
    }
  }

  void reset() => emit(const TextPredictionInitial());
}
