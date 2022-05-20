import 'package:flutter/material.dart';
import 'package:avarias/models/userapi2.dart';
import 'package:requests/requests.dart';
import 'package:avarias/services/API.dart';
import 'dart:convert' as convert;

class CreatePresale extends StatefulWidget {
  const CreatePresale({ Key key }) : super(key: key);

  @override
  State<CreatePresale> createState() => _CreatePresaleState();
}

class _CreatePresaleState extends State<CreatePresale> {
  bool _preload = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: FutureBuilder<List<Clientes>>(
            future: _getClientes(),
            builder: (context, snapshot){
              _preload = false;
              if(snapshot.hasData){
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index){
                    Clientes clientes = snapshot.data[index];
                    return GestureDetector(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children:<Widget> [
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(clientes.nOME)
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }else if(snapshot.hasError){
                return Text(snapshot.error.toString());
              }
              return const Center(
                child: CircularProgressIndicator(),
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