import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  String cid;
  String pid;
  String rid;
  int time;
  String uid;
  double total;
  Timestamp data;
  String parkingName;
  String photoUrl;
  Timestamp enddata;
  String plateNo;
  String metodaPlata;

  ReservationModel({
    required this.cid,
    required this.pid,
    required this.rid,
    required this.time,
    required this.uid,
    required this.total,
    required this.data,
    required this.parkingName,
    required this.photoUrl,
    required this.enddata,
    required this.plateNo,
    required this.metodaPlata,
  });

  factory ReservationModel.fromMap(map) {
    return ReservationModel(
        cid: map['cid'],
        pid: map['pid'],
        rid: map['rid'],
        time: map['time'],
        uid: map['uid'],
        total: map['total'],
        data: map['date'],
        parkingName: map['name'],
        photoUrl: map['photo_url'],
        enddata: map['enddate'],
        plateNo: map['plate_no'],
        metodaPlata: map['metodaPlata']);
  }
}
