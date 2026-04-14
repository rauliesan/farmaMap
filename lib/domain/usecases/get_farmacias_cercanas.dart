import '../../data/models/farmacia.dart';
import '../../data/repositories/farmacias_repository.dart';

/// Use case: Get nearby pharmacies within a radius
class GetFarmaciasCercanas {
  GetFarmaciasCercanas(this._repository);

  final FarmaciasRepository _repository;

  Future<List<Farmacia>> call({
    required double lat,
    required double lng,
    double radiusMeters = 2000,
  }) {
    return _repository.getNearby(
      lat: lat,
      lng: lng,
      radiusMeters: radiusMeters,
    );
  }
}
