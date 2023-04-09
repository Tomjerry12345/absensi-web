import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class UsersDatabase {
  List list = [];
  final CollectionReference ref =
      FirebaseFirestore.instance.collection("users");

  Future getData() async {
    try {
      await ref.get().then((snapshot) {
        for (var res in snapshot.docs) {
          list.add(res.data());
        }
      });

      return list;
    } catch (e) {
      debugPrint("Error - $e");
      return null;
    }
  }
}
