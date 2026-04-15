import '../datasources/supabase_farmacias_datasource.dart';
import '../models/farmacia.dart';
import 'farmacias_repository.dart';

/// Supabase implementation of [FarmaciasRepository]
class FarmaciasRepositoryImpl implements FarmaciasRepository {
  FarmaciasRepositoryImpl(this._datasource);

  final SupabaseFarmaciasDatasource _datasource;

  @override
  Future<List<Farmacia>> getAll({int offset = 0, int limit = 20}) {
    return _datasource.getAll(offset: offset, limit: limit);
  }

  @override
  Future<Farmacia?> getById(int id) {
    return _datasource.getById(id);
  }

  @override
  Future<List<Farmacia>> getNearby({
    required double lat,
    required double lng,
    double radiusMeters = 2000,
  }) {
    return _datasource.getNearby(
      lat: lat,
      lng: lng,
      radiusMeters: radiusMeters,
    );
  }

  @override
  Future<List<Farmacia>> search(String query) {
    return _datasource.search(query);
  }

  @override
  Future<int> getCount() {
    return _datasource.getCount();
  }

  @override
  Future<Farmacia> addFarmacia({
    required String nombre,
    required double lat,
    required double lng,
    required String direccion,
    String? localidad,
    String? codigoPostal,
  }) {
    return _datasource.addFarmacia(
      nombre: nombre,
      lat: lat,
      lng: lng,
      direccion: direccion,
      localidad: localidad,
      codigoPostal: codigoPostal,
    );
  }

  @override
  Future<void> deleteFarmacia(int id) {
    return _datasource.deleteFarmacia(id);
  }

  @override
  Future<Farmacia> updateFarmacia(int id, {required String newNombre}) {
    return _datasource.updateFarmacia(id, newNombre: newNombre);
  }
}
