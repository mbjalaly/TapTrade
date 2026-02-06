import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taptrade/Services/LocationService/locationService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/l10n/app_localizations.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({Key? key, this.initialPosition}) : super(key: key);

  final LatLng? initialPosition;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _center;
  String _address = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() { _loading = true; });
    try {
      await LocationService.instance.ensurePermissionsGranted();
      LatLng start = widget.initialPosition ?? _getLatLngFromService();
      _center = start;
      _address = await LocationService.instance.getAddressFromLatLng(start.latitude, start.longitude);
    } catch (_) {}
    setState(() { _loading = false; });
  }

  LatLng _getLatLngFromService() {
    final pos = LocationService.instance.userLocation;
    if (pos != null) {
      return LatLng(pos.latitude, pos.longitude);
    }
    return LatLng(LocationService.instance.defaultLatitude, LocationService.instance.defaultLongitude);
  }

  Future<void> _onCameraIdle() async {
    if (_center == null) return;
    final addr = await LocationService.instance.getAddressFromLatLng(_center!.latitude, _center!.longitude);
    setState(() {
      _address = addr;
    });
  }

  @override
  Widget build(BuildContext context) {
    final LatLng initPos = _center ?? _getLatLngFromService();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor(context),
        elevation: 0,
        title: Text(AppLocalizations.of(context)?.pickLocation ?? 'Pick Location', style: TextStyle(color: AppColors.primaryText(context), fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: AppColors.primaryText(context)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _center == null ? null : () {
              Navigator.pop(context, {
                'lat': _center!.latitude,
                'lng': _center!.longitude,
                'address': _address,
              });
            },
            child: Text(AppLocalizations.of(context)?.use ?? 'Use', style: TextStyle(color: AppColors.primaryText(context), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_loading)
            Center(child: CircularProgressIndicator(color: AppColors.primaryText(context)))
          else
            GoogleMap(
              initialCameraPosition: CameraPosition(target: initPos, zoom: 12),
              onMapCreated: (c) => _mapController = c,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              onCameraMove: (pos) {
                _center = pos.target;
              },
              onCameraIdle: _onCameraIdle,
            ),
          // Center pin
          IgnorePointer(
            child: Center(
              child: Icon(Icons.location_pin, size: 48, color: Colors.red.shade700),
            ),
          ),
          // Address bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Material(
              color: AppColors.contentBg(context),
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  _address.isEmpty ? 'Move the map to choose a location' : _address,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.primaryText(context)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


