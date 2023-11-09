import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:ledtest/helper_class.dart';
import 'package:ledtest/scan.dart';
class MapUtils {
  MapUtils._();
  static Future<void> openMap(double slat,double slon,double dlat, double dlon) async {
    String googleUrl =
        'https://www.google.com/maps/dir/?api=1&origin=$slat,$slon&destination=$dlat,$dlon&travelmode=driving&dir_action=navigate';
    AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: googleUrl,
        package: "com.google.android.apps.maps");
    intent.launch();
  }
}

class LocationCard extends StatelessWidget {
  final LocationData location;
  final VoidCallback onCardTap;
  final double slat,slon,dlat,dlon;

  LocationCard({required this.location, required this.onCardTap,required this.slat,required this.slon,required this.dlat,required this.dlon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardTap,
      child: Container(width: MediaQuery.of(context).size.width*0.7,
        child: Card(
          color: Colors.black,
          child: Column(crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Display location details here
              Text(location.location,style: TextStyle(color: Colors.white,fontSize: 18),),
              // Add a button
              location.chargeSpot==1?
              Text("Suggested Charging here!",style: TextStyle(color: Colors.greenAccent,fontSize: 18),):
              Text("Charger Available",style: TextStyle(color: Colors.white,fontSize: 18),),
              location.locId==1?
              Text("Home",style: TextStyle(color: Colors.white,fontSize: 18),):
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent
                  ),
                    onPressed: () {
                      // Handle button click
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext bs)=>scanpage()));
                    },
                    child: Text("Connect"),
                  ),
                  SizedBox(width: 10,),
                  ElevatedButton(style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent
                  ),
                    onPressed: () {
                      // Handle button click
                      MapUtils.openMap(slat,slon,dlat,dlon);
                    },
                    child: Text("Navigate"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
