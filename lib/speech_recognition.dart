import 'dart:async';

import 'dart:ui';
import 'package:flutter/services.dart';

typedef AvailabilityHandler = void Function(bool result);
typedef StringResultHandler = void Function(String text);

/// the channel to control the speech recognition
class SpeechRecognition {
  static const MethodChannel _channel = MethodChannel('speech_recognition');

  static final SpeechRecognition _speech = SpeechRecognition._internal();

  factory SpeechRecognition() => _speech;

  SpeechRecognition._internal() {
    _channel.setMethodCallHandler(_platformCallHandler);
  }

  late AvailabilityHandler availabilityHandler;
  late StringResultHandler currentLocaleHandler;
  late StringResultHandler recognitionResultHandler;
  late VoidCallback recognitionStartedHandler;
  late VoidCallback recognitionCompleteHandler;

  /// ask for speech  recognizer permission
  Future activate() => _channel.invokeMethod("speech.activate");

  /// start listening
  Future listen({String? locale}) =>
      _channel.invokeMethod("speech.listen", locale);

  Future cancel() => _channel.invokeMethod("speech.cancel");

  Future stop() => _channel.invokeMethod("speech.stop");

  Future _platformCallHandler(MethodCall call) async {
    print("_platformCallHandler call ${call.method} ${call.arguments}");
    switch (call.method) {
      case "speech.onSpeechAvailability":
        availabilityHandler(call.arguments);
        break;
      case "speech.onCurrentLocale":
        currentLocaleHandler(call.arguments);
        break;
      case "speech.onSpeech":
        recognitionResultHandler(call.arguments);
        break;
      case "speech.onRecognitionStarted":
        recognitionStartedHandler();
        break;
      case "speech.onRecognitionComplete":
        recognitionCompleteHandler();
        break;
      default:
        print('Unknowm method ${call.method} ');
    }
  }

  // define a method to handle availability / permission result
  void setAvailabilityHandler(AvailabilityHandler handler) =>
      availabilityHandler = handler;

  // define a method to handle recognition result
  void setRecognitionResultHandler(StringResultHandler handler) =>
      recognitionResultHandler = handler;

  // define a method to handle native call
  void setRecognitionStartedHandler(VoidCallback handler) =>
      recognitionStartedHandler = handler;

  // define a method to handle native call
  void setRecognitionCompleteHandler(VoidCallback handler) =>
      recognitionCompleteHandler = handler;

  void setCurrentLocaleHandler(StringResultHandler handler) =>
      currentLocaleHandler = handler;
}
