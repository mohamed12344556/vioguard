import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/api/token_storage.dart';
import '../../data/models/gemini_verification.dart';
import '../../data/models/text_prediction_response.dart';
import '../../data/datasources/gemini_verifier.dart';
import '../../data/datasources/text_prediction_datasource.dart';

part 'text_prediction_state.dart';

class TextPredictionCubit extends Cubit<TextPredictionState> {
  final TextPredictionDataSource dataSource;
  final TokenStorage tokenStorage;
  final GeminiVerifier geminiVerifier;

  TextPredictionCubit({
    required this.dataSource,
    required this.tokenStorage,
    required this.geminiVerifier,
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

  /// Runs the AI model AND the Gemini verification, then persists and shows the
  /// FINAL (possibly Gemini-corrected) result in a single step.
  ///
  /// The UI stays in [TextPredictionLoading] until both finish, so the result
  /// screen opens once with the final verdict instead of flickering when the
  /// second opinion arrives. The corrected verdict is what gets saved.
  /// When [alreadyLoading] is true the loading state was emitted by the caller.
  Future<void> _analyze(
    String text, {
    String? url,
    bool alreadyLoading = false,
  }) async {
    if (!alreadyLoading) emit(const TextPredictionLoading());
    try {
      final response = await dataSource.predict(text);

      // Gemini needs the model's verdict to verify it, so this follows predict.
      // While it runs the UI is still in Loading — both reads as "analyzing".
      final verification = await _verify(text, response.isViolent);

      // The verdict shown and saved. The primary sentiment model is currently
      // broken (returns the same label for everything), so Gemini IS the
      // classifier: whenever it returned a verdict, that wins. We fall back to
      // the model only when Gemini is disabled or its call failed.
      final finalIsViolent = verification != null
          ? verification.effectiveVerdict
          : response.isViolent;
      // Backend expects "0" => violent, "1" => non-violent.
      final finalResult = finalIsViolent ? '0' : '1';

      // The flagged words to persist (and highlight later). Only meaningful when
      // the final verdict is violent; Gemini supplies them.
      final flaggedWords = finalIsViolent
          ? (verification?.violentWords ?? const [])
          : const <String>[];

      // TEMP: trace whether Gemini ran and what words we're about to persist.
      debugPrint('💾 SAVE text: violent=$finalIsViolent, '
          'gemini=${verification != null ? "ran" : "NULL"}, '
          'words=$flaggedWords');

      // Persist the FINAL (corrected) verdict to the backend history.
      final email = tokenStorage.getUserEmail();
      if (email != null && email.isNotEmpty) {
        await dataSource.saveTextContent(
          text: text,
          result: finalResult,
          userEmail: email,
          url: url,
          violentWords: flaggedWords,
        );
      }

      // Single emit with the final, verified result — no flicker.
      emit(TextPredictionLoaded(response, verification: verification));
    } on DioException catch (e) {
      emit(TextPredictionError(_messageFrom(e)));
    } catch (e) {
      emit(TextPredictionError(e.toString()));
    }
  }

  /// Best-effort Gemini second opinion. Returns null when disabled or on error.
  Future<GeminiVerification?> _verify(String text, bool modelSaysViolent) async {
    if (!geminiVerifier.isEnabled) return null;
    return geminiVerifier.verifyText(
      text: text,
      modelSaysViolent: modelSaysViolent,
    );
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
