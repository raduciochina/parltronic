import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parktronic/models/parking.dart';
import 'package:parktronic/screens/navigation_drawer.dart';
import 'package:parktronic/screens/reservation_screen.dart';

class MapScreenV2 extends StatefulWidget {
  const MapScreenV2({Key? key}) : super(key: key);

  @override
  _MapScreenV2State createState() => _MapScreenV2State();
}

class _MapScreenV2State extends State<MapScreenV2> {
  Stream<QuerySnapshot>? _parkingPlaces;
  final Completer<GoogleMapController> _mapController = Completer();

  @override
  void initState() {
    super.initState();
    _parkingPlaces = FirebaseFirestore.instance
        .collection("parkings")
        .orderBy("name")
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawer(),
      appBar: AppBar(
        title: Text("Harta"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _parkingPlaces,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          // return ParkingList(documents: snapshot.data!.docs);
          return Column(
            children: [
              Flexible(
                flex: 5,
                child: ParkingMap(
                  documents: snapshot.data!.docs,
                  initialPosition: const LatLng(44.439663, 26.096306),
                  mapController: _mapController,
                ),
              ),
              Flexible(
                child: ParkingList(
                  documents: snapshot.data!.docs,
                  mapController: _mapController,
                ),
                flex: 2,
              ),
            ],
          );
        },
      ),
    );
  }
}

class ParkingList extends StatelessWidget {
  const ParkingList(
      {Key? key, required this.documents, required this.mapController})
      : super(key: key);

  final List<DocumentSnapshot> documents;
  final Completer<GoogleMapController> mapController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: documents.length,
      itemBuilder: (builder, index) {
        final document = documents[index];

        return ParkingListTile(
            document: document, mapController: mapController);
      },
    );
  }
}

class ParkingListTile extends StatefulWidget {
  const ParkingListTile(
      {Key? key, required this.document, required this.mapController})
      : super(key: key);

  final DocumentSnapshot document;
  final Completer<GoogleMapController> mapController;
  @override
  _ParkingListTileState createState() => _ParkingListTileState();
}

class _ParkingListTileState extends State<ParkingListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing: IconButton(
        icon: Icon(Icons.book),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ReservationScreen()));
        },
      ),
      leading: Container(
        child: CircleAvatar(
          backgroundImage: NetworkImage(widget.document['photo']),
        ),
        width: 60,
        height: 60,
      ),
      title: Text(widget.document['name']),
      subtitle: Text(widget.document["address"]),
      onTap: () async {
        final controller = await widget.mapController.future;
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(widget.document['location'].latitude,
                    widget.document['location'].longitude),
                zoom: 16),
          ),
        );
      },
    );
  }
}

class ParkingMap extends StatelessWidget {
  const ParkingMap(
      {Key? key,
      required this.documents,
      required this.initialPosition,
      required this.mapController})
      : super(key: key);

  final List<DocumentSnapshot> documents;
  final LatLng initialPosition;
  final Completer<GoogleMapController> mapController;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 12,
      ),
      markers: documents
          .map((document) => Marker(
                markerId: MarkerId(document['pid']),
                position: LatLng(
                  document['location'].latitude,
                  document['location'].longitude,
                ),
                infoWindow: InfoWindow(
                  title: document['name'],
                  snippet: document['address'],
                ),
              ))
          .toSet(),
      onMapCreated: (mapController) {
        this.mapController.complete(mapController);
      },
    );
  }
}
