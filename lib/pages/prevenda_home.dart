import 'package:avarias/models/customPopupMenu.dart';
import 'package:avarias/pages/selectClient.dart';
import 'package:toast/toast.dart';
import 'package:avarias/pages/unicUserHome.dart';
import 'package:avarias/services/API.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:avarias/models/prevendas.dart';
import 'package:avarias/models/userapi2.dart';
import 'package:requests/requests.dart';
import 'dart:convert' as convert;

class PrevendaHome extends StatefulWidget {
  const PrevendaHome({ Key key }) : super(key: key);

  @override
  State<PrevendaHome> createState() => _PrevendaHomeState();
}

List<CustomPopupMenu> choices = [
  CustomPopupMenu(id: 'exit', title: 'Sair do APP', icon: Icons.exit_to_app),
  CustomPopupMenu(id: 'create', title: 'Nova Prevenda', icon: Icons.add_circle_outline_sharp)
];

class _PrevendaHomeState extends State<PrevendaHome> {
  Prevendas prevenda = Prevendas();
  Future<List<Prevendas>> usersApi;
  Clientes cliente = Clientes();
  String searchText = '';

  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameClient = TextEditingController();
  TextEditingController _emailClient = TextEditingController();
  TextEditingController _phoneClient = TextEditingController();
  
  @override
  void initState(){
    super.initState();
    usersApi = _getUsersList();
  }

  bool _preload = true;
  @override
  Widget build(BuildContext context) {
    prevenda = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text('Prevendas',
        style: TextStyle(
          color: Colors.white
        ),),
        backgroundColor: Theme.of(context).primaryColorDark,
        actions: [
          PopupMenuButton<CustomPopupMenu>(
            elevation: 3.2,
            onSelected: _selectOptionMenu,
            itemBuilder: (BuildContext context){
              return choices.map((CustomPopupMenu choice){
                return PopupMenuItem(
                  value: choice,
                  enabled: true,
                  child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(choice.icon, color: Colors.black)),
                    Text(choice.title)
                  ],
                )
                );
              }).toList();
            }
          )
        ],
      ),
      backgroundColor: Colors.grey[300],
      body: RefreshIndicator(
        onRefresh: _getUsersList,
        child: ModalProgressHUD(
          inAsyncCall: _preload,
          color: Colors.white,
          opacity: 0.7,
          child: FutureBuilder<List<Prevendas>>(
            future: _getUsersList(),
            builder: (context, snapshot){
              _preload = false;
              if(snapshot.hasData){
                return snapshot.data.length > 0 ? ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index){
                    Prevendas usersApi = snapshot.data[index];
                    return GestureDetector(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children:<Widget> [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(usersApi.cLIENTE,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColorDark
                                    ),
                                    ),
                                    Divider(),
                                    Row(
                                      children: [
                                        Text("Pré-Venda: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColorDark
                                        )),
                                        Text(usersApi.iD,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold
                                        )),
                                        
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text("Data: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColorDark
                                        )),
                                        Text(usersApi.dATA,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold
                                        )),
                                        
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text("Quantidade: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColorDark
                                        )),
                                        Text(usersApi.qUANTIDADE.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold
                                        ),)
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text('Valor: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColorDark
                                        ),),
                                        Text(usersApi.vALOR,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold
                                        ),)
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          )
                        ),
                      ),
                      onTap: () async {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: Duration(seconds: 2),
                            pageBuilder:(_, __, ___) => UserHome(
                              nome: snapshot.data[index].cLIENTE,
                              idcliente: snapshot.data[index].iDCLIENTE,
                              id: snapshot.data[index].iD,
                            )
                          )
                        );
                      }
                    );
                  }
                )
                :
                Center(
                  child: Text('Sem nenhuma prevenda em andamento!',
                  style: TextStyle( fontWeight: FontWeight.bold, color: Colors.indigo),
                  )
                );
              }else if(snapshot.hasError){
                return Text(snapshot.error.toString());
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          )
        )
      )
      
    );
  }

  Future<List<Prevendas>> _getUsersList() async {
    setState(() {
      _preload = false;
    });
    var request = await Requests.get('${API().urlApi}/api/prevendas', verify: false);
    print(request.statusCode);
    if(request.statusCode == 200){
      var req = convert.jsonDecode(request.content());
      var jsonReq = req['prevendas'];
      List listOfUsers = jsonReq;
      print(listOfUsers);
      return listOfUsers.map((json) => Prevendas.fromJson(json)).toList();
    }else{
      throw Exception('Ocorreu um erro');
    }
  }

  void _dialogExit(){
    showDialog(
        context: context,
        builder: (context) {
          return SingleChildScrollView(
              child: AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Sair da Aplicação?",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColorDark),
                )
              ],
            ),
            content: Container(
              child: Text("Deseja sair da aplicação e voltar ao login?",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColorDark)),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("SAIR"),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
              FlatButton(
                child: Text("CANCELAR"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ));
        });
  }

  Future<List<Clientes>> _getClientes()async{
    var reqClientes = await Requests.get('${API().urlApi}/api/clientes');
    print(reqClientes.statusCode);
    if(reqClientes.statusCode == 200){
      var jsonReq = convert.jsonDecode(reqClientes.content().toString())['clientes'];
      print(jsonReq);
      List listOfClientes = jsonReq;
      return listOfClientes.map((json) => Clientes.fromJson(json)).where((c){
        final nome = c.nOME.toLowerCase();
        final search = searchText.toLowerCase();
        return nome.contains(search);
      }).toList();
    }else{
      throw Exception('Ocorreu um erro!');
    }
  }

  void _dialogNewPrevenda(BuildContext context) async {
    var dEL = 'false';
    showDialog(
      context: context,
      builder: (context){
        return SingleChildScrollView(
          child: AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Selecione um Cliente'),
                Divider(),
                TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search),
                    hintText: 'Pesquisar',
                    border: InputBorder.none
                  ),
                  onChanged: (texxt){
                    setState(() {
                      searchText = texxt;
                    });
                  },
                ),
                Center(
                  child: TextButton(onPressed: (){
                  Navigator.pop(context);
                  setState(() {
                    _dialogNewPrevenda(context);
                  });
                }, child: Text('Filtrar', style: TextStyle(color: Colors.white),),
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blue)),
                ),
                ),
                Divider()
              ],
            ),
            content: FutureBuilder<List<Clientes>>(
            future: _getClientes(),
            builder: (context, snapshot){
              _preload = false;
              if(snapshot.hasData){
                return snapshot.data.length > 0 ? ListView.builder(
                  shrinkWrap:true,
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
                      onTap: () async {
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
                                        setState(() {});
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                        Toast.show('Ação realizada com sucesso!', context);
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
                          setState(() {
                          });
                        }
                      }
                    );
                  },
                ) :
                Center(
                  child: Text('Ops... Nenhum cliente cadastrado')
                );
              }else if(snapshot.hasError){
                return Text(snapshot.error.toString());
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }, 
          ),
          actions:<Widget> [
            FlatButton(onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context){
                  return SingleChildScrollView(
                    child: Form(
                    key: _formKey,
                    child: AlertDialog(
                      title: Column(
                        children:<Widget> [
                          Text('Adicionar cliente'),
                        ],
                      ),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: TextFormField(
                              autofocus: true,
                              textInputAction: TextInputAction.next,
                              controller: _nameClient,
                              validator: (value){
                                if(value.isEmpty){
                                  return 'Informe o nome';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                                hintText: "Nome"
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: TextFormField(
                              controller: _emailClient,
                              textInputAction: TextInputAction.next,
                              validator: (value){
                                if(value.isEmpty){
                                  return 'Informe o e-mail';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                                hintText: "E-mail"
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              // inputFormatters: [
                              //   FilteringTextInputFormatter.deny(RegExp(r'[0-9]{3}-[0-9]{6}'))
                              // ],
                              controller: _phoneClient,
                              validator: (value){
                                if(value.isEmpty){
                                  return 'Informe o número';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                                hintText: "Contato"
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: RawMaterialButton(
                              onPressed: (){
                                if(_formKey.currentState.validate()){
                                  setState(() {
                                    _preload = true;
                                  });
                                  _cadastrarClient();
                                }
                              },
                              fillColor: Colors.blue[700],
                              child: Text('Cadastrar',
                              style: TextStyle(color: Colors.white),),
                              ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 5),
                                child: RawMaterialButton(onPressed: (){
                                Navigator.pop(context);
                              },
                              fillColor: Colors.blue[700],
                              child: Text('Voltar',
                              style: TextStyle(color: Colors.white),),
                              )
                              )
                            ],
                          ),
                        ]
                      )
                    ),
                    ),
                  );
                }
              );
            }, child: Text('Novo')),
            FlatButton(
              onPressed: () { Navigator.pop(context); setState((){searchText = '';});},
              child: Text('Cancelar')
            ),
          ],
          )
        );
      }
    );
    //api/clientes
    
  }

  void _cadastrarClient() async {
    try{
      var req = await Requests.post('${API().urlApi}/api/clientes/cadastrar',
      body: {"nome": _nameClient.text, "email": _emailClient.text, "fone": _phoneClient.text});
      print("StatusCode do /clientes/cadastrar: ${req.statusCode}");
      print(req.content());
      _nameClient.clear();
      _emailClient.clear();
      _phoneClient.clear();
      Navigator.pop(context);
      setState(() {
        _preload = false;
      });
    }catch(e){
      print(e);
    }
  }

  void _selectOptionMenu(CustomPopupMenu result){
    switch(result.id){
      case 'exit':
        _dialogExit();
        break;
      case 'create':
        _dialogNewPrevenda(context);
        break;
    }
    setState(() {
      
    });
  }
}