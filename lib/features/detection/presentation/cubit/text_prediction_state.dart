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

  const TextPredictionLoaded(this.response);

  @override
  List<Object?> get props => [response];
}

class TextPredictionError extends TextPredictionState {
  final String message;

  const TextPredictionError(this.message);

  @override
  List<Object?> get props => [message];
}
