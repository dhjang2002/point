// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

class MemberInfo {
  int lStoreId;

  String sStoreName;
  String sState;
  String sName;
  String sGender;
  String sMobile;
  double rNowBonus;
  double rTotalBonus;

  MemberInfo({
    this.lStoreId=0,
    this.sStoreName="",
    this.sState="",
    this.sName="",
    this.sGender="",
    this.sMobile="",
    this.rNowBonus=0.0,
    this.rTotalBonus=0.0,
  });

  factory MemberInfo.fromJson(Map<String, dynamic> person)
  {
    //dynamic person = jdata['employee'];
    return MemberInfo(
      lStoreId: (person['lStoreId']!=null)
          ? int.parse(person['lStoreId'].toString().trim()) : 0,
      sStoreName: (person['sStoreName']!=null) ? person['sStoreName'].toString().trim():"",
      sState: (person['sState']!=null) ? person['sState'].toString().trim():"",
      sName: (person['sName']!=null) ? person['sName'].toString().trim():"",
      sGender: (person['sGender']!=null) ? person['sGender'].toString().trim():"",
      sMobile: (person['sMobile']!=null) ? person['sMobile'].toString().trim():"",
      rNowBonus: (person['rNowBonus']!=null)
          ? double.parse(person['rNowBonus'].toString().trim()) : 0,
      rTotalBonus: (person['rTotalBonus']!=null)
          ? double.parse(person['rTotalBonus'].toString().trim()) : 0,
    );
  }

  @override
  String toString(){
    return 'MemberInfo {'
        'lStoreId:$lStoreId, '
        'sStoreName:$sStoreName, '
        'sState:$sState, '
        'sName:$sName, '
        'sGender:$sGender, '
        'sMobile:$sMobile '
        'rNowBonus:$rNowBonus '
        'rTotalBonus:$rTotalBonus '
        '}';
  }
}
