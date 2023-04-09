class Order {
  String bulan;
  String date;

  Map<String, dynamic> toJson() => {'bulan': bulan, "date": date};

  Order.fromSnapshot(snapshot)
      : bulan = snapshot.data()['bulan'],
        date = snapshot.data()['date'];
}
