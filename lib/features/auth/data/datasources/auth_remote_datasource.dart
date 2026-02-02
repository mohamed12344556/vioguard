import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<List<AuthModel>> getAuths();
  Future<AuthModel> getAuthById(String id);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<List<AuthModel>> getAuths() async {
    throw UnimplementedError();
  }

  @override
  Future<AuthModel> getAuthById(String id) async {
    throw UnimplementedError();
  }
}
