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
    await _analyze(trimmed);
  }

  /// Scrapes text from a source [url] via the backend, then analyzes it.
  Future<void> predictFromUrl(String url) async {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) return;

    emit(const TextPredictionLoading());
    try {
      final scraped = await dataSource.scrapeText(trimmedUrl);
      final text = scraped.textContent.trim();
      if (text.isEmpty) {
        emit(const TextPredictionError('No text found at this URL'));
        return;
      }
      await _analyze(text, url: trimmedUrl, alreadyLoading: true);
    } on DioException catch (e) {
      emit(TextPredictionError(_messageFrom(e)));
    } catch (e) {
      emit(TextPredictionError(e.toString()));
    }
  }

  /// Runs the AI model on [text] and persists the result (best-effort).
  /// When [alreadyLoading] is true the loading state was emitted by the caller.
  Future<void> _analyze(
    String text, {
    String? url,
    bool alreadyLoading = false,
  }) async {
    if (!alreadyLoading) emit(const TextPredictionLoading());
    try {
      final response = await dataSource.predict(text);

      // Best-effort persistence to the backend history.
      final email = tokenStorage.getUserEmail();
      if (email != null && email.isNotEmpty) {
        await dataSource.saveTextContent(
          text: text,
          result: response.sentimentLabel,
          userEmail: email,
          url: url,
        );
      }

      emit(TextPredictionLoaded(response));
    } on DioException catch (e) {
      emit(TextPredictionError(_messageFrom(e)));
    } catch (e) {
      emit(TextPredictionError(e.toString()));
    }
  }

  String _messageFrom(DioException e) {
    return e.response?.data is Map
        ? (e.response?.data['detail']?.toString() ??
            e.message ??
            'Failed to analyze text')
        : (e.message ?? 'Failed to analyze text');
  }

  void reset() => emit(const TextPredictionInitial());
}
