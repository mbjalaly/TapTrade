import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/l10n/app_localizations.dart';
import 'package:taptrade/Models/UserProfile/userProfile.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Services/LocationService/locationService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/deviceResolutionType.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Widgets/customText.dart';

class TradePreferences extends StatefulWidget {
  TradePreferences({Key? key, required this.profileData}) : super(key: key);
  UserProfileResponseModel profileData;
  @override
  State<TradePreferences> createState() => _TradePreferencesState();
}

class _TradePreferencesState extends State<TradePreferences> {
  var userController = Get.find<UserController>();
  bool isLoading = false;
  double radius = 0.0;

  // NEW PREFERENCE STATE VARIABLE
  String meetingPreference = 'public_place';

  // LOCATION STATE VARIABLES
  GoogleMapController? _googleMapController;
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    radius = double.tryParse(
        (userController.getPreference.value.tradeRadius ?? '0').toString()) ?? 0.0;

    // LOAD NEW PREFERENCE FIELD
    meetingPreference = userController.getPreference.value.meetingPreference ?? 'public_place';

    // GET USER'S CURRENT LOCATION
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await LocationService.instance.getCurrentLocation();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  // Calculate appropriate zoom level based on radius in KM
  double _getZoomLevel(double radiusKm) {
    if (radiusKm <= 0) return 14;
    if (radiusKm <= 1) return 14;
    if (radiusKm <= 5) return 12;
    if (radiusKm <= 10) return 11;
    if (radiusKm <= 25) return 10;
    if (radiusKm <= 50) return 9;
    if (radiusKm <= 100) return 8;
    if (radiusKm <= 200) return 7;
    if (radiusKm <= 300) return 6;
    if (radiusKm <= 500) return 5;
    return 4;
  }

  void _updateMapCamera() {
    if (_googleMapController != null && _currentPosition != null) {
      _googleMapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition!,
            zoom: _getZoomLevel(radius),
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isTab = DeviceTypeHelper.isTablet(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor(context),
        automaticallyImplyLeading: true,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryText(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          "assets/images/t.png",
          height: 30,
          width: 30,
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: AppText(
                text: AppLocalizations.of(context)?.tradePreferencesTitle ?? "Trade Preferences",
                fontSize: size.width * 0.078,
                textcolor: AppColors.darkBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Stack(
              children: [
                Container(
                  width: size.width,
                  height: size.height * 0.77,
                  color: Colors.transparent,
                ),
                Center(
                  child: Material(
                    elevation: 4.5,
                    borderRadius: BorderRadius.circular(60),
                    color: AppColors.contentBg(context),
                    child: Container(
                      width: size.width * 0.9,
                      height: size.height * 0.75,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: isTab ? 30 : 40),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryColor.withOpacity(0.2), // #ecfcff
                            AppColors.secondaryColor
                                .withOpacity(0.2), // #fff5db
                          ],
                        ),
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                          // YOUR LOCATION LABEL
                          Text(
                            AppLocalizations.of(context)?.yourLocationLabel ?? "Your Location:",
                            style: TextStyle(
                                color: AppColors.primaryText(context),
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)?.locationAutomatic ?? "This is your automatic location (cannot be changed)",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          // MAP SHOWING USER'S LOCATION (NON-EDITABLE)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: size.width,
                              height: size.height * 0.25,
                              child: _currentPosition == null
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: _currentPosition!,
                                        zoom: _getZoomLevel(radius),
                                      ),
                                      onMapCreated: (controller) {
                                        _googleMapController = controller;
                                      },
                                      markers: {
                                        Marker(
                                          markerId: const MarkerId('userLocation'),
                                          position: _currentPosition!,
                                          infoWindow: const InfoWindow(title: 'Your Location'),
                                        ),
                                      },
                                      circles: {
                                        Circle(
                                          circleId: const CircleId('tradeRadius'),
                                          center: _currentPosition!,
                                          radius: radius * 1000, // Convert KM to meters
                                          fillColor: AppColors.primaryColor.withOpacity(0.2),
                                          strokeColor: AppColors.primaryColor,
                                          strokeWidth: 2,
                                        ),
                                      },
                                      zoomControlsEnabled: false,
                                      scrollGesturesEnabled: false,
                                      rotateGesturesEnabled: false,
                                      tiltGesturesEnabled: false,
                                      zoomGesturesEnabled: false,
                                      myLocationButtonEnabled: false,
                                      myLocationEnabled: false,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "${AppLocalizations.of(context)?.tradeRadius ?? 'Select Trade Radius'}: ${radius.toInt()} KM",
                            style: TextStyle(
                                color: AppColors.primaryText(context),
                                fontSize: isTab ? 16 : 20,
                                fontWeight: FontWeight.bold),
                          ),
                          Slider(
                            thumbColor: AppColors.secondaryColor,
                            value: radius,
                            activeColor: AppColors.primaryText(context),
                            inactiveColor: AppColors.primaryColor,
                            min: 0,
                            max: 500,
                            divisions: 100,
                            onChanged: (newValue) {
                              setState(() {
                                radius = newValue;
                              });
                              _updateMapCamera();
                            },
                            label:
                                '${radius.toInt()}', // Optional: Show current value
                          ),
                          const SizedBox(
                            height: 10,
                          ),

                          // === NEW PREFERENCES UI START ===

                          const SizedBox(height: 25),

                          // 1. MEETING PREFERENCE DROPDOWN
                          Text(
                            AppLocalizations.of(context)?.meetingPreferenceLabel ?? "Meeting Preference:",
                            style: TextStyle(
                              color: AppColors.primaryText(context),
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: meetingPreference,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.primaryColor, width: 1.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                            items: [
                              DropdownMenuItem(value: 'public_place', child: Text(AppLocalizations.of(context)?.publicPlace ?? 'Public Place')),
                              DropdownMenuItem(value: 'delivery', child: Text(AppLocalizations.of(context)?.deliveryPickup ?? 'Delivery/Pickup')),
                              DropdownMenuItem(value: 'shipping', child: Text(AppLocalizations.of(context)?.willingToShip ?? 'Willing to Ship')),
                            ],
                            onChanged: (val) {
                              setState(() {
                                meetingPreference = val ?? 'public_place';
                              });
                            },
                          ),

                          const SizedBox(height: 20),

                          // === NEW PREFERENCES UI END ===
                        ],
                      ),
                        ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: size.width / 4.5,
                  right: size.width / 4.5,
                  child: AppButton(
                    onPressed: () async {
                      String? message;
                      if (radius == 0.0) {
                        message = AppLocalizations.of(context)?.pleaseSelectTradeRadius ?? "Please select trade radius";
                      }

                      if (message != null) {
                        ShowMessage.notify(context, message);
                        return;
                      }
                      Map<String, dynamic> body = {
                        "trade_radius": radius.toInt(),
                        "meeting_preference": meetingPreference,
                      };
                      String id = widget.profileData.data?.id ?? '';
                      setState(() {
                        isLoading = true;
                      });
                      final result = await ProfileService.instance
                          .updateTradePreference(context, body, id);
                      await ProfileService.instance
                          .getTradePreference(context, id);
                      setState(() {
                        isLoading = false;
                      });
                      if (result.status == Status.COMPLETED) {
                        ShowMessage.notify(
                            context, "${result.responseData['message']}");
                        Navigator.pop(context);
                      } else {
                        ShowMessage.notify(context, "${result.message}");
                      }
                    },
                    isLoading: isLoading,
                    width: size.width * 0.4,
                    text: AppLocalizations.of(context)?.done ?? "Done",
                    fontSize: size.width * 0.045,
                    height: size.height * 0.065,
                    buttonColor: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
