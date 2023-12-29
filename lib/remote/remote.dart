// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print
import 'package:point/provider/sessionData.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io' as io;
import 'dart:async';
import 'dart:convert';

import '../constant/constant.dart';

const bool _isDebug = true;
//const bool _isDebug = false;

//const apiUrl = "http://rc.maxidc.net:8080";
// http://211.175.164.202/api/taka/GoodsList

class Remote{
  static Future <void> upLoad({
    required String token,
    required String method, //"auth/thumnail"
    required Map<String,String> params,
    required String filePath,
    required Function(dynamic data) onResult,
    required Function(String error) onError
  }) async {

    Uri uri = Uri.parse("$URL_API/$method");

    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({ "Content-type": "multipart/form-data" });
    request.fields.addAll(params);

    // 파일 업로드
    if (filePath.isNotEmpty) {
        if (await io.File(filePath).exists()) {
          request.files.add(await http.MultipartFile.fromPath('file', filePath));
        }
    }

    if(_isDebug) {
      debugPrint(">>> apiUpLoad: $uri params=${params.toString()}");
    }

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        String data = await response.stream.bytesToString();
        int start = data.indexOf('{', 0);
        if (start > 0) {
          data = data.substring(start);
        }

        if(_isDebug) {
          debugPrint("<<< Rep: $data");
        }
        return onResult(jsonDecode(data));
      }
      debugPrint("<<< HTTP Error CODE:${response.statusCode}");
      return onError("HTTP Error CODE:${response.statusCode}");
    } catch (e) {
      debugPrint("<<< Network Error:$e");
      return onError("Network Error:$e");
    }
  }

  static Future <void> apiPost({
    required BuildContext context,
    required SessionData  session,
    required String method, //"auth/login"
    required Map<String,dynamic>? params,
    required Function(dynamic data) onResult,
    required Function(String error) onError
  }) async {

    Uri uri = Uri.parse("$URL_API/$method");
    if(_isDebug) {
      debugPrint(
          ">>> apiPost: $uri params=${params.toString()}");
    }

    try {
      final response = await http.post(
          uri,
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json',
            "Authorization": "Bearer ${session.Token}"},
          body: (params != null) ? json.encode(params) : ""
      );

      if (response.statusCode == 200) {
        String data = response.body;
        // if(_isDebug) {
        //   debugPrint(data);
        // }

        int start = data.indexOf('{', 0);
        if (start > 0) {
          data = data.substring(start);
        }
        // if(_isDebug) {
        //   debugPrint("<<< Rep: " + data);
        // }
        var json = jsonDecode(data);
        if(json['session'] != null && json['session']=="false") {
          session.setLogout();
          Navigator.of(context).popUntil((route) => route.isFirst);
          return;
        }
        return onResult(json);
      }

      debugPrint("<<< HTTP Error CODE:${response.statusCode}");
      return onError("HTTP Error CODE:${response.statusCode}");
    } catch (e) {
      debugPrint("<<< Network Error:$e");
      return onError("Network Error:$e");
    }
  }

  static Future <void> apiGet({
    required String token,
    required String method, //"auth/info"
    required Map<String,dynamic> params,
    required Function(dynamic data) onResult,
    required Function(String error) onError
  }) async {

    Uri uri = Uri.parse("$URL_API/$method");
    if(_isDebug) {
      debugPrint(">>> apiGet: $uri params=${params.toString()}");
    }

    try {
        final response = await http.get(uri,
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json',
            "Authorization": "Bearer$token"},
      );

      if (response.statusCode == 200) {
        String data = response.body;
        if(_isDebug) {
          debugPrint(data);
        }

        int start = data.indexOf('{', 0);
        if (start > 0) {
          data = data.substring(start);
        }
        if(_isDebug) {
          debugPrint("<<< Rep: $data");
        }
        return onResult(jsonDecode(data));
      }

      debugPrint("<<< HTTP Error CODE:${response.statusCode}");
      return onError("HTTP Error CODE:${response.statusCode}");
    } catch (e) {
      debugPrint("<<< Network Error:$e");
      return onError("Network Error:$e");
    }
  }
}