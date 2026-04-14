// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'farmacia.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Farmacia _$FarmaciaFromJson(Map<String, dynamic> json) {
  return _Farmacia.fromJson(json);
}

/// @nodoc
mixin _$Farmacia {
  int get id => throw _privateConstructorUsedError;
  String get nombre => throw _privateConstructorUsedError;
  String get direccion => throw _privateConstructorUsedError;
  String? get localidad => throw _privateConstructorUsedError;
  @JsonKey(name: 'codigo_postal')
  String? get codigoPostal => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Farmacia to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Farmacia
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FarmaciaCopyWith<Farmacia> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FarmaciaCopyWith<$Res> {
  factory $FarmaciaCopyWith(Farmacia value, $Res Function(Farmacia) then) =
      _$FarmaciaCopyWithImpl<$Res, Farmacia>;
  @useResult
  $Res call({
    int id,
    String nombre,
    String direccion,
    String? localidad,
    @JsonKey(name: 'codigo_postal') String? codigoPostal,
    double lat,
    double lng,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$FarmaciaCopyWithImpl<$Res, $Val extends Farmacia>
    implements $FarmaciaCopyWith<$Res> {
  _$FarmaciaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Farmacia
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? direccion = null,
    Object? localidad = freezed,
    Object? codigoPostal = freezed,
    Object? lat = null,
    Object? lng = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            nombre: null == nombre
                ? _value.nombre
                : nombre // ignore: cast_nullable_to_non_nullable
                      as String,
            direccion: null == direccion
                ? _value.direccion
                : direccion // ignore: cast_nullable_to_non_nullable
                      as String,
            localidad: freezed == localidad
                ? _value.localidad
                : localidad // ignore: cast_nullable_to_non_nullable
                      as String?,
            codigoPostal: freezed == codigoPostal
                ? _value.codigoPostal
                : codigoPostal // ignore: cast_nullable_to_non_nullable
                      as String?,
            lat: null == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double,
            lng: null == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FarmaciaImplCopyWith<$Res>
    implements $FarmaciaCopyWith<$Res> {
  factory _$$FarmaciaImplCopyWith(
    _$FarmaciaImpl value,
    $Res Function(_$FarmaciaImpl) then,
  ) = __$$FarmaciaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String nombre,
    String direccion,
    String? localidad,
    @JsonKey(name: 'codigo_postal') String? codigoPostal,
    double lat,
    double lng,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$$FarmaciaImplCopyWithImpl<$Res>
    extends _$FarmaciaCopyWithImpl<$Res, _$FarmaciaImpl>
    implements _$$FarmaciaImplCopyWith<$Res> {
  __$$FarmaciaImplCopyWithImpl(
    _$FarmaciaImpl _value,
    $Res Function(_$FarmaciaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Farmacia
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? direccion = null,
    Object? localidad = freezed,
    Object? codigoPostal = freezed,
    Object? lat = null,
    Object? lng = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$FarmaciaImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        nombre: null == nombre
            ? _value.nombre
            : nombre // ignore: cast_nullable_to_non_nullable
                  as String,
        direccion: null == direccion
            ? _value.direccion
            : direccion // ignore: cast_nullable_to_non_nullable
                  as String,
        localidad: freezed == localidad
            ? _value.localidad
            : localidad // ignore: cast_nullable_to_non_nullable
                  as String?,
        codigoPostal: freezed == codigoPostal
            ? _value.codigoPostal
            : codigoPostal // ignore: cast_nullable_to_non_nullable
                  as String?,
        lat: null == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double,
        lng: null == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FarmaciaImpl extends _Farmacia {
  const _$FarmaciaImpl({
    required this.id,
    required this.nombre,
    required this.direccion,
    this.localidad,
    @JsonKey(name: 'codigo_postal') this.codigoPostal,
    this.lat = 0.0,
    this.lng = 0.0,
    @JsonKey(name: 'created_at') this.createdAt,
  }) : super._();

  factory _$FarmaciaImpl.fromJson(Map<String, dynamic> json) =>
      _$$FarmaciaImplFromJson(json);

  @override
  final int id;
  @override
  final String nombre;
  @override
  final String direccion;
  @override
  final String? localidad;
  @override
  @JsonKey(name: 'codigo_postal')
  final String? codigoPostal;
  @override
  @JsonKey()
  final double lat;
  @override
  @JsonKey()
  final double lng;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Farmacia(id: $id, nombre: $nombre, direccion: $direccion, localidad: $localidad, codigoPostal: $codigoPostal, lat: $lat, lng: $lng, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FarmaciaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.direccion, direccion) ||
                other.direccion == direccion) &&
            (identical(other.localidad, localidad) ||
                other.localidad == localidad) &&
            (identical(other.codigoPostal, codigoPostal) ||
                other.codigoPostal == codigoPostal) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    nombre,
    direccion,
    localidad,
    codigoPostal,
    lat,
    lng,
    createdAt,
  );

  /// Create a copy of Farmacia
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FarmaciaImplCopyWith<_$FarmaciaImpl> get copyWith =>
      __$$FarmaciaImplCopyWithImpl<_$FarmaciaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FarmaciaImplToJson(this);
  }
}

abstract class _Farmacia extends Farmacia {
  const factory _Farmacia({
    required final int id,
    required final String nombre,
    required final String direccion,
    final String? localidad,
    @JsonKey(name: 'codigo_postal') final String? codigoPostal,
    final double lat,
    final double lng,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$FarmaciaImpl;
  const _Farmacia._() : super._();

  factory _Farmacia.fromJson(Map<String, dynamic> json) =
      _$FarmaciaImpl.fromJson;

  @override
  int get id;
  @override
  String get nombre;
  @override
  String get direccion;
  @override
  String? get localidad;
  @override
  @JsonKey(name: 'codigo_postal')
  String? get codigoPostal;
  @override
  double get lat;
  @override
  double get lng;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of Farmacia
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FarmaciaImplCopyWith<_$FarmaciaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
