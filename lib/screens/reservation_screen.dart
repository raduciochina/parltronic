import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_number_picker/flutter_number_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nfc_manager/nfc_manager.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({Key? key, required this.document}) : super(key: key);
  final DocumentSnapshot document;

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  var parkingsCollection = FirebaseFirestore.instance.collection('parkings');
  var setDefaultCarModel = true;
  var carModel;
  var plateNumber;
  var numberOfHours = 1;

  var carCollection = FirebaseFirestore.instance.collection('vehicles');

  //preia colectia de masini a utilizatorului curent

  @override
  Widget build(BuildContext context) {
    Query queryByUserCars =
        carCollection.where('uid', isEqualTo: "${user!.uid}");
    var streamQuery = queryByUserCars.get().asStream();

    return Scaffold(
      appBar: AppBar(
        title: Text("Rezerva loc de parcare"),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: parkingsCollection.doc('${widget.document.id}').snapshots(),
        builder: (_, snapshot) {
          if (snapshot.hasError) return Text('Error = ${snapshot.error}');

          if (snapshot.hasData) {
            var parkingDetails = snapshot.data!.data();
            var value = parkingDetails!['price']; // <-- Your value
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Image.network(
                        "${parkingDetails['photo']}",
                      ),
                      height: 250,
                      width: double.infinity,
                    ),
                    Center(
                      child: Text(
                        "${parkingDetails['name']}",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Divider(),
                    SizedBox(
                      height: 15,
                    ),
                    Text("Tarif orar"),
                    Text(
                      "${parkingDetails['price']} lei",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text("Adresa"),
                    Text(
                      "${parkingDetails['address']}",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text("Locuri disponibile"),
                    Text(
                      "${parkingDetails['capacity']}",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text("Numar de ore"),
                    CustomNumberPicker(
                      initialValue: 1,
                      maxValue: 24,
                      minValue: 1,
                      step: 1,
                      onValue: (value) {
                        numberOfHours = int.parse(value.toString());
                      },
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text("Alegeti autovehiculul"),
                    StreamBuilder<QuerySnapshot>(
                      stream: streamQuery,
                      builder: (context, snapshot) {
                        if (snapshot.hasError)
                          return Text('Error = ${snapshot.error}');
                        if (snapshot.hasData) {
                          var masini = snapshot.data?.docs;
                          if (setDefaultCarModel) {
                            carModel = snapshot.data!.docs[0].get("model");
                            plateNumber =
                                snapshot.data!.docs[0].get("plate_no");
                          }

                          return DropdownButton(
                            value: carModel,
                            items: snapshot.data!.docs.map((value) {
                              return DropdownMenuItem(
                                value: value.get("model"),
                                child: Text('${value.get("model")}'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                carModel = value;
                                setDefaultCarModel = false;
                              });
                            },
                            isExpanded: false,
                          );
                        }
                        return Text("");
                      },
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(50),
                        textStyle: TextStyle(fontSize: 20),
                      ),
                      onPressed: () async {
                        var total = parkingDetails['price'] * numberOfHours;
                        if (parkingDetails['capacity'] > 0) {
                          print(parkingDetails['capacity']);
                          print(total);
                          print(carModel);
                          //print()

                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Confirmare rezervare"),
                              content: Text(
                                  "Confirmare rezervare loc de parcare pentru " +
                                      numberOfHours.toString() +
                                      " ore, " +
                                      " total de plata " +
                                      total.toString() +
                                      " lei."),
                              actions: [
                                TextButton(
                                  child: Text("DA"),
                                  onPressed: () async {
                                    DocumentReference createdRecord =
                                        await FirebaseFirestore.instance
                                            .collection('reservations')
                                            .add({
                                      'cid': carModel,
                                      'pid': parkingDetails['pid'],
                                      'photo_url': parkingDetails['photo'],
                                      'uid': user?.uid,
                                      'time': numberOfHours,
                                      'total': total,
                                      'date': DateTime.now(),
                                      'name': parkingDetails['name'],
                                      'enddate': DateTime.now().add(
                                        Duration(hours: numberOfHours),
                                      ),
                                      'plate_no': plateNumber,
                                    });
                                    FirebaseFirestore.instance
                                        .collection('reservations')
                                        .doc(createdRecord.id)
                                        .update({'rid': createdRecord.id});

                                    FirebaseFirestore.instance
                                        .collection('parkings')
                                        .doc(parkingDetails['pid'])
                                        .update({
                                      'capacity': parkingDetails['capacity'] - 1
                                    });
                                    Navigator.pop(context);
                                    Fluttertoast.showToast(
                                        msg: "Rezervare efecutata.");
                                  },
                                ),
                                TextButton(
                                  child: Text("NU"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            ),
                          );
                        } else {
                          AlertDialog(
                            title: const Text('Alerta'),
                            content: const Text('Aceasta parcare este plina.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('INAPOI'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        }
                      },
                      child: Text("REZERVA"),
                    )
                  ],
                ),
              ),
            );
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
