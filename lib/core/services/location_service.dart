import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:safe_signal/core/errors/exceptions.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String? address;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    this.address,
  });
}

class LocationService {
  Future<LocationResult> getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          throw const LocationPermissionException();
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw const LocationPermissionException();
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const LocationUnavailableException();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      String? address;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = <String>[
            if (p.street != null && p.street!.isNotEmpty) p.street!,
            if (p.locality != null && p.locality!.isNotEmpty) p.locality!,
            if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty)
              p.administrativeArea!,
            if (p.country != null && p.country!.isNotEmpty) p.country!,
          ];
          address = parts.join(', ');
        }
      } catch (_) {
        // Reverse geocoding failed — continue without address
      }

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );
    } on LocationPermissionException {
      rethrow;
    } on LocationUnavailableException {
      rethrow;
    } catch (e) {
      throw const LocationUnavailableException();
    }
  }
}
