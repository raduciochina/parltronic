import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ParkingModel {
  GeoPoint location;
  String parkingName;
  String photo;
  String address;
  int capacity;
  double price;
  String pid;
  int baseCapacity;

  ParkingModel({
    required this.location,
    required this.parkingName,
    required this.photo,
    required this.address,
    required this.capacity,
    required this.price,
    required this.pid,
    required this.baseCapacity,
  });

  factory ParkingModel.fromMap(map) {
    return ParkingModel(
      parkingName: map['name'],
      address: map['address'],
      photo: map['photo'],
      capacity: map['capacity'],
      location: map['location'],
      price: map['price'],
      pid: map['pid'],
      baseCapacity: map['baseCapacity'],
    );
  }

  //sending data to server
  Map<String, dynamic> toMap() {
    return {
      // 'uid': uid,
      // 'email': email,
      // 'firstName': firstName,
      // 'secondName': secondName,
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
