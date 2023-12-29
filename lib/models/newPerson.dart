// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class NewPerson {
  int id;
  String? name;
  String? mobile;
  String? email;

  NewPerson({
    this.id = 0,
    this.name="",
    this.mobile="",
    this.email="",
  });

  factory NewPerson.fromJson(Map<String, dynamic> data)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(data);
    }

    var kakao_account = data['kakao_account'];
    return NewPerson(
      id:(data['id']!=null) ? int.parse(data['id'].toString().trim()) : 0,
      name: (kakao_account['profile']['nickname']!=null) ?
                kakao_account['profile']['nickname']:"",
      email: (kakao_account['email'] != null) ? kakao_account['email'] : "",
    );
  }

  @override
  String toString(){
    return 'NewPerson {'
        'id:$id, '
        'name:$name, '
        'mobile:$mobile, '
        'email:$email }';
  }
}
