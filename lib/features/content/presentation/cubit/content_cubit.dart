import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/api/token_storage.dart';
import '../../data/models/content_model.dart';
import '../../data/repositories/content_repository.dart';

part 'content_state.dart';

class ContentCubit extends Cubit<ContentState> {
  final ContentRepository repository;
  final TokenStorage tokenStorage;

  ContentCubit({required this.repository, required this.tokenStorage})
      : super(const ContentInitial());

  Future<void> loadContent() async {
    emit(const ContentLoading());
    final email = tokenStorage.getUserEmail();
    final result = await repository.getContent(
      userEmail: (email == null || email.isEmpty) ? null : email,
    );
    result.fold(
      (failure) => emit(ContentError(failure.message)),
      (items) => emit(ContentLoaded(items)),
    );
  }
}
