import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Models/UserProfile/userProfile.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/generalService.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Services/LocationService/locationService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/deviceResolutionType.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Widgets/customText.dart';
import 'package:taptrade/Screens/Dashboard/ProfileSetting/LocationPicker/location_picker_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TradePreferences extends StatefulWidget {
  TradePreferences({Key? key, required this.profileData}) : super(key: key);
  UserProfileResponseModel profileData;
  @override
  State<TradePreferences> createState() => _TradePreferencesState();
}

class _TradePreferencesState extends State<TradePreferences> {
  List<String> selectedInterest = [];
  var userController = Get.find<UserController>();
  List<String> interest = [];
  bool isLoading = false;
  double radius = 0.0;
  String? selectedCategory;
  String? selectedCondition;
  TextEditingController interestController = TextEditingController();
  GoogleMapController? _googleMapController;
  LatLng? _currentPosition;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    radius = double.parse(
        (userController.getPreference.value.tradeRadius ?? 0.0).toString());
    // print("-=-=-=-=-=-=-= ${selectedInterest}");
    // print("-=-=-=-=-=-=-= ${userController.getPreference.value.interests
    //     ?.map((e) => e.interestName) // Assuming e.name can be null
    //     .whereType<String>() // Filter out null values
    //     .toList() ??
    //     []}");
    selectedInterest = userController.getPreference.value.interests
            ?.map((e) => e.interestName) // Assuming e.name can be null
            .whereType<String>() // Filter out null values
            .toList() ??
        [];
    // print("-=-=-=-=-=-=-= ${selectedInterest}");
    if (selectedInterest.isNotEmpty) {
      interestController.text = selectedInterest.join(', ');
    }
    interest = GeneralService.instance.allInterest.value.data
            ?.map((e) => e.name)
            .whereType<String>()
            .toList() ??
        [];
    
    // Try to use existing location from user profile first
    _initializeLocation();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await LocationService.instance.checkPermission((){
        _getCurrentLocation();
      });
    });
  }
  
  void _initializeLocation() {
    // Try to get location from user profile first
    final userProfile = userController.userProfile.value.data;
    if (userProfile?.latitude != null && userProfile?.longitude != null) {
      _currentPosition = LatLng(
        double.parse(userProfile!.latitude.toString()),
        double.parse(userProfile.longitude.toString()),
      );
      setState(() {});
    } else {
      // If no profile location, get current location
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        _setDefaultLocation();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          _setDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        _setDefaultLocation();
        return;
      }
      
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _currentPosition = LatLng(position.latitude, position.longitude);
      
      if (mounted) {
        setState(() {
          _googleMapController
              ?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
        });
      }
      
      // Automatically update location in database when getting current location
      await _updateLocationInDatabase(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting current location: $e');
      _setDefaultLocation();
    }
  }
  
  void _setDefaultLocation() {
    // Set a default location (you can change this to any default coordinates)
    _currentPosition = const LatLng(37.7749, -122.4194); // San Francisco coordinates
    if (mounted) {
      setState(() {});
    }
  }
  
  Future<void> _updateLocationInDatabase(double latitude, double longitude) async {
    try {
      String address = await LocationService.instance
          .getAddressFromLatLng(latitude, longitude);
      final String userId = userController.userProfile.value.data?.id ?? '';
      if (userId.isEmpty) return;
      
      final Map<String, dynamic> body = {
        'latitude': double.parse(latitude.toStringAsFixed(6)),
        'longitude': double.parse(longitude.toStringAsFixed(6)),
        'address': address,
      };
      
      await ProfileService.instance.updateProfile(context, body, userId);
      print("Location updated in database: $latitude, $longitude");
    } catch (e) {
      print("Error updating location in database: $e");
      // Don't show error to user as this is a background operation
    }
  }

  // void showInterestSelectionDialog() async {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Select Interest'),
  //         content: StatefulBuilder(
  //             builder: (BuildContext context, StateSetter setState) {
  //           return SingleChildScrollView(
  //             child: Column(
  //               children: interest.map((item) {
  //                 final isSelected = selectedInterest.contains(item);
  //                 return CheckboxListTile(
  //                   value: isSelected,
  //                   title: Text(item),
  //                   onChanged: (bool? value) {
  //                     setState(() {
  //                       if (value == true) {
  //                         selectedInterest.add(item);
  //                       } else {
  //                         selectedInterest.remove(item);
  //                       }
  //                     });
  //                   },
  //                 );
  //               }).toList(),
  //             ),
  //           );
  //         }),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context); // Cancel selection
  //             },
  //             child: const Text('CANCEL'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context); // Confirm selection
  //             },
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void showInterestSelectionDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        Size size = MediaQuery.of(context).size;
        return Dialog(
          insetPadding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              width: size.width * 0.9,
              height: size.height * 0.8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryColor.withOpacity(0.2), // #ecfcff
                    AppColors.secondaryColor.withOpacity(0.2), // #fff5db
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(12), // Match the dialog shape
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: size.height * 0.0525,
                    width: size.width,
                    child: Center(
                      child: Text(
                        'Select Interests',
                        style: TextStyle(
                          fontSize: size.width * 0.06,
                          fontWeight: FontWeight.bold,
                          color: AppColors
                              .primaryTextColor, // Contrast text with the gradient
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: size.width,
                    height: size.height * 0.65,
                    child: SingleChildScrollView(
                      child: Column(
                        children: interest.map((item) {
                          final isSelected = selectedInterest.contains(item);
                          return CheckboxListTile(
                            value: isSelected,
                            title: Text(
                              "${item.capitalize}",
                              style: TextStyle(
                                  color: AppColors.primaryTextColor,
                                  fontSize: size.width * 0.04,
                                  fontWeight: FontWeight.w600), // White text
                            ),
                            activeColor: AppColors.secondaryColor,
                            checkColor: AppColors
                                .primaryTextColor, // Contrast for the checkbox
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedInterest.add(item);
                                } else {
                                  selectedInterest.remove(item);
                                }
                                interestController.text =
                                    selectedInterest.join(', ');
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      width: size.width * 0.5,
                      height: size.height * 0.05,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          color: AppColors.primaryTextColor),
                      child: const Center(
                        child: Text(
                          'Done',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isTab = DeviceTypeHelper.isTablet(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryTextColor),
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
                text: "Trade Preferences",
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
                    color: Colors.white,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            "Select Interests:",
                            style: TextStyle(
                                color: AppColors.primaryTextColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: size.width,
                            height: isTab ? size.height * 0.08: size.height * 0.07,
                            child: TextFormField(
                              onTap: () {
                                showInterestSelectionDialog();
                              },
                              readOnly: true,
                              controller: interestController,
                              decoration: InputDecoration(
                                  labelText: 'Select Category',
                                  labelStyle:
                                      const TextStyle(color: Colors.grey),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.grey, width: 1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.grey, width: 1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  suffixIcon: const Icon(
                                      Icons.arrow_drop_down_outlined)),
                            ),
                          ),
                          SizedBox(
                            height: isTab ? 20 : 40,
                          ),
                          Text(
                            "Select Trade Radius: ${radius.toInt()} KM",
                            style: TextStyle(
                                color: AppColors.primaryTextColor,
                                fontSize: isTab ? 16 : 20,
                                fontWeight: FontWeight.bold),
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
                          const SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: _currentPosition == null
                                ? Column(
                                    children: [
                                      const CircularProgressIndicator(
                                        color: AppColors.primaryColor,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Loading location...',
                                        style: TextStyle(
                                          color: AppColors.primaryTextColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox(
                                    height: size.height / 3,
                                    width: size.height / 3,
                                    child: GoogleMap(
                                      scrollGesturesEnabled:
                                          true, // Enable map dragging with one finger
                                      zoomGesturesEnabled:
                                          true, // Enable pinch-to-zoom with two fingers
                                      rotateGesturesEnabled:
                                          true, // Enable rotation (optional)
                                      tiltGesturesEnabled:
                                          true, // Enable tilting gestures (optional)
                                      initialCameraPosition: CameraPosition(
                                        target: _currentPosition!,
                                        zoom: 8.0, // Set the initial zoom level
                                      ),
                                      minMaxZoomPreference: MinMaxZoomPreference(
                                          2.0,
                                          18.0), // Custom zoom limits (min: 2, max: 18)
                                      markers: _currentPosition != null
                                          ? {
                                              Marker(
                                                markerId:
                                                    MarkerId('currentLocation'),
                                                position: _currentPosition!,
                                              ),
                                            }
                                          : {},
                                      circles: _currentPosition != null
                                          ? {
                                              Circle(
                                                circleId: const CircleId(
                                                    'radiusCircle'),
                                                center: _currentPosition!,
                                                radius: radius *
                                                    1000.0, // Radius in meters
                                                strokeColor: AppColors
                                                    .secondaryColor, // Circle border color
                                                strokeWidth:
                                                    2, // Circle border width
                                                fillColor: AppColors
                                                    .secondaryColor
                                                    .withOpacity(
                                                        0.3), // Circle fill color
                                              ),
                                            }
                                          : {},
                                      onMapCreated: (controller) {
                                        _googleMapController = controller;
                                      },
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final result = await Get.to(() => LocationPickerScreen(initialPosition: _currentPosition));
                                if (result != null && result is Map) {
                                  final double lat = (result['lat'] as num).toDouble();
                                  final double lng = (result['lng'] as num).toDouble();
                                  setState(() {
                                    _currentPosition = LatLng(lat, lng);
                                  });
                                  _googleMapController?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
                                  
                                  // Update location in database
                                  await _updateLocationInDatabase(lat, lng);
                                }
                              },
                              icon: const Icon(Icons.place_outlined),
                              label: const Text('Change location on map'),
                            ),
                          ),
                        ],
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
                        message = "Please select trade radius";
                      }
                      if (selectedInterest.length < 5) {
                        message = "Please select at least 5 interest";
                      }
                      if (selectedInterest.isEmpty) {
                        message = "Please select interest";
                      }

                      if (message != null) {
                        ShowMessage.notify(context, message);
                        return;
                      }
                      Map<String, dynamic> body = {
                        "interest_names": selectedInterest,
                        "trade_radius": radius.toInt()
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
                    text: "Done",
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
