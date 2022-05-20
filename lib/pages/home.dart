import 'dart:async';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:avarias/models/customPopupMenu.dart';
import 'package:avarias/models/presale_helper.dart';
import 'package:avarias/models/user.dart';
import 'package:avarias/pages/scanner.dart';
import 'package:avarias/services/API.dart';
import 'package:avarias/widgets/buttonScanner.dart';
import 'package:toast/toast.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:requests/requests.dart';
import 'package:vibration/vibration.dart';
import 'package:avarias/models/userapi.dart';

/* 
  Biscoito: 252
  Colher: 321
*/

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

TextEditingController nameUserController = TextEditingController();

//Nova Adição de dados
List<CustomPopupMenu> choices = [
  CustomPopupMenu(id: 'save', title: 'Salvar Cesta', icon: Icons.save),
  CustomPopupMenu(id: 'delete', title: 'Deletar Cesta', icon: Icons.delete_forever),
  // CustomPopupMenu(id: 'ordens', title: 'Pedidos Pendentes', icon: Icons.list),
  // CustomPopupMenu(id: 'nameEdit', title: 'Editar nome do cliente', icon: Icons.edit),
  CustomPopupMenu(id: 'exit', title: 'Sair do APP', icon: Icons.exit_to_app)

];

class _HomeState extends State<Home> with TickerProviderStateMixin {
  var _bottomNavIndex = 0; //default index of first screen

  Future<List<Produtos>> produtosApi;

  bool _preload = true;
  String totalPreVenda;
  PresaleHelper helper = PresaleHelper();
  UserApi userapi = UserApi();
  Produtos produtos = Produtos();
  Product product = Product();
  User _user = User();
  bool permitScan = true;
  AnimationController _animationController;
  Animation<double> animation;
  CurvedAnimation curve;
  final _formKey = GlobalKey<FormState>();

  final iconList = <IconData>[Icons.keyboard, Icons.photo_camera];
  
  List<Product> products = List();

  /*
   * Consulta todos os produtos armazenados na tabela do SQLite
  */
  
  void _getAllProducts() async {
    product = Product();
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
    
    produtosApi = _getToUsers();

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
      var response = await Requests.get('${API().urlApi}/api/produto/consultar/${newCodeBarras}', verify: false, timeoutSeconds: 30);
        print(response);
      print(response.statusCode);
    if (response.statusCode == 200) {
      print(response.content());
      var jsonResponse = convert.jsonDecode(response.content());
      print(jsonResponse);
      print("---------------------------------");
      print(codBarras);
      print('==============');
      print(jsonResponse['data']['prodcod']);
      produtos.eAN = codBarras;
      produtos.sEQPRODUTOS = jsonResponse['data']['prodcod'].toString();
      produtos.dESCREDUZIDA = jsonResponse['data']['prodes'].toString();
      produtos.cODAV = jsonResponse['data']['procodav'].toString();
      produtos.mATRICULATION = _user.matriculation;
      print("PRINTANDO O PRODUTO");
      print("====================");
      print(produtos.sEQPRODUTOS);
      print(produtos.dESCREDUZIDA);
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
          '/productEdit',
          arguments: produtos,
        );
        if (retorno) {
          setState(() {
            permitScan = true;
          });
          //_getAllProducts();
        }
      }

      succsses = true;
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

    if(_user.acaoController == 'balanco'){
      Map _saveProduct = {
        "usuario": _user.matriculation
      };
      
      try{
        var res = await Requests.post(
          '${API().urlApi}/api/produtos/salvar',
          timeoutSeconds: 30,
          body: _saveProduct,
          verify: false
        );
        print('Produtos salvos: $_saveProduct');
        print("Status do Servidor: ${res.statusCode}");
        print("Resposta do Servidor: ${res.content()}");
        showDialog(
          context: context,
          builder: (context){
            return SingleChildScrollView(
              child: AlertDialog(
                title: Column(
                  children: [
                    Text(
                      'Balanço registrado com sucesso!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColorDark
                      )
                    ),
                  ],
                ),
                content: Container(
                  child: Center(
                    child: Text(
                      'Consulte o balanço para acessar as informações dos produtos bipados!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                ),
                actions: [
                  FlatButton(
                    child: Text("Ok"),
                    onPressed: () async { 
                      setState(() => _preload = false ); 
                      Navigator.pop(context); 
                    }
                  )
                ],
              )
            );
          }
        );
      }catch(e){
        Toast.show("Algo deu errado, tente novamente.", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    }else{
      print('Salvando a prevenda');
    }
    setState((){
      _preload = false;
    });

  }

  /*
   * Menu inferior do produto
  */
  void _menuBottomSheet(BuildContext context, Produtos produtos) {
    produtos.mATRICULATION = _user.matriculation;

    Map del;

    Vibration.vibrate(duration: 300);
    print("ESTE É A MATRÍCULA: ${produtos.mATRICULATION}");

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
                            '/productEdit',
                            arguments: produtos,
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
                        print(produtos.sEQPRODUTOS);
                        del = {
                          "seqproduto": produtos.sEQPRODUTOS,
                          "usuario": _user.matriculation
                        };

                        try{
                          print(produtos.sEQPRODUTOS);
                          var response2 = await Requests.post('${API().urlApi}/api/produtos/deletar',
                            body: del,
                            verify: false,
                            timeoutSeconds: 30
                          );
                          setState((){});
                          print(response2.statusCode);
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
                  "Deletar cesta?",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor),
                )
              ],
            ),
            content: Container(
              child: Text("Deseja deletar todos os produtos da cesta?",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor)),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("DELETAR"),
                onPressed: () async {
                  Map cancel = {
                    "usuario": _user.matriculation
                  };
                  try{
                    var response = await Requests.post(
                      '${API().urlApi}/api/produtos/cancelar',
                      body: cancel,
                      verify: false,
                      timeoutSeconds: 30
                    );
                    print("Status Code: ${response.statusCode}");
                    print("Responta do Servidor: ${response.content()}");
                  }catch(e){
                    print(e);
                  }
                  // await helper.deleteAll().then((value) => _getAllProducts());
                  // totalPreVenda = null;
                  setState(() {});
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("CACELAR"),
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
    Produtos produtos = Produtos();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    _user = ModalRoute.of(context).settings.arguments;
    produtos.mATRICULATION = _user.matriculation;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text('sistema de avarias\nUsuário: ${produtos.mATRICULATION} - ${_user.acaoController}'.toUpperCase(),
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
        child: FutureBuilder<List<Produtos>>(
          future: _getToUsers(),
          builder: (context, snapshot){
            _preload = false;
            if(snapshot.hasData){
              return snapshot.data.length > 0 ? ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index){
                  Produtos produtosApi = snapshot.data[index];
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
                                  Text(produtosApi.dESCREDUZIDA,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColorDark
                                  )),
                                  Row(
                                    children: [
                                      Text("EAN: ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      )),
                                      Text(produtosApi.eAN,
                                      style: TextStyle(
                                        fontSize: 15
                                      ),)
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text("QTD: ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      )),
                                      Text(produtosApi.eSTOQUE,
                                        style: TextStyle(
                                          fontSize: 15
                                        ),
                                      )
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
                      _menuBottomSheet(context, await userapi.getProductApi(produtosApi.eAN, produtos.mATRICULATION)); 
                    }
                  );
                },
              ):Center(
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
                          'Sem itens para o Balanço!',
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
                builder: (context) => Scanner(
                  function: _getProduct,
                  permitScan: permitScan,
                ),
              ),
            );
            if (result) {
              setState(() {
                permitScan = true;
              });
              _getAllProducts();
            }
          }
        },
      ),
    );
  }


  Future<List<Produtos>> _getToUsers() async {
    setState(() {
      permitScan = true;
      _preload = false;
    });
    print('Realizando teste');
    print(_user.matriculation);
    print(product.matriculation);
    print(_user.acaoController);
    
    print(_user.matriculation);
    var response = await Requests.get('${API().urlApi}/api/produtos/listar/${_user.matriculation}', timeoutSeconds: 30);
    print(response.statusCode);

    if(response.statusCode == 200){
      List listOfUsers = convert.jsonDecode(response.content());
      print(_user.matriculation);

      print(listOfUsers);
      return listOfUsers.map((json) => Produtos.fromJson(json)).toList();
    }else{
      throw Exception('Erro! Não foi possível carregar os dados.');
    }
  }

  void _selectOptionMenu(CustomPopupMenu result) {
    switch(result.id) {
      case 'delete':
        _dialogDeleteAllProducts(context);
        break;
      case 'save':
        _saveOrder();
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
