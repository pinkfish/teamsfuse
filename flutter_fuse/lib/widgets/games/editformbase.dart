import 'package:fusemodel/fusemodel.dart';

abstract class EditFormBase {
  Game get finalGameResult;

  bool validate();

  void save();
}