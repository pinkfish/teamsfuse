import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fusemodel/fusemodel.dart';

import '../serializer.dart';

part 'messagesblocstate.g.dart';

class MessagesBlocStateType extends EnumClass {
  static Serializer<MessagesBlocStateType> get serializer =>
      _$messagesBlocStateTypeSerializer;

  static const MessagesBlocStateType Uninitialized = _$uninitialized;
  static const MessagesBlocStateType Loaded = _$loaded;

  const MessagesBlocStateType._(String name) : super(name);

  static BuiltSet<MessagesBlocStateType> get values => _$values;

  static MessagesBlocStateType valueOf(String name) => _$valueOf(name);
}

///
/// The base state for the messages bloc.  It tracks all the
/// exciting messages stuff.
///
@BuiltValue(instantiable: false)
abstract class MessagesBlocState {
  @override
  BuiltList<MessageRecipient> get unreadMessages;
  @override
  BuiltList<MessageRecipient> get recentMessages;
  MessagesBlocStateType get type;

  // Don't save this stuff
  @BuiltValueField(serialize: false)
  bool get loadedFirestore;

  static MessagesBlocStateBuilder fromState(
      MessagesBlocState state, MessagesBlocStateBuilder builder) {
    return builder
      ..unreadMessages = state.unreadMessages.toBuilder()
      ..recentMessages = state.recentMessages.toBuilder()
      ..loadedFirestore = state.loadedFirestore;
  }

  static void initializeStateBuilder(MessagesBlocStateBuilder b) =>
      b..loadedFirestore = false;

  Map<String, dynamic> toMap();
}

///
/// The messages loaded from the database.
///
abstract class MessagesLoaded
    implements MessagesBlocState, Built<MessagesLoaded, MessagesLoadedBuilder> {
  MessagesLoaded._();
  factory MessagesLoaded([void Function(MessagesLoadedBuilder) updates]) =
      _$MessagesLoaded;

  static MessagesLoadedBuilder fromState(MessagesBlocState state) {
    return MessagesBlocState.fromState(state, MessagesLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(MessagesLoadedBuilder b) {
    MessagesBlocState.initializeStateBuilder(b);

    b..type = MessagesBlocStateType.Loaded;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(MessagesLoaded.serializer, this);
  }

  static MessagesLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(MessagesLoaded.serializer, jsonData);
  }

  static Serializer<MessagesLoaded> get serializer =>
      _$messagesLoadedSerializer;
}

///
/// The messages bloc that is unitialized.
///
abstract class MessagesUninitialized
    implements
        MessagesBlocState,
        Built<MessagesUninitialized, MessagesUninitializedBuilder> {
  MessagesUninitialized._();
  factory MessagesUninitialized(
          [void Function(MessagesUninitializedBuilder) updates]) =
      _$MessagesUninitialized;

  static MessagesUninitializedBuilder fromState(MessagesBlocState state) {
    return MessagesBlocState.fromState(state, MessagesUninitializedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(MessagesUninitializedBuilder b) {
    MessagesBlocState.initializeStateBuilder(b);

    b..type = MessagesBlocStateType.Uninitialized;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(MessagesUninitialized.serializer, this);
  }

  static MessagesUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        MessagesUninitialized.serializer, jsonData);
  }

  static Serializer<MessagesUninitialized> get serializer =>
      _$messagesUninitializedSerializer;
}
