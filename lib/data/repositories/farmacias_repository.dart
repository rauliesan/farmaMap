import '../models/farmacia.dart';

/// Abstract repository interface for farmacias
/// Follows Clean Architecture — domain depends on this, not on Supabase
abstract class FarmaciasRepository {
  /// Get all farmacias with pagination
  Future<List<Farmacia>> getAll({int offset = 0, int limit = 20});

  /// Get a farmacia by its ID
  Future<Farmacia?> getById(int id);

  /// Get farmacias near a given location
  Future<List<Farmacia>> getNearby({
    required double lat,
    required double lng,
    double radiusMeters = 2000,
  });

  /// Search farmacias by name or address
  Future<List<Farmacia>> search(String query);

  /// Get total count of farmacias
  Future<int> getCount();

  /// Admin or quick action to add a new farmacia
  Future<Farmacia> addFarmacia({
    required String nombre,
    required double lat,
    required double lng,
    required String direccion,
    String? localidad,
    String? codigoPostal,
  });

  /// Delete a pharmacy
  Future<void> deleteFarmacia(int id);

  /// Update a pharmacy's name
  Future<Farmacia> updateFarmacia(int id, {required String newNombre});
}
