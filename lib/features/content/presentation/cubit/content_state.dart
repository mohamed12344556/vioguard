part of 'content_cubit.dart';

abstract class ContentState extends Equatable {
  const ContentState();

  @override
  List<Object> get props => [];
}

class ContentInitial extends ContentState {
  const ContentInitial();
}

class ContentLoading extends ContentState {
  const ContentLoading();
}

class ContentLoaded extends ContentState {
  final List<ContentModel> items;
  const ContentLoaded(this.items);

  @override
  List<Object> get props => [items];
}

class ContentError extends ContentState {
  final String message;
  const ContentError(this.message);

  @override
  List<Object> get props => [message];
}
