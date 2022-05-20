import 'package:requests/requests.dart';
import 'package:avarias/services/API.dart';
import 'dart:convert' as convert;


class Produtos {
  String mATRICULATION;
  String eAN;
  String dESCREDUZIDA;
  String eSTOQUE;
  String sEQPRODUTOS;
  String cODAV;

  Produtos({this.mATRICULATION, this.eAN, this.dESCREDUZIDA, this.eSTOQUE, this.sEQPRODUTOS, this.cODAV});

  Produtos.fromJson(Map<String, dynamic> json) {
    mATRICULATION = json['MATRICULATION'];
    eAN = json['EAN'];
    dESCREDUZIDA = json['DESCREDUZIDA'];
    eSTOQUE = json['ESTOQUE'];
    sEQPRODUTOS = json['SEQPRODUTO'];
    cODAV = json['CODIGO'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MATRICULATION'] = this.mATRICULATION;
    data['EAN'] = this.eAN;
    data['DESCREDUZIDA'] = this.dESCREDUZIDA;
    data['ESTOQUE'] = this.eSTOQUE;
    data['SEQPRODUTO'] = this.sEQPRODUTOS;
    data['CODIGO'] = this.cODAV;
    return data;
  }
  
}

class UserApi {
  Future<Produtos> getProductApi(String barCode, String matricula) async {
    print(barCode);
    print(matricula);
    var res = await Requests.get('${API().urlApi}/api/produtos/listar/$matricula?ean=${barCode}');
    print(res.statusCode);

    if(res.statusCode == 200){
      
      var jconv = convert.jsonDecode(res.content());
      return Produtos.fromJson(jconv[0]);
    }else{
      print("Algo deu errado!");
    }
    
  }

  // Future<Produtos> verifyUser(String matriculation) async {
  //   var res = await Requests.get('http://10.86.201.48:8080/api/produtos/listar/${matriculation}');
  //   print(res.statusCode);
  //   if(res.statusCode == 200){
  //     var jconv = convert.jsonDecode(res.content());
  //     print(jconv);
  //     return jconv;
  //   }
  // }
}
