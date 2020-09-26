import 'package:flutter/cupertino.dart';

class MenuItem {
  String chave;
  String texto;
  Widget icone;

  MenuItem();
  MenuItem.fromAtributos(this.chave, this.texto, this.icone);
}