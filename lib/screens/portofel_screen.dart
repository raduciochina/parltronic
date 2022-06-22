import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parktronic/models/credit_card_model.dart';
import 'package:parktronic/models/user_model.dart';

class PortofelScreen extends StatefulWidget {
  @override
  State<PortofelScreen> createState() => _PortofelPageState();
}

class _PortofelPageState extends State<PortofelScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  String userName = "";
  UserModel loggedInUser = UserModel();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  bool random(min, max) {
    var x = min + Random().nextInt(max - min);
    if (x % 2 == 0) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    Stream<List<CreditCard>> cardModelStreams = FirebaseFirestore.instance
        .collection("cards")
        .where("uid", isEqualTo: user?.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CreditCard.fromMap(doc.data()))
            .toList());
    return Scaffold(
      floatingActionButton: _buildAddCardButton(
        icon: Icon(Icons.add),
        color: Colors.green,
      ),
      appBar: AppBar(
        title: Text("Portofel"),
      ),
      body: StreamBuilder<List<CreditCard>>(
          stream: cardModelStreams,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<CreditCard> cardModels = snapshot.data!;
              return ListView(
                  children: cardModels.map((card) {
                return _buildCreditCard(
                  cardId: card.cardId.toString(),
                  cardExpiration: card.expiringDate.toString(),
                  cardHolder: loggedInUser.firstName.toString().toUpperCase() +
                      " " +
                      loggedInUser.secondName.toString().toUpperCase(),
                  cardNumber: card.cardNumber.toString(),
                  color: random(1, 20) ? Color(0xFF081603) : Color(0xFF090943),
                );
              }).toList());
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  // Build the credit card widget
  InkWell _buildCreditCard(
      {required String cardId,
      required Color color,
      required String cardNumber,
      required String cardHolder,
      required String cardExpiration}) {
    return InkWell(
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Sunteti sigur?"),
                content: Text(
                    " Cardul cu numarul " + cardNumber + " va fi eliminat."),
                actions: [
                  TextButton(
                    onPressed: () async {
                      FirebaseFirestore.instance
                          .collection("cards")
                          .doc(cardId)
                          .delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Cardul a fost eliminat"),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: Text("Da"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Nu"),
                  )
                ],
              );
            });
      },
      child: Card(
        margin: EdgeInsets.all(
          15.5,
        ),
        elevation: 4.0,
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Container(
          height: 200,
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildLogosBlock(),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  '$cardNumber',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontFamily: 'CourrierPrime'),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _buildDetailsBlock(
                    label: 'CARDHOLDER',
                    value: cardHolder,
                  ),
                  _buildDetailsBlock(
                      label: 'VALID THRU', value: cardExpiration),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build the top row containing logos
  Row _buildLogosBlock() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Image.asset(
          "assets/contact_less.png",
          height: 20,
          width: 18,
        ),
        Image.asset(
          "assets/mastercard.png",
          height: 50,
          width: 50,
        ),
      ],
    );
  }

// Build Column containing the cardholder and expiration information
  Column _buildDetailsBlock({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$label',
          style: TextStyle(
              color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold),
        ),
        Text(
          '$value',
          style: TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        )
      ],
    );
  }

// Build the FloatingActionButton
  Container _buildAddCardButton({
    required Icon icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 24.0),
      alignment: Alignment.bottomCenter,
      child: FloatingActionButton(
        elevation: 2.0,
        onPressed: () {
          showDialog(context: context, builder: (context) => AddCardDialog());
        },
        backgroundColor: color,
        mini: false,
        child: icon,
      ),
    );
  }
}

class AddCardDialog extends StatefulWidget {
  const AddCardDialog({Key? key}) : super(key: key);

  @override
  _AddCardDialogState createState() => _AddCardDialogState();
}

class _AddCardDialogState extends State<AddCardDialog> {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiringDateController = TextEditingController();
  final TextEditingController cvcController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey();
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    cardNumberController.dispose();
    cvcController.dispose();
    expiringDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: formKey,
        child: Container(
          height: 220,
          child: Column(
            children: [
              TextFormField(
                controller: cardNumberController,
                decoration: InputDecoration(
                  hintText: "Introduceti numarul cardului",
                  filled: true,
                ),
                keyboardType: TextInputType.number,
                maxLength: 30,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  RegExp regex = new RegExp(
                      r'^(?:4[0-9]{12}(?:[0-9]{3})?|[25][1-7][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})$');
                  if (value == null || value.isEmpty) {
                    return 'Va rugam sa introduceti numarul cardului!';
                  }
                  if (!regex.hasMatch(value)) {
                    return ("Introduceti un numar de card valid!");
                  }
                  return null;
                },
              ),
              TextFormField(
                keyboardType: TextInputType.datetime,
                controller: expiringDateController,
                decoration: InputDecoration(
                  hintText: "Adaugati data de expirare a cardului",
                  filled: true,
                ),
                maxLength: 30,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  RegExp regex = new RegExp(
                      r' ^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]|(?:Jan|Mar|May|Jul|Aug|Oct|Dec)))\1|(?:(?:29|30)(\/|-|\.)(?:0?[1,3-9]|1[0-2]|(?:Jan|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec))\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)(?:0?2|(?:Feb))\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9]|(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep))|(?:1[0-2]|(?:Oct|Nov|Dec)))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$');
                  if (value == null || value.isEmpty) {
                    return 'Va rugam sa introduceti data expirarii!';
                  }
                  if (!regex.hasMatch(value)) {
                    return ("Introduceti o data valida!");
                  }
                  return null;
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: cvcController,
                decoration: InputDecoration(
                  hintText: "Adaugati codul CVC",
                  filled: true,
                ),
                maxLength: 15,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  RegExp regex = new RegExp(r'^[0-9]{3}$');

                  if (value == null || value.isEmpty) {
                    return 'Va rugam sa introduceti data expirarii!';
                  }
                  if (!regex.hasMatch(value)) {
                    return ("Introduceti o data valida!");
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
                msg = "Card adaugat";
                DocumentReference createdRecord =
                    await FirebaseFirestore.instance.collection('cards').add({
                  'cardNumber': cardNumberController.text,
                  'expiringDate': expiringDateController.text,
                  'cvc': cvcController.text,
                  'uid': user?.uid,
                });

                FirebaseFirestore.instance
                    .collection('cards')
                    .doc(createdRecord.id)
                    .update({'cardId': createdRecord.id});
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
