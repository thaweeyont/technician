import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';

import 'utility/my_constant.dart';

class OrderTrakingPage extends StatefulWidget {
  const OrderTrakingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrakingPage> createState() => _OrderTrakingPageState();
}

class _OrderTrakingPageState extends State<OrderTrakingPage> {
  final Completer<GoogleMapController> _controller = Completer();
  String googleAPiKey = "AIzaSyCKHlCUFhM_tnjkitcFuiaQLsBbDOacIPE";
  static const LatLng sourceLocation =
      LatLng(19.872873176953288, 99.82790038116167);
  static const LatLng destination =
      LatLng(19.860702397877536, 99.8198684718666);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;
  bool status = false;

  @override
  void initState() {
    status = true;
    getCurrentLocation();
    getPolyPoints();
    super.initState();
  }

  void getCurrentLocation() {
    Location location = Location();

    location.getLocation().then(
      (location) {
        currentLocation = location;
        setState(() {});
      },
    );
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Traking Map',
          style: MyConstant().h2whiteStyle(),
        ),
      ),
      body: currentLocation == null
          ? Center(child: Text("Loading"))
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    currentLocation!.latitude!, currentLocation!.longitude!),
                zoom: 14.5,
              ),
              myLocationEnabled: true,
              tiltGesturesEnabled: true,
              compassEnabled: true,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              polylines: {
                Polyline(
                  polylineId: PolylineId("route"),
                  points: polylineCoordinates,
                  color: Colors.deepPurple,
                  width: 6,
                ),
              },
              markers: {
                Marker(
                  markerId: MarkerId("currentLocation"),
                  position: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                ),
                Marker(
                  markerId: MarkerId("source"),
                  position: sourceLocation,
                ),
                Marker(
                  markerId: MarkerId("destination"),
                  position: destination,
                ),
              },
            ),
    );
  }
}
