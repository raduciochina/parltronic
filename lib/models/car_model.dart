import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CarModel {
  String? carId;
  String? model;
  String? user;
  String? plate_no;

  CarModel({this.carId, this.model, this.plate_no, this.user});

  factory CarModel.fromMap(map) {
    return CarModel(
        carId: map['cid'],
        model: map['model'],
        user: map['uid'],
        plate_no: map['plate_no']);
  }

  //sending data to server
  Map<String, dynamic> toMap() {
    return {
      'cid': carId,
      'uid': user,
      'plate_no': plate_no,
      'model': model,
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
