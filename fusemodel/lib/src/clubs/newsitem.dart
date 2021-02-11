import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../serializer.dart';

part 'newsitem.g.dart';

///
/// Keeps track of the newsItem information for the club.  This will be the
/// details about the newsItem in the contect of the specific club.
///
abstract class NewsItem implements Built<NewsItem, NewsItemBuilder> {
  /// Uid for the newsItem
  String get uid;

  /// Name of the newsItem
  String get subject;

  /// The photo to display for the newsItem
  @nullable
  String get photoUrl;

  /// The categories associated with the new item.
  BuiltList<String> get categories;

  /// Some text describing what the newsItem is about.
  String get body;

  /// The uid of the club to lookup.
  String get clubUid;

  /// Nme of the user that posted the item
  String get postedByName;

  /// Uid of the person that posted the item.
  String get postedByUid;

  /// Creates a news item for the club.
  NewsItem._();

  /// Factory class to create the news items
  factory NewsItem([updates(NewsItemBuilder b)]) = _$NewsItem;

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(NewsItemBuilder b) => b..body = "";

  /// Serialize the news item
  Map<String, dynamic> toMap({bool includeMembers}) =>
      dataSerializers.serializeWith(NewsItem.serializer, this);

  /// Deserialize the news item.
  static NewsItem fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(NewsItem.serializer, jsonData);
  }

  /// The serializer to use for this item.
  static Serializer<NewsItem> get serializer => _$newsItemSerializer;
}