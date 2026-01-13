import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taptrade/Services/LocationService/locationService.dart';
import 'package:taptrade/Models/MatchProduct/matchProduct.dart';
import 'package:taptrade/Const/globleKey.dart';
//
// double calculateDistance(double targetLat, double targetLng) {
//   double currentLat = LocationService.instance.userLocation?.latitude ?? 0.0;
//   double currentLng = LocationService.instance.userLocation?.longitude ?? 0.0;
//
//   double distanceInMeters =
//   Geolocator.distanceBetween(currentLat, currentLng, targetLat, targetLng);
//
//   double distanceInKilometers = distanceInMeters / 1000;
//
//   return distanceInKilometers; // Return distance in kilometers
// }

double calculateDistance(double targetLat, double targetLng) {
  double currentLat = LocationService.instance.userLocation?.latitude ?? 0.0;
  double currentLng = LocationService.instance.userLocation?.longitude ?? 0.0;

  double distanceInMeters =
  Geolocator.distanceBetween(currentLat, currentLng, targetLat, targetLng);

  // Convert meters to kilometers
  double distanceInKilometers = distanceInMeters / 1000;

  return distanceInKilometers; // Return distance in kilometers
}

/// Calculate distance with proper null handling for sorting
/// Returns double.maxFinite for invalid/missing coordinates to sort them to the end
double calculateDistanceForSorting(NearbyUser? nearbyUser) {
  if (nearbyUser == null) {
    return double.maxFinite; // Place items without location at end
  }

  final double latitude = nearbyUser.latitude ?? 0.0;
  final double longitude = nearbyUser.longitude ?? 0.0;

  // If coordinates are (0,0), treat as invalid and place at end
  if (latitude == 0.0 && longitude == 0.0) {
    return double.maxFinite;
  }

  return calculateDistance(latitude, longitude);
}

/// Build an image widget that handles both network URLs and base64 data URIs
Widget buildProductImage({
  required String? imageUrl,
  required BoxFit fit,
  double? width,
  double? height,
  Widget? errorWidget,
}) {
  // Handle null or empty image
  if (imageUrl == null || imageUrl.isEmpty) {
    return errorWidget ?? const Icon(Icons.image_not_supported, color: Colors.grey);
  }

  // Check if it's a base64 data URI
  if (imageUrl.startsWith('data:image')) {
    try {
      // Extract base64 data from data URI
      final base64String = imageUrl.split(',').last;
      final Uint8List bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? const Icon(Icons.broken_image, color: Colors.grey);
        },
      );
    } catch (e) {
      return errorWidget ?? const Icon(Icons.broken_image, color: Colors.grey);
    }
  }

  // Handle network URLs (http/https)
  if (imageUrl.startsWith('http')) {
    return Image.network(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? const Icon(Icons.broken_image, color: Colors.grey);
      },
    );
  }

  // Handle relative paths - prepend base URL
  return Image.network(
    '${KeyConstants.imageUrl}$imageUrl',
    fit: fit,
    width: width,
    height: height,
    errorBuilder: (context, error, stackTrace) {
      return errorWidget ?? const Icon(Icons.broken_image, color: Colors.grey);
    },
  );
}

/// Get ImageProvider that handles both network URLs and base64 data URIs
ImageProvider getImageProvider(String? imageUrl) {
  // Handle null or empty image
  if (imageUrl == null || imageUrl.isEmpty) {
    return const NetworkImage(KeyConstants.imagePlaceHolder);
  }

  // Check if it's a base64 data URI
  if (imageUrl.startsWith('data:image')) {
    try {
      final base64String = imageUrl.split(',').last;
      final Uint8List bytes = base64Decode(base64String);
      return MemoryImage(bytes);
    } catch (e) {
      return const NetworkImage(KeyConstants.imagePlaceHolder);
    }
  }

  // Handle network URLs (http/https)
  if (imageUrl.startsWith('http')) {
    return NetworkImage(imageUrl);
  }

  // Handle relative paths - prepend base URL
  return NetworkImage('${KeyConstants.imageUrl}$imageUrl');
}
