class Prevendas {
  String iD;
  String mATRICULATION;
  String vALOR;
  String qUANTIDADE;
  String dATA;
  String cLIENTE;
  String iDCLIENTE;

  Prevendas({this.iD, this.mATRICULATION, this.vALOR, this.qUANTIDADE, this.dATA, this.cLIENTE, this.iDCLIENTE});

  Prevendas.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    mATRICULATION = json['MATRICULATION'];
    vALOR = json['VALOR'];
    qUANTIDADE = json['QUANTIDADE'];
    dATA = json['DATA'];
    cLIENTE = json['CLIENTE'];
    iDCLIENTE = json['IDCLIENTE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.iD;
    data['MATRICULATION'] = this.mATRICULATION;
    data['VALOR'] = this.vALOR;
    data['QUANTIDADE'] = this.qUANTIDADE;
    data['DATA'] = this.dATA;
    data['CLIENTE'] = this.cLIENTE;
    data['IDCLIENTE'] = this.iDCLIENTE;
    return data;
  }
}