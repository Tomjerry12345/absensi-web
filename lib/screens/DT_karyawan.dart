import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_dashboard_app_tut/resources/warna.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:excel/excel.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class Karyawan extends StatefulWidget {
  const Karyawan({Key? key}) : super(key: key);

  @override
  State<Karyawan> createState() => _KaryawanState();
}

class _KaryawanState extends State<Karyawan> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String search = "";
  late TextEditingController searchController =
      TextEditingController(text: search);

  String nama = "";
  String email = "";
  String noHp = "";
  String noRekening = "";
  String alamat = "";
  bool _loading = false;

  Future editUser(String? id, BuildContext context, Function setLoad) async {
    setLoad(true);
    try {
      final docUser = FirebaseFirestore.instance.collection("users").doc(id);
      final json = {
        "email": email,
        "nama": nama,
        "no_rekening": noRekening,
        "alamat": alamat,
        "no_hp": noHp,
        "updated_at": DateTime.now(),
      };

      await docUser.update(json);

      Navigator.of(this.context).pop('dialog');
      setLoad(false);
      // Fluttertoast.showToast(
      //     msg: "Berhasil update user.",
      //     toastLength: Toast.LENGTH_SHORT,
      //     timeInSecForIosWeb: 2,
      //     webShowClose: true,
      //     webPosition: "right",
      //     webBgColor: "#5cb85c",
      //     gravity: ToastGravity.TOP,
      //     textColor: Colors.white,
      //     fontSize: 16.0);
    } on FirebaseException {
      Navigator.of(this.context).pop('dialog');
      setLoad(false);
    }
  }

  Future deleteUser(String? id, BuildContext context, Function setLoad) async {
    setLoad(true);
    try {
      final docUser = FirebaseFirestore.instance.collection("users").doc(id);

      await docUser.delete();

      Navigator.of(this.context).pop('dialog');
      setLoad(false);
      // Fluttertoast.showToast(
      //     msg: "Berhasil hapus user.",
      //     toastLength: Toast.LENGTH_SHORT,
      //     timeInSecForIosWeb: 2,
      //     webShowClose: true,
      //     webPosition: "right",
      //     webBgColor: "#5cb85c",
      //     gravity: ToastGravity.TOP,
      //     textColor: Colors.white,
      //     fontSize: 16.0);
    } on FirebaseException {
      Navigator.of(this.context).pop('dialog');
      setLoad(false);
    }
  }

  void _exportToExcel(QuerySnapshot<Map<String, dynamic>?>? data) {
    final excel = Excel.createExcel();
    final sheet = excel.sheets[excel.getDefaultSheet() as String];
    sheet!.setColWidth(2, 50);
    sheet.setColAutoFit(0);

    String fileName = excellKaryawan(sheet, data);

    excel.save(fileName: fileName);
  }

  String excellKaryawan(sheet, data) {
    int row = 0;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        'No';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value =
        'Nama';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value =
        'Alamat';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value =
        'No Hp';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value =
        'No Rekening';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0)).value =
        'Email';

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
          .value = e['alamat'];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          .value = e["no_hp"];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
          .value = e["no_rekening"];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
          .value = e["email"];
    });

    return "data_karyawan.xlsx";
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
          return pdfKaryawan(no, documentList);
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

  pw.Column pdfKaryawan(no, documentList) {
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
                pw.Text("Alamat",
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.Text("No HP",
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.Text("No Rekening",
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.Text("Email",
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
                    pw.Text(data["alamat"],
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(
                          fontSize: 12,
                        )),
                    pw.Text(data["no_hp"],
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(
                          fontSize: 12,
                        )),
                    pw.Text(data["no_rekening"],
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(
                          fontSize: 12,
                        )),
                    pw.Text(data["email"],
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
    final scrollController = ScrollController();
    return FutureBuilder<QuerySnapshot>(
        future: search != ""
            ? firestore
                .collection("users")
                .where("nama", isEqualTo: search)
                .get()
            : firestore.collection("users").get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
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
                          "Data Karyawan",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                        bottom: 10, top: 10, right: 20, left: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Warna.hijauht,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
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
                                    const Color.fromARGB(255, 88, 104, 103),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                              ),
                              child: const Text("Download"),
                              // onPressed: _createPDF,
                              onPressed: () {
                                _exportToExcel(snapshot.data
                                    as QuerySnapshot<Map<String, dynamic>?>?);
                              },
                            )
                          ],
                        ),
                      ],
                    ),
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50, top: 15),
                    child: Scrollbar(
                      controller: scrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              // crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                DataTable(
                                    // showBottomBorder: true,
                                    // columnSpacing: 45,
                                    // dataRowHeight: 45,
                                    columnSpacing: 70,
                                    horizontalMargin: 70,
                                    showCheckboxColumn: false,
                                    dataRowHeight: 48,
                                    headingRowColor: MaterialStateProperty.all(
                                        Colors.grey.shade200),
                                    columns: const <DataColumn>[
                                      DataColumn(label: Text("No.")),
                                      DataColumn(label: Text("nama")),
                                      DataColumn(label: Text("Alamat")),
                                      DataColumn(label: Text("No HP")),
                                      DataColumn(label: Text("No Rekening")),
                                      DataColumn(label: Text("Email")),
                                      DataColumn(label: Text("Ubah")),
                                    ],
                                    rows: List<DataRow>.generate(
                                        snapshot.data!.docs.length, (index) {
                                      DocumentSnapshot data =
                                          snapshot.data!.docs[index];
                                      final number = index + 1;

                                      return DataRow(cells: [
                                        DataCell(Text(number.toString())),
                                        DataCell(Text(data["nama"])),
                                        DataCell(Text(data['alamat'])),
                                        DataCell(Text(data['no_hp'])),
                                        DataCell(Text(data['no_rekening'])),
                                        DataCell(Text(data['email'])),
                                        DataCell(
                                          Row(
                                            children: [
                                              ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.amber,
                                                          textStyle:
                                                              const TextStyle(
                                                                  fontSize:
                                                                      16)),
                                                  onPressed: () {
                                                    setState(() {
                                                      nama = data["nama"];
                                                      email = data["email"];
                                                      noHp = data['no_hp'];
                                                      noRekening =
                                                          data["no_rekening"];
                                                      alamat = data["alamat"];
                                                    });
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return StatefulBuilder(
                                                              builder: (BuildContext
                                                                      context,
                                                                  void Function(
                                                                          void
                                                                              Function())
                                                                      setState) {
                                                            return Dialog(
                                                                insetPadding:
                                                                    const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            300),
                                                                child: Stack(
                                                                  children: [
                                                                    Container(
                                                                        width: double
                                                                            .infinity,
                                                                        height:
                                                                            500,
                                                                        padding:
                                                                            const EdgeInsets.all(
                                                                                20),
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                const Icon(
                                                                                  Icons.close,
                                                                                  color: Colors.white,
                                                                                ),
                                                                                const Text(
                                                                                  "Edit User",
                                                                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                                                                                ),
                                                                                InkWell(
                                                                                    child: const Icon(Icons.close),
                                                                                    onTap: () {
                                                                                      Navigator.of(context).pop('dialog');
                                                                                    }),
                                                                              ],
                                                                            ),
                                                                            Container(
                                                                              margin: const EdgeInsets.symmetric(vertical: 30),
                                                                              child: Column(
                                                                                children: [
                                                                                  Row(
                                                                                    children: [
                                                                                      TextInput("Email", false, email, (String value) {
                                                                                        setState(() {
                                                                                          email = value;
                                                                                        });
                                                                                      }),
                                                                                      TextInput("Nama", false, nama, (String value) {
                                                                                        setState(() {
                                                                                          nama = value;
                                                                                        });
                                                                                      })
                                                                                    ],
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    height: 20,
                                                                                  ),
                                                                                  Row(
                                                                                    children: [
                                                                                      TextInput("No HP", false, noHp, (String value) {
                                                                                        setState(() {
                                                                                          noHp = value;
                                                                                        });
                                                                                      }),
                                                                                      TextInput("No Rekening", false, noRekening, (String value) {
                                                                                        setState(() {
                                                                                          noRekening = value;
                                                                                        });
                                                                                      })
                                                                                    ],
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    height: 20,
                                                                                  ),
                                                                                  Row(
                                                                                    children: [
                                                                                      TextInput("Alamat", true, alamat, (String value) {
                                                                                        setState(() {
                                                                                          alamat = value;
                                                                                        });
                                                                                      }),
                                                                                    ],
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                ElevatedButton(
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    backgroundColor: Colors.green,
                                                                                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                                                                                    textStyle: const TextStyle(fontSize: 16),
                                                                                  ),
                                                                                  onPressed: !_loading
                                                                                      ? () {
                                                                                          editUser(data.id, context, (bool val) {
                                                                                            setState(() {
                                                                                              _loading = val;
                                                                                            });
                                                                                          });
                                                                                        }
                                                                                      : null,
                                                                                  child: _loading
                                                                                      ? const CircularProgressIndicator(
                                                                                          strokeWidth: 2.0,
                                                                                          color: Colors.white,
                                                                                        )
                                                                                      : const Text("Submit"),
                                                                                ),
                                                                              ],
                                                                            )
                                                                          ],
                                                                        )),
                                                                  ],
                                                                ));
                                                          });
                                                        });
                                                  },
                                                  child: const Text('Ubah')),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    textStyle: const TextStyle(
                                                        fontSize: 16)),
                                                onPressed: () {
                                                  setState(() {
                                                    nama = data["nama"];
                                                    email = data["email"];
                                                    noHp = data['no_hp'];
                                                    noRekening =
                                                        data["no_rekening"];
                                                    alamat = data["alamat"];
                                                  });
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return StatefulBuilder(
                                                            builder: (BuildContext
                                                                    context,
                                                                void Function(
                                                                        void
                                                                            Function())
                                                                    setState) {
                                                          return Dialog(
                                                              insetPadding:
                                                                  const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          300),
                                                              child: Stack(
                                                                children: [
                                                                  Container(
                                                                      width:
                                                                          400,
                                                                      height:
                                                                          240,
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              20),
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: const [
                                                                              Text(
                                                                                "Hapus User",
                                                                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Container(
                                                                              margin: const EdgeInsets.symmetric(vertical: 30),
                                                                              child: Text(
                                                                                textAlign: TextAlign.center,
                                                                                "Apakah anda yakin menghapus user ${data["nama"]}?",
                                                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                                                                              )),
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              ElevatedButton(
                                                                                style: ElevatedButton.styleFrom(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                                                                                  textStyle: const TextStyle(fontSize: 16),
                                                                                ),
                                                                                onPressed: () {
                                                                                  Navigator.of(context).pop("dialog");
                                                                                },
                                                                                child: const Text("Close"),
                                                                              ),
                                                                              const SizedBox(
                                                                                width: 10,
                                                                              ),
                                                                              ElevatedButton(
                                                                                style: ElevatedButton.styleFrom(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                                                                                  textStyle: const TextStyle(fontSize: 16),
                                                                                ),
                                                                                onPressed: !_loading
                                                                                    ? () {
                                                                                        deleteUser(data.id, context, (bool val) {
                                                                                          setState(() {
                                                                                            _loading = val;
                                                                                          });
                                                                                        });
                                                                                      }
                                                                                    : null,
                                                                                child: _loading
                                                                                    ? const CircularProgressIndicator(
                                                                                        strokeWidth: 2.0,
                                                                                        color: Colors.white,
                                                                                      )
                                                                                    : const Text("Ya"),
                                                                              ),
                                                                            ],
                                                                          )
                                                                        ],
                                                                      )),
                                                                ],
                                                              ));
                                                        });
                                                      });
                                                },
                                                child: const Text("Hapus"),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]);
                                    })),
                                //Now let's set the pagination
                                const SizedBox(
                                  height: 40.0,
                                ),
                              ],
                            )
                            //ok
                          ],
                        ),
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

// Future<void> _createPDF() async{
//   PdfDocument document = PdfDocument();
//   document.pages.add();

//   List<int> bytes = document.save();
//   document.dispose();
// }

void _createPdf() async {
  final doc = pw.Document();

  /// for using an image from assets
  // final image = await imageFromAssetBundle('assets/image.png');

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Column(children: [
          pw.Center(
            child: pw.Text("Data Karyawan"),
          ),
          pw.SizedBox(height: 20),
          pw.Table(
              border: pw.TableBorder.all(
                color: PdfColor.fromHex("#000000"),
                width: 2,
              ),
              children: [
                pw.TableRow(children: [
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
                  pw.Text("Alamat",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      )),
                  pw.Text("No Hp",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      )),
                  pw.Text("Nomor Rekening ",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      )),
                  pw.Text("Email",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      )),
                ]),
                // tabel isinya
                ...List.generate(15, (index) {
                  return pw.TableRow(children: [
                    pw.Text("${index + 1}",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        )),
                    pw.Text("-}",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        )),
                    pw.Text("-",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        )),
                    pw.Text("-",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        )),
                    pw.Text("-",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        )),
                    pw.Text("-",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        )),
                  ]);
                })
              ])
        ]);
      },
    ),
  ); // Page

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

class PreviewScreen extends StatelessWidget {
  final pw.Document doc;

  const PreviewScreen({
    Key? key,
    required this.doc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

// ignore: unused_element
void _convertPdfToImages(pw.Document doc) async {
  await for (var page
      in Printing.raster(await doc.save(), pages: [0, 1], dpi: 72)) {
    final image = page.toImage(); // ...or page.toPng()
    // ignore: avoid_print
    print(image);
  }
}

/// print an existing Pdf file from a Flutter asset
// ignore: unused_element
void _printExistingPdf() async {
  // import 'package:flutter/services.dart';
  final pdf = await rootBundle.load('assets/document.pdf');
  await Printing.layoutPdf(onLayout: (_) => pdf.buffer.asUint8List());
}

/// more advanced PDF styling
// ignore: unused_element
Future<Uint8List> _generatePdf(PdfPageFormat format, String title) async {
  final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
  final font = await PdfGoogleFonts.nunitoExtraLight();

  pdf.addPage(
    pw.Page(
      pageFormat: format,
      build: (context) {
        return pw.Column(
          children: [
            pw.SizedBox(
              width: double.infinity,
              child: pw.FittedBox(
                child: pw.Text(title, style: pw.TextStyle(font: font)),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Flexible(child: pw.FlutterLogo())
          ],
        );
      },
    ),
  );
  return pdf.save();
}
