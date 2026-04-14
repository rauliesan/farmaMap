// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farmacia.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FarmaciaImpl _$$FarmaciaImplFromJson(Map<String, dynamic> json) =>
    _$FarmaciaImpl(
      id: (json['id'] as num).toInt(),
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String,
      localidad: json['localidad'] as String?,
      codigoPostal: json['codigo_postal'] as String?,
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$FarmaciaImplToJson(_$FarmaciaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'direccion': instance.direccion,
      'localidad': instance.localidad,
      'codigo_postal': instance.codigoPostal,
      'lat': instance.lat,
      'lng': instance.lng,
      'created_at': instance.createdAt?.toIso8601String(),
    };
