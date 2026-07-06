import '../core/api_client.dart';

class ConfigRepository {
  final ApiClient _client;

  ConfigRepository({ApiClient? client}) : _client = client ?? ApiClient();

  Future<List<String>> getWorkshopOptions() async =>
      (await _client.get('/config/workshops') as List<dynamic>).cast<String>();

  Future<List<String>> getLevelOptions() async =>
      (await _client.get('/config/levels') as List<dynamic>).cast<String>();
}
