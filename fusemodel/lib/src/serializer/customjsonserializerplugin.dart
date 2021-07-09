import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'dart:convert' show json;

/// Extends [StandardJsonPlugin] but also understands custom/external enums.
///
/// See https://github.com/google/built_value.dart/issues/568.
///
/// Example use:
/// ```
/// import 'package:built_value/serializer.dart';
///
/// import 'custom_enum_json_plugin.dart';
///
/// void addJsonPlugin(SerializersBuilder builder) {
///   builder.addPlugin(CustomEnumJsonPlugin([
///     MyEnum1,
///     MyEnum2,
///   ]));
/// }
/// ```
class CustomEnumJsonPlugin extends StandardJsonPlugin {
  final Set<Type> _customEnumTypes;

  CustomEnumJsonPlugin(this._customEnumTypes,
      {this.discriminator = r'$', this.valueKey = ''});

  Map<String, Object> _addEnumEncoding(Map<String, Object> json) {
    return json.map((key, value) {
      return MapEntry('"$key"', {
        valueKey: value,
        discriminator: '${value.runtimeType}',
      });
    });
  }

  Map<String, Object> _removeEnumEncoding(Map<String, Object> json) {
    return json.map((key, value) {
      var valOut = value;
      if (key is String && key.startsWith('"')) {
        key = key.substring(1, key.length - 1);
      }
      if (value is Map && value.containsKey(discriminator)) {
        valOut = value[valueKey];
      }
      return MapEntry(key, valOut);
    });
  }

  static final BuiltSet<Type> _unsupportedTypes =
      BuiltSet<Type>([BuiltListMultimap, BuiltSetMultimap]);

  /// The field used to specify the value type if needed. Defaults to `$`.
  @override
  final String discriminator;

  // The key used when there is just a single value, for example if serializing
  // an `int`.
  @override
  final String valueKey;

  @override
  Object beforeSerialize(Object object, FullType specifiedType) {
    if (_unsupportedTypes.contains(specifiedType.root)) {
      throw ArgumentError(
          'Standard JSON cannot serialize type ${specifiedType.root}.');
    }
    return object;
  }

  @override
  Object afterSerialize(Object object, FullType specifiedType) {
    var json = super.afterSerialize(object, specifiedType);
    if (specifiedType.root == BuiltMap && specifiedType.parameters.isNotEmpty) {
      if (_customEnumTypes.contains(specifiedType.parameters.first.root)) {
        json = _removeEnumEncoding(json as Map<String, Object>);
      }
    }
    if (object is List &&
        specifiedType.root != BuiltList &&
        specifiedType.root != BuiltSet &&
        specifiedType.root != JsonObject) {
      if (specifiedType.isUnspecified) {
        return _toMapWithDiscriminator(object);
      } else {
        return _toMap(object, _needsEncodedKeys(specifiedType));
      }
    } else {
      return object;
    }
  }

  @override
  Object beforeDeserialize(Object object, FullType specifiedType) {
    if (specifiedType.root == BuiltMap && specifiedType.parameters.isNotEmpty) {
      if (_customEnumTypes.contains(specifiedType.parameters.first.root)) {
        if (object is Map && object.isEmpty) {
          object = _addEnumEncoding(object as Map<String, Object>);
        }
      }
    }

    if (object is Map && specifiedType.root != JsonObject) {
      if (specifiedType.isUnspecified) {
        return _toListUsingDiscriminator(object);
      } else {
        return _toList(object, _needsEncodedKeys(specifiedType));
      }
    } else {
      return object;
    }
  }

  @override
  Object afterDeserialize(Object object, FullType specifiedType) {
    return object;
  }

  /// Returns whether a type has keys that aren't supported by JSON maps; this
  /// only applies to `BuiltMap` with non-String keys.
  bool _needsEncodedKeys(FullType specifiedType) =>
      specifiedType.root == BuiltMap &&
      specifiedType.parameters[0].root != String &&
      !_customEnumTypes.contains(specifiedType.parameters[0].root);

  /// Converts serialization output, a `List`, to a `Map`, when the serialized
  /// type is known statically.
  Map _toMap(List list, bool needsEncodedKeys) {
    var result = <String, Object>{};
    for (var i = 0; i != list.length ~/ 2; ++i) {
      final key = list[i * 2];
      final value = list[i * 2 + 1];
      result[needsEncodedKeys ? _encodeKey(key) : key as String] = value;
    }
    return result;
  }

  /// Converts serialization output, a `List`, to a `Map`, when the serialized
  /// type is not known statically. The type will be specified in the
  /// [discriminator] field.
  Map _toMapWithDiscriminator(List list) {
    var type = list[0];

    if (type == 'list') {
      // Embed the list in the map.
      return <String, Object>{discriminator: type, valueKey: list.sublist(1)};
    }

    // Length is at least two because we have one entry for type and one for
    // the value.
    if (list.length == 2) {
      // Just a type and a primitive value. Encode the value in the map.
      return <String, Object>{discriminator: type, valueKey: list[1]};
    }

    // If a map has non-String keys then they need encoding to strings before
    // it can be converted to JSON. Because we don't know the type, we also
    // won't know the type on deserialization, and signal this by changing the
    // type name on the wire to `encoded_map`.
    var needToEncodeKeys = false;
    if (type == 'map') {
      for (var i = 0; i != (list.length - 1) ~/ 2; ++i) {
        if (list[i * 2 + 1] is! String) {
          needToEncodeKeys = true;
          type = 'encoded_map';
          break;
        }
      }
    }

    var result = <String, Object>{discriminator: type};
    for (var i = 0; i != (list.length - 1) ~/ 2; ++i) {
      final key = needToEncodeKeys
          ? _encodeKey(list[i * 2 + 1])
          : list[i * 2 + 1] as String;
      final value = list[i * 2 + 2];
      result[key] = value;
    }
    return result;
  }

  /// JSON-encodes an `Object` key so it can be stored as a `String`. Needed
  /// because JSON maps are only allowed strings as keys.
  String _encodeKey(Object key) {
    return json.encode(key);
  }

  /// Converts [StandardJsonPlugin] serialization output, a `Map`, to a `List`,
  /// when the serialized type is known statically.
  List _toList(Map map, bool hasEncodedKeys) {
    var result = List<dynamic>.filled(map.length * 2, null);
    var i = 0;
    map.forEach((key, value) {
      // Drop null values, they are represented by missing keys.
      if (value == null) return;

      result[i] = hasEncodedKeys ? _decodeKey(key as String) : key;
      result[i + 1] = value;
      i += 2;
    });
    return result;
  }

  /// Converts [StandardJsonPlugin] serialization output, a `Map`, to a `List`,
  /// when the serialized type is not known statically. The type is retrieved
  /// from the [discriminator] field.
  List _toListUsingDiscriminator(Map map) {
    var type = map[discriminator];

    if (type == null) {
      throw ArgumentError('Unknown type on deserialization. '
          'Need either specifiedType or discriminator field.');
    }

    if (type == 'list') {
      return [type, ...(map[valueKey] as Iterable)];
    }

    if (map.containsKey(valueKey)) {
      // Just a type and a primitive value. Retrieve the value in the map.
      final result = List.filled(2, null);
      result[0] = type;
      result[1] = map[valueKey];
      return result;
    }

    // A type name of `encoded_map` indicates that the map has non-String keys
    // that have been serialized and JSON-encoded; decode the keys when
    // converting back to a `List`.
    var needToDecodeKeys = type == 'encoded_map';
    if (needToDecodeKeys) {
      type = 'map';
    }

    var result = List.filled(map.length * 2 - 1, null);
    result[0] = type;

    var i = 1;
    map.forEach((key, value) {
      if (key == discriminator) return;

      // Drop null values, they are represented by missing keys.
      if (value == null) return;

      result[i] = needToDecodeKeys ? _decodeKey(key as String) : key;
      result[i + 1] = value;
      i += 2;
    });
    return result;
  }

  /// JSON-decodes a `String` encoded using [_encodeKey].
  Object _decodeKey(String key) {
    return json.decode(key);
  }
}
