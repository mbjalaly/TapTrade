import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Screens/UserDetail/AddInterest/addInterest.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/deviceResolutionType.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Widgets/customText.dart';

class AddLocationScreen extends StatefulWidget {
  AddLocationScreen({Key? key, this.imageFile}) : super(key: key);
  File? imageFile;
  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  var userController = Get.find<UserController>();
  bool isLoading = false;
  bool isLocationLoading = true;
  String currentAddress = "Detecting your location...";
  GoogleMapController? _googleMapController;
  LatLng? _currentPosition;
  double radius = 50.0;
  String? locationError;
  
  // Real-time location stream
  StreamSubscription<Position>? _positionStream;
  bool _isTracking = true;

  // Default location (Dubai)
  static const LatLng _defaultLocation = LatLng(25.204849, 55.270782);

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _googleMapController?.dispose();
    super.dispose();
  }

  /// Start real-time GPS tracking
  Future<void> _startLocationTracking() async {
    setState(() {
      isLocationLoading = true;
      locationError = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _useDefaultLocation('Please enable location services');
        return;
      }

      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _useDefaultLocation('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _useDefaultLocation('Location permission permanently denied');
        return;
      }

      // Get initial position first
      try {
        Position initialPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 10));
        
        _updatePosition(initialPosition);
      } catch (e) {
        print('Error getting initial position: $e');
      }

      // Start listening to position stream for real-time updates
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      );

      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          if (_isTracking && mounted) {
            _updatePosition(position);
          }
        },
        onError: (error) {
          print('Location stream error: $error');
          if (mounted && _currentPosition == null) {
            _useDefaultLocation('Unable to track location');
          }
        },
      );

    } catch (e) {
      print('Error starting location tracking: $e');
      _useDefaultLocation('Unable to get location');
    }
  }

  /// Update position and address
  void _updatePosition(Position position) {
    final newPosition = LatLng(position.latitude, position.longitude);
    
    if (mounted) {
      setState(() {
        _currentPosition = newPosition;
        isLocationLoading = false;
      });

      // Animate map to new position
      _googleMapController?.animateCamera(
        CameraUpdate.newLatLng(newPosition),
      );

      // Update address (debounced)
      _getAddressFromLatLng(newPosition);
    }
  }

  void _useDefaultLocation(String error) {
    if (mounted) {
      setState(() {
        _currentPosition = _defaultLocation;
        locationError = error;
        isLocationLoading = false;
        currentAddress = "Default location - please enable GPS";
      });
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 10), onTimeout: () => []);

      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks[0];
        setState(() {
          currentAddress = "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        });
      }
    } catch (e) {
      print("Error getting address: $e");
      if (mounted) {
        setState(() {
          currentAddress = "Location detected";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isTab = DeviceTypeHelper.isTablet(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.secondaryColor.withOpacity(0.1),
              AppColors.secondaryColor.withOpacity(0.1)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        height: size.height * 0.087,
        padding: const EdgeInsets.only(bottom: 20),
        child: Center(
          child: AppButton(
            onPressed: () async {
              if (radius == 0.0) {
                ShowMessage.notify(context, "Please select a trade radius");
                return;
              }
              
              if (_currentPosition == null) {
                ShowMessage.notify(context, "Waiting for location...");
                return;
              }

              Map<String, dynamic> body = {
                'image': widget.imageFile,
                'longitude': double.parse(_currentPosition!.longitude.toStringAsFixed(6)),
                'latitude': double.parse(_currentPosition!.latitude.toStringAsFixed(6)),
                'Trade_radius': radius.toInt().toString(),
                'address': currentAddress,
              };
              
              String id = userController.userProfile.value.data?.id ?? '';
              
              setState(() {
                isLoading = true;
              });
              
              final result = await ProfileService.instance.updateProfile(context, body, id);
              
              setState(() {
                isLoading = false;
              });
              
              if (result.status == Status.COMPLETED) {
                ProfileService.instance.getProfile(context);
                Get.to(() => const AddInterestScreen());
              } else {
                ShowMessage.notify(context, "${result.message}");
              }
            },
            isLoading: isLoading,
            width: Get.width * 0.5,
            text: "Next",
            textColor: Colors.white,
            fontSize: Get.width * 0.04,
          ),
        ),
      ),
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor.withOpacity(0.1),
              AppColors.secondaryColor.withOpacity(0.1)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: isTab ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: Get.height * 0.02),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.primaryTextColor,
                        size: size.width * 0.1,
                      ),
                    ),
                  ),
                ),
                AppText(
                  text: "Location",
                  fontSize: Get.width * 0.075,
                  textcolor: AppColors.darkBlue,
                  fontWeight: FontWeight.w500,
                ),
                Padding(
                  padding: EdgeInsets.only(top: Get.height * 0.01),
                  child: AppText(
                    text: "Your location is detected automatically",
                    fontSize: Get.width * 0.04,
                    textcolor: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                
                // Real-time tracking indicator
                Padding(
                  padding: EdgeInsets.only(top: Get.height * 0.01),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isTracking && !isLocationLoading ? Colors.green : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isLocationLoading 
                            ? "Detecting location..." 
                            : _isTracking 
                                ? "GPS tracking active" 
                                : "GPS tracking paused",
                        style: TextStyle(
                          color: _isTracking ? Colors.green : Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Error message
                if (locationError != null)
                  Padding(
                    padding: EdgeInsets.only(top: Get.height * 0.01),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          locationError!,
                          style: const TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  
                SizedBox(height: Get.height * 0.04),
                
                // Trade Area label
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: Get.width * 0.07),
                    child: AppText(
                      text: "Your Location",
                      fontSize: Get.width * 0.05,
                      textcolor: AppColors.darkBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                // Address display
                Padding(
                  padding: EdgeInsets.only(
                    left: Get.width * 0.05,
                    right: Get.width * 0.05,
                    top: 7,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF00E3DF), Color(0xFFF2B721)],
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: isLocationLoading
                                  ? Row(
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          "Detecting location...",
                                          style: TextStyle(fontSize: 14, color: Colors.grey),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      currentAddress,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14, color: Colors.black),
                                    ),
                            ),
                            SvgPicture.asset("assets/svgs/location.svg"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Map
                SizedBox(
                  height: isTab ? Get.height * 0.3 : Get.height * 0.35,
                  width: isTab ? Get.width * 0.8 : Get.width * 0.85,
                  child: isLocationLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: AppColors.primaryColor),
                              const SizedBox(height: 16),
                              const Text(
                                'Detecting your location...',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: GoogleMap(
                            scrollGesturesEnabled: false, // Disable - auto tracking
                            zoomGesturesEnabled: true,
                            rotateGesturesEnabled: false,
                            tiltGesturesEnabled: false,
                            myLocationEnabled: true, // Show blue dot
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            initialCameraPosition: CameraPosition(
                              target: _currentPosition ?? _defaultLocation,
                              zoom: 12.0,
                            ),
                            markers: _currentPosition != null
                                ? {
                                    Marker(
                                      markerId: const MarkerId('currentLocation'),
                                      position: _currentPosition!,
                                      icon: BitmapDescriptor.defaultMarkerWithHue(
                                        BitmapDescriptor.hueAzure,
                                      ),
                                    ),
                                  }
                                : {},
                            circles: _currentPosition != null
                                ? {
                                    Circle(
                                      circleId: const CircleId('radiusCircle'),
                                      center: _currentPosition!,
                                      radius: radius * 1000.0, // km to meters
                                      strokeColor: AppColors.secondaryColor,
                                      strokeWidth: 2,
                                      fillColor: AppColors.secondaryColor.withOpacity(0.2),
                                    ),
                                  }
                                : {},
                            onMapCreated: (controller) {
                              _googleMapController = controller;
                            },
                          ),
                        ),
                ),
                
                // Radius slider
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: Get.width * 0.07),
                        child: AppText(
                          text: "Trade Radius: ${radius.toInt()} KM",
                          fontSize: Get.width * 0.05,
                          textcolor: AppColors.darkBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Slider(
                      thumbColor: AppColors.secondaryColor,
                      value: radius,
                      activeColor: AppColors.primaryTextColor,
                      inactiveColor: AppColors.primaryColor,
                      min: 5, // Minimum 5km
                      max: 500,
                      divisions: 99,
                      onChanged: (newValue) {
                        setState(() {
                          radius = newValue;
                        });
                      },
                      label: '${radius.toInt()} KM',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
