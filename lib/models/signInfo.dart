// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

class SignInfo {
  int lMemberID;
  String sName;
  int sKakaoID;
  String sMobile;
  String sEmailAddr;
  String sRegDate;
  String sUpDate;

  SignInfo({
    this.lMemberID=0,
    this.sName="",
    this.sKakaoID=0,
    this.sMobile="",
    this.sEmailAddr="",
    this.sRegDate="",
    this.sUpDate="",
  });

  factory SignInfo.fromJson(Map<String, dynamic> person)
  {
    return SignInfo(
      lMemberID: (person['lMemberID'] != null)
          ? int.parse(person['lMemberID'].toString().trim()) : 0,
      sKakaoID: (person['sKakaoID'] != null)
          ? int.parse(person['sKakaoID'].toString().trim()) : 0,
      sName: (person['sName']!=null) ? person['sName'].toString().trim():"",
      sMobile: (person['sMobile']!=null) ? person['sMobile'].toString().trim():"",
      sEmailAddr: (person['sEmailAddr']!=null) ? person['sEmailAddr'].toString().trim():"",
      sRegDate: (person['sRegDate']!=null) ? person['sRegDate'].toString().trim():"",
      sUpDate: (person['sUpDate']!=null) ? person['sUpDate'].toString().trim():"",
    );
  }

  @override
  String toString(){
    return 'SignInfo {'
        'lMemberID:$lMemberID, '
        'sKakaoID:$sKakaoID, '
        'sName:$sName, '
        'sEmailAddr:$sEmailAddr, '
        'sMobile:$sMobile, '
        'sRegDate:$sRegDate, '
        'sUpDate:$sUpDate, '
        '}';
  }
}
