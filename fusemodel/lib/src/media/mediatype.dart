import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'mediatype.g.dart';

///
/// The GamePeriod to deal with in the game.
///
class MediaType extends EnumClass {
  /// The serializer for the enum.
  static Serializer<MediaType> get serializer => _$mediaTypeSerializer;

  /// The video stream,ing media type.
  static const MediaType videoStreaming = _$videoStreaming;

  /// The video on demand video type.
  static const MediaType videoOnDemand = _$videoOnDemand;

  /// The image for the media type.
  static const MediaType image = _$image;

  const MediaType._(String name) : super(name);

  /// The values of the mediatype.
  static BuiltSet<MediaType> get values => _$values;

  /// The mediatype of data to find the name from.
  static MediaType valueOf(String name) => _$valueOf(name);
}
