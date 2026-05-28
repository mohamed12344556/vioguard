part of 'detection_cubit.dart';

abstract class DetectionState extends Equatable {
  const DetectionState();

  @override
  List<Object> get props => [];
}

class DetectionInitial extends DetectionState {
  const DetectionInitial();
}

class DetectionLoading extends DetectionState {
  const DetectionLoading();
}

class DetectionLoaded extends DetectionState {
  final AnalyzeResponse response;
  const DetectionLoaded(this.response);

  @override
  List<Object> get props => [response];
}

class DetectionError extends DetectionState {
  final String message;
  const DetectionError(this.message);

  @override
  List<Object> get props => [message];
}
