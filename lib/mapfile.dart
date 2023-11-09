import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ledtest/helper_class.dart';
import 'package:ledtest/location_card.dart';
import 'dart:async';
import 'dart:convert';
import 'package:mapmyindia_gl/mapmyindia_gl.dart';

class Mappg extends StatefulWidget {
  final List<LocationData> locationList;
  final List<ChargerData> chargerList;
  const Mappg({super.key, required this.locationList,required this.chargerList});

  @override
  State<Mappg> createState() => _MappgState();
}

class _MappgState extends State<Mappg> {
  List<List<double>> coordinates=[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    MapmyIndiaAccountManager.setMapSDKKey("57a26e33f01c196b3dcae40dfcbe8631");
    MapmyIndiaAccountManager.setRestAPIKey("57a26e33f01c196b3dcae40dfcbe8631");
    MapmyIndiaAccountManager.setAtlasClientId("33OkryzDZsKRfz_CJzyYwvQx5uRB2HtzzYFkL47EiEClL4_q1woUw1JfOcqlX8EOCnLoY2w5zQxHBAs_Arlzvg==");
    MapmyIndiaAccountManager.setAtlasClientSecret("lrFxI-iSEg_xZ0HRFEgPqubZD8z5Kc3j7ZC_0XlFvQPLwEXfdNlPnGzE7xXE20dI-EwYId4qkX9nsXypIHuiBnfj9SWL_prF");
    lat=widget.locationList.first.lat;
    lon=widget.locationList.first.lon;
    coordinates = widget.locationList.map((location) {
      return [location.lon, location.lat];
    }).toList();
    setMark();
    getDir();
  }
  /// Adds an asset image to the currently displayed style
  Future<void> addImageFromAsset(String name, String assetName) async {
    final ByteData bytes = await rootBundle.load(assetName);
    final Uint8List list = bytes.buffer.asUint8List();
    return _controller!.addImage(name, list);
  }
  Future<void> getDir() async {
    final List<LatLng> waypoints =widget.locationList
        .sublist(1, widget.locationList.length - 1) // Exclude the first and last entries
        .map((location) {
      return LatLng(location.lat, location.lon); // Create LatLng objects
    })
        .toList();
  }
  void moveCameraToLocation(LocationData location) {
    // Use Flutter's map controller to move the camera to the specified lat and lon
    _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(
            LatLng(location.lat,location.lon), 14));
    }

  Future<void> setMark() async {
    widget.chargerList.forEach((charger) {
      widget.locationList.forEach((loc) async {
        if(charger.location!=loc.location){
          await addImageFromAsset("icon", "assets/location.png");
          Symbol symbol = await _controller!.addSymbol(SymbolOptions(geometry: LatLng(charger.lat,charger.lon), iconImage: "icon"));
        }
      });
    });
    widget.locationList.forEach((element) async {
      await addImageFromAsset("icon", "assets/custmarker.png");
      Symbol symbol = await _controller!.addSymbol(SymbolOptions(geometry: LatLng(element.lat,element.lon), iconImage: "icon"));
    });
    final Map<String, dynamic> polylineFeature = {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "geometry": {
            "type": "LineString",
            "coordinates": coordinates,
          },
        }
      ]
    };

    await _controller!.addSource("gradient-line-source-id",
        GeojsonSourceProperties(data: polylineFeature, lineMetrics: true, buffer: 2.0));

    await _controller!.addLineLayer(
        "gradient-line-source-id",
        "gradient-line-layer-id",
        LineLayerProperties(
            lineGradient: [
              Expressions.interpolate,
              ['linear'],
              [Expressions.lineProgress],
              0,
              "#3dd2d0",
              1,
              "#00FF00"
            ],
            lineWidth: 4.0));
  }
  double lat=0.0,lon=0.0;
  MapmyIndiaMapController? _controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chargers'),
        titleTextStyle: TextStyle(color: Colors.white,fontSize: 20),
        centerTitle: true,
        backgroundColor: Colors.brown,
      ),
      body: Builder(builder: (BuildContext context) {
        return Stack(
          children:[
            MapmyIndiaMap(initialCameraPosition:CameraPosition(target: LatLng(lat, lon),zoom: 14),
              onMapCreated: (map) =>
              {
                _controller = map,
              },
              onStyleLoadedCallback: () => {
                setMark()
              },
              onMapClick: (point, latLng) => {
                debugPrint("${latLng.latitude},${latLng.longitude}")
              },
            ),
            Positioned(
              bottom: 30,
              left: 10,
              right: 10,
              child:Container(
                height:MediaQuery.of(context).size.height*0.2,
                width: MediaQuery.of(context).size.width*0.5,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,

                itemCount: widget.locationList.length,
                itemBuilder: (context, index) {
                  return LocationCard(
                    location: widget.locationList[index],
                    onCardTap: () {
                      // Call your function to move the camera to the selected location's lat and lon
                      moveCameraToLocation(widget.locationList[index]);
                    },
                    slat: widget.locationList.first.lat,
                    slon: widget.locationList.first.lon,
                    dlat: widget.locationList[index].lat,
                    dlon: widget.locationList[index].lon,
                  );
                },
            ),
              ),
            ),
          ]
        );
      }),
    );
  }
}