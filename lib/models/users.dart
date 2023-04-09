// import 'package:cloud_firestore/cloud_firestore.dart';

// class Users {
//   String? id;
//   String? name;

//   Users({this.id, this.name});

//   factory Users.fromMap(Map<String, dynamic> map, String docId) {
//     return Users(
//       id: docId,
//       name: map['name'] as String?,
//     );
//   }
// }

// class Customer {
//   String? id;
//   String? name;
//   List<Users>? orders;

//   Customer({this.id, this.name, this.orders});

//   factory Customer.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
//     var data = snapshot.data();
//     var ordersList = (data!['orders'] as List)
//         .map((item) => Users.fromMap(item as Map<String, dynamic>, item.id as String))
//         .toList();

//     return Customer(
//       id: snapshot.id,
//       name: data['name'] as String?,
//       orders: ordersList,
//     );
//   }
// }


// FirebaseFirestore firestore = FirebaseFirestore.instance;

// Future<List<Customer>> getAllCustomers() async {
//   var customers = <Customer>[];

//   var snapshot = await firestore.collection('customers').get();
//   for (var doc in snapshot.docs) {
//     customers.add(Customer.fromSnapshot(doc));
//   }

//   return customers;
// }

