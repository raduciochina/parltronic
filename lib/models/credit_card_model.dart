import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreditCard {
  String? cardId;
  String? cardNumber;
  String? expiringDate;
  String? uid;
  double? amount;

  CreditCard(
      {this.cardId, this.cardNumber, this.expiringDate, this.uid, this.amount});

  factory CreditCard.fromMap(map) {
    return CreditCard(
      cardId: map['cardId'],
      cardNumber: map['cardNumber'],
      expiringDate: map['expiringDate'],
      uid: map['uid'],
    );
  }

  //sending data to server
  Map<String, dynamic> toMap() {
    return {
      'cardId': cardId,
      'cardNumber': cardNumber,
      'uid': uid,
      'expiringDate': expiringDate,
    };
  }

  // static final List<ParkingModel> parkingModels = [
  //   ParkingModel(
  //     location: const LatLng(44.447947, 26.099324),
  //     parkingName: "Parcare Cibernetica",
  //     photo:
  //         "https://admitere.ase.ro/images/ase/thumbs/Cladirea-Virgil-Madgearu.jpg",
  //     address: "Calea Dorobanti, 15-17",
  //     capacity: 15,
  //   )
  // ];
}
