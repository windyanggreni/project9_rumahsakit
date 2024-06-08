import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../model/model_kamar.dart' as kamarModel;
import '../model/model_rs.dart' as rsModel;

class PageDetailRS extends StatefulWidget {
  final rsModel.Datum rumahSakit;

  const PageDetailRS({Key? key, required this.rumahSakit}) : super(key: key);

  @override
  State<PageDetailRS> createState() => _PageDetailRSState();
}

class _PageDetailRSState extends State<PageDetailRS> {
  bool isLoading = false;
  List<kamarModel.Datum> listKamar = [];

  @override
  void initState() {
    super.initState();
    fetchKamarData();
  }

  Future<void> fetchKamarData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('http://192.168.43.124/rumahsakitDB/getKamar.php?id_rs=${widget.rumahSakit.id}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Data kamar diterima: $data'); // Debug print

        setState(() {
          kamarModel.ModelKamar modelKamar = kamarModel.ModelKamar.fromJson(data);
          listKamar = modelKamar.data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.rumahSakit.namaRs,
          style: TextStyle(color: Colors.white), // Ubah warna teks judul AppBar menjadi putih
        ),
        backgroundColor: Colors.pink, // Ubah warna background AppBar menjadi pink
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(double.parse(widget.rumahSakit.lat), double.parse(widget.rumahSakit.long)),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(widget.rumahSakit.id),
                    position: LatLng(double.parse(widget.rumahSakit.lat), double.parse(widget.rumahSakit.long)),
                    infoWindow: InfoWindow(
                      title: widget.rumahSakit.namaRs,
                      snippet: widget.rumahSakit.alamat,
                    ),
                  ),
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.rumahSakit.namaRs,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink, // Ubah warna teks nama rumah sakit menjadi pink
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Alamat: ${widget.rumahSakit.alamat ?? 'N/A'}',
                    style: TextStyle(
                      color: Colors.black87, // Ubah warna teks alamat menjadi hitam
                    ),
                  ),
                  Text(
                    'Deskripsi: ${widget.rumahSakit.deskripsi ?? 'N/A'}',
                    style: TextStyle(
                      color: Colors.black87, // Ubah warna teks deskripsi menjadi hitam
                    ),
                  ),
                  Text(
                    'No Telp: ${widget.rumahSakit.noTelp ?? 'N/A'}',
                    style: TextStyle(
                      color: Colors.black87, // Ubah warna teks nomor telepon menjadi hitam
                    ),
                  ),
                  SizedBox(height: 16),
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: listKamar.length,
                    itemBuilder: (context, index) {
                      final kamar = listKamar[index];
                      return Padding(
                        padding: EdgeInsets.all(10),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5,
                          child: ListTile(
                            leading: Icon(Icons.hotel, size: 40, color: Colors.pink), // Ubah warna ikon kamar menjadi pink
                            title: Text(
                              kamar.namaKamar,
                              style: TextStyle(
                                color: Colors.pink, // Ubah warna teks nama kamar menjadi pink
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kamar Tersedia: ${int.tryParse(kamar.kamarTersedia) ?? 0}',
                                  style: TextStyle(
                                    color: Colors.black87, // Ubah warna teks kamar tersedia menjadi hitam
                                  ),
                                ),
                                Text(
                                  'Kamar Kosong: ${int.tryParse(kamar.kamarKosong) ?? 0}',
                                  style: TextStyle(
                                    color: Colors.black87, // Ubah warna teks kamar kosong menjadi hitam
                                  ),
                                ),
                                Text(
                                  'Jumlah Antrian: ${int.tryParse(kamar.jumlahAntrian) ?? 0}',
                                  style: TextStyle(
                                    color: Colors.black87, // Ubah warna teks jumlah antrian menjadi hitam
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
