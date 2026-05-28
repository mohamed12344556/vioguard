part of 'video_prediction_cubit.dart';

abstract class VideoPredictionState extends Equatable {
  const VideoPredictionState();

  @override
  List<Object> get props => [];
}

class VideoPredictionInitial extends VideoPredictionState {
  const VideoPredictionInitial();
}

class VideoPredictionLoading extends VideoPredictionState {
  const VideoPredictionLoading();
}

class VideoPredictionLoaded extends VideoPredictionState {
  final VideoPredictionResponse response;
  const VideoPredictionLoaded(this.response);

  @override
  List<Object> get props => [response];
}

class VideoPredictionError extends VideoPredictionState {
  final String message;
  const VideoPredictionError(this.message);

  @override
  List<Object> get props => [message];
}
