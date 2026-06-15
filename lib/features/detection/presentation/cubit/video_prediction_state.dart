part of 'video_prediction_cubit.dart';

abstract class VideoPredictionState extends Equatable {
  const VideoPredictionState();

  @override
  List<Object?> get props => [];
}

class VideoPredictionInitial extends VideoPredictionState {
  const VideoPredictionInitial();
}

class VideoPredictionLoading extends VideoPredictionState {
  const VideoPredictionLoading();
}

class VideoPredictionLoaded extends VideoPredictionState {
  final VideoPredictionResponse response;

  /// Gemini's second-opinion verification, when available.
  final GeminiVerification? verification;

  /// Whether the Gemini second opinion is still being fetched.
  final bool verifying;

  const VideoPredictionLoaded(
    this.response, {
    this.verification,
    this.verifying = false,
  });

  VideoPredictionLoaded copyWith({
    GeminiVerification? verification,
    bool? verifying,
  }) {
    return VideoPredictionLoaded(
      response,
      verification: verification ?? this.verification,
      verifying: verifying ?? this.verifying,
    );
  }

  @override
  List<Object?> get props => [response, verification, verifying];
}

class VideoPredictionError extends VideoPredictionState {
  final String message;
  const VideoPredictionError(this.message);

  @override
  List<Object> get props => [message];
}
