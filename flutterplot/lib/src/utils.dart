import 'package:flutter/material.dart';

void debugLog(String message) {
    debugPrint('FlutterPlot: $message');
  }


class FlutterPlotException implements Exception {
  String cause;
  FlutterPlotException(this.cause);
}