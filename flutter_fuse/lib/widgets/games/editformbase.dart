import 'package:fusemodel/fusemodel.dart';

///
/// Base edit form class so we can use forms in multiple places.
///
mixin EditFormBase {
  /// The final result of the game.
  GameBuilder get finalGameResult;

  /// Validates the current form.
  bool validate();

  /// Saved the details of the form.
  void save();
}
