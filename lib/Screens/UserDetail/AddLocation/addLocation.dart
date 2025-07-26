import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
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
  String currentAddress = "Tap the icon to get your location";
  GoogleMapController? _googleMapController;
  LatLng? _currentPosition;
  double radius = 50.0;

  @override
  void initState(){
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _currentPosition = LatLng(position.latitude, position.longitude);
    await _getAddressFromLatLng(_currentPosition!);
    setState(() {
      _googleMapController
          ?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
    });
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      print(
          "Fetching address for Lat: ${position.latitude}, Lng: ${position.longitude}");
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        print("Placemark: $place");
        setState(() {
          currentAddress =
              "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        });
      } else {
        setState(() {
          currentAddress = "No address available for this location";
        });
      }
    } catch (e) {
      print("Error occurred while fetching address: $e");
      setState(() {
        currentAddress = "Unable to get address";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container( decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryColor.withOpacity(0.1),
            AppColors.secondaryColor.withOpacity(0.1)
          ], // Define your gradient colors
          begin: Alignment.topLeft, // Starting point of the gradient
          end: Alignment.bottomRight, // Ending point of the gradient
        ),
      ),height: size.height * 0.067,child: Center(child:  AppButton(
        onPressed: () async {
          if (radius != 0.0) {
            if (currentAddress.isNotEmpty &&
                _currentPosition != null) {
              Map<String, dynamic> body = {
                'image': widget.imageFile,
                'longitude': double.parse((_currentPosition?.longitude ?? 0.0).toStringAsFixed(6)),
                'latitude': double.parse((_currentPosition?.latitude ?? 0.0).toStringAsFixed(6)),
                'Trade_radius': radius.toInt().toString(),
                'address': currentAddress,
              };
              String id = userController.userProfile.value.data?.id ??
                  '';
              setState(() {
                isLoading = true;
              });
              final result = await ProfileService.instance
                  .updateProfile(context, body, id);
              setState(() {
                isLoading = false;
              });
              if(result.status == Status.COMPLETED){
                ProfileService.instance.getProfile(context);
                Get.to(() => const AddInterestScreen());
              }else{
                ShowMessage.notify(context, "${result.message}");
              }
            } else {
              ShowMessage.notify(context, "Please Add Your Location");
            }
          } else {
            ShowMessage.notify(context, "Please Add Radius");
          }
        },
        isLoading: isLoading,
        width: Get.width * 0.5,
        text: "Next",
        textColor: Colors.white,
        fontSize: Get.width * 0.04,
      ),),),
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor.withOpacity(0.1),
              AppColors.secondaryColor.withOpacity(0.1)
            ], // Define your gradient colors
            begin: Alignment.topLeft, // Starting point of the gradient
            end: Alignment.bottomRight, // Ending point of the gradient
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: Get.height * 0.02,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: Icon(
                            Icons.arrow_back,
                            color: AppColors.primaryTextColor,
                            size: size.width * 0.1,
                          ))),
                ),
                AppText(
                  text: "Location",
                  fontSize: Get.width * 0.075,
                  textcolor: AppColors.darkBlue,
                  fontWeight: FontWeight.w500,
                ),
                Padding(
                  padding: EdgeInsets.only(top: Get.height * 0.02),
                  child: AppText(
                    text: "Zoom for your preferred trade area",
                    fontSize: Get.width * 0.04,
                    textcolor: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.06,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: Get.width * 0.07),
                    child: AppText(
                      text: "Trade Area",
                      fontSize: Get.width * 0.05,
                      textcolor: AppColors.darkBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: Get.width * 0.05, right: Get.width * 0.05, top: 7),
                  child: Stack(
                    children: [
                      // Outer Container with gradient border
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF00E3DF),
                              Color(0xFFF2B721),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: EdgeInsets.all(
                            2), // This gives the border thickness
                        child: Container(
                          // Inner Container with transparent border color
                          decoration: BoxDecoration(
                            color: Colors
                                .white, // Background color of the inner container
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child:  GestureDetector(
                              onTap: () {
                                _getCurrentLocation();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      currentAddress,
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    ),
                                  ),
                                  SvgPicture.asset(
                                          "assets/svgs/location.svg"),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: Get.height * 0.35,
                  width: Get.width * 0.85,
                  child: _currentPosition == null
                      ? const Center(
                          child:
                              Text('Tap the icon to get the current location'))
                      : Center(
                          child: GoogleMap(
                            scrollGesturesEnabled: true,   // Enable map dragging with one finger
                            zoomGesturesEnabled: true,     // Enable pinch-to-zoom with two fingers
                            rotateGesturesEnabled: true,   // Enable rotation (optional)
                            tiltGesturesEnabled: true,     // Enable tilting gestures (optional)
                            initialCameraPosition: CameraPosition(
                              target: _currentPosition!,
                              zoom: 8.0,                  // Set the initial zoom level
                            ),
                            minMaxZoomPreference: MinMaxZoomPreference(2.0, 18.0),  // Custom zoom limits (min: 2, max: 18)
                            markers: _currentPosition != null
                                ? {
                              Marker(
                                markerId: MarkerId('currentLocation'),
                                position: _currentPosition!,
                              ),
                            }
                                : {},
                            circles: _currentPosition != null
                                ? {
                              Circle(
                                circleId: const CircleId('radiusCircle'),
                                center: _currentPosition!,
                                radius: radius * 1000.0,  // Radius in meters
                                strokeColor: AppColors.secondaryColor,  // Circle border color
                                strokeWidth: 2,                         // Circle border width
                                fillColor: AppColors.secondaryColor.withOpacity(0.3),  // Circle fill color
                              ),
                            }
                                : {},
                            onMapCreated: (controller) {
                              _googleMapController = controller;
                            },
                          ),
                        ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20,),
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
                      min: 0,
                      max: 500,
                      divisions: 100,
                      onChanged: (newValue) {
                        setState(() {
                          radius = newValue;
                        });
                      },
                      label:
                      '${radius.toInt()}', // Optional: Show current value
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
