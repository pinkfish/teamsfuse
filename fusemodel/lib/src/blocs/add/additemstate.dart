import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

///
/// Basic state for all the data in this system.
///
abstract class AddItemState extends Equatable {
  AddItemState({List props = const []}) : super(props);
}

///
/// No data at all yet.
///
class AddItemUninitialized extends AddItemState {
  AddItemUninitialized();

  @override
  String toString() {
    return 'AddItemUninitialized{}';
  }
}

///
/// Doing something.
///
class AddItemSaving extends AddItemState {
  AddItemSaving();

  @override
  String toString() {
    return 'AddItemSaving{}';
  }
}

///
/// Invalid arguements.
///
class AddItemInvalidArguments extends AddItemState {
  final Error error;

  AddItemInvalidArguments({@required this.error}) : super(props: [error]);

  @override
  String toString() {
    return 'AddItemInvalidArguments{}';
  }
}

///
/// Data is now loaded.
///
class AddItemDone extends AddItemState {
  final String uid;

  AddItemDone({@required this.uid}) : super(props: [uid]);

  @override
  String toString() {
    return 'AddItemDone{}';
  }
}

///
/// Failed to save the player (this could be an accept or an add).
///
class AddItemSaveFailed extends AddItemState {
  final Error error;

  AddItemSaveFailed({@required this.error}) : super(props: [error]);

  @override
  String toString() {
    return 'AddItemSaveFailed{}';
  }
}
