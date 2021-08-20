import 'package:flutter/cupertino.dart';

abstract class SymEditorType {
  bool get isMobile;
}

class SymEditorTypeKalpataru extends SymEditorType {
  SymEditorTypeKalpataru(this.controller, this._isMobile);

  final TextEditingController controller;
  final bool _isMobile;

  @override
  bool get isMobile => _isMobile;
}

class SymEditorTypeFace extends SymEditorType {
  SymEditorTypeFace();

  // final bool _isMobile;

  @override
  bool get isMobile => false;
}

class SymEditorTypeSpace extends SymEditorType {
  SymEditorTypeSpace();
  // final bool _isMobile;

  @override
  bool get isMobile => false;
}