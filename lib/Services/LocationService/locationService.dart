import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:get/get.dart';

class LocationService {
  static final LocationService instance = LocationService._internal();

  factory LocationService() => instance;

  LocationService._internal();

  double defaultLatitude = 25.204849;

  double defaultLongitude = 55.270782;

  Position? _userLocation;

  String userAddress = '';

  Position? get userLocation => _userLocation;

  String? _userCity;

  String? get userCity => _userCity;

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  Future<void> startLocationUpdates() async {
    try {
      await ensurePermissionsGranted();
      Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position position) async {
          _userLocation = position;
          _userCity = await getCityFromCoordinates(position.latitude, position.longitude);
          userAddress = await getAddressFromLatLng(position.latitude, position.longitude);
          
          // Automatically update location in database when location changes
          await _updateLocationInDatabase(position.latitude, position.longitude);
        },
        onError: (error) {
          print("Error getting location: $error");
        },
      );
      try {
        _userLocation = await getCurrentLocation();
        // Update database with initial location
        if (_userLocation != null) {
          await _updateLocationInDatabase(_userLocation!.latitude, _userLocation!.longitude);
        }
      } catch (e) {
        // Swallow to avoid crashing when permission is denied
        print("Error getting initial location: $e");
      }
    } catch (e) {
      // Permissions not granted or services disabled
      print("Error starting location updates: $e");
    }
  }
  
  Future<void> _updateLocationInDatabase(double latitude, double longitude) async {
    try {
      // Only update if we have a valid user ID
      if (Get.isRegistered<UserController>()) {
        final userController = Get.find<UserController>();
        final String userId = userController.userProfile.value.data?.id ?? '';
        if (userId.isEmpty) return;
        
        String address = await getAddressFromLatLng(latitude, longitude);
        final Map<String, dynamic> body = {
          'latitude': double.parse(latitude.toStringAsFixed(6)),
          'longitude': double.parse(longitude.toStringAsFixed(6)),
          'address': address,
        };
        
        // Use navigatorKey to get current context for background updates
        final context = navigatorKey.currentState?.context;
        if (context != null) {
          await ProfileService.instance.updateProfile(context, body, userId);
          print("Location automatically updated in database: $latitude, $longitude");
        }
      }
    } catch (e) {
      print("Error automatically updating location in database: $e");
      // Don't throw error as this is a background operation
    }
  }

  Future<Position> getCurrentLocation() async {
    await ensurePermissionsGranted();
    try {
      Position myLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _userLocation = myLocation;
      return myLocation;
    } catch (e) {
      // Fallback to last known position if available
      print("Error getting current position, trying last known: $e");
      Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        _userLocation = lastKnown;
        return lastKnown;
      }
      rethrow;
    }
  }

  Future<void> checkPermission(VoidCallback afterLocationEnable) async {
    BuildContext? context = navigatorKey.currentState?.context;
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Ask once
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context != null) {
          ShowMessage.notify(context, 'Location permission denied');
          ShowMessage.openAppSetting(() {
            afterLocationEnable();
          });
        }
      } else {
        // Permission granted, update location in database
        await _updateLocationWhenPermissionGranted();
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (context != null) {
        ShowMessage.notify(context, 'Location permission denied forever');
        ShowMessage.openAppSetting(() {
          afterLocationEnable();
        });
      }
    }
    bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      if (context != null) {
        ShowMessage.notify(context, 'Location services are disabled');
      }
    } else if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      // Location services enabled and permission granted, update location
      await _updateLocationWhenPermissionGranted();
    }
  }
  
  Future<void> _updateLocationWhenPermissionGranted() async {
    try {
      final position = await getCurrentLocation();
      await _updateLocationInDatabase(position.latitude, position.longitude);
      print("Location updated after permission granted: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      print("Error updating location after permission granted: $e");
    }
  }

  Future<void> ensurePermissionsGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      throw Exception("User denied permissions to access the device's location.");
    }
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }
  }

  Future<String> getCityFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(latitude, longitude);
      Placemark placeMark = placeMarks.first;
      return placeMark.locality ?? "Unknown City";
    } catch (e) {
      print("Error getting city: $e");
      return "Unknown City";
    }
  }

  Future<String> getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark>? placeMarks = await placemarkFromCoordinates(latitude, longitude);
      if (placeMarks != null && placeMarks.isNotEmpty) {
        Placemark place = placeMarks[0];
        String address = '${place.street}, ${place.locality}, ${place.country}';
        userAddress = address;
        return address;
      } else {
        return "Address not found";
      }
    } catch (e) {
      print("Error: $e");
      return "Address not found";
    }
  }
}
