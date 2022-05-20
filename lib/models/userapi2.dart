
import 'package:requests/requests.dart';
import 'package:avarias/services/API.dart';
import 'dart:convert' as convert;


class Produtos2 {
  String iDPREVENDA;
  String eAN;
  String dESCREDUZIDA;
  String eSTOQUE;
  String cODAV;
  String vALUNIT;
  String vALORTOTAL;

  Produtos2({this.iDPREVENDA, this.eAN, this.dESCREDUZIDA, this.eSTOQUE, this.cODAV, this.vALUNIT, this.vALORTOTAL});

  Produtos2.fromJson(Map<String, dynamic> json) {
    iDPREVENDA = json['IDPREVENDA'];
    eAN = json['EAN'];
    dESCREDUZIDA = json['DESCRICAO'];
    eSTOQUE = json['QUANT'];
    cODAV = json['CODIGO'];
    vALUNIT = json['VALORUNIT'];
    vALORTOTAL = json['VALORTOT'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['IDPREVENDA'] = this.iDPREVENDA;
    data['EAN'] = this.eAN;
    data['DESCRICAO'] = this.dESCREDUZIDA;
    data['QUANT'] = this.eSTOQUE;
    data['CODIGO'] = this.cODAV;
    data['VALORUNIT'] = this.vALUNIT;
    data['VALORTOT'] = this.vALORTOTAL;
    return data;
  }
  
}

class Clientes{
  String nOME;
  String iD;
  String eMAIL;
  String fONE;

  Clientes({this.nOME, this.eMAIL, this.fONE, this.iD});

  Clientes.fromJson(Map<String, dynamic> json){
    nOME = json['NOME'];
    eMAIL = json['EMAIL'];
    fONE = json['FONE'];
    iD = json['ID'];
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['NOME'] = this.nOME;
    data['EMAIL'] = this.eMAIL;
    data['FONE'] = this.fONE;
    data['ID'] = this.iD;
    return data;
  }
}

class UserApi {
  Future<Produtos2> getProductApi(String idcliente, String idprevenda, String cod) async {
    
    var res = await Requests.get('${API().urlApi}/api/prevenda/${idcliente}/${idprevenda}?codigo=$cod');
    print(res.statusCode);

    if(res.statusCode == 200){
      
      var jconv = convert.jsonDecode(res.content());
      print(jconv);
      print(jconv['itens'][0]);
      return Produtos2.fromJson(jconv['itens'][0]);
      
    }else{
      print("Algo deu errado!");
    }
    
  }

  // Future<Produtos2> verifyUser(String matriculation) async {
  //   var res = await Requests.get('http://10.86.201.48:8080/api/produtos/listar/${matriculation}');
  //   print(res.statusCode);
  //   if(res.statusCode == 200){
  //     var jconv = convert.jsonDecode(res.content());
  //     print(jconv);
  //     return jconv;
  //   }
  // }
}
