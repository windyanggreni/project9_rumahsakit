import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project9_rumahsakit/screen_page/page_rs.dart';
import '../model/model_kabupaten.dart';

class PageKabupaten extends StatefulWidget {
  final String idProv;

  const PageKabupaten({Key? key, required this.idProv}) : super(key: key);

  @override
  _PageKabupatenState createState() => _PageKabupatenState();
}

class _PageKabupatenState extends State<PageKabupaten> {
  bool isLoading = false;
  List<Datum> listKabupaten = [];
  List<Datum> filteredKabupaten = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getKabupaten();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> getKabupaten() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse("http://192.168.43.124/rumahsakitDB/getKabupaten.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          ModelKabupaten modelKabupaten = ModelKabupaten.fromJson(data);
          listKabupaten = modelKabupaten.data.where((datum) => datum.provinsiId == widget.idProv).toList();
          filteredKabupaten = List.from(listKabupaten);
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

  void searchKabupaten(String query) {
    setState(() {
      filteredKabupaten = listKabupaten.where((kabupaten) {
        return kabupaten.namaKabupaten.toLowerCase().contains(query.toLowerCase()) ||
            kabupaten.id.toLowerCase() == query.toLowerCase();
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          'List Kabupaten',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: searchKabupaten,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
                hintText: 'Search Kabupaten',
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredKabupaten.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.all(10),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: ListTile(
                      leading: Image.asset('gambar/rs2.jpg', width: 40),
                      title: Text(
                        filteredKabupaten[index].namaKabupaten,
                        style: TextStyle(
                          color: Colors.pink,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PageRumahSakit(kabupatenId: filteredKabupaten[index].id),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
