import 'package:fusemodel/fusemodel.dart';

abstract class EditFormBase {
  GameBuilder get finalGameResult;

  bool validate();

  void save();
}
