import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:ledtest/Welcome.dart';
import 'package:http/http.dart' as http;
class cnttime extends StatefulWidget {
  final int duration;
  const cnttime({super.key,required this.duration});

  @override
  State<cnttime> createState() => _cnttimeState();
}

class _cnttimeState extends State<cnttime> {
  double h(double height) {
    return MediaQuery.of(context).size.height * height;
  }

  double w(double width) {
    return MediaQuery.of(context).size.width * width;
  }
  CountDownController _controller = CountDownController();
  Timer? countdownTimer;
  Duration myDuration = Duration();
  bool charging=false;
  int cnt=0,tcnt=0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _duration = widget.duration;
    myDuration = Duration(minutes: widget.duration);
    log("${myDuration.inSeconds}");
    startTimer();
  }

  void setCountDown() {
    final reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer?.cancel();
        setState(() {
          charging=false;
          cnt=0;
          tcnt=0;
        });
        log("$charging");
      } else {
        myDuration = Duration(seconds: seconds);
        setState(() {
          cnt=myDuration.inSeconds;
        });
        log("$cnt");
      }
    });
  }
  Future<void> startCharging() async {
    // You can add your own validation logic here
      // Send an API request to start charging
      final response = await http.get(
        Uri.parse('http://192.168.4.1:80/relay/on'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          charging = true;
        });
        print("Charging started");
      }
  }
  Future<void> stopCharging() async {
    // Send an API request to stop charging
    final response = await http.get(
      Uri.parse('http://192.168.4.1:80/relay/off'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        charging = false;
      });
    }
  }

  void startTimer() {
    setState(() {
      charging=true;
      tcnt=widget.duration*60;
    });
    startCharging();
    log("$charging");
    countdownTimer =
        Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }

  void stoptimer() {
    setState(() {
      charging=false;
    });
    stopCharging();
    log("$charging");
    countdownTimer?.cancel();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1B1D20),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 70),
              Center(
                child: Container(
                  padding: EdgeInsets.all(12),
                  // margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    "Congratulations, you've added Green miles🍀",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade600),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: Column(
                  children: [
                    Center(
                      child: CircularCountDownTimer(
                        duration: widget.duration * 60,
                        controller: _controller,
                        width: MediaQuery.of(context).size.width / 2,
                        height: MediaQuery.of(context).size.height / 2,
                        ringColor: Colors.grey[400]!,
                        ringGradient:const LinearGradient(
                            colors: [Colors.white10, Colors.white70]),
                        fillColor: Colors.blue,
                        fillGradient: LinearGradient(colors: [
                          Colors.blue.shade300,
                          Colors.blue.shade900
                        ]),
                        backgroundColor: Colors.grey[500],
                        backgroundGradient: LinearGradient(colors: [
                          Colors.grey.shade900,
                          Colors.grey.shade500
                        ]),
                        strokeWidth: 20.0,
                        strokeCap: StrokeCap.round,
                        textStyle: const TextStyle(
                            fontSize: 33.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        // textFormat: CountdownTextFormat.MM_SS,
                        isTimerTextShown: true,
                        isReverse: false,
                        onComplete: () {
                          debugPrint('Countdown Ended');
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => Welcome()));
                        },
                      ),
                    ),
                    //   SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.flash_on,
                          size: 30,
                          color: Colors.blue,
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Text(
                          "Charging",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                    //SizedBox(height: 5,),
                  ],
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Container(
                  padding: EdgeInsets.all(15),
                  // height: 130,
                  // width:MediaQuery.of(context).size.width ,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10.0),
                        topLeft: Radius.circular(10.0)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Docket",
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                primary: Colors.red.shade900,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 15),
                                // minimumSize: Size(50,20 ),
                              ),
                              child: const Text(
                                "Stop ",
                                style: TextStyle(
                                    fontSize: 15, color: Colors.white),
                              ),
                              onPressed: () async {
                                _controller.pause();
                                stoptimer();
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Welcome()));
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      //bottomNavigationBar: bottbar(),
    );
  }
}


