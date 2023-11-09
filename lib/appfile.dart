import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ledtest/timer.dart';
import 'dart:async';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
class appfile extends StatefulWidget {
  final String ssid;
  final String pass;
  const appfile({super.key,required this.ssid,required this.pass});

  @override
  State<appfile> createState() => _appfileState();
}

class _appfileState extends State<appfile> {
  String deviceType = "";
  int vehicleType=2;
  int duration = 1;
  double payment = 10.0;
  bool isCharging = false;
  @override
  void initState() {
    super.initState();
    connect();
  }
  void connect(){
    WiFiForIoTPlugin.findAndConnect(widget.ssid,withInternet: false).whenComplete(() => getDeviceInfo());
  }

  Future<void> getDeviceInfo() async {
    final response = await http.get(
      Uri.parse('http://192.168.4.1:80/deviceInfo'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        deviceType = data['deviceType'];
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Charging Screen',),
        titleTextStyle: TextStyle(color: Colors.white,fontSize: 20),
        centerTitle:true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.developer_board,color: Colors.brown,size: 110,),
            Text('Device Type: $deviceType',style: TextStyle(color: Colors.white,fontSize: 20),),
            SizedBox(height: 20),
            DropdownButton<int>(
              dropdownColor: Colors.brown,
              value: vehicleType,
              items: <DropdownMenuItem<int>>[
                DropdownMenuItem<int>(
                  value: 2,
                  child: Text('2 Wheeler',style: TextStyle(color: Colors.white),),
                ),
                DropdownMenuItem<int>(
                  value: 4,
                  child: Text('4 Wheeler',style: TextStyle(color: Colors.white),),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  vehicleType = value!;
                });
              },
            ),
            SizedBox(height: 15,),
            Container(width: MediaQuery.of(context).size.width*0.5,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(5)),
              child: TextFormField(
                style: const TextStyle(fontSize: 18, color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(labelText: 'Duration(minutes)',
                labelStyle: TextStyle(color: Colors.grey),
                  focusColor: Colors.brown,
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    duration = int.tryParse(value) ?? 0;
                  });
                },
              ),
            ),
            SizedBox(height: 15,),
            Container(width: MediaQuery.of(context).size.width*0.5,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(5)),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: TextFormField(
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(labelText: 'Payment',
                      labelStyle: TextStyle(color: Colors.grey),
                    focusColor: Colors.brown,
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    setState(() {
                      payment = double.tryParse(value) ?? 0.0;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 10,),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder:(BuildContext bs)=>cnttime(duration: duration)));
              },
              child: Text('Start Charging'),
            ),
          ],
        ),
      ),
    );
  }
}
