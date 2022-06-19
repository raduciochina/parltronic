import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parktronic/models/user_model.dart';
import 'package:parktronic/screens/home_screen.dart';
import 'package:parktronic/screens/map_screenv2.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  // our form key
  final _formKey = GlobalKey<FormState>();
  //editing controllers
  final firstNameEditingController = new TextEditingController();
  final secondNameEditingController = new TextEditingController();
  final emailEditingController = new TextEditingController();
  final phoneNumberController = new TextEditingController();
  final passwordEditingController = new TextEditingController();
  final confirmPasswordEditingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final firstNameField = TextFormField(
      autofocus: false,
      controller: firstNameEditingController,
      keyboardType: TextInputType.name,
      validator: (value) {
        RegExp regex = new RegExp(r'^.{3,}$');
        if (value!.isEmpty) {
          return ("Va rugam sa introduceti numele!");
        }
        if (!regex.hasMatch(value)) {
          return ("Introduceti un nume valid - minim 3 caractere");
        }
        return null;
      },
      onSaved: (value) {
        firstNameEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.account_circle,
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Nume",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    final phoneNumberField = TextFormField(
      autofocus: false,
      controller: phoneNumberController,
      keyboardType: TextInputType.phone,
      validator: (value) {
        RegExp regex = new RegExp(r'^.{10,}$');
        if (value!.isEmpty) {
          return ("Va rugam sa introduceti numarul de telefon!");
        }
        if (!regex.hasMatch(value)) {
          return ("Introduceti un numar de telefon valid - minim 10 caractere");
        }
        return null;
      },
      onSaved: (value) {
        phoneNumberController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.account_circle,
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Numar de telefon",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    final secondNameField = TextFormField(
      autofocus: false,
      controller: secondNameEditingController,
      keyboardType: TextInputType.name,
      validator: (value) {
        RegExp regex = new RegExp(r'^.{3,}$');
        if (value!.isEmpty) {
          return ("Va rugam sa introduceti prenumele!");
        }
        if (!regex.hasMatch(value)) {
          return ("Introduceti un prenume valid - minim 3 caractere");
        }
        return null;
      },
      onSaved: (value) {
        secondNameEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.account_circle,
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Prenume",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    final emailField = TextFormField(
      autofocus: false,
      controller: emailEditingController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Va rugam sa introduceti email-ul!");
        }
        //reg expression for email validation
        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
          return ("Introduceti o adresa de email valida");
        }
        return null;
      },
      onSaved: (value) {
        emailEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.mail,
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Email",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    final passwordField = TextFormField(
      autofocus: false,
      controller: passwordEditingController,
      obscureText: true,
      validator: (value) {
        RegExp regex = new RegExp(r'^.{6,}$');
        if (value!.isEmpty) {
          return ("Va rugam sa introduceti parola!");
        }
        if (!regex.hasMatch(value)) {
          return ("Introduceti o parola valida - minim 6 caractere");
        }
      },
      onSaved: (value) {
        passwordEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.password,
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Parola",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    final confirmPasswordField = TextFormField(
      autofocus: false,
      controller: confirmPasswordEditingController,
      obscureText: true,
      validator: (value) {
        if (confirmPasswordEditingController.text !=
            passwordEditingController.text) {
          return "Parolele nu se potrivesc";
        }
        return null;
      },
      onSaved: (value) {
        confirmPasswordEditingController.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.password,
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Confirma Parola",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    //sign up button
    final signupButton = Material(
      elevation: 5,
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onPressed: () {
          signUp(emailEditingController.text, passwordEditingController.text);
        },
        child: Text("Sign Up",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        color: Colors.greenAccent,
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
      ),
      borderRadius: BorderRadius.circular(33),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.green,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 180,
                      child: Image.asset(
                        "assets/logo.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(
                      height: 45,
                    ),
                    firstNameField,
                    SizedBox(
                      height: 20,
                    ),
                    secondNameField,
                    SizedBox(
                      height: 20,
                    ),
                    emailField,
                    SizedBox(
                      height: 20,
                    ),
                    phoneNumberField,
                    SizedBox(
                      height: 20,
                    ),
                    passwordField,
                    SizedBox(
                      height: 20,
                    ),
                    confirmPasswordField,
                    SizedBox(
                      height: 20,
                    ),
                    signupButton,
                    SizedBox(
                      height: 15,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void signUp(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => {postDetailsToFirestore()})
          .catchError((e) {
        Fluttertoast.showToast(msg: e!.message);
      });
    }
  }

  postDetailsToFirestore() async {
    //calling firestore
    //calling user model
    //sending these values
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    UserModel userModel = UserModel();

    //writing all the values
    userModel.email = user!.email;
    userModel.uid = user.uid;
    userModel.firstName = firstNameEditingController.text;
    userModel.secondName = secondNameEditingController.text;
    userModel.phoneNumber = phoneNumberController.text;

    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap());
    Fluttertoast.showToast(msg: "Cont creat");

    Navigator.pushAndRemoveUntil(
        (context),
        MaterialPageRoute(builder: (context) => MapScreenV2()),
        (route) => false);
  }
}
