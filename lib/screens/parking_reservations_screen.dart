import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:parktronic/models/parking.dart';

import '../models/reservation_model.dart';

class ParkingReservations extends StatefulWidget {
  const ParkingReservations({Key? key, required this.parkingModel})
      : super(key: key);
  final ParkingModel parkingModel;
  @override
  _ParkingReservationsState createState() => _ParkingReservationsState();
}

class _ParkingReservationsState extends State<ParkingReservations> {
  var tileColor = Colors.greenAccent;
  var isOk;
  String search = "";
  final controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    controller.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    controller.removeListener(onSearchChanged);
    controller.dispose();
    super.dispose();
  }

  onSearchChanged() {
    print(controller.text);
  }

  //

  @override
  Widget build(BuildContext context) {
    Stream<List<ReservationModel>> reservationModelStream = FirebaseFirestore
        .instance
        .collection("reservations")
        .where("pid", isEqualTo: widget.parkingModel.pid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReservationModel.fromMap(doc.data()))
            .toList());

    Future queryData(String queryString) async {
      return FirebaseFirestore.instance
          .collection("reservations")
          .where("pid", isEqualTo: widget.parkingModel.pid)
          .where("plate_no", isGreaterThanOrEqualTo: queryString)
          .get();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Rezervari " + widget.parkingModel.parkingName),
      ),
      body: StreamBuilder<List<ReservationModel>>(
        stream: reservationModelStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<ReservationModel> reservationModels = snapshot.data!;
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Numar masina",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.green),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: reservationModels.length,
                    itemBuilder: (context, index) {
                      if (search.isEmpty) {
                        return Card(
                          child: ListTile(
                            tileColor: reservationModels[index]
                                            .data
                                            .millisecondsSinceEpoch <
                                        DateTime.now().millisecondsSinceEpoch &&
                                    reservationModels[index]
                                            .enddata
                                            .toDate()
                                            .millisecondsSinceEpoch >
                                        DateTime.now().millisecondsSinceEpoch
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            title: Text(reservationModels[index].cid +
                                ": " +
                                reservationModels[index].plateNo),
                            subtitle: Text(DateFormat("E, d MMM yyyy HH:mm")
                                    .format(reservationModels[index]
                                        .data
                                        .toDate()) +
                                " - " +
                                DateFormat("E, d MMM yyyy HH:mm").format(
                                    reservationModels[index].enddata.toDate())),
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => ReservationDetailsScreen(
                              //
                              //          reservation: reservationModels[index])));
                            },
                          ),
                        );
                      } else if (reservationModels[index]
                          .plateNo
                          .toLowerCase()
                          .startsWith(controller.text.toLowerCase())) {
                        return Card(
                          child: ListTile(
                            tileColor: reservationModels[index]
                                            .data
                                            .millisecondsSinceEpoch <
                                        DateTime.now().millisecondsSinceEpoch &&
                                    reservationModels[index]
                                            .enddata
                                            .toDate()
                                            .millisecondsSinceEpoch >
                                        DateTime.now().millisecondsSinceEpoch
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            title: Text(reservationModels[index].cid +
                                ": " +
                                reservationModels[index].plateNo),
                            subtitle: Text(DateFormat("E, d MMM yyyy HH:mm")
                                    .format(reservationModels[index]
                                        .data
                                        .toDate()) +
                                " - " +
                                DateFormat("E, d MMM yyyy HH:mm").format(
                                    reservationModels[index].enddata.toDate())),
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => ReservationDetailsScreen(
                              //
                              //          reservation: reservationModels[index])));
                            },
                          ),
                        );
                      }
                      return Container();
                    },
                  ),
                ),
              ],
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
    );
  }
}
