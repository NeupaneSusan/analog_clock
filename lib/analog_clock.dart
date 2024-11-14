import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class AnalogClock extends StatefulWidget {
  const AnalogClock({super.key});

  @override
  State<AnalogClock> createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  ValueNotifier<DateTime> valueNotifier = ValueNotifier(DateTime.now());
  late Timer timer;
  TextStyle timeStyle =
      const TextStyle(fontSize: 10, fontWeight: FontWeight.w500);

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      valueNotifier.value = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Center(
        child: Card(
          shape: const CircleBorder(),
          elevation: 20,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: 48,
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                    ),
                    child: ValueListenableBuilder(
                        valueListenable: valueNotifier,
                        builder: (context, dataTime, child) {
                          String hrs = '${dataTime.hour}'.length == 2
                              ? dataTime.hour > 12
                                  ? '0${dataTime.hour - 12}'
                                  : '${dataTime.hour}'
                              : '0${dataTime.hour}';
                          String min = '${dataTime.minute}'.length == 2
                              ? '${dataTime.minute}'
                              : '0${dataTime.minute}';
                          String sec = '${dataTime.second}'.length == 2
                              ? '${dataTime.second}'
                              : '0${dataTime.second}';
                          String m = dataTime.hour < 12 ? 'Am' : 'Pm';
                          return Row(
                            children: [
                              SizedBox(
                                width: 14,
                                child: Text(
                                  hrs,
                                  style: timeStyle,
                                ),
                              ),
                              Text(
                                ':',
                                style: timeStyle,
                              ),
                              SizedBox(
                                width: 14,
                                child: Text(min, style: timeStyle),
                              ),
                              Text(
                                ':',
                                style: timeStyle,
                              ),
                              SizedBox(
                                width: 15,
                                child: Text(
                                  sec,
                                  style: timeStyle,
                                ),
                              ),
                              Text(
                                m,
                                style: timeStyle,
                              )
                            ],
                          );
                        }),
                  ),
                ),
              ),
              CustomPaint(
                size: const Size(200, 200),
                painter: CriclePainter(),
              ),
              CustomPaint(
                size: const Size(200, 200),
                painter: ClockDialPainter(),
              ),
              ValueListenableBuilder(
                valueListenable: valueNotifier,
                builder: (context, dateTime, child) {
                  return CustomPaint(
                    size: const Size(200, 200),
                    painter: ClockPainter(timeOfDay: dateTime),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CriclePainter extends CustomPainter {
  final paintV = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, paintV);
    canvas.drawCircle(center, 2, paintV);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class ClockDialPainter extends CustomPainter {
  final hourTickMarkLength = 10.0;
  final minuteTickMarkLength = 5.0;

  final hourTickMarkWidth = 3.0;
  final minuteTickMarkWidth = 1.5;

  final TextPainter textPainter = TextPainter(
    textAlign: TextAlign.center,
    textDirection: TextDirection.rtl,
  );
  TextStyle textStyle = const TextStyle(
    color: Colors.black,
    fontSize: 15.0,
  );
  final tickPaint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    double tickMarkLength;
    const angle = 2 * pi / 60;
    final radius = size.width / 2;
    canvas.save();

    // drawing
    canvas.translate(radius, radius);
    for (var i = 0; i < 60; i++) {
      tickMarkLength = i % 5 == 0 ? hourTickMarkLength : minuteTickMarkLength;
      tickPaint.strokeWidth =
          i % 5 == 0 ? hourTickMarkWidth : minuteTickMarkWidth;
      canvas.drawLine(Offset(0.0, -radius),
          Offset(0.0, -radius + tickMarkLength), tickPaint);

      if (i % 5 == 0) {
        canvas.save();
        canvas.translate(0.0, -radius + 20.0);
        textPainter.text = TextSpan(
          text: i ~/ 5 == 0 ? '12' : '${i ~/ 5}',
          style: textStyle,
        );

        canvas.rotate(-angle * i);

        textPainter.layout();

        textPainter.paint(canvas,
            Offset(-(textPainter.width / 2), -(textPainter.height / 2)));

        canvas.restore();
      }

      canvas.rotate(angle);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class ClockPainter extends CustomPainter {
  final DateTime timeOfDay;
  ClockPainter({required this.timeOfDay});

  @override
  void paint(Canvas canvas, Size size) {
    final paintSecond = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;

    final paintMin = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round;

    final paintHrs = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4
      ..strokeJoin = StrokeJoin.round;

    double secRad = ((pi / 2) - (pi / 30) * timeOfDay.second) % (2 * pi);
    double minRad = ((pi / 2) - (pi / 30) * timeOfDay.minute) % (2 * pi);
    double hourRad = ((pi / 2) - (pi / 6) * timeOfDay.hour) % (2 * pi);

    double centerX = size.width / 2;
    double centerY = size.height / 2;
    Offset center = Offset(centerX, centerY);
    double radius = min(centerX, centerY);

    double secHeight = radius / 1.5;
    double minHeight = radius / 1.8;
    double hoursHeight = radius / 2 - 10;

    Offset seconds = Offset(
        centerX + secHeight * cos(secRad), centerY - secHeight * sin(secRad));
    Offset minutes = Offset(
        centerX + cos(minRad) * minHeight, centerY - sin(minRad) * minHeight);
    Offset hours = Offset(centerX + cos(hourRad) * hoursHeight,
        centerY - sin(hourRad) * hoursHeight);
    canvas.drawLine(center, seconds, paintSecond);
    canvas.drawLine(center, minutes, paintMin);
    canvas.drawLine(center, hours, paintHrs);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
