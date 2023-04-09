import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:web_dashboard_app_tut/screens/dashboard_screen.dart';

import 'package:web_dashboard_app_tut/widgets/formcuxtom.dart';

import 'package:web_dashboard_app_tut/resources/warna.dart';

import '../widgets/Utils.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passworController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          color: Colors.green,
          child: Center(
            child: Container(
              margin: EdgeInsets.all(80),
              height: 600,
              width: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    width: double.infinity,
                    height: 100,
                    child: Image.asset("assets/logo.png"),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Center(
                      child: Text(
                        "SELAMAT DATANG ADMIN",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 24,
                            color: Warna.abuTr,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // ignore: sized_box_for_whitespace
                        Container(
                          width: double.infinity,
                          child: const Text(
                            "Email",
                            textAlign: TextAlign.left,
                          ),
                        ),

                        FormCustom(
                          text: 'Email',
                          controller: emailController,
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // ignore: sized_box_for_whitespace
                        Container(
                          width: double.infinity,
                          child: const Text(
                            "Password",
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        FormCustom(
                          text: 'Password',
                          controller: passworController,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Warna.borderside),
                      onPressed: () {},
                      child: const Text("Lupa Password ?"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Warna.hijau2,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      child: const Text("Masuk"),
                      onPressed: () {
                        if (emailController.text == "admin@gmail.com" &&
                            passworController.text == "admin123") {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DashboardScreen()),
                          );
                        }
                        // Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => DashboardScreen()),
                        // );
                        // log("tes");
                        // await signIn();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future signIn() async {
    final user = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: emailController.text.trim())
        .get();

    if (user.docs.isNotEmpty) {
      try {
        final res = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passworController.text.trim(),
        );
        log("tess${res}");
        Utils.showSnackBar("Berhasil Login.", Colors.green);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } on FirebaseAuthException catch (e) {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        Utils.showSnackBar(e.message, Colors.red);
      }
    }
  }
}
