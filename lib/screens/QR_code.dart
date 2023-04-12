// ignore_for_file: file_names

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:web_dashboard_app_tut/resources/warna.dart';
import 'package:web_dashboard_app_tut/utils/Utilitas.dart';

class Code extends StatefulWidget {
  const Code({Key? key}) : super(key: key);

  @override
  State<Code> createState() => _CodeState();
}

class _CodeState extends State<Code> {
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamQrcode() async* {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    yield* firestore.collection("code").doc("generate").snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      //sebelum ini buat seleksi
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 40),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Text(
                  "QR Code",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 50),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: streamQrcode(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return QrImage(
                            data: snapshot.data?.data()!["uid"],
                            size: 280,
                            // You can include embeddedImageStyle Property if you
                            //wanna embed an image from your Asset folder
                            embeddedImageStyle: QrEmbeddedImageStyle(
                              size: const Size(
                                100,
                                100,
                              ),
                            ),
                          );
                        }

                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      })
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
