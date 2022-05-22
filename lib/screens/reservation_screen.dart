import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_number_picker/flutter_number_picker.dart';

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
                        print(value.toString());
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
                          // var listaMasini = snapshot.data!.docs
                          //     .map((e) => e.data())
                          //     .toList();
                          // print(listaMasini.first);
                          if (setDefaultCarModel) {
                            carModel = snapshot.data!.docs[0].get('model');
                            print(carModel + "hello _____________________--");
                            //debugPrint('setDefault make: $carMake');
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
                      onPressed: () {
                        // controllerEmail.text = '',
                        // controllerMessage.text = '',
                        // controllerName.text = '',
                        // controllerSubject.text = '',
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
