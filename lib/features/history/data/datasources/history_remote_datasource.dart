import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/server_strings.dart';
import '../models/history_item_model.dart';
import '../models/history_details_model.dart';

abstract class HistoryRemoteDataSource {
  Future<List<HistoryItemModel>> getHistory({String type = 'All'});
  Future<HistoryDetailsModel> getHistoryDetails(String id);
  Future<void> deleteHistory(String id);
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final ApiConsumer api;

  HistoryRemoteDataSourceImpl({required this.api});

  @override
  Future<List<HistoryItemModel>> getHistory({String type = 'All'}) async {
    final response = await api.get(
      ServerStrings.history,
      queryParameters: {'type': type},
    );
    return (response as List<dynamic>)
        .map((e) => HistoryItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<HistoryDetailsModel> getHistoryDetails(String id) async {
    final response = await api.get(ServerStrings.historyDetails(id));
    return HistoryDetailsModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> deleteHistory(String id) async {
    await api.delete(ServerStrings.deleteHistory(id));
  }
}
