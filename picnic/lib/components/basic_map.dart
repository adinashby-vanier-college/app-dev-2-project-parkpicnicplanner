import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/location_service.dart';

class BasicMap extends StatefulWidget {
  const BasicMap({
    super.key,
  });

  @override
  State<BasicMap> createState() => _BasicMapState();
}

class _BasicMapState extends State<BasicMap> {
  GoogleMapController? _mapController;
  LatLng? currentPosition;

  MapType currentMapType = MapType.normal;

  // Default position (San Francisco)
  static const LatLng _defaultPosition = LatLng(45.5019, -73.5674);


  void _changeMapType() {
    setState(() {
      switch (currentMapType) {
        case MapType.normal:
          currentMapType = MapType.satellite;
          break;
        case MapType.satellite:
          currentMapType = MapType.hybrid;
          break;
        case MapType.hybrid:
          currentMapType = MapType.terrain;
          break;
        case MapType.terrain:
          currentMapType = MapType.normal;
          break;
        case MapType.none:
          //Do nothing
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _moveToCurrentLocation() {
    if (currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentPosition!,
            zoom: 15.0,
          ),
        ),
      );
    }
  }

  void _getCurrentLocation() async {
    Position? location = await LocationService.getCurrentPosition();

    if (location != null) {
      setState(() {
        currentPosition = LatLng(location.latitude, location.longitude);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      // onTap: _onMapTapped,
      // onLongPress: _onMapLongPressed,
      initialCameraPosition: CameraPosition(
        target: currentPosition ?? _defaultPosition,
        zoom: 12.0,
      ),
      mapType: currentMapType,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      compassEnabled: true,
      trafficEnabled: false,
      buildingsEnabled: true,
    );
  }
}
