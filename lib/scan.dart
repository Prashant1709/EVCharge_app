import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:ledtest/appfile.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import 'dart:async';
class scanpage extends StatefulWidget {
  const scanpage({super.key});

  @override
  State<scanpage> createState() => _scanpageState();
}

class _scanpageState extends State<scanpage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdevices();
    fetchCurrentLocation();
    _getScannedResults(context).whenComplete(() => fnr());
  }
  Map<String,String> chargers={};
  Future<void> getdevices() async {
    final response = await http.get(
      Uri.parse('http://evcharger.centralindia.cloudapp.azure.com:3000/evcharge/device_info'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );
    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      for(int i=0;i<data['data'].length;i++){
        chargers.addEntries({data['data'][i]['ssid'].toString():data['data'][i]['pass'].toString()}.entries);
      }
    }
  }
  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
  StreamSubscription<List<WiFiAccessPoint>>? subscription;
  bool shouldCheckCan = true,found=false;

  bool get isStreaming => subscription != null;
  fetchCurrentLocation() async {
    print("STARTING LOCATION SERVICE");
    var location = Location();
    location.changeSettings(accuracy: LocationAccuracy.powerSave,interval: 1000,distanceFilter: 500);
    await location.requestPermission().whenComplete(() => log(100));
  }
  Future<void> _startScan(BuildContext context) async {
    // check if "can" startScan
    if (shouldCheckCan) {
      // check if can-startScan
      final can = await WiFiScan.instance.canStartScan();
      // if can-not, then show error
      if (can != CanStartScan.yes) {
        if (mounted) kShowSnackBar(context, "Cannot start scan: $can");
        return;
      }
    }

    // call startScan API
    final result = await WiFiScan.instance.startScan();
    if (mounted) kShowSnackBar(context, "startScan: $result");
    // reset access points.
    setState(() => accessPoints = <WiFiAccessPoint>[]);
  }

  Future<bool> _canGetScannedResults(BuildContext context) async {
    if (shouldCheckCan) {
      // check if can-getScannedResults
      final can = await WiFiScan.instance.canGetScannedResults();
      // if can-not, then show error
      if (can != CanGetScannedResults.yes) {
        if (mounted) kShowSnackBar(context, "Cannot get scanned results: $can");
        accessPoints = <WiFiAccessPoint>[];
        return false;
      }
    }
    return true;
  }
  Future<void> _getScannedResults(BuildContext context) async {
    if (await _canGetScannedResults(context)) {
      // get scanned results
      final results = await WiFiScan.instance.getScannedResults();
      setState(() => accessPoints = results);
    }
    print("found");
//fnr();
  }
  void fnr(){
    print("Searching..");
    for(var i in accessPoints){
      chargers.forEach((key, value) {
        if(key==i.ssid){
          print("located");
          setState(() {
            found=true;
          });
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext bs)=>appfile(ssid: i.ssid,pass:value,)));
        }
      });
      }
    }

  Future<void> _startListeningToScanResults(BuildContext context) async {
    if (await _canGetScannedResults(context)) {
      subscription = WiFiScan.instance.onScannedResultsAvailable
          .listen((result) => setState(() => accessPoints = result));
    }
    //fnr();
  }

  void _stopListeningToScanResults() {
    subscription?.cancel();
    setState(() => subscription = null);
  }

  @override
  void dispose() {
    super.dispose();
    // stop subscription for scanned results
  }

  // build toggle with label
  Widget _buildToggle({
    String? label,
    bool value = false,
    ValueChanged<bool>? onChanged,
    Color? activeColor,
  }) =>
      Row(
        children: [
          if (label != null) Text(label),
          Switch(value: value, onChanged: onChanged, activeColor: activeColor),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Wi-Fi Scan'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.wifi,
              size: 120,
              color: Color(0xff6B4339).withOpacity(1),
            ),
            SizedBox(height: 20),
            Text(found?'Charger Found Connecting':'Scanning for Nearby Chargers',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff6B4339).withOpacity(1)),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add scan button functionality here
          getdevices();
          _getScannedResults(context).whenComplete(() => fnr());
        },
        icon: Icon(Icons.refresh),
        label: Text('Tap to Scan'),
        backgroundColor: Color(0xff6B4339).withOpacity(1),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// /// Show tile for AccessPoint.
// ///
// /// Can see details when tapped.
// class _AccessPointTile extends StatelessWidget {
//   final WiFiAccessPoint accessPoint;
//
//   const _AccessPointTile({Key? key, required this.accessPoint})
//       : super(key: key);
//
//   // build row that can display info, based on label: value pair.
//   Widget _buildInfo(String label, dynamic value) => Container(
//     decoration: const BoxDecoration(
//       border: Border(bottom: BorderSide(color: Colors.grey)),
//     ),
//     child: Row(
//       children: [
//         Text(
//           "$label: ",
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//       ],
//     ),
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     final title = accessPoint.ssid.isNotEmpty ? accessPoint.ssid : "**EMPTY**";
//     final signalIcon = accessPoint.level >= -80
//         ? Icons.signal_wifi_4_bar
//         : Icons.signal_wifi_0_bar;
//     return ListTile(
//       visualDensity: VisualDensity.compact,
//       leading: Icon(signalIcon),
//       title: Text(title),
//       subtitle: Text(accessPoint.capabilities),
//       onTap: () => showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text(title),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildInfo("BSSDI", accessPoint.bssid),
//               _buildInfo("Capability", accessPoint.capabilities),
//               _buildInfo("frequency", "${accessPoint.frequency}MHz"),
//               _buildInfo("level", accessPoint.level),
//               _buildInfo("standard", accessPoint.standard),
//               _buildInfo(
//                   "centerFrequency0", "${accessPoint.centerFrequency0}MHz"),
//               _buildInfo(
//                   "centerFrequency1", "${accessPoint.centerFrequency1}MHz"),
//               _buildInfo("channelWidth", accessPoint.channelWidth),
//               _buildInfo("isPasspoint", accessPoint.isPasspoint),
//               _buildInfo(
//                   "operatorFriendlyName", accessPoint.operatorFriendlyName),
//               _buildInfo("venueName", accessPoint.venueName),
//               _buildInfo("is80211mcResponder", accessPoint.is80211mcResponder),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

/// Show snackbar.
void kShowSnackBar(BuildContext context, String message) {
  if (kDebugMode) print(message);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}