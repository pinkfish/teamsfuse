import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../serializer.dart';
import '../serializer/timestampserializer.dart';
import 'mediatype.dart';

part 'mediainfo.g.dart';

///
/// Data about the videoInfo itself.
///
abstract class MediaInfo implements Built<MediaInfo, MediaInfoBuilder> {
  /// the uid for the mediaInfo.
  @nullable
  String get uid;

  /// The sessonUid the media is for.
  String get seasonUid;

  /// The team the media is for.
  String get teamUid;

  /// The game the media is for.
  String get gameUid;

  /// When the media was uploaded.
  @nullable
  Timestamp get uploadTime;

  /// The duration of the media (0 for images)
  Duration get length;

  /// Tracks when this videoInfo is starting at in respect to the game
  /// itself.
  DateTime get startAt;

  /// The description the media.
  String get description;

  /// The thumnbnail url to use for the media.
  @nullable
  Uri get thumbnailUrl;

  /// The rtmp url for streaming data.
  @nullable
  Uri get rtmpUrl;

  /// The type of the media.
  MediaType get type;

  /// The main url associated with this piece of media.
  Uri get url;

  MediaInfo._();

  /// The MediaInfo associated factory.
  factory MediaInfo([Function(MediaInfoBuilder b) updates]) = _$MediaInfo;

  /// Serializer to make an exciting map.
  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(MediaInfo.serializer, this);
  }

  /// Create the serializer for the data.
  static MediaInfo fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(MediaInfo.serializer, jsonData);
  }

  /// The serializer associated with the MediaInfo.
  static Serializer<MediaInfo> get serializer => _$mediaInfoSerializer;
}
