part of 'history_cubit.dart';

// History List States
abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object> get props => [];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  final List<HistoryItemModel> items;
  const HistoryLoaded(this.items);

  @override
  List<Object> get props => [items];
}

class HistoryError extends HistoryState {
  final String message;
  const HistoryError(this.message);

  @override
  List<Object> get props => [message];
}

// History Details States
abstract class HistoryDetailsState extends Equatable {
  const HistoryDetailsState();

  @override
  List<Object> get props => [];
}

class HistoryDetailsInitial extends HistoryDetailsState {
  const HistoryDetailsInitial();
}

class HistoryDetailsLoading extends HistoryDetailsState {
  const HistoryDetailsLoading();
}

class HistoryDetailsLoaded extends HistoryDetailsState {
  final HistoryDetailsModel details;
  const HistoryDetailsLoaded(this.details);

  @override
  List<Object> get props => [details];
}

class HistoryDetailsError extends HistoryDetailsState {
  final String message;
  const HistoryDetailsError(this.message);

  @override
  List<Object> get props => [message];
}
