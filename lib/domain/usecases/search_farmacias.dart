import '../../data/models/farmacia.dart';
import '../../data/repositories/farmacias_repository.dart';

/// Use case: Search pharmacies by name or address
class SearchFarmacias {
  SearchFarmacias(this._repository);

  final FarmaciasRepository _repository;

  Future<List<Farmacia>> call(String query) {
    if (query.trim().isEmpty) return Future.value([]);
    return _repository.search(query.trim());
  }
}
