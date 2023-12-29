// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:point/models/kItemNotify.dart';
import 'package:point/models/memberInfo.dart';
import 'package:point/models/signInfo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionData with ChangeNotifier {
  bool   bNotice;
  String IsSigned;
  String Token;
  String FirebaseToken;
  String? FireBaseTopic;
  String? FireBaseTopicSaved;
  String? NoticeId;
  SignInfo? signInfo;
  MemberInfo? memberInfo;
  List<ItemNotify> notifyItems;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  SessionData({
    this.bNotice = false,
    this.IsSigned = "N",
    this.Token = "",
    this.FirebaseToken = "",
    this.FireBaseTopic = "",
    this.FireBaseTopicSaved = "",
    this.NoticeId = "",
    this.signInfo,
    this.memberInfo,
    this.notifyItems = const[],
  });

  @override
  String toString(){
    return 'SessionData {'
        'IsSigned:$IsSigned, '
        'token:$Token, '
        'FirebaseToken:$FirebaseToken, '
        'FireBaseTopicSaved:$FireBaseTopicSaved, '
        'memberInfo:${memberInfo.toString()}, '
        'signInfo:${signInfo.toString()} '
        '}';
  }

  String getMemberGrade() {
    if(signInfo!.lMemberID == 0) {
      return "비회원";
    }
    return "일반회원";
  }

  bool isSigned() {
    return (IsSigned=="Y") ? true : false;
  }

  // 신규 로그인 처리
  Future<void> setLogin(SignInfo user, MemberInfo member) async {
    IsSigned   = "Y";
    signInfo   = user;
    memberInfo = member;
    await _storage.write(key: 'Token',   value: Token);
    notifyListeners();
  }

  Future<void> setLogout() async {
    Token = "";
    IsSigned = "N";
    await _storage.write(key: 'Token', value: Token);
    notifyListeners();
  }

  Future <void> setNoticeId(String noticeId) async {
    NoticeId = noticeId;
    await _storage.write(key: 'NoticeId', value: NoticeId);
  }

  Future <void> setFirebaseTopic(String topic) async {
    FireBaseTopicSaved = topic;
    await _storage.write(key: 'FireBaseTopicSaved', value: FireBaseTopicSaved);
  }

  Future <void> setFirebaseToken(String firebaseToken) async {
    if(FirebaseToken != firebaseToken) {
      FirebaseToken = firebaseToken;
      await _storage.write(key: 'FirebaseToken', value: FirebaseToken);
      notifyListeners();
    }
  }
  
  Future <void> loadData() async {
    Token = "";
    if(await _storage.containsKey(key:'Token')) {
      String? v = await _storage.read(key: 'Token');
      if(v!=null) {
        Token = v;
      }
    }

    if(await _storage.containsKey(key:'NoticeId')) {
      NoticeId = await _storage.read(key: 'NoticeId');
    }

    FirebaseToken = "";
    if(await _storage.containsKey(key:'FirebaseToken')) {
      String? t = await _storage.read(key: 'FirebaseToken');
      if(t != null) {
        FirebaseToken = t;
      }
    }

    if(await _storage.containsKey(key:'FireBaseTopicSaved')) {
      FireBaseTopicSaved = await _storage.read(key: 'FireBaseTopicSaved');
    }

    notifyListeners();
  }

}