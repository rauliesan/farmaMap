import '../../data/models/farmacia.dart';
import '../../data/repositories/farmacias_repository.dart';

/// Use case: Get all pharmacies with pagination
class GetAllFarmacias {
  GetAllFarmacias(this._repository);

  final FarmaciasRepository _repository;

  Future<List<Farmacia>> call({int offset = 0, int limit = 20}) {
    return _repository.getAll(offset: offset, limit: limit);
  }
}
