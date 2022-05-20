import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:requests/requests.dart';
import 'dart:convert' as convert;

//Definição do nome da tabela
final String productBasket = "productBasket";
//Definição dos nomes das colunas da tabela do SQLite
final String idColumn = "id";
final String proCodeColumn = "proCode";
final String barCodeColumn = "barCode"; // procodaux
final String proDesColumn = "proDes";
final String proUnidColumn = "proUnid";
final String proPesVarColumn = "proPesVar";
final String proPrcVdavarColumn = "proPrcVdavar";
final String proPrcVda2Column = "proPrcVda2";
final String proQtdMinPrc2Column = "proQtdMinPrc2"; 
final String proPrcVda3Column = "proPrcVda3";
final String proQtdMinPrc3Column = "proQtdMinPrc3"; // quantidade minima atacado
final String proPrcOfevarColumn = "proPrcOfevar";
//final String priceTypeColumn = "priceType"; // Tipo de preço
final String quantityColumn = "quantity"; // quantidade contada
final String matriculationColumn = "matriculation";


class PresaleHelper {
  //Criando um padrão Sigleton
  //Variavel static, é uma variavel unica no código interio, é um variavel da class e não do objeto
  //Declaração do proprio objeto dentro dele mesmo, chamdno um contructorName
  static final PresaleHelper _instance = PresaleHelper.internal();

  factory PresaleHelper() => _instance;

  PresaleHelper.internal();

  //Inciando o banco de dados
  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    //Declarando uma constant (final) do path do banco de dados
    final databasesPath = await getDatabasesPath();
    //Pegando o arquivo do banco de dados
    final path = join(databasesPath, "avarias.db");

    //Iniciando o banco de dados
    return await openDatabase(path, version: 1,
        //Criando o banco de dados na primeira vez que ele for aberto.
        //Como é uma função que não retorna instantaneamente, ela deve ser definida com async
        onCreate: (Database db, int newVersion) async {
      await db.execute(//$idColumn INTEGER PRIMARY KEY
          "CREATE TABLE $productBasket($idColumn INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $proCodeColumn TEXT, $barCodeColumn TEXT, $proDesColumn TEXT, $proUnidColumn TEXT, $proPesVarColumn TEXT, $proPrcVdavarColumn TEXT, $proPrcVda2Column TEXT, $proQtdMinPrc2Column TEXT, $proPrcVda3Column TEXT, $proPrcOfevarColumn TEXT, $proQtdMinPrc3Column TEXT, $quantityColumn TEXT, $matriculationColumn TEXT");
    });
  }

  //Criando a função para salvar os contatos
  Future<Product> saveProduct(Product product) async {
    Database dbProduct = await db;
    //Inserindo dados na tabela
    product.id = await dbProduct.insert(productBasket, product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail);
    return product;
  }


  Future<Product> getProduct(int barCode) async {
    Database dbProduct = await db;
    List<Map> maps = await dbProduct.query(productBasket,
        columns: [
          idColumn,
          proCodeColumn,
          barCodeColumn,
          proDesColumn,
          proUnidColumn,
          proPesVarColumn,
          proPrcVdavarColumn,
          proPrcVda2Column,
          proQtdMinPrc2Column,
          proPrcVda3Column,
          proQtdMinPrc3Column,
          proPrcOfevarColumn,
          quantityColumn,
          matriculationColumn,
          
        ],
        where: "$barCodeColumn = ?",
        whereArgs: [barCode]);
    if (maps.length > 0) {
      Product.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteProduct(int id) async {
    Database dbProduct = await db;
    return await dbProduct
        .delete(productBasket, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future deleteAll() async {
    Database dbProduct = await db;
    return await dbProduct.delete(productBasket);
  }

  Future<int> updateProduct(Product product) async {
    Database dbProduct = await db;
    return await dbProduct.update(productBasket, product.toMap(),
        where: "$idColumn = ?", whereArgs: [product.id]);
  }

  Future<List> getAllProducts() async {
    Database dbProduct = await db;
    //Obtendo uma lista de contatos
    List listMap = await dbProduct.rawQuery("SELECT * FROM $productBasket");
    //Criando uma nova lista do tipo expecifico 'Product'
    List<Product> listProducts = List();
    //Passando cada item do listMap para um mapa do formato contato
    for (Map m in listMap) {
      listProducts.add(Product.fromMap(m));
    }
    return listProducts;
  }

  Future<List> getProductByBarcode(int barcode) async {
    Database dbProduct = await db;
    //Obtendo uma lista de contatos
    List listMap = await dbProduct
        .rawQuery("SELECT * FROM $productBasket where barCode = $barcode");
    //Criando uma nova lista do tipo expecifico 'Product'
    List<Product> listProducts = List();
    //Passando cada item do listMap para um mapa do formato contato
    for (Map m in listMap) {
      listProducts.add(Product.fromMap(m));
    }
    return listProducts;
  }

  Future<int> getNumber() async {
    Database dbProduct = await db;
    return Sqflite.firstIntValue(
        await dbProduct.rawQuery("SELECT COUNT(*) FROM $productBasket"));
  }

  Future close() async {
    Database dbProduct = await db;
    dbProduct.close();
  }
}

class Product {
  int id;
  String barCode;
  String proCode;
  String proDes;
  String proUnid;
  String proPesVar;
  String proPrcVdavar;
  String proPrcVda2;
  String proQtdMinPrc2;
  String proPrcVda3;
  String proQtdMinPrc3;
  String proPrcOfevar;
  String priceType;
  String quantity = '0';
  String matriculation;
  

  Product();

  Product.fromMap(Map map) {
    id = map[idColumn];
    barCode = map[barCodeColumn];
    proCode = map[proCodeColumn];
    proDes = map[proDesColumn];
    proUnid = map[proUnidColumn];
    proPesVar = map[proPesVarColumn];
    proPrcVdavar = map[proPrcVdavarColumn];
     proPrcVda2 = map[proPrcVda2Column];
    proQtdMinPrc2 = map[proQtdMinPrc2Column];
    proPrcVda3 = map[proPrcVda3Column];
    proQtdMinPrc3 = map[proQtdMinPrc3Column];
    proPrcOfevar = map[proPrcOfevarColumn];
    quantity = map[quantityColumn];
    matriculation = map[matriculationColumn];
    
  }

  Map toMap() {
    Map<String, dynamic> map = {
      idColumn: id,
      barCodeColumn: barCode,
      proCodeColumn: proCode,
      proDesColumn: proDes,
      proUnidColumn: proUnid,
      proPesVarColumn: proPesVar,
      proPrcVdavarColumn: proPrcVdavar,
      proPrcVda2Column: proPrcVda2,
      proQtdMinPrc2Column: proQtdMinPrc2,
      proPrcVda3Column: proPrcVda3,
      proQtdMinPrc3Column: proQtdMinPrc3,
      proPrcOfevarColumn: proPrcOfevar,
      quantityColumn: quantity,
      matriculationColumn: matriculation,
      
    };
    return map;
  }

  @override
  String toString() {
    return "Product(id: $id, barCode: $barCode, proCode: $proCode, proDes: $proDes, proUnid: $proUnid,proPrcVda2: $proPrcVda2,proQtdMinPrc2: $proQtdMinPrc2 , proPesVar: $proPesVar, proPrcVdavar: $proPrcVdavar, proPrcVda3: $proPrcVda3, proPrcOfevar: $proPrcOfevar, proQtdMinPrc3: $proQtdMinPrc3, quantity: $quantity, matriculation: $matriculation";
  }
}