
// ignore_for_file: non_constant_identifier_names, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:point/models/memberInfo.dart';
import 'package:point/models/signInfo.dart';
import 'package:point/provider/sessionData.dart';
import 'package:point/remote/remote.dart';

Future <bool> SigningWithToken(BuildContext context, SessionData session) async {
  bool flag = false;

  //session.Token = "645|yJpDzsjvmUaYkQh8l3v1xuutMBWeTu1j0U5FxG3L";

  if(session.Token.isEmpty || session.Token.length<8) {
    return false;
  }

  print("session.Token:${session.Token}");

  await Remote.apiPost(
      context: context,
      session: session,
      method: "auth/token",
      params: {},
      onResult: (dynamic data) {
        if (kDebugMode) {
          var logger = Logger();
          logger.d(data);
        }

        if (data['status'] == "success") {
          MemberInfo member = MemberInfo();
          SignInfo sign = SignInfo.fromJson(data['data']['signInInfo']);
          if(sign.lMemberID != 0) {
            member = MemberInfo.fromJson(data['data']['userInfo']);
          }
          session.setLogin(sign, member);
          session.notifyListeners();
          flag = true;
        }
      },
      onError: (String error) {}
  );

  return flag;
}