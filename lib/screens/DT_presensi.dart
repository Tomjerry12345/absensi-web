import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:web_dashboard_app_tut/resources/warna.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:web_dashboard_app_tut/utils/Utilitas.dart';
import '../models/present.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class Presensi extends StatefulWidget {
  const Presensi({Key? key}) : super(key: key);
  @override
  State<Presensi> createState() => _PresensiState();
}

class _PresensiState extends State<Presensi> {
  List<Object> _historyList = [];
  List<String> gajiDayList = [];
  String? _selectedUserId;

  DateTime selectedPeriod = DateTime.now();
  bool show = false;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String search = "";
  late TextEditingController searchController =
      TextEditingController(text: search);

  String nama = "";
  String email = "";
  String jenis = "";
  String createdat = "";
  // ignore: non_constant_identifier_names
  String tanggal_mulai = "";
  // ignore: non_constant_identifier_names
  String tanggal_selesai = "";
  String keterangan = "";
  String jumlah = "";
  bool loading = false;

  int rowNumber = 0;

  List<QueryDocumentSnapshot<Map<String, dynamic>>>? snaps = [];

  void _selectPeriod(BuildContext context) async {
    showMonthPicker(
      context: context,
      initialDate: DateTime.now(),
    ).then((date) {
      if (date != null) {
        setState(() {
          selectedPeriod = date;
        });
      }
    });
  }

  Future submit(String? status, String? id, BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    try {
      final doc = FirebaseFirestore.instance.collection("pengajuan").doc(id);
      final json = {
        "status": status,
      };
      await doc.update(json);
      Navigator.of(this.context).pop('dialog');
    } on FirebaseException {
      Navigator.of(this.context).pop('dialog');
    }
  }

  List<Map<String, dynamic>> myList = [];

  List<Map<String, dynamic>> searchResultList = [];

  Stream<QuerySnapshot<Map<String, dynamic>>> streamAllPresent() async* {
    logO("selectedPeriod.month", selectedPeriod.month);
    rowNumber = 0;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    if (search == "") {
      yield* firestore
          .collection("present")
          .where("tanggal.bulan", isEqualTo: "${selectedPeriod.month}")
          .snapshots();
    } else {
      yield* firestore
          .collection("present")
          .where("nama", isEqualTo: search)
          .where("tanggal.bulan", isEqualTo: "${selectedPeriod.month}")
          .snapshots();
    }
  }

  void _exportToExcel(QuerySnapshot<Map<String, dynamic>?>? data) {
    final excel = Excel.createExcel();
    final sheet = excel.sheets[excel.getDefaultSheet() as String];
    sheet!.setColWidth(2, 50);
    sheet.setColAutoFit(0);

    String fileName = excellPresensi(sheet, data);

    excel.save(fileName: fileName);
  }

  String excellPresensi(sheet, data) {
    int row = 0;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        'No';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value =
        'Nama';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value =
        'Tanggal';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value =
        'Waktu Datang';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value =
        'Waktu Pulang';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0)).value =
        'Keterangan';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0)).value =
        'Durasi';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0)).value =
        'Lembur';

    data?.docs.forEach((e) {
      final tanggal = e["tanggal"];
      final waktuDatang = e["waktu_datang"];
      final waktuPulang = e["waktu_pulang"];

      row++;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = row.toString();
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = e["nama"];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          .value = "${tanggal["hari"]}/${tanggal["bulan"]}/${tanggal["tahun"]}";
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          .value = "${waktuDatang["jam"]}:${waktuDatang["menit"]}";
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
          .value = "${waktuPulang["jam"]}:${waktuPulang["menit"]}";
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
          .value = e["keterangan_waktu_pulang"];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
          .value = e["durasi"].toString();
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
          .value = e["lembur"].toString();
    });

    return "data_presensi.xlsx";
  }

  void _createPdf(data1) async {
    final doc = pw.Document();

    // retrieve data from Firebase collection pengajuan
    // QuerySnapshot querySnapshot =
    //     await FirebaseFirestore.instance.collection('pengajuan').get();

    List<DocumentSnapshot> documentList = data1.docs;

    int no = 0;

    /// for using an image from assets
    // final image = await imageFromAssetBundle('assets/image.png');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pdfPresensi(no, documentList);
        },
      ),
    );

    /// print the document using the iOS or Android print service:
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());

    /// share the document to other applications:
    // await Printing.sharePdf(bytes: await doc.save(), filename: 'my-document.pdf');

    /// tutorial for using path_provider: https://www.youtube.com/watch?v=fJtFDrjEvE8
    /// save PDF with Flutter library "path_provider":
    // final output = await getTemporaryDirectory();
    // final file = File('${output.path}/example.pdf');
    // await file.writeAsBytes(await doc.save());
  }

  pw.Column pdfPresensi(no, documentList) {
    return pw.Column(
      children: [
        pw.Center(
          child: pw.Text("Data Presensi"),
        ),
        pw.SizedBox(height: 20),
        pw.Table(
          border: pw.TableBorder.all(
            color: PdfColor.fromHex("#000000"),
            width: 2,
          ),
          children: [
            pw.TableRow(
              children: [
                pw.Text("No",
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.Text("Nama",
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.Text("Tanggal",
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.Text("Waktu Datang",
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.Text("Waktu Pulang",
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.Text("Keterangan",
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.Text("Durasi",
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.Text("Lembur",
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    )),
              ],
            ),
            // add data to table
            ...documentList.map(
              (DocumentSnapshot document) {
                no++;

                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;

                Map<String, dynamic> tanggal = data["tanggal"];
                Map<String, dynamic> waktuDatang = data["waktu_datang"];
                Map<String, dynamic> waktuPulang = data["waktu_pulang"];

                return pw.TableRow(
                  children: [
                    pw.Text(no.toString(),
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(
                          fontSize: 12,
                        )),
                    pw.Text(data["nama"],
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(
                          fontSize: 12,
                        )),
                    pw.Text(
                        "${tanggal["hari"]}/${tanggal["bulan"]}/${tanggal["tahun"]}",
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(
                          fontSize: 12,
                        )),
                    pw.Text("${waktuDatang["jam"]}:${waktuDatang["menit"]}",
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(
                          fontSize: 12,
                        )),
                    pw.Text("${waktuPulang["jam"]}:${waktuPulang["menit"]}",
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(
                          fontSize: 12,
                        )),
                    pw.Text(data["keterangan_waktu_pulang"],
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(
                          fontSize: 12,
                        )),
                    pw.Text(data["durasi"].toString(),
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(
                          fontSize: 12,
                        )),
                    pw.Text(data["lembur"].toString(),
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(
                          fontSize: 12,
                        )),
                  ],
                );
              },
            )
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: streamAllPresent(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            var l = snapshot.data?.docs;
            return Expanded(
                child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 20, bottom: 40),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Text(
                        "Data Presensi",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Container(
                  // margin: EdgeInsets.only(top: 10),
                  // margin: EdgeInsets.symmetric(horizontal: 30),
                  margin: const EdgeInsets.only(bottom: 10, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('yMMMM').format(selectedPeriod),
                        style: TextStyle(
                            color: Warna.hijau2,
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                          icon: Icon(Icons.keyboard_arrow_down),
                          color: Warna.hijau2,
                          onPressed: () {
                            _selectPeriod(context);
                            show = true;
                          }),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                          bottom: 10, top: 10, right: 20, left: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Warna.hijauht,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                            ),
                            onPressed: () {
                              _createPdf(snapshot.data);
                            },
                            child: const Text("Cetak"),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(255, 88, 104, 103),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                ),
                                child: const Text("Download"),
                                // onPressed: _createPDF,
                                onPressed: () {
                                  _exportToExcel(snapshot.data);
                                },
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(left: 900, right: 20),
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                      color: Warna.putih,
                      borderRadius: BorderRadius.circular(5)),
                  child: Center(
                      child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        search = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Warna.hijau2,
                            width: 1.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Warna.hijau2,
                            width: 1.0,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {},
                        )),
                  )),
                ),
                SizedBox(
                  height: 30,
                ),
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 90,
                      horizontalMargin: 70,
                      showCheckboxColumn: false,
                      dataRowHeight: 48,
                      headingRowColor:
                          MaterialStateProperty.all(Colors.grey.shade200),
                      columns: const [
                        DataColumn(label: Text('No')),
                        DataColumn(label: Text('Nama')),
                        DataColumn(label: Text('Tanggal')),
                        DataColumn(label: Text('Waktu Datang')),
                        DataColumn(label: Text('Waktu Pulang')),
                        DataColumn(
                            label: Text('Keterangan')), //Normal datang cepat
                        DataColumn(label: Text('Durasi')),
                        DataColumn(label: Text('Lembur')),
                        // DataColumn(label: Text('Keterlambatan')),
                      ],
                      rows: l!.map((e) {
                        var t = e["tanggal"];
                        var wd = e["waktu_datang"];
                        var wp = e["waktu_pulang"];
                        var date = "${t["hari"]}/${t["bulan"]}/${t["tahun"]}";
                        rowNumber++;
                        return DataRow(cells: [
                          DataCell(Text(rowNumber.toString())),
                          DataCell(Text(e["nama"])),
                          DataCell(Text(date)),
                          DataCell(Text(wd.toString() == "{}"
                              ? "-"
                              : "${wd["jam"]}:${wd["menit"]}")),
                          DataCell(Text(wp.toString() == "{}"
                              ? "-"
                              : "${wp["jam"]}:${wp["menit"]}")),
                          DataCell(Text(e["keterangan_waktu_pulang"])),
                          DataCell(Text(e["durasi"].toString())),
                          DataCell(Text(e["lembur"].toString())),
                        ]);
                      }).toList(),
                    ))
              ],
            ));
          }
          return const Expanded(
            child: Center(child: CircularProgressIndicator()),
          );
        }));
  }
}
