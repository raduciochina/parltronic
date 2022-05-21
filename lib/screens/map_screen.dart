import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parktronic/models/parking.dart';
import 'package:parktronic/screens/navigation_drawer.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  bool mapToggle = true;
  late GoogleMapController mapController;
  List<ParkingModel> parkings = [];
  List<Marker> markers = [];
  Position? _currentPosition;
  PageController? pageController;

  Stream<List<ParkingModel>> parkingModelStream = FirebaseFirestore.instance
      .collection("parkings")
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ParkingModel.fromMap(doc.data()))
          .toList());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // FirebaseFirestore.instance
    //     .collection("parkings")
    //     .doc(user!.uid)
    //     .get()
    //     .then((values) {
    //   {}
    // });
    //pageController = PageController(initialPage: 1, viewportFraction: 0.8);
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawer(),
      appBar: AppBar(
        title: Text("Harta"),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              StreamBuilder<List<ParkingModel>>(
                stream: parkingModelStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<ParkingModel> parkingModels = snapshot.data!;
                    for (var parking in parkingModels) {
                      markers.add(
                        Marker(
                          onTap: () {
                            print("hello *****************************");
                          },
                          markerId: MarkerId(parking.parkingName),
                          draggable: false,
                          infoWindow: InfoWindow(
                              title: parking.parkingName,
                              snippet: parking.address +
                                  ", " +
                                  parking.capacity.toString() +
                                  ' locuri, ' +
                                  parking.price.toString() +
                                  " lei/ora"),
                          position: LatLng(parking.location.latitude,
                              parking.location.longitude),
                        ),
                      );
                    }
                    return Container(
                      height: MediaQuery.of(context).size.height - 80.0,
                      width: double.infinity,
                      child: mapToggle
                          ? GoogleMap(
                              initialCameraPosition: CameraPosition(
                                  target: LatLng(44.439663, 26.096306),
                                  zoom: 15.0), //Bucuresti
                              onMapCreated: onMapCreated,
                              compassEnabled: true,
                              markers: Set.from(markers),
                            )
                          : Center(
                              child: Text(
                                "Harta se incarca...",
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                    );
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void onMapCreated(controller) {
    setState(() {
      mapController = controller;
    });
  }

  getCurrentLocation() {
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        print(position.latitude);
        print(position.longitude);
      });
    }).catchError((e) {
      print(e);
    });
  }
}
