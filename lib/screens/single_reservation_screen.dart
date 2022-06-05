import 'package:flutter/material.dart';
import 'package:parktronic/models/reservation_model.dart';

class ReservationDetailsScreen extends StatelessWidget {
  const ReservationDetailsScreen({Key? key, required this.reservation})
      : super(key: key);
  final ReservationModel reservation;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rezervare"),
      ),
      body: Padding(
        padding: EdgeInsets.all(
          (8.0),
        ),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              reservation.photoUrl,
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                reservation.parkingName,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Pe data de " +
                  reservation.data.toDate().toString() +
                  ", ati parcat autoturismul personal " +
                  reservation.cid +
                  ", avand un total de plata in valoare de " +
                  reservation.total.toString() +
                  " lei."),
            ),
          ],
        ),
      ),
    );
  }
}
