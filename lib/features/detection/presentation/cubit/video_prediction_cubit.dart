import 'dart:convert';
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

  /// Analyzes a video the user picked from their device.
  Future<void> predict(String filePath) async {
    emit(const VideoPredictionLoading());
    try {
      final response = await dataSource.predict(filePath);

      final email = tokenStorage.getUserEmail();
      if (email != null && email.isNotEmpty) {
        // Upload the raw video (best-effort), then record the result.
        try {
          await dataSource.uploadVideo(filePath);
        } catch (_) {
          // Ignore upload failures.
        }
        await _saveResult(response, email);
      }

      emit(VideoPredictionLoaded(response));
    } on DioException catch (e) {
      emit(VideoPredictionError(_messageFrom(e)));
    } catch (e) {
      emit(VideoPredictionError(e.toString()));
    }
  }

  /// Scrapes a video from a source [url] via the backend, then analyzes its
  /// binary directly without writing it to disk.
  Future<void> predictFromUrl(String url) async {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) return;

    emit(const VideoPredictionLoading());
    try {
      final scraped = await dataSource.scrapeVideo(trimmedUrl);
      final base64Data = scraped.videoBinary.data;
      if (base64Data == null || base64Data.isEmpty) {
        emit(const VideoPredictionError('No video found at this URL'));
        return;
      }

      final bytes = base64Decode(base64Data);
      final fileName = scraped.videoBinary.fileName.isNotEmpty
          ? scraped.videoBinary.fileName
          : 'scraped_video.mp4';
      final response = await dataSource.predictBytes(bytes, fileName);

      final email = tokenStorage.getUserEmail();
      if (email != null && email.isNotEmpty) {
        await _saveResult(response, email, url: trimmedUrl);
      }

      emit(VideoPredictionLoaded(response));
    } on DioException catch (e) {
      emit(VideoPredictionError(_messageFrom(e)));
    } catch (e) {
      emit(VideoPredictionError(e.toString()));
    }
  }

  /// Persists the analysis result (best-effort; failures are swallowed).
  Future<void> _saveResult(
    VideoPredictionResponse response,
    String email, {
    String? url,
  }) async {
    await dataSource.saveVideoContent(
      userEmail: email,
      // `violence` is a 0–1 fraction; the backend expects a percentage.
      violentPercent: response.violence * 100,
      url: url,
    );
  }

  String _messageFrom(DioException e) {
    return e.response?.data?['detail'] as String? ??
        e.message ??
        'Failed to analyze video';
  }

  void reset() => emit(const VideoPredictionInitial());
}
