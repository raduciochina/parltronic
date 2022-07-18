import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parktronic/models/parking.dart';
import 'package:parktronic/screens/login_screen.dart';
import 'package:parktronic/screens/parking_reservations_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int toggle = 0;
  Stream<List<ParkingModel>> parkingModelStream = FirebaseFirestore.instance
      .collection("parkings")
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ParkingModel.fromMap(doc.data()))
          .toList());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Administrator"),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
              icon: Icon(Icons.exit_to_app),
            )
          ],
        ),
        body: StreamBuilder<List<ParkingModel>>(
          stream: parkingModelStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<ParkingModel> parkingModels = snapshot.data!;
              return ListView.builder(
                itemCount: parkingModels.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(parkingModels[index].photo)),
                      title: Text(parkingModels[index].parkingName),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ParkingReservations(
                              parkingModel: parkingModels[index],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}
