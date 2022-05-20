import 'package:avarias/services/API.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:avarias/models/presale_helper.dart';
import 'package:toast/toast.dart';
import 'package:requests/requests.dart';
import 'package:avarias/models/userapi2.dart';
import 'package:avarias/models/user.dart';

class ProductEdit2 extends StatefulWidget {
  @override
  _ProductStateEdit2 createState() => _ProductStateEdit2();
}

class _ProductStateEdit2 extends State<ProductEdit2> {
  final _formKey = GlobalKey<FormState>();
  int qtdeProducts = 0;
  TextEditingController _quantidadeContada = TextEditingController();
  PresaleHelper helper = PresaleHelper();
  Product product = Product();
  Produtos2 produtosApi2 = Produtos2();
  User _user = User();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // void _saveProduct(BuildContext context, {Product product}) async {
  //   if (_formKey.currentState.validate()) {
      
  //     //Verificando se o produto já esta inserido no banco de dados.
  //     Product retorno = await helper.getProduct(int.parse(product.barCode));
  //     //Caso o retorno seja diferente null, será omente atualizado a quantidade do produto.
  //     if (retorno != null) {
  //       print("retorno---------------------");
  //       print(retorno);
  //       //Pegando a quantidade do produto existete e incrementando com a quantidade do produto coletado.
  //       retorno.quantity =
  //           (double.parse(retorno.quantity) + double.parse(product.quantity))
  //               .toString();
  //       helper.updateProduct(retorno);
  //       Toast.show("Quantidade adicionada ao produto", context,
  //           duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  //       Navigator.pop(context, true);
  //     } else {
  //       product.id = await helper.getNumber() + 1;
  //       print('--------------------------');
  //       print(product);
  //       await helper.saveProduct(product);
  //       Navigator.pop(context, true);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    Map _productsSave;
    Map _productEdit;
    Map _productsSaveWithCod;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double statusBarWidth = MediaQuery.of(context).padding.top;
    String titleAppBar = 'Detalhes do Produto';
    produtosApi2 = ModalRoute.of(context).settings.arguments;
    
    print("PRODUTOS ----> ${produtosApi2.cODAV}");
    print("PRODUTOS ----> ${produtosApi2.eSTOQUE}");
    //Verificando se o id veio o que indica uma edição e não uma adição!
    // if (product.id != null) {
    //   titleAppBar = 'Edição do Produto';
    //   _quantidadeContada.text = product.quantity;
    // } else {
    //   if (double.parse(product.quantity) > 0) {
    //     _quantidadeContada.text = product.quantity;
    //   } else {
    //     _quantidadeContada.text = '1';
    //   }
    // }

    //Forçando o cursor a iniciar a direita do texto na abertura do teclado virtual.
    _quantidadeContada.selection = TextSelection.fromPosition(TextPosition(offset: _quantidadeContada.text.length));

    print('Mostrando o Detalhe do Produto');
    print(produtosApi2.eSTOQUE);
    print(produtosApi2.cODAV);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text(
          titleAppBar,
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Wrap(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    top: 10, bottom: 10, left: 20, right: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CÓDIGO DO PRODUTO:',
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                      Divider(),
                      Text(
                          produtosApi2.cODAV ?? "",
                          style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 2, bottom: 10, left: 20, right: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DESCRIÇÃO DO PRODUTO:',
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                      Divider(),
                      Text(
                        produtosApi2.dESCREDUZIDA ?? "",
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 15, bottom: 10, left: 20, right: 20
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Divider(),
                    Text(
                        'PREÇO DO PRODUTO:',
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                      Divider(),
                      Text(
                        produtosApi2.vALUNIT ?? "",
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                          ),
                      )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 10, bottom: 5, left: 20, right: 20),
                child: TextField(
                  maxLength: 10,
                  onChanged: (value){
                    if(value.length > 6 && !value.contains('.')){
                      _quantidadeContada.text = "${_quantidadeContada.text.substring(0, 6)}.${_quantidadeContada.text.substring(6)}";
                      _quantidadeContada.selection = TextSelection.fromPosition(
                              TextPosition(offset: _quantidadeContada.text.length));
                    }
                  },
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: true, signed: false
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r"^(\d+)?\.?\d{0,3}")
                    )
                  ],
                  controller: _quantidadeContada,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: produtosApi2.eSTOQUE == null  ? 'Quantidade' : produtosApi2.eSTOQUE
                  ),
                )
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 10, bottom: 10, left: 20, right: 20),
                child: Container(
                  width: screenWidth,
                  height: 60,
                  decoration: new BoxDecoration(
                    color: Theme.of(context).primaryColorDark,
                    borderRadius: new BorderRadius.all(Radius.circular(4.0)),
                  ),
                  child: FlatButton(
                    child: Text(
                      'Salvar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                    onPressed: ()async {
                      print('SALVANDO');
                      
                      _productEdit = {
                          "quantidade": _quantidadeContada.text,
                          "idPrevenda": produtosApi2.iDPREVENDA,
                          "codigo": produtosApi2.cODAV 
                        };

                      _productsSave = {
                          'codigo':produtosApi2.cODAV,
                          'idPrevenda': produtosApi2.iDPREVENDA,
                          'quantidade':_quantidadeContada.text
                        };
      
                      print(produtosApi2.eSTOQUE);
                      if (produtosApi2.eSTOQUE != null) {
                        produtosApi2.eSTOQUE = _quantidadeContada.text;
                        
                        print('EDITANDO A QUANTIDADE DO PRODUTO');
                        print(produtosApi2.eAN);
                        print(_productEdit);
                        
                        try{
                          var request2 = await Requests.post('${API().urlApi}/api/prevenda/itens/editar',
                          body: _productEdit,
                          verify: false);
                          print(request2.statusCode);
                          print('Retorno: ${request2.content()}');
                          Navigator.pop(context);
                        }catch(e){
                          print('ALGO DEU ERRADO: $e');
                        }
                      
                      
                      } else {
                        print('BIPANDO UM PRODUTO QUE NÃO EXISTE NA SEXTA');
                        print('Código Único: ${produtosApi2.cODAV}');

                          try{
                            var response = await Requests.post("${API().urlApi}/api/prevenda/itens/adicionar",
                            body: _productsSave,
                            verify: false,
                            timeoutSeconds: 30
                            );
                            Navigator.pop(context);
                            print(response.statusCode);
                            print(_quantidadeContada.text);
                            print("--------------> $_productsSave");
                            
                          }catch(e){
                            print(e);
                          }
                        
                        // product.id = qtdeProducts + 1;
                        // _saveProduct(context, product: product);
                      }
                      _quantidadeContada.clear();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
