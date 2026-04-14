// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'farmacia.freezed.dart';
part 'farmacia.g.dart';

/// Domain model for a pharmacy
@freezed
class Farmacia with _$Farmacia {
  const Farmacia._();

  const factory Farmacia({
    required int id,
    required String nombre,
    required String direccion,
    String? localidad,
    @JsonKey(name: 'codigo_postal') String? codigoPostal,
    @Default(0.0) double lat,
    @Default(0.0) double lng,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Farmacia;

  factory Farmacia.fromJson(Map<String, dynamic> json) =>
      _$FarmaciaFromJson(json);

  /// Whether this pharmacy has valid geo coordinates
  bool get hasValidCoordinates => lat != 0.0 && lng != 0.0;

  /// Display-friendly short address (without locality/zip repetition)
  String get shortDireccion {
    final parts = direccion.split(',');
    if (parts.length >= 2) {
      return parts.take(2).join(',').trim();
    }
    return direccion;
  }

  /// Formatted name (title case style)
  String get displayNombre {
    if (nombre.isEmpty) return 'Farmacia';

    // Check if it's already mostly formatted
    if (nombre.contains(RegExp(r'[a-z]'))) return nombre;

    // Title-case conversion for ALL CAPS names
    return nombre
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          if (word.length == 1) return word.toUpperCase();
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
