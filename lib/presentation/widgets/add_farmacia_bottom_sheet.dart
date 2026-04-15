import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../providers/farmacias_provider.dart';

class AddFarmaciaBottomSheet extends ConsumerStatefulWidget {
  const AddFarmaciaBottomSheet({
    super.key,
    required this.lat,
    required this.lng,
  });

  final double lat;
  final double lng;

  static Future<void> show(BuildContext context, {required double lat, required double lng}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddFarmaciaBottomSheet(lat: lat, lng: lng),
      ),
    );
  }

  @override
  ConsumerState<AddFarmaciaBottomSheet> createState() => _AddFarmaciaBottomSheetState();
}

class _AddFarmaciaBottomSheetState extends ConsumerState<AddFarmaciaBottomSheet> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(farmaciasRepositoryProvider);
      
      // Auto-fetch all location fields to meet requirement:
      // "que se añadan de forma automática información... y todos los campos de base de datos"
      String direccion = "Desconocida";
      String? localidad;
      String? codigoPostal;
      
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(widget.lat, widget.lng);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          
          final addressParts = [
            place.street,
            place.subThoroughfare,
            place.thoroughfare
          ].where((e) => e != null && e.isNotEmpty).toSet().toList();
          
          if (addressParts.isNotEmpty) {
            direccion = addressParts.join(', ').replaceAll(RegExp(r',\s+,'), ',');
          }
          
          localidad = place.locality ?? place.subAdministrativeArea;
          codigoPostal = place.postalCode;
        }
      } catch (e) {
        // Ignoramos si falla el geocoding y dejamos los valores por defecto
        debugPrint('Geocoding error: $e');
      }
      
      await repository.addFarmacia(
        nombre: name,
        lat: widget.lat,
        lng: widget.lng,
        direccion: direccion,
        localidad: localidad,
        codigoPostal: codigoPostal,
      );

      // Invalidate providers to refresh map
      ref.invalidate(mapFarmaciasProvider);
      ref.invalidate(allFarmaciasProvider);
      ref.invalidate(farmaciasListProvider);

      if (mounted) {
        Navigator.of(context).pop();
        context.showSnackBar('Farmacia añadida con éxito');
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Error al añadir: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surface.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_business_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Añadir Nueva Farmacia',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'En tu ubicación actual',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Coordinates display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 20, color: context.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Lat: ${widget.lat.toStringAsFixed(5)}, Lng: ${widget.lng.toStringAsFixed(5)}',
                        style: context.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Icon(Icons.check_circle_rounded, size: 20, color: Colors.green),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Name input
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Nombre de la farmacia',
                  hintText: 'Ej. Farmacia Los Remedios',
                  prefixIcon: const Icon(Icons.local_pharmacy_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: context.colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: context.colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: context.colorScheme.surface,
                ),
                onFieldSubmitted: (_) => _submit(),
              ),
              
              const SizedBox(height: 32),
              
              // Submit button
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Guardar Farmacia',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
