import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:avarias/models/user.dart';
import 'package:avarias/services/API.dart';
import 'package:avarias/widgets/dropdownField.dart';
import 'package:avarias/widgets/inputField.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
// recent
import 'package:requests/requests.dart';
// ========
import 'package:toast/toast.dart';
import 'package:avarias/models/userapi.dart';

import 'package:avarias/models/prevendas.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _matricula = TextEditingController();
  User user = User();
  Prevendas prevenda = Prevendas();
  Produtos produtos = Produtos();
  String valueDropDown = '';
  List<dynamic> dataDropDown = List();
  bool isAttacked = false;

  void _getOrganizations() async {
    //var response = await http.get('${API().urlBase}/api/v1/organizations/');
    print("Iniciando...");
    try{
      print('${API().urlBase}');
      var response = await Requests.get('${API().urlBase}/api/v1/organizations/', verify: true);
      response.raiseForStatus();
      print("response.statusCode");
      print(response.statusCode);
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.content());
        for (var item in jsonResponse['data']) {
          dataDropDown.add({
            "display": '${item['number']} - ${item['business_name']}',
            "value": item['number'].toString(),
          });
        }
        setState(() {});
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    }catch(e){
      print("----");
      print(e);
      Toast.show("A aplicação não funcionará perfeitamente, verifique sua conexão e reinicie a aplicação.",
      context,
      duration: 5
      );
      
      Future.delayed(Duration(seconds: 6), (){
        SystemNavigator.pop();
      });
    }
    
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  //Definindo a largura e a altura do container baseado na tela em questão
                  width: MediaQuery.of(context).size.width,
                  //Dividindo o tamanho da tela por dois, visando que a tela terá dois container principais
                  height: MediaQuery.of(context).size.height / 3.5,
                  child: Center(
                    child: Hero(
                      tag: 'imageHero',
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 200,
                      ),
                    ),
                  ),
                ),
                ClipPath(
                  clipper: WaveClipperTwo(reverse: true),
                  child: Container(
                    //Definindo a largura e a altura do container baseado na tela em questão
                    width: MediaQuery.of(context).size.width,
                    //Dividindo o tamanho da tela por dois, visando que a tela terá dois container principais
                    height: MediaQuery.of(context).size.height / 1.3,
                    color: Theme.of(context).primaryColorDark,
                    child: Center(
                        child: Column(
                      //Alinha o conteudo no centro
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10, bottom: 10, left: 20, right: 20),
                          child: Container(
                            height: 66,
                            padding: EdgeInsets.symmetric(vertical: 3),
                            decoration: new BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  new BorderRadius.all(Radius.circular(4.0)),
                            ),
                            child: InputField(
                              controller: _matricula,
                              label: 'Matrícula',
                              typeInput: TextInputType.number,
                              obscure: false,
                              stateField: true,
                              //colorInput: Theme.of(context).primaryColorDark,
                              noDecoration: true,
                              formats: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')),
                              ],
                              validator: (value) {
                                print("THIS IS MATR.: ${value}");

                                if (value.isEmpty) {
                                  return 'Digite sua matrícula';
                                }
                                return null;
                              },
                              // onFieldSubmitted: (value) {
                              //   if (_formKey.currentState.validate()) {
                              //     user.matriculation = value;
                              //     Navigator.pushReplacementNamed(
                              //         context, '/home',
                              //         arguments: user);
                              //   }
                              // },
                            ),
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.only(
                        //       top: 10, bottom: 10, left: 20, right: 20),
                        //   child: Container(
                        //     width: screenWidth,
                        //     height: 66,
                        //     padding: EdgeInsets.only(left: 10),
                        //     decoration: new BoxDecoration(
                        //       color: Colors.white,
                        //       borderRadius:
                        //           new BorderRadius.all(Radius.circular(4.0)),
                        //     ),
                        //     child: Row(
                        //       children: [
                        //         Expanded(
                        //           child: Column(
                        //             crossAxisAlignment: CrossAxisAlignment.start,
                        //             mainAxisAlignment: MainAxisAlignment.center,
                        //             children: [
                        //               Text('Usar preço atacado', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),)
                        //             ],
                        //           ),
                        //         ),
                        //         Container(
                        //           width: 60,
                        //           child: Switch(
                        //             value: isAttacked,
                        //             onChanged: (value) {
                        //               setState(() {
                        //                 isAttacked = value;
                        //                 if (value) {
                        //                   user.priceType = 3;
                        //                   Toast.show(
                        //                   "Preço Atacado selecionado",
                        //                   context,
                        //                   duration: Toast.LENGTH_LONG,
                        //                   gravity: Toast.BOTTOM);
                        //                 } else {
                        //                   user.priceType = 1;
                        //                   Toast.show(
                        //                   "Preço Atacarejo Selecionado",
                        //                   context,
                        //                   duration: Toast.LENGTH_LONG,
                        //                   gravity: Toast.BOTTOM);
                        //                 }
                        //               });
                        //             },
                        //             activeTrackColor: Colors.orange[200],
                        //             activeColor: Colors.orange[600],
                        //           ),
                        //         )
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10, bottom: 0, left: 20, right: 20),
                          child: Container(
                            width: screenWidth,
                            height: 60,
                            decoration: new BoxDecoration(
                              color: Colors.orange[600],
                              borderRadius:
                                  new BorderRadius.all(Radius.circular(4.0)),
                            ),
                            child: FlatButton(
                              child: const Text(
                                'Balanço',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  user.matriculation = _matricula.text;
                                  user.acaoController = 'balanco';
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/home',
                                    arguments: user,
                                  );
                                  _matricula.clear();
                                }
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10, bottom: 0, left: 20, right: 20),
                          child: Container(
                            width: screenWidth,
                            height: 60,
                            decoration: new BoxDecoration(
                              color: Colors.orange[600],
                              borderRadius:
                                  new BorderRadius.all(Radius.circular(4.0)),
                            ),
                            child: RawMaterialButton(
                              child: const Text(
                                'Pré Venda',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  prevenda.mATRICULATION = _matricula.text;
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/prevenda',
                                    arguments: prevenda,
                                  );
                                  _matricula.clear();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    )),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
