import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
                  DateFormat('MM-dd-yyyy HH:mm')
                      .format(reservation.data.toDate())
                      .toString() +
                  ", ati parcat autoturismul personal " +
                  reservation.cid +
                  ", cu numarul de inmatriculare " +
                  reservation.plateNo +
                  ", avand un total de plata in valoare de " +
                  reservation.total.toStringAsFixed(2) +
                  " lei. Rezervarea expira la " +
                  DateFormat('MM-dd-yyyy HH:mm')
                      .format(reservation.enddata.toDate())
                      .toString() +
                  "."),
            ),
          ],
        ),
      ),
    );
  }
}
