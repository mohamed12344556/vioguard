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

  /// The FINAL verdict actually shown/saved (Gemini's if it ran, else the
  /// keyword-fallback's). Authoritative — the UI should use this.
  final bool finalIsViolent;

  /// The words to highlight for the final verdict (empty when safe).
  final List<String> finalViolentWords;

  const TextPredictionLoaded(
    this.response, {
    this.verification,
    this.verifying = false,
    this.finalIsViolent = false,
    this.finalViolentWords = const [],
  });

  TextPredictionLoaded copyWith({
    GeminiVerification? verification,
    bool? verifying,
    bool? finalIsViolent,
    List<String>? finalViolentWords,
  }) {
    return TextPredictionLoaded(
      response,
      verification: verification ?? this.verification,
      verifying: verifying ?? this.verifying,
      finalIsViolent: finalIsViolent ?? this.finalIsViolent,
      finalViolentWords: finalViolentWords ?? this.finalViolentWords,
    );
  }

  @override
  List<Object?> get props =>
      [response, verification, verifying, finalIsViolent, finalViolentWords];
}

class TextPredictionError extends TextPredictionState {
  final String message;

  const TextPredictionError(this.message);

  @override
  List<Object?> get props => [message];
}
