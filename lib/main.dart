import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock/wakelock.dart';
import 'package:wear/wear.dart';

void main() {
  runApp(const MyApp());
}

enum TimerState { running, paused, finish, start }

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final CountDownController _controller = CountDownController();

  final int totalTime = 60;

  TimerState timerState = TimerState.start;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: WatchShape(
            builder: (BuildContext context, WearShape shape, Widget? child) {
              return Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: InkWell(
                      onTap: () {
                        showInfo(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.info,
                          size: 26,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Center(
                      child: GestureDetector(
                    onDoubleTap: () {
                      timerStart();
                    },
                    onTap: () {
                      if (timerState == TimerState.paused) {
                        Wakelock.enable();
                        _controller.resume();
                        timerState = TimerState.running;
                      } else if (timerState == TimerState.running) {
                        stopTimer();
                        timerState = TimerState.paused;
                      } else if (timerState == TimerState.start ||
                          timerState == TimerState.finish) {
                        timerStart();
                        timerState = TimerState.running;
                      }
                    },
                    child: SizedBox(
                      height: 200,
                      child: CircularCountDownTimer(
                        duration: totalTime,
                        initialDuration: 0,
                        controller: _controller,
                        width: MediaQuery.of(context).size.width / 2,
                        height: MediaQuery.of(context).size.height / 2,
                        ringColor: const Color(0xFF706565),
                        ringGradient: null,
                        fillColor: Colors.white,
                        fillGradient: null,
                        backgroundColor: Colors.black,
                        backgroundGradient: null,
                        strokeWidth: 20.0,
                        strokeCap: StrokeCap.round,
                        textStyle: const TextStyle(
                            fontSize: 33.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        textFormat: CountdownTextFormat.S,
                        isReverse: true,
                        isReverseAnimation: false,
                        isTimerTextShown: true,
                        autoStart: false,
                        onStart: () {
                          timerState = TimerState.running;
                        },
                        onComplete: () async {
                          timerState = TimerState.finish;
                          if (await Vibration.hasVibrator() ?? false) {
                            Vibration.vibrate();
                          } else {
                            FlutterBeep.beep();
                          }
                          timerStart();
                        },
                      ),
                    ),
                  )),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  timerStart() {
    Wakelock.enable();
    _controller.start();
  }

  showInfo(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: WatchShape(
                builder:
                    (BuildContext context2, WearShape shape, Widget? child) {
                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.arrow_back_ios_outlined,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 20, 10, 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  "assets/next.png",
                                  height: 20,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Tap for start/pause",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  "assets/next.png",
                                  height: 20,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "double tap for restart",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        });
  }

  stopTimer() {
    _controller.pause();
    Wakelock.disable();
  }
}
