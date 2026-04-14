import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_constants.dart';
import '../models/farmacia.dart';

/// Remote data source for pharmacy data from Supabase
class SupabaseFarmaciasDatasource {
  SupabaseFarmaciasDatasource(this._client);

  final SupabaseClient _client;

  /// Get all pharmacies with pagination
  Future<List<Farmacia>> getAll({
    int offset = 0,
    int limit = 20,
  }) async {
    final response = await _client
        .from(SupabaseConstants.tableaFarmacias)
        .select()
        .not('lat', 'eq', 0)
        .not('lng', 'eq', 0)
        .range(offset, offset + limit - 1)
        .order('nombre', ascending: true);

    return (response as List)
        .map((json) => Farmacia.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get a single pharmacy by ID
  Future<Farmacia?> getById(int id) async {
    final response = await _client
        .from(SupabaseConstants.tableaFarmacias)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Farmacia.fromJson(response);
  }

  /// Get pharmacies near a location using the Supabase RPC function
  Future<List<Farmacia>> getNearby({
    required double lat,
    required double lng,
    double radiusMeters = 2000,
  }) async {
    final response = await _client.rpc(
      SupabaseConstants.rpcFarmaciasCercanas,
      params: {
        'user_lat': lat,
        'user_lng': lng,
        'radio_metros': radiusMeters,
      },
    );

    return (response as List)
        .map((json) => Farmacia.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Search pharmacies by name or address using ilike
  Future<List<Farmacia>> search(String query) async {
    final searchPattern = '%$query%';

    final response = await _client
        .from(SupabaseConstants.tableaFarmacias)
        .select()
        .not('lat', 'eq', 0)
        .not('lng', 'eq', 0)
        .or('nombre.ilike.$searchPattern,direccion.ilike.$searchPattern')
        .order('nombre', ascending: true)
        .limit(50);

    return (response as List)
        .map((json) => Farmacia.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get total count of pharmacies
  Future<int> getCount() async {
    final response = await _client
        .from(SupabaseConstants.tableaFarmacias)
        .select()
        .not('lat', 'eq', 0)
        .not('lng', 'eq', 0)
        .count(CountOption.exact);

    return response.count;
  }
}
