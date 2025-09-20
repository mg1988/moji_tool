// ignore: file_names
import 'package:flutter/services.dart';

class Native{

  static callNative(String methName, Map<String,dynamic> args) async {
    const platform = MethodChannel('com.mg.voice/native');
    try {
      var result = await platform.invokeMethod(methName,args);
      return result;
    } on PlatformException catch (e) {
      print("Failed to navigate: ${e.message}");
      return "";
    }
  }
}