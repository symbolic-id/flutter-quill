import 'package:flutter/cupertino.dart';

abstract class SymEditorType {}

class SymEditorTypeKalpataru extends SymEditorType {
  SymEditorTypeKalpataru(this.controller);

  final TextEditingController controller;
}

class SymEditorTypeFace extends SymEditorType {}
class SymEditorTypeSpace extends SymEditorType {}