import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

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
    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) async {
        _userLocation = position;
        _userCity = await getCityFromCoordinates(position.latitude, position.longitude);
        userAddress = await getAddressFromLatLng(position.latitude, position.longitude);
          },
      onError: (error) {
        print("Error getting location: $error");
      },
    );
    _userLocation = await getCurrentLocation();
  }

  Future<Position> getCurrentLocation() async {
    await checkPermission();
    Position myLocation = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      // locationSettings: const LocationSettings(
      //   accuracy: LocationAccuracy.high,
      // ),
    );
    _userLocation = myLocation;
    return myLocation;
  }

  Future<void> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied forever');
    }
    bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      throw Exception('Location services are disabled');
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
