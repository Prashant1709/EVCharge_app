import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ledtest/helper_class.dart';
import 'package:ledtest/mapfile.dart';
import 'package:ledtest/scan.dart';
import 'package:swipeable/swipeable.dart';
import 'package:http/http.dart' as http;
class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}
class _WelcomeState extends State<Welcome> {
  List<LocationData> locationList = [];
  List<ChargerData> chargerList=[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getroute().then((data) {
      setState(() {
        locationList = data;
      });
    });
    fetchChargerData().then((data){
      setState(() {
        chargerList=data;
      });
    });
  }
  Future<List<ChargerData>> fetchChargerData() async {
    final response = await http.get(
      Uri.parse('http://evcharger.centralindia.cloudapp.azure.com:3000/evcharge/charger_info'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> chargerList = json.decode(response.body)['data'];
      List<ChargerData> chargers = chargerList
          .map((data) => ChargerData.fromJson(data))
          .toList();
      return chargers;
    } else {
      throw Exception('Failed to load charger data');
    }
  }
  Future<List<LocationData>>getroute() async {
    final response = await http.get(
      Uri.parse('http://evcharger.centralindia.cloudapp.azure.com:3000/evcharge/route_info'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        List<LocationData> locationList = (data['data'] as List)
            .map((data) => LocationData.fromJson(data))
            .toList();
        return locationList;
      } else {
        throw Exception('Invalid data format');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Charged'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height*0.1),
            Icon(
              Icons.bolt,
              size: 120,
              color: Color(0xff6B4339),
            ),
            SizedBox(height: 20),
            Text('Welcome to being charged!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.3),

            Container(
              margin: const EdgeInsets.fromLTRB(20, 5, 20,5),
              child: Swipeable(
                threshold: 60.0,
                onSwipeLeft: () {
                  fetchChargerData().then((data){
                    setState(() {
                      chargerList=data;
                    });
                  });
                  getroute().then((data) {
                    setState(() {
                      locationList = data;
                    });
                  }).whenComplete(() =>
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext bs)=>Mappg(locationList: locationList,chargerList: chargerList,)))
                  );

                },
                onSwipeRight: () {
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext bs)=>scanpage()));
                  },
                background: Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                      color: Color(0xff6B4339).withOpacity(1)),
                  child: ListTile(
                    leading: Container(
                      width: 82.0,
                      height: 82.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Color(0xff6B4339).withOpacity(1),
                      ),
                    ),
                    trailing: Container(
                      width: 82.0,
                      height: 82.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color:Color(0xff6B4339).withOpacity(1),
                      ),
                    ),
                  ),
                ),
                child: Container(
                  decoration:const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                      color: Colors.brown),
                  child: const ListTile(
                    title: Text(">> Charge"),
                    textColor: Colors.white,
                    trailing: Text("Map <<"),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}