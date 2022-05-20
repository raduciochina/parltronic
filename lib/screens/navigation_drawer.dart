import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parktronic/models/user_model.dart';
import 'package:parktronic/screens/cars_screen.dart';
import 'package:parktronic/screens/contact_screen.dart';
import 'package:parktronic/screens/faqs_screen.dart';
import 'package:parktronic/screens/profil_screen.dart';
import 'package:parktronic/screens/profile_photo_screen.dart';
import 'package:parktronic/screens/settings_screen.dart';

import 'login_screen.dart';

class NavigationDrawer extends StatefulWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  _NavigationDrawerState createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  final urlImage =
      "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.pngfind.com%2Fmpng%2FhiJwTJo_icon-user-icon-hd-png-download%2F&psig=AOvVaw0TKZzN8kh-FF2ZvDR1iATU&ust=1652907529724000&source=images&cd=vfe&ved=0CAwQjRxqFwoTCJiPxcK25_cCFQAAAAAdAAAAABAP";

  final padding = EdgeInsets.symmetric(horizontal: 20);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
          color: Color.fromARGB(176, 14, 136, 65),
          child: ListView(
            padding: padding,
            children: [
              // buildHeader(
              //     urlImage: urlImage,
              //     name: loggedInUser.firstName,
              //     email: loggedInUser.email,
              //     onClicked: () => Navigator.of(context).push(MaterialPageRoute(
              //         builder: (context) => ProfilePhotoScreen(
              //             name: loggedInUser.firstName, urlImage: urlImage)))),
              Container(
                height: 200,
                width: double.infinity,
                padding: EdgeInsets.only(top: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/user.png'),
                        ),
                      ),
                    ),
                    Text(
                      loggedInUser.firstName.toString() +
                          " " +
                          loggedInUser.secondName.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    Text(
                      loggedInUser.email.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              buildMenuItem(
                text: "Profil",
                icon: Icons.people,
                onClicked: () => selectedItem(context, 0),
              ),
              SizedBox(
                height: 16,
              ),
              buildMenuItem(
                  text: "Masini",
                  icon: Icons.car_rental,
                  onClicked: () => selectedItem(context, 1)),
              SizedBox(
                height: 16,
              ),
              buildMenuItem(
                  text: "Setari",
                  icon: Icons.settings,
                  onClicked: () => selectedItem(context, 2)),
              SizedBox(
                height: 16,
              ),
              buildMenuItem(
                  text: "Contact",
                  icon: Icons.contact_mail,
                  onClicked: () => selectedItem(context, 3)),
              SizedBox(
                height: 16,
              ),
              buildMenuItem(
                  text: "FAQs",
                  icon: Icons.question_answer,
                  onClicked: () => selectedItem(context, 4)),
              SizedBox(
                height: 16,
              ),
              Divider(
                color: Colors.white70,
              ),
              buildMenuItem(
                text: "Logout",
                icon: Icons.logout,
                onClicked: () => selectedItem(context, 5),
              )
            ],
          )),
    );
  }

  Widget buildMenuItem({
    required String text,
    required IconData icon,
    VoidCallback? onClicked,
  }) {
    final color = Colors.white;
    final hoverColor = Colors.white70;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: TextStyle(color: color)),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  Widget buildHeader({
    required Image urlImage,
    required String name,
    required String email,
    required VoidCallback onClicked,
  }) =>
      InkWell(
        onTap: onClicked,
        child: Container(
          padding: padding.add(EdgeInsets.symmetric(vertical: 40)),
          child: Row(children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(
                  "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.pngfind.com%2Fmpng%2FhiJwTJo_icon-user-icon-hd-png-download%2F&psig=AOvVaw0TKZzN8kh-FF2ZvDR1iATU&ust=1652907529724000&source=images&cd=vfe&ved=0CAwQjRxqFwoTCJiPxcK25_cCFQAAAAAdAAAAABAP"),
            )
          ]),
        ),
      );

  void selectedItem(BuildContext context, int index) {
    Navigator.of(context).pop();
    switch (index) {
      case 0:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: ((context) => ProfilScreen())));
        break;
      case 1:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: ((context) => CarsScreen())));
        break;
      case 2:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: ((context) => SettingsScreen())));
        break;

      case 3:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: ((context) => ContactScreen())));
        break;

      case 4:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: ((context) => FaqsScreen())));
        break;
      case 5:
        logout(context);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: ((context) => LoginScreen())));
        break;
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}
