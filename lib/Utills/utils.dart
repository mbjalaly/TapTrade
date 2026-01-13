import 'package:geolocator/geolocator.dart';
import 'package:taptrade/Services/LocationService/locationService.dart';
import 'package:taptrade/Models/MatchProduct/matchProduct.dart';
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

  // Convert kilometers to miles
  double distanceInMiles = distanceInKilometers * 0.621371;

  return distanceInMiles; // Return distance in miles
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
