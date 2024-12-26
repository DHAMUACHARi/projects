import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'firebase_options.dart'; // Ensure this file is generated and contains the Firebase options

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const UserBApp());
}

class UserBApp extends StatelessWidget {
  const UserBApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "User B App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: UserBLocationUpdater(),
    );
  }
}

class UserBLocationUpdater extends StatefulWidget {
  @override
  _UserBLocationUpdaterState createState() => _UserBLocationUpdaterState();
}

class _UserBLocationUpdaterState extends State<UserBLocationUpdater> {
  final DatabaseReference _locationRef = FirebaseDatabase.instance.ref('users/userB_id/location');
  final Location _location = Location();
  late GoogleMapController _mapController;

  LocationData? _userBLocation;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _startUpdatingLocation();
  }

  void _startUpdatingLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
    }

    if (serviceEnabled && permissionGranted == PermissionStatus.granted) {
      _location.onLocationChanged.listen((LocationData locationData) {
        setState(() {
          _userBLocation = locationData;
          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId('userB'),
              position: LatLng(locationData.latitude!, locationData.longitude!),
              infoWindow: const InfoWindow(title: 'User B'),
            ),
          );
        });

        _locationRef.set({
          'latitude': locationData.latitude,
          'longitude': locationData.longitude,
        });

        // Update the map camera to User B's location
        _mapController.animateCamera(
          CameraUpdate.newLatLng(LatLng(locationData.latitude!, locationData.longitude!)),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User B Location Updater")),
      body: _userBLocation == null
          ? const Center(child: CircularProgressIndicator(
        color: Colors.purpleAccent,
        strokeWidth: 1,
      ))
          : GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(_userBLocation!.latitude!, _userBLocation!.longitude!),
          zoom: 14.0,
        ),
        markers: _markers,
        zoomControlsEnabled: true,
        scrollGesturesEnabled: true,
        rotateGesturesEnabled: true,
        tiltGesturesEnabled: true,
      ),
    );
  }
}
