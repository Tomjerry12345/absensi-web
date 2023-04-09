// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:web_dashboard_app_tut/widgets/Utils.dart';
import 'package:web_dashboard_app_tut/resources/warna.dart';
import 'package:web_dashboard_app_tut/screens/login.dart';
import 'package:web_dashboard_app_tut/resources/gambar.dart';

class Profil extends StatefulWidget {
  const Profil({Key? key}) : super(key: key);

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.hijau2,
        actions: [
          Container(
            margin: const EdgeInsets.all(13),
            padding: const EdgeInsets.symmetric(horizontal: 139),
            child: Text(
              "Profil",
              style: TextStyle(
                color: Warna.putih,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 35),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage(Gambar.logo),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 35,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Alamat",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Warna.htam,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "No HP",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Warna.htam,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "No Rekening",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Warna.htam,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Email",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Warna.htam,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 230,
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            width: double.infinity,
            padding: const EdgeInsets.all(3),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Warna.hijau2,
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              child: const Text("Logout"),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const Login()));
                Utils.showSnackBar("Berhasil Logout.", Colors.red);
              },
            ),
          ),
        ],
      ),
    );
  }
}
