import 'package:flutter/material.dart';

class UserModel {
  String? uid;
  String? email;
  String? firstName;
  String? secondName;
  String? phoneNumber;

  UserModel(
      {this.uid,
      this.email,
      this.firstName,
      this.secondName,
      this.phoneNumber});

  //getting data from server
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      firstName: map['firstName'],
      secondName: map['secondName'],
      phoneNumber: map['phoneNumber'],
    );
  }

  //sending data to server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'secondName': secondName,
      'phoneNumber': phoneNumber,
    };
  }
}
