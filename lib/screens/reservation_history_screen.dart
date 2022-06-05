import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parktronic/models/reservation_model.dart';
import 'package:parktronic/screens/single_reservation_screen.dart';

class ReservationHistoryScreen extends StatefulWidget {
  const ReservationHistoryScreen({Key? key}) : super(key: key);

  @override
  _ReservationHistoryScreenState createState() =>
      _ReservationHistoryScreenState();
}

class _ReservationHistoryScreenState extends State<ReservationHistoryScreen> {
  Stream<List<ReservationModel>> reservationModelStream = FirebaseFirestore
      .instance
      .collection("reservations")
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ReservationModel.fromMap(doc.data()))
          .toList());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Istoric rezervari"),
        ),
        body: StreamBuilder<List<ReservationModel>>(
          stream: reservationModelStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<ReservationModel> reservationModels = snapshot.data!;
              return ListView.builder(
                itemCount: reservationModels.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(reservationModels[index].parkingName),
                      subtitle: Text(
                        reservationModels[index].data.toDate().toString(),
                      ),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReservationDetailsScreen(
                                    reservation: reservationModels[index])));
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
