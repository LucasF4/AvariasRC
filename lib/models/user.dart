class User {
  String _matriculation;
  String _userNameController;
  String _acaoController;
  int _priceType = 1;

  String get matriculation => _matriculation;
  set matriculation(String matriculation) => _matriculation = matriculation;

  String get userNameController => _userNameController;
  set userNameController(String userNameController) => _userNameController = userNameController;

  String get acaoController => _acaoController;
  set acaoController(String acaoController) => _acaoController = acaoController;

  int get priceType => _priceType;
  set priceType(int priceType) => _priceType = priceType;
}
