import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OsrmService {
  static const String _baseUrl = 'https://router.project-osrm.org/route/v1/driving';

  /// Obtiene la ruta entre dos puntos usando la API de OSRM
  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    try {
      // Formato OSRM: lon,lat
      final response = await http.get(Uri.parse(
          '$_baseUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final geometry = data['routes'][0]['geometry'];
          final coordinates = geometry['coordinates'] as List;

          return coordinates.map((coord) {
            // GeoJSON devuelve [lon, lat]
            return LatLng(coord[1] as double, coord[0] as double);
          }).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error al obtener la ruta OSRM: $e');
      return [];
    }
  }
}
