import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:parktronic/models/parking.dart';
import 'package:parktronic/models/user_model.dart';
import 'package:parktronic/screens/login_screen.dart';
import 'package:parktronic/screens/search_widget.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:telephony/telephony.dart';

import '../models/reservation_model.dart';

class ParkingReservations extends StatefulWidget {
  const ParkingReservations({Key? key, required this.parkingModel})
      : super(key: key);
  final ParkingModel parkingModel;
  @override
  _ParkingReservationsState createState() => _ParkingReservationsState();
}

class _ParkingReservationsState extends State<ParkingReservations> {
  String phoneNumber = "";
  var tileColor = Colors.greenAccent;
  var isOk;
  String search = "";
  final Telephony telephony = Telephony.instance;
  bool toggle = false;
  String query = '';
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
    Stream<List<ReservationModel>> reservationModelStreamLast24h =
        FirebaseFirestore.instance
            .collection("reservations")
            .where("pid", isEqualTo: widget.parkingModel.pid)
            .where(
              "date",
              isGreaterThan:
                  // Timestamp.now()
                  //         .millisecondsSinceEpoch -
                  //     86400000 * Timestamp.now().millisecondsSinceEpoch)

                  // DateTime.now().subtract(Duration(days: 1)))
                  Timestamp.now(),
            )
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => ReservationModel.fromMap(doc.data()))
                .toList());
    Stream<List<ReservationModel>> reservationModelStream = FirebaseFirestore
        .instance
        .collection("reservations")
        .where("pid", isEqualTo: widget.parkingModel.pid)
        // .orderBy("enddate", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReservationModel.fromMap(doc.data()))
            .toList());

    Stream<List<ReservationModel>> reservationModelFilterStream =
        FirebaseFirestore.instance
            .collection("reservations")
            .where("pid", isEqualTo: widget.parkingModel.pid)
            .where("plate_no", isGreaterThanOrEqualTo: search)
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => ReservationModel.fromMap(doc.data()))
                .toList());
    Stream<List<UserModel>> userModels = FirebaseFirestore.instance
        .collection("users")
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList());

    // Widget buildSearch() => SearchWidget(
    //     text: query,
    //     onChanged: queryData,
    //     hintText: "Numarul de inmatriculare");

    return Scaffold(
      appBar: AppBar(
        title: Text("Rezervari " + widget.parkingModel.parkingName),
      ),
      body: StreamBuilder<List<ReservationModel>>(
        // stream: (search != "" || search != null)
        //     ? reservationModelStream
        //     : reservationModelFilterStream,
        stream: (search != "" || search != null)
            ? reservationModelStream
            : (toggle == true)
                ? reservationModelStreamLast24h
                : reservationModelFilterStream,

        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<ReservationModel> reservationModels = snapshot.data!;
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        search = val;
                      });
                    },
                    controller: controller,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Numarul de inmatriculare",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.green),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Rezervarile din ultimele 24h"),
                    buildSwitch(),
                  ],
                ),
                //buildSearch(),
                Expanded(
                  child: ListView.builder(
                    itemCount: reservationModels.length,
                    itemBuilder: (context, index) {
                      if (search.isEmpty) {
                        return Card(
                          child: ListTile(
                            onLongPress: () async {
                              var user = await FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(reservationModels[index].uid)
                                  .get()
                                  .then((value) {
                                phoneNumber = value.data()!['phoneNumber'];
                              });
                              print(phoneNumber);
                              String message =
                                  "Va informam ca rezervarea dvs. a expirat. Va rugam sa luati masuri!";
                              telephony.sendSms(
                                  to: phoneNumber, message: message);
                            },
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
                              //B 1
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

  void _sendSMS(String message, List<String> recipents) async {
    String _result = await sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
  }

  Widget buildSwitch() => Switch.adaptive(
        value: toggle,
        onChanged: (value) {
          setState(() {
            this.toggle = value;
            print(toggle.toString());
          });
        },
      );
}
