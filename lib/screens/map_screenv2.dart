import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parktronic/models/parking.dart';
import 'package:parktronic/screens/navigation_drawer.dart';
import 'package:parktronic/screens/reservation_screen.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class MapScreenV2 extends StatefulWidget {
  const MapScreenV2({Key? key}) : super(key: key);

  @override
  _MapScreenV2State createState() => _MapScreenV2State();
}

class _MapScreenV2State extends State<MapScreenV2> {
  Stream<QuerySnapshot>? _parkingPlaces;
  final Completer<GoogleMapController> _mapController = Completer();
  QRViewController? controller;
  ValueNotifier<String> result = new ValueNotifier("");

  @override
  void initState() {
    super.initState();
    _parkingPlaces = FirebaseFirestore.instance
        .collection("parkings")
        .orderBy("name")
        .snapshots();
  }

  void _qrCodeRead() {
    final qrKey = GlobalKey(debugLabel: 'QR');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(10),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'))
          ],
          content: Container(
            width: 300,
            height: 300,
            child: QRView(
              key: qrKey,
              onQRViewCreated: (QRViewController controller) {
                setState(
                  () {
                    this.controller = controller;
                  },
                );

                controller.scannedDataStream.listen(
                  (barcode) {
                    setState(
                      () {
                        result.value = barcode.code!;
                        //print(doc_snapshot.id);
                        controller.pauseCamera();
                        controller.dispose();
                      },
                    );
                  },
                  onDone: () async {
                    DocumentSnapshot<Object> docSnapshot =
                        await FirebaseFirestore.instance
                            .collection("parkings")
                            .doc(result.value)
                            .get();
                    if (docSnapshot.exists) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return ReservationScreen(
                              document: docSnapshot,
                            );
                          },
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Cod invalid. Incearca altul."),
                        ),
                      );
                    }
                  },
                );
              },
              overlay: QrScannerOverlayShape(
                  borderColor: Colors.blue,
                  borderRadius: 10,
                  borderLength: 20,
                  borderWidth: 10,
                  cutOutSize: MediaQuery.of(context).size.width * 0.5),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawer(),
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                _qrCodeRead();

                //ValueListenable listenable;
              },
              icon: Icon(Icons.qr_code))
        ],
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
            return Center(child: CircularProgressIndicator());
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
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ReservationScreen(document: widget.document)));
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
      subtitle: Text(widget.document["address"] +
          ", " +
          widget.document["capacity"].toString() +
          " locuri, " +
          widget.document["price"].toString() +
          " lei/ora"),
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
