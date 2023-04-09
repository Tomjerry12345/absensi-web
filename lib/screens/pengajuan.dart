import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:web_dashboard_app_tut/resources/warna.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:web_dashboard_app_tut/utils/Utilitas.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class Pengajuan extends StatefulWidget {
  const Pengajuan({Key? key}) : super(key: key);

  @override
  State<Pengajuan> createState() => _PengajuanState();
}

class _PengajuanState extends State<Pengajuan> {
  String? dropDownValue = "Kasbon";
  List<String> citylist = [
    'Izin',
    'Kasbon',
  ];

  DateTime selectedPeriod = DateTime.now();
  DateTime? _selected;
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

  void _exportToExcel(QuerySnapshot<Map<String, dynamic>?>? data, type) {
    final excel = Excel.createExcel();
    final sheet = excel.sheets[excel.getDefaultSheet() as String];
    sheet!.setColWidth(2, 50);
    sheet.setColAutoFit(0);

    String fileName =
        type == "Izin" ? excellIzin(sheet, data) : excellKasbon(sheet, data);

    excel.save(fileName: fileName);
  }

  String excellIzin(sheet, data) {
    int row = 0;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        'No';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value =
        'Nama';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value =
        'Tanggal Pengajuan';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value =
        'Keterangan';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value =
        'Tanggal Mulai';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0)).value =
        'Tanggal Selesai';

    data?.docs.forEach((e) {
      row++;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = row.toString();
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = e["nama"];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          .value = DateFormat('dd MMMM yyyy').format(e['tanggal'].toDate());
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          .value = e["keterangan"];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
          .value = e["tanggal_mulai"];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
          .value = e["tanggal_selesai"];
    });

    return "data_izin.xlsx";
  }

  String excellKasbon(sheet, data) {
    int row = 0;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        'No';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value =
        'Nama';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value =
        'Tanggal Pengajuan';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value =
        'Keterangan';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value =
        'Biaya';

    data?.docs.forEach((e) {
      row++;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = row.toString();
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = e["nama"];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          .value = DateFormat('dd MMMM yyyy').format(e['tanggal'].toDate());
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          .value = e["keterangan"];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
          .value = e["biaya"];
    });

    return "data_kasbon.xlsx";
  }

  DataTable TabelIzin(snapshot, submit, context) {
    return DataTable(
      columnSpacing: 78,
      horizontalMargin: 30,
      showCheckboxColumn: false,
      dataRowHeight: 48,
      // headingRowHeight: 0,
      headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
      columns: const <DataColumn>[
        DataColumn(label: Text("No")),
        DataColumn(label: Text("Nama")),
        DataColumn(label: Text("Tanggal Pengajuan")),
        DataColumn(label: Text("Jenis")),
        DataColumn(label: Text("Keterangan")),
        DataColumn(label: Text("Tanggal Mulai")),
        DataColumn(label: Text("Tanggal Selesai")),
        DataColumn(label: Text("Status")),
      ],
      rows: List<DataRow>.generate(snapshot.data!.docs.length, (index) {
        DocumentSnapshot data = snapshot.data!.docs[index];
        final number = index + 1;

        return DataRow(cells: [
          DataCell(Text(number.toString())),
          DataCell(Text(data["nama"])),
          DataCell(Text(DateFormat('dd MMMM yyyy')
              .format(data['created_at'].toDate())
              .toString())),
          DataCell(Text(data["jenis"])),
          DataCell(Text(data['keterangan'])),
          DataCell(data['tipe_pengajuan'] == 'Izin'
              ? Text(DateFormat('dd MMMM yyyy')
                  .format(data['tanggal_mulai'].toDate())
                  .toString())
              : const Text('-')),

          DataCell(data['tipe_pengajuan'] == 'Izin'
              ? Text(DateFormat('dd MMMM yyyy')
                  .format(data['tanggal_selesai'].toDate())
                  .toString())
              : const Text('-')),

          DataCell(Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 75, vertical: 4)),
              data['status'] == "0"
                  ? Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              textStyle: const TextStyle(fontSize: 16)),
                          child: const Text("Setujui"),
                          onPressed: () {
                            submit("1", data.id, context);
                          },
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              textStyle: const TextStyle(fontSize: 16)),
                          child: const Text("Tolak"),
                          onPressed: () {
                            submit("-1", data.id, context);
                          },
                        ),
                      ],
                    )
                  : data['status'] == '1'
                      ? Container(
                          color: Color.fromARGB(255, 134, 174, 134),
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Disetujui',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          color: Color.fromARGB(255, 207, 115, 115),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Ditolak',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        )
            ],
          )),

          // DataCell(Text(data['jenis'])),
        ]);
      }),
    );
  }

  DataTable TabelKasbon(snapshot, submit, context) {
    return DataTable(
      columnSpacing: 100,
      horizontalMargin: 70,
      showCheckboxColumn: false,
      dataRowHeight: 48,
      headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
      columns: const <DataColumn>[
        DataColumn(label: Text("No")),
        DataColumn(label: Text("Nama")),
        DataColumn(label: Text("Tanggal Pengajuan")),
        //DataColumn(label: Text("Jenis")),
        DataColumn(label: Text("Keterangan")),
        DataColumn(label: Text("Biaya")),
        DataColumn(label: Text("Status")),
      ],
      rows: List<DataRow>.generate(snapshot.data!.docs.length, (index) {
        DocumentSnapshot data = snapshot.data!.docs[index];
        final number = index + 1;

        return DataRow(cells: [
          DataCell(Text(number.toString())),
          DataCell(Text(data["nama"])),
          DataCell(Text(DateFormat('dd MMMM yyyy')
              .format(data['created_at'].toDate())
              .toString())),
          //DataCell(Text(data["jenis"])),
          DataCell(Text(data['keterangan'])),
          DataCell(Text("Rp ${data['biaya']}")),
          DataCell(Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 75, vertical: 4)),
              data['status'] == "0"
                  ? Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              textStyle: const TextStyle(fontSize: 16)),
                          child: const Text("Setujui"),
                          onPressed: () {
                            submit("1", data.id, context);
                          },
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              textStyle: const TextStyle(fontSize: 16)),
                          child: const Text("Tolak"),
                          onPressed: () {
                            submit("-1", data.id, context);
                          },
                        ),
                      ],
                    )
                  : data['status'] == '1'
                      ? Container(
                          color: Color.fromARGB(255, 134, 174, 134),
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Disetujui',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          color: Color.fromARGB(255, 207, 115, 115),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Ditolak',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        )
            ],
          )),

          // DataCell(Text(data['jenis'])),
        ]);
      }),
    );
  }

  void _createPdf(data1, type) async {
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
          return type == "Izin"
              ? pdfIzin(no, documentList)
              : pdfKasbon(no, documentList);
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

  pw.Column pdfIzin(no, documentList) {
    return pw.Column(
      children: [
        pw.Center(
          child: pw.Text("Data Pengajuan"),
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
                pw.Text("Tanggal Pengajuan",
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
                pw.Text("Tanggal Mulai",
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.Text("Tanggal Selesai",
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
                        DateFormat('dd MMMM yyyy')
                            .format(data['tanggal'].toDate())
                            .toString(),
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(
                          fontSize: 12,
                        )),
                    pw.Text(data["keterangan"],
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(
                          fontSize: 12,
                        )),
                    pw.Text(data["tanggal_mulai"],
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(
                          fontSize: 12,
                        )),
                    pw.Text(data["tanggal_selesai"],
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

  pw.Column pdfKasbon(no, documentList) {
    return pw.Column(
      children: [
        pw.Center(
          child: pw.Text("Data Pengajuan"),
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
                pw.Text("Tanggal Pengajuan",
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
                pw.Text("Biaya",
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
                        DateFormat('dd MMMM yyyy')
                            .format(data['tanggal'].toDate())
                            .toString(),
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(
                          fontSize: 12,
                        )),
                    pw.Text(data["keterangan"],
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(
                          fontSize: 12,
                        )),
                    pw.Text(data["biaya"],
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

  void _displayPdf() {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text(
              'Data Pengajuan Karyawan',
              style: const pw.TextStyle(fontSize: 30),
            ),
          );
        },
      ),
    );

    /// open Preview Screen

    // Navigator.push(context, MaterialPageRoute(builder:
    //     (context) => PreviewScreen(doc: doc),));
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController _firstController = ScrollController();
    return FutureBuilder<QuerySnapshot>(
        future: search != ""
            ? firestore
                .collection("pengajuan")
                .where("tipe_pengajuan", isEqualTo: dropDownValue)
                .where("nama", isEqualTo: search)
                .where("month",
                    isEqualTo: DateFormat("MMMM").format(selectedPeriod))
                .get()
            : firestore
                .collection("pengajuan")
                .where("tipe_pengajuan", isEqualTo: dropDownValue)
                .where("month",
                    isEqualTo: DateFormat("MMMM").format(selectedPeriod))
                .get(),
        builder: (context, snapshot) {
          logO("snapshoot", snapshot.data?.size);
          if (snapshot.hasData) {
            return Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 20, bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
                        Text(
                          "Data Pengajuan Karyawan",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10, right: 20),
                    //margin: EdgeInsets.symmetric(horizontal: 30),
                    // padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('MMMM yyyy').format(selectedPeriod),
                          style: TextStyle(
                              color: Warna.hijau2,
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                            icon: const Icon(Icons.keyboard_arrow_down),
                            color: Warna.hijau2,
                            onPressed: () {
                              _selectPeriod(context);
                              // show = true;
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
                        margin: const EdgeInsets.only(right: 24),
                        child: Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Warna.hijauht,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                              ),
                              onPressed: () {
                                _createPdf(snapshot.data, dropDownValue);
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
                                  onPressed: () {
                                    _exportToExcel(
                                        snapshot.data as QuerySnapshot<
                                            Map<String, dynamic>?>?,
                                        dropDownValue);
                                  },
                                  child: const Text("Download"),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 30),
                        width: 200,
                        child: Column(
                          children: <Widget>[
                            DropdownButtonFormField(
                              decoration: InputDecoration(
                                  filled: true,
                                  hintStyle: TextStyle(color: Warna.abuabu),
                                  hintText: "Izin / Kasbon",
                                  fillColor: Warna.putih),
                              value: dropDownValue,
                              // ignore: non_constant_identifier_names
                              onChanged: (String? Value) {
                                setState(() {
                                  dropDownValue = Value ?? "";
                                });
                              },
                              items: citylist
                                  .map((cityTitle) => DropdownMenuItem(
                                      value: cityTitle, child: Text(cityTitle)))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 20),
                        width: 200,
                        height: 48,
                        decoration: BoxDecoration(
                            color: Warna.putih,
                            borderRadius: BorderRadius.circular(5)),
                        child: Center(
                            child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                            setState(() {
                              search = value;
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
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50, top: 10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            //crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              //Now let's set the pagination
                              dropDownValue == "Kasbon"
                                  ? TabelKasbon(snapshot, submit, context)
                                  : TabelIzin(snapshot, submit, context),
                              const SizedBox(
                                height: 10.0,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Expanded(
              child: Center(child: CircularProgressIndicator()),
            );
          }
        });
  }

  // ignore: non_constant_identifier_names
  Container TextInput(
      String? label, bool? multiline, String? value, Function? onChanged) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      width: 300,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(label!),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          TextFormField(
            enabled: label == "Email" ? false : true,
            onChanged: ((value) {
              onChanged!(value);
            }),
            initialValue: value,
            keyboardType:
                multiline! ? TextInputType.multiline : TextInputType.none,
            maxLines: multiline ? 3 : 1,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: label,
            ),
          ),
        ],
      ),
    );
  }
}

class PreviewScreen extends StatelessWidget {
  final pw.Document doc;

  const PreviewScreen({
    Key? key,
    required this.doc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_outlined),
        ),
        centerTitle: true,
        title: const Text("Preview"),
      ),
      body: PdfPreview(
        build: (format) => doc.save(),
        allowSharing: true,
        allowPrinting: true,
        initialPageFormat: PdfPageFormat.a4,
        pdfFileName: "mydoc.pdf",
      ),
    );
  }
}
