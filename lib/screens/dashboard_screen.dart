import 'package:flutter/material.dart';
import 'package:web_dashboard_app_tut/resources/gambar.dart';
import 'package:web_dashboard_app_tut/resources/warna.dart';
import 'package:web_dashboard_app_tut/screens/Logout.dart';
import 'package:web_dashboard_app_tut/screens/login.dart';

import 'package:web_dashboard_app_tut/screens/pengajuan.dart';
import 'package:web_dashboard_app_tut/screens/QR_code.dart';
import 'package:web_dashboard_app_tut/screens/DT_karyawan.dart';
import 'package:web_dashboard_app_tut/screens/DT_presensi.dart';

import 'package:web_dashboard_app_tut/screens/slip_gaji.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  //setting the expansion function for the navigation rail

  int index = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Let's start by adding the Navigation Rail
          Container(
            child: NavigationRail(
                leading: Container(
                  color: Warna.putih,
                  width: 240,
                  height: 80,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Warna.mrah,
                          backgroundImage: AssetImage(Gambar.logo),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => Profil()));
                          },
                          child: Column(
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(
                                left: 90,
                                top: 15,
                              )),
                              Text(
                                "ADMIN",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Warna.htam,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                extended: true,
                backgroundColor: Warna.hijau2,
                unselectedIconTheme:
                    IconThemeData(color: Colors.white, opacity: 1),
                unselectedLabelTextStyle: TextStyle(
                  color: Warna.putih,
                ),
                selectedLabelTextStyle: TextStyle(color: Warna.kuning),
                selectedIconTheme: IconThemeData(color: Warna.kuning),
                onDestinationSelected: (value) {
                  setState(() {
                    index = value;
                  });
                },
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.qr_code_2_sharp),
                    label: Text("QR Code"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.bar_chart),
                    label: Text("Data Permohonan Karyawan"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.account_box),
                    label: Text("Data Karyawan"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.fact_check),
                    label: Text("Data Presensi"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.monetization_on),
                    label: Text("Slip Gaji"),
                  ),
                ],
                selectedIndex: index),
          ),
          index == 0
              ? Code()
              : index == 1
                  ? Pengajuan()
                  : index == 2
                      ? Karyawan()
                      : index == 3
                          ? Presensi()
                          : Gaji()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.logout),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Login()),
          );
        },
      ),
    );
  }
}
