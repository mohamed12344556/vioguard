part of 'text_prediction_cubit.dart';

abstract class TextPredictionState extends Equatable {
  const TextPredictionState();

  @override
  List<Object?> get props => [];
}

class TextPredictionInitial extends TextPredictionState {
  const TextPredictionInitial();
}

class TextPredictionLoading extends TextPredictionState {
  const TextPredictionLoading();
}

class TextPredictionLoaded extends TextPredictionState {
  final TextPredictionResponse response;

  /// Gemini's second-opinion verification, when available. `null` while it is
  /// still being fetched (or if the Gemini layer is disabled/failed).
  final GeminiVerification? verification;

  /// Whether the Gemini second opinion is still being fetched.
  final bool verifying;

  const TextPredictionLoaded(
    this.response, {
    this.verification,
    this.verifying = false,
  });

  TextPredictionLoaded copyWith({
    GeminiVerification? verification,
    bool? verifying,
  }) {
    return TextPredictionLoaded(
      response,
      verification: verification ?? this.verification,
      verifying: verifying ?? this.verifying,
    );
  }

  @override
  List<Object?> get props => [response, verification, verifying];
}

class TextPredictionError extends TextPredictionState {
  final String message;

  const TextPredictionError(this.message);

  @override
  List<Object?> get props => [message];
}
