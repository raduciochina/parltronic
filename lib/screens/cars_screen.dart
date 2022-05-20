import 'dart:math';
import 'package:parktronic/models/car_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:parktronic/models/car_model.dart';

class CarsScreen extends StatefulWidget {
  const CarsScreen({Key? key}) : super(key: key);

  @override
  _CarsScreenState createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  final modelController = TextEditingController();
  final plateNoController = TextEditingController();

  // Stream<List<CarModel>> carModelStream = FirebaseFirestore.instance
  //     .collection("vehicles")
  //     .snapshots()
  //     .map((snapshot) =>
  //         snapshot.docs.map((doc) => CarModel.fromMap(doc.data())).toList());

  Stream<List<CarModel>> carModelStreams = FirebaseFirestore.instance
      .collection("vehicles")
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => CarModel.fromMap(doc.data())).toList());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Autovehiculele personale"),
        ),
        body: StreamBuilder<List<CarModel>>(
          stream: carModelStreams,
          //FirebaseFirestore.instance.collection("vehicles").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<CarModel> carModels = snapshot.data!;
              return ListView(
                  children: carModels.map((car) {
                return Center(
                  child: ListTile(
                    onLongPress: () {},
                    title: Text(car.model.toString()),
                    subtitle: Text(car.plate_no.toString()),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection("vehicles")
                            .doc(car.carId)
                            .delete();
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Masina a fost eliminata")));
                      },
                    ),
                  ),
                );
              }).toList());
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            showDialog(context: context, builder: (context) => AddCarDialog());
          },
        ));
  }
}

class AddCarDialog extends StatefulWidget {
  const AddCarDialog({Key? key}) : super(key: key);

  @override
  _AddCarDialogState createState() => _AddCarDialogState();
}

class _AddCarDialogState extends State<AddCarDialog> {
  final TextEditingController modelController = TextEditingController();
  final TextEditingController plateController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    modelController.dispose();
    plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: formKey,
        child: Container(
          height: 150,
          child: Column(
            children: [
              TextFormField(
                controller: modelController,
                decoration: InputDecoration(
                  hintText: "Adaugati marca si modelul masinii",
                  filled: true,
                ),
                maxLength: 30,
                textInputAction: TextInputAction.next,
                validator: (String? text) {
                  if (text == null || text.isEmpty) {
                    return 'Va rugam sa introduceti marca si modelul';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: plateController,
                decoration: InputDecoration(
                  hintText: "Adauga numarul de inmatriculare",
                  filled: true,
                ),
                maxLength: 15,
                textInputAction: TextInputAction.next,
                validator: (String? text) {
                  if (text == null || text.isEmpty) {
                    return 'Va rugam sa introduceti numarul de inmatriculare';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("ANULARE"),
        ),
        TextButton(
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              String msg;
              try {
                // final collection =
                //     FirebaseFirestore.instance.collection("vehicles");
                // await collection.doc().set({
                //   'model': modelController.text,
                //   'plate_no': plateController.text,
                //   'uid': user?.uid,
                //   'cid': "",
                // });
                msg = "Masina adaugata";
                DocumentReference createdRecord = await FirebaseFirestore
                    .instance
                    .collection('vehicles')
                    .add({
                  'model': modelController.text,
                  'plate_no': plateController.text,
                  'uid': user?.uid,
                });

                FirebaseFirestore.instance
                    .collection('vehicles')
                    .doc(createdRecord.id)
                    .update({'cid': createdRecord.id});
              } catch (e) {
                msg = "Eroare la adaugare";
              }
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(msg)));
              Navigator.pop(context);
            }
          },
          child: Text("ADAUGA"),
        ),
      ],
    );
  }
}
