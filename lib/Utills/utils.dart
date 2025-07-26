import 'package:geolocator/geolocator.dart';
import 'package:taptrade/Services/LocationService/locationService.dart';
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
