import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  final controllerSubject = TextEditingController();
  final controllerMessage = TextEditingController();
  final controllerName = TextEditingController();
  final controllerEmail = TextEditingController();

  @override
  Widget build(BuildContext context) {
    controllerEmail.text = user!.email.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text("Feedback"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          buildTextFromField(title: 'Nume', controller: controllerName),
          buildTextFromField(title: 'Email', controller: controllerEmail),
          buildTextFromField(title: 'Subiect', controller: controllerSubject),
          buildTextFromField(
            title: 'Mesaj',
            controller: controllerMessage,
            maxLines: 8,
          ),
          const SizedBox(
            height: 32,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size.fromHeight(50),
              textStyle: TextStyle(fontSize: 20),
            ),
            onPressed: () => {
              sendEmail(
                  email: controllerEmail.text,
                  message: controllerMessage.text,
                  name: controllerName.text,
                  subject: controllerSubject.text),
              Fluttertoast.showToast(msg: "Mesaj trimis"),
              controllerEmail.text = '',
              controllerMessage.text = '',
              controllerName.text = '',
              controllerSubject.text = '',
            },
            child: Text("TRIMITE"),
          )
        ]),
      ),
    );
  }

  Widget buildTextFromField({
    required String title,
    required TextEditingController controller,
    int maxLines = 1,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 8,
          ),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );

  // Future launchEamil({
  //   required String toEmail,
  //   required String subject,
  //   required String message,
  // }) async {
  //   final url =
  //       'mailto:$toEmail?subject=${Uri.encodeFull(subject)}&body=${Uri.encodeFull(message)}'; //special statemnt
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   }
  // }

  Future sendEmail({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    final serviceId = 'service_ol3c5l5';
    final templateId = 'template_ej6ni8t';
    final publicKey = '5vPapuDo8YEzMKO2g';
    final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'origin': 'http://localhost',
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'template_params': {
          'user_name': name,
          'user_email': email,
          'user_subject': subject,
          'user_message': message,
        },
        'user_id': publicKey,
      }),
    );

    print(response.body);
  }
}
