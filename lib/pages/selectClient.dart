import 'package:avarias/pages/prevenda_home.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:avarias/models/userapi2.dart';
import 'package:avarias/services/API.dart';

import 'package:requests/requests.dart';

import 'dart:convert' as convert;

class SelectClient extends StatefulWidget {
  const SelectClient({ Key key }) : super(key: key);

  @override
  State<SelectClient> createState() => _SelectClientState();
}

class _SelectClientState extends State<SelectClient> {

  bool _preload = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecione um Cliente',
        style: TextStyle(
          color: Colors.white
        ),)
      ),
      body: ModalProgressHUD(
        inAsyncCall: _preload,
        opacity: 0.7,
        child: FutureBuilder<List<Clientes>>(
          future: _getClientes(),
          builder: (context, snapshot){
            _preload = false;
            if(snapshot.hasData){
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index){
                  Clientes cliente = snapshot.data[index];
                  return GestureDetector(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children:<Widget> [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(cliente.nOME)
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ),
                    onTap: () async {
                        var dEL = 'false';
                        print(snapshot.data[index].iD);
                        var req = await Requests.post('${API().urlApi}/api/prevendas/adicionar/?delet=$dEL',
                        body: {"cliente": snapshot.data[index].iD},
                        timeoutSeconds: 30);
                        var res = convert.jsonDecode(req.content());
                        print("Status Code: ${req.statusCode}\nResposta: ${req.content()}");
                        if(res['erro'] != null){
                          showDialog(
                            context: context,
                            builder: (context){
                              return SingleChildScrollView(
                                child: AlertDialog(
                                  title: Column(
                                    children:<Widget> [
                                      Text('Há uma prevenda em andamento!')
                                    ],
                                  ),
                                  content: Container(
                                    child: Text('Existe uma prevenda em andamento. Deseja criar um novo processo?'),
                                  ),
                                  actions:<Widget> [
                                    FlatButton(
                                      child: Text('Criar nova prevenda'),
                                      onPressed: () async {
                                        dEL = 'true';
                                        var newReq = await Requests.post('${API().urlApi}/api/prevendas/adicionar/?delet=$dEL',
                                        body: {"cliente": snapshot.data[index].iD});
                                        print(newReq.statusCode);
                                        print(newReq.content());
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            transitionDuration: Duration(seconds: 2),
                                            pageBuilder: (_, __, ___) => PrevendaHome()
                                          )
                                        );
                                      },
                                    ),
                                    FlatButton(
                                      child: Text('Cancelar'),
                                      onPressed: () => Navigator.pop(context),
                                    )
                                  ],
                                )
                              );
                            }
                          );
                        }else{
                          Navigator.pop(context);
                        }
                      }
                  );
                },
              );
            }else if(snapshot.hasError){
              throw Exception('Ocorreu um erro');
            }
            return Center(
              child: const CircularProgressIndicator(),
            );
          },
        )
      )
    );
  }
  
  Future<List<Clientes>> _getClientes()async{
    var reqClientes = await Requests.get('${API().urlApi}/api/clientes');
    print(reqClientes.statusCode);
    if(reqClientes.statusCode == 200){
      var jsonReq = convert.jsonDecode(reqClientes.content().toString())['clientes'];
      print(jsonReq);
      List listOfClientes = jsonReq;
      return listOfClientes.map((json) => Clientes.fromJson(json)).toList();
    }else{
      throw Exception('Ocorreu um erro!');
    }
  }
}