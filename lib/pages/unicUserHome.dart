import 'dart:async';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:avarias/models/customPopupMenu.dart';
import 'package:avarias/models/presale_helper.dart';
import 'package:avarias/models/user.dart';
import 'package:avarias/pages/scanner.dart';
import 'package:avarias/pages/cdUnic.dart';
import 'package:avarias/services/API.dart';
import 'package:avarias/widgets/buttonScanner.dart';
import 'package:toast/toast.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:requests/requests.dart';
import 'package:vibration/vibration.dart';
import 'package:avarias/models/userapi2.dart';

/* 
  Biscoito: 252
  Colher: 321
*/

class UserHome extends StatefulWidget {
  final String nome;
  final String idcliente;
  final String id;
  const UserHome({ Key key, this.nome, this.idcliente, this.id});
  @override
  _UserHomeState createState() => _UserHomeState();
}

TextEditingController nameUserController = TextEditingController();

//Nova Adição de dados
List<CustomPopupMenu> choices = [
  CustomPopupMenu(id: 'delete', title: 'Cancelar Prevenda', icon: Icons.delete_forever),
  // CustomPopupMenu(id: 'ordens', title: 'Pedidos Pendentes', icon: Icons.list),
  // CustomPopupMenu(id: 'nameEdit', title: 'Editar nome do cliente', icon: Icons.edit),
  CustomPopupMenu(id: 'exit', title: 'Sair do APP', icon: Icons.exit_to_app)

];

class _UserHomeState extends State<UserHome> with TickerProviderStateMixin {
  var _bottomNavIndex = 0; //default index of first screen

  Future<List<Produtos2>> produtosApi2;

  bool _preload = true;
  String totalPreVenda;
  PresaleHelper helper = PresaleHelper();
  UserApi userapi = UserApi();
  Produtos2 produtos2 = Produtos2();
  User _user = User();
  bool permitScan = true;
  AnimationController _animationController;
  Animation<double> animation;
  CurvedAnimation curve;
  final _formKey = GlobalKey<FormState>();

  final iconList = <IconData>[Icons.keyboard, Icons.copyright_rounded];
  
  List<Product> products = List();

  /*
   * Consulta todos os produtos armazenados na tabela do SQLite
  */
  
  void _getAllProducts() async {
    await helper.getAllProducts().then((list) {
      print(list);
      setState(() {
        products = list;
        _preload = false;
      });
    });
    _getValorTotal();
  }

  void _atualizar(){
    setState(() => {
      nameUserController.text = _user.userNameController
    });
  }

//   void _craeteUser(BuildContext context){
//   nameUserController.text = _user.userNameController;
//   showDialog(
//     context: context,
//     builder: (configCtx){
//       return SingleChildScrollView(
//         child: AlertDialog(
//           title: FittedBox(
//             child: Text(
//                     "Nome do cliente",
//                     style: TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).primaryColorDark
//                     ),
//                   ),
//           ),
//           content: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 TextFormField(
//                   controller: nameUserController,
//                   validator: (value){
//                     String r;
//                     if (value.isEmpty) {
//                       r = "informe o nome de usuário";
//                     }
//                     return r;
//                   }
//                 )
//               ],
//             )
//           ),
//           actions: [
//                 TextButton(
//                   child: Text(
//                     "Salvar",
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   onPressed: () {
//                     if(_formKey.currentState.validate()){
//                       _user.userNameController = nameUserController.text;
//                       (nameUserController.text == null) ? Navigator.pop(context) : _atualizar();
//                       Navigator.pop(context);
//                     }
//                   },
//                 )
//               ],
//         ),
//       );
//     }
//   );
// }

  /*
   * Calcula o total em valor dos produtos armazenados no SQLite 
  */
  void _getValorTotal() async {
    await helper.getAllProducts().then((list) {
      setState(() {
        if (list.length > 0) {
          double total = 0;
          for (int i = 0; i < list.length; i++) {
            total += _getPriceType(list[i])['productValueByPrice'] *
                double.parse(list[i].quantity);
            total = double.parse(total.toStringAsFixed(2));
          }
          totalPreVenda = FlutterMoneyFormatter(
            amount: total,
            settings: MoneyFormatterSettings(
              thousandSeparator: '.',
              decimalSeparator: ',',
              fractionDigits: 2,
            ),
          ).output.nonSymbol;
        } else {
          totalPreVenda = null;
        }
      });
    });
  }

  /*
   * Verifica o tipo de preço selecionado pelo usuário e faz a seleção de preço para a apresentação
  */
  Map _getPriceType(Product product) {
    int priceType;
    double productValueByPrice = 0.0;
    double proPrcVdavar = double.parse(product.proPrcVdavar);
    double proQtdMinPrc2 = double.parse(product.proQtdMinPrc2);
    double quantity = double.parse(product.quantity);
    double proQtdMinPrc3 = double.parse(product.proQtdMinPrc3);
    double proPrcVda2 = double.parse(product.proPrcVda2);
    double proPrcVda3 = double.parse(product.proPrcVda3);

    if(quantity < proQtdMinPrc2){

      priceType = 1;
      productValueByPrice = proPrcVdavar;

    }else if((quantity >= proQtdMinPrc2) && (quantity < proQtdMinPrc3)){

      priceType = 2;
      productValueByPrice = proPrcVda2;

    }else if(quantity >= proQtdMinPrc3){

      if (proQtdMinPrc3 == proQtdMinPrc2) {
        
        if (proPrcVda2 < proPrcVda3) {

          priceType = 2;
          productValueByPrice = proPrcVda2;

        } else {

          priceType = 3;
          productValueByPrice = proPrcVda3;

        }

      } else {

        priceType = 3;
        productValueByPrice = proPrcVda3;

      }

    }
    return {'priceType': priceType ,'productValueByPrice': productValueByPrice};

    // if (_user.priceType == 1) {
    //   if ((double.parse(product.quantity) >=
    //           double.parse(product.proQtdMinPrc3) &&
    //       double.parse(product.proQtdMinPrc3) > 0.0)) {
    //     productValueByPrice = double.parse(product.proPrcVda3);
    //     priceType = 3; //Preço de atacado
    //   } else {
    //     if (double.parse(product.proPrcOfevar) > 0) {
    //       productValueByPrice = double.parse(product.proPrcOfevar);
    //     } else {
    //       productValueByPrice = double.parse(product.proPrcVdavar);
    //     }
    //     priceType = _user.priceType; //Preço de varejo
    //   }
    // }
    // if (_user.priceType == 3) {
    //   productValueByPrice = double.parse(product.proPrcVda3);
    //   priceType = _user.priceType; //Preço de atacado
    // }

    // return {'priceType': priceType, 'productValueByPrice': productValueByPrice};
  }

  @override
  void initState() {
    super.initState();
    
    produtosApi2 = _getToUsers();

    //_getAllProducts();

    _animationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    curve = CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.5,
        1.0,
        curve: Curves.fastOutSlowIn,
      ),
    );
    animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(curve);

    Future.delayed(
      Duration(seconds: 1),
      () => _animationController.forward(),
    );


    // WidgetsBinding.instance.addPostFrameCallback((_) => _craeteUser(context));

  }

  /*
   * Obtem o produto pelo seu código EAN seja ele capturado pela camera ou scanner laser.
  */

  Future _getProductCode(BuildContext context, String codigo) async {
    bool succsses = false;
    double precoProdutoEtiqueta;
    print("Consultando produto pelo código: ${codigo}");
    try{
      var response = await Requests.get('${API().urlApi}/api/prevenda/itens/consultar/?codigo=${codigo}', verify: false, timeoutSeconds: 30);
      print(response.statusCode);
      if (response.statusCode == 200) {
      var resp = convert.jsonDecode(response.content());
      print(resp);
      if(resp['erro'] != null){
        Toast.show('Produto não encontrado!', context);
        setState(() {
          _preload = false;
        });
      }else{
        var jsonResponse = convert.jsonDecode(response.content());
      print("---------------------------------");
      print(codigo);
      print('==============');
      produtos2.dESCREDUZIDA = jsonResponse['produto']['DESCRICAO'].toString();
      produtos2.cODAV = jsonResponse['produto']['CODIGO'].toString();
      produtos2.vALUNIT = jsonResponse['produto']['VALOR'].toString();
      produtos2.iDPREVENDA = widget.id;
      print("PRINTANDO O PRODUTO");
      print("====================");
      print(produtos2.dESCREDUZIDA);
      print("=====================");
      setState(() {
        _preload = false;
      });

      if (precoProdutoEtiqueta != null && permitScan) {

        setState(() {
          permitScan = false;
        });
      } else {
        permitScan = false;
        final retorno = await Navigator.pushNamed(
          context,
          '/productEdit2',
          arguments: produtos2,
        );
        if (retorno) {
          setState(() {
            permitScan = true;
          });
          //_getAllProducts();
        }
      }

      succsses = true;
      }
      
    } else {
      Toast.show("Problema com a conexão com o servidor. Tente novamente!", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      setState(() {
        _preload = false;
      });
      print('Request failed with status: ${response.statusCode}.');
    }
    return succsses;
    }catch(e){
      print(e);
    }
  }

  Future _getProduct(BuildContext context, String codBarras) async {
    String newCodeBarras;
    double precoProdutoEtiqueta;
    double quantidadeProdutoEtiqueta;
    bool succsses = false;
    setState(() {
      _preload = true;
    });

    print("------------ Estou aqui --------------");

    //Tratnado codigo balança
    if (int.parse(codBarras.substring(0, 1)) == 2) {
      print('*** 123, testando ***');
      newCodeBarras = codBarras.substring(1, 6);
      precoProdutoEtiqueta = double.parse(codBarras.substring(6, 13)) / 1000;
    } else {
      print('| ---> Registrando novo Código de Barras <--- |');
      newCodeBarras = codBarras;
    }
    print(newCodeBarras);
    try{
      var response = await Requests.get('${API().urlApi}/api/prevenda/itens/consultar/?ean=${newCodeBarras}', verify: false, timeoutSeconds: 30);
      
      print(response.statusCode);
    if (response.statusCode == 200) {
      var resp = convert.jsonDecode(response.content());
      print(resp);
      if(resp['erro'] != null){
        Toast.show('Produto não encontrado!', context);
        setState(() {
          _preload = false;
        });
      }else{
        var jsonResponse = convert.jsonDecode(response.content());
      print("---------------------------------");
      print(codBarras);
      print('==============');
      produtos2.dESCREDUZIDA = jsonResponse['produto']['DESCRICAO'].toString();
      produtos2.cODAV = jsonResponse['produto']['CODIGO'].toString();
      produtos2.vALUNIT = jsonResponse['produto']['VALOR'].toString();
      produtos2.iDPREVENDA = widget.id;
      print("PRINTANDO O PRODUTO");
      print("====================");
      print(produtos2.dESCREDUZIDA);
      print("=====================");
      setState(() {
        _preload = false;
      });

      if (precoProdutoEtiqueta != null && permitScan) {

        setState(() {
          permitScan = false;
        });
      } else {
        permitScan = false;
        final retorno = await Navigator.pushNamed(
          context,
          '/productEdit2',
          arguments: produtos2,
        );
        if (retorno) {
          setState(() {
            permitScan = true;
          });
          //_getAllProducts();
        }
      }

      succsses = true;
      }
      
    } else {
      Toast.show("Problema com a conexão com o servidor. Tente novamente!", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      setState(() {
        _preload = false;
      });
      print('Request failed with status: ${response.statusCode}.');
    }
    return succsses;
    }catch(e){
      print("| =========> Deu Erro! Erro: 500 <======== |");
      // print(e);
      // Toast.show(
      //     "Algo deu errado! Verifique sua conexão e tente novamente.",
      //     context,
      //     duration: Toast.LENGTH_LONG,
      //     gravity: Toast.BOTTOM);
      setState(() {
        _preload = false;
      });
    }
  }

  /*
   * Monta o pedido e envia para o salvamento no syspdv
  */
  void _saveOrder() async {
    setState(() {
      _preload = true;
    });

  }

  /*
   * Menu inferior do produto
  */
  void _menuBottomSheet(BuildContext context, Produtos2 produtos2) {
    Map del;

    print(produtos2);

    Vibration.vibrate(duration: 300);
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
            //height: 350,
            decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: new BorderRadius.all(Radius.circular(4.0)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: Row(
                children: [
                  Expanded(
                    child: IconButton(
                      icon: Icon(
                        Icons.edit,
                        size: 35,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                          final retorno = await Navigator.pushNamed(
                            context,
                            '/productEdit2',
                            arguments: produtos2,
                          );
                          if (retorno) {
                            setState(() {
                              _preload = false;
                            });
                            //_getAllProducts();
                          }
                      },
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      icon: Icon(
                        Icons.delete_forever,
                        size: 35,
                        color: Colors.red[700],
                      ),
                      onPressed: () async {
                        del = {
                          "codigo": produtos2.cODAV,
                          "idPrevenda": widget.id
                        };
                        
                        try{
                          var request = await Requests.post(
                            '${API().urlApi}/api/prevenda/itens/deletar',
                            body: del
                          );
                          print(del);
                          print(request.statusCode);
                          setState((){});
                        }catch(e){
                          print(e);
                        }
                        
                        //Aqui ele vai deletar do banco de dados.
                        // await helper.deleteProduct(product.id);
                        // setState(() {
                        //   _preload = true;
                        // });
                        // _getAllProducts();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }

  /*
   * Questiona se o usuário deseja deletar todos os produtos da base SQLite
  */
  void _dialogDeleteAllProducts(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return SingleChildScrollView(
              child: AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Cancelar Prevenda?",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor),
                )
              ],
            ),
            content: Container(
              child: Text("Deseja cancelar essa prevenda?",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor)),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("CANCELAR"),
                onPressed: () async {
                  var req = await Requests.post('${API().urlApi}/api/prevenda/cancelar',
                  body: {'idPrevenda': widget.id});
                  print(req.statusCode);
                  // await helper.deleteAll().then((value) => _getAllProducts());
                  // totalPreVenda = null;
                  Navigator.pop(context);
                  Toast.show('Produto cancelado com sucesso!', context);
                  Navigator.pop(context);
                  setState((){});
                },
              ),
              FlatButton(
                child: Text("VOLTAR"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ));
        });
  }

  // Future _listaPendente()async{
    
  //   String loja = _user.filial.toString();
  //     var response = await Requests.get('${API().urlBase}/api/v1/organizations/${loja}/orders', verify: false, timeoutSeconds: 30);

  //     var jsonDecode = convert.jsonDecode(response.content());
  //     var date = jsonDecode['date'];
  //     var data = jsonDecode['data'];

  //     return {"date": date, "data": data};
  // }

  // void _dialogOrdens() async {
  //   String name = _user.userNameController;
  //   var dados = await _listaPendente();
  //   print("------------");
  //   print(dados);
  //   showDialog(context: context,
  //   builder: (context){
  //     return Scaffold(
  //     appBar: AppBar(
  //       centerTitle: true,
  //       backgroundColor: Theme.of(context).primaryColor,
  //       title: dados['date'] != null
  //        ? Text(
  //         "Data: ${dados['date']}",
  //         style: TextStyle(color: Colors.white),
  //       )
  //       : Text(
  //         "Nenhuma Pendencia",
  //         style: TextStyle(color: Colors.white),
  //       ),
  //       leading: IconButton(
  //         icon: Icon(
  //           Icons.arrow_back_ios,
  //           size: 20,
  //           color: Colors.white,
  //         ),
  //         onPressed: () => Navigator.pop(context, true),
  //       ),
  //     ),
  //     body: ModalProgressHUD(
  //       inAsyncCall: _preload,
  //       child: Container(
  //         child: dados['data'] != null
  //         ? ListView(
  //           children: <Widget> [
  //           for(var i = 0; i < dados['data'].length; i++)
  //           Card(child: ListTile(
  //             leading: Icon(Icons.format_align_right_outlined),
  //             title: Text('Nº do Pedido: ${dados['data'][i]['num_pedido']}'),
  //             subtitle: Text('Cliente: ${(dados['data'][i]['cliente'] == null)?'N/A':dados['data'][i]['cliente']}\nData de Emissão: ${dados['data'][i]['data_emissao']}\nHora de Emissão: ${dados['data'][i]['hora_emissao']}\nTotal: ${dados['data'][i]['total']}'),
  //             ),
  //           ),
  //       ],
  //     )
  //     :Center(
  //                 child: Container(
  //                   //Definindo a largura e a altura do container baseado na tela em questão
  //                   height: 200,
  //                   child: Column(
  //                     mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                     children: [
  //                       Image.asset(
  //                         'assets/images/empty_car.png',
  //                         width: 200,
  //                       ),
  //                       Text(
  //                         'Sem Pendencias',
  //                         style: TextStyle(
  //                             fontSize: 18, fontWeight: FontWeight.bold),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 //Text('Cesta de Produtos Vazia.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
  //               ),
  //       )
        
  //     )
      
       
  //   );
  //   });
  // }

  /*
   * Questiona se o usuário deseja realmente sair do app e voltar ao login
  */
  void _dialogExitApp() {
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

  @override
  Widget build(BuildContext context) {
    Produtos2 produtos2 = Produtos2();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    _user = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text('Pré-venda: ${widget.id}\nNome: ${widget.nome}'.toUpperCase(),
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Theme.of(context).primaryColorDark,
        actions: [
          // IconButton(
          //   icon: Icon(Icons.delete_forever),
          //   onPressed:
          //       products.length > 0 ? () => _dialogDeleteAllProducts() : null,
          // ),
          // IconButton(
          //   icon: Icon(Icons.save),
          //   onPressed: products.length > 0 ? () => _saveOrder() : null,
          // )
          PopupMenuButton<CustomPopupMenu>(
            elevation: 3.2,
            onCanceled: () {
              print('You have not chossed anything');
            },
            tooltip: 'Ações do app',
            onSelected: _selectOptionMenu,
            itemBuilder: (BuildContext context) {
              return choices.map((CustomPopupMenu choice) {
                return PopupMenuItem(
                  value: choice,
                  enabled: /* choice.id == 'exit' ? true : products.length > 0 ? true : false, */ true,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(choice.icon, color: Colors.black,),
                      ),
                      Text(choice.title),
                    ],
                  ),
                );
              }).toList();
            },
          )
        ],
      ),
      backgroundColor: Colors.grey[300],
      body: RefreshIndicator(
        onRefresh: _getToUsers,
        child: ModalProgressHUD(
        inAsyncCall: _preload,
        color: Colors.white,
        opacity: 0.7,
        child: FutureBuilder<List<Produtos2>>(
          future: _getToUsers(),
          builder: (context, snapshot){
            _preload = false;
            if(snapshot.hasData){
              return snapshot.data.length > 0 ? ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index){
                  Produtos2 produtosApi2 = snapshot.data[index];
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
                                  Text('${produtosApi2.dESCREDUZIDA} (${produtosApi2.cODAV})',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColorDark
                                  )),
                                  Row(
                                    children: [
                                      Text("Quantidade: ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      )),
                                      Text(produtosApi2.eSTOQUE,
                                        style: TextStyle(
                                          fontSize: 15
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Valor Unitário: ',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                                      Text(produtosApi2.vALUNIT),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Valor Total: ',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      Text(produtosApi2.vALORTOTAL)
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    onLongPress: () async {
                      print(widget.id);
                      print(widget.idcliente);
                      print(produtosApi2.cODAV);
                      _menuBottomSheet(context, await userapi.getProductApi(widget.idcliente, widget.id, produtosApi2.cODAV)); 
                    }
                  );
                },
              )
              :Center(
                  child: Container(
                    //Definindo a largura e a altura do container baseado na tela em questão
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Image.asset(
                          'assets/images/empty_car.png',
                          width: 200,
                        ),
                        Text(
                          'Nenhum Produto Encontrado',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  //Text('Cesta de Produtos Vazia.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                );
      
            }else if(snapshot.hasError){
              return Text(snapshot.error.toString());
            }
            //Retorna um progress bar de carregando os itens da API na balança.
            return const Center(
              child: CircularProgressIndicator()
            );
          }
        )
      ),
      ),
      floatingActionButton: ScaleTransition(
        scale: animation,
        child: ButtonScanner(
          function: _getProduct, permitScan: permitScan, //_modalBottomSheet,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        elevation: 2,
        backgroundColor: Theme.of(context).primaryColorDark,
        activeIndex: _bottomNavIndex,
        activeColor: Colors.white,
        splashColor: Colors.white,
        inactiveColor: Colors.white,
        notchAndCornersAnimation: animation,
        splashSpeedInMilliseconds: 300,
        notchSmoothness: NotchSmoothness.defaultEdge,
        gapLocation: GapLocation.center,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) async {
          if (index == 0) {
            final result = await Navigator.pushNamed(context, '/keyboard');
            if (result != null) {
              _getProduct(context, result);
            }
          }
          if (index == 1) {
            //Codigo para navegar de uma tela para outra
            // final result = await Navigator.pushNamed(context, '/scanner',
            //     arguments: _user);
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CodeUnico(),
              ),
            );
            if (result != null){
              _getProductCode(context, result);
            }
          }
        },
      ),
    );
  }


  Future<List<Produtos2>> _getToUsers() async {
    setState(() {
      permitScan = true;
      _preload = false;
    });
    print('Realizando teste');
    var response = await Requests.get('${API().urlApi}/api/prevenda/${widget.idcliente}/${widget.id}', timeoutSeconds: 30);
    print(response.statusCode);
    var idprevenda = convert.jsonDecode(response.content().toString())['prevenda']['ID'];
    print(idprevenda);

    if(response.statusCode == 200){
      List listOfUsers = convert.jsonDecode(response.content().toString())['itens'];
      print(response.content());
      print(listOfUsers);
      return listOfUsers.map((json) => Produtos2.fromJson(json)).toList();
    }else{
      throw Exception('Erro! Não foi possível carregar os dados.');
    }
  }

  void _selectOptionMenu(CustomPopupMenu result) {
    switch(result.id) {
      case 'delete':
        _dialogDeleteAllProducts(context);
        break;
      case 'exit':
        _dialogExitApp();
        break;
      // case 'ordens':
      //   _dialogOrdens();
      //   break;
      // case 'nameEdit':
      //   _craeteUser(context);
      //   break;
    }
    setState(() {});
  }
}
