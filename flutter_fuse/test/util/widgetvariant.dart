import 'package:flutter_fuse/widgets/blocs/base/singleprovider.dart';
import 'package:flutter_test/flutter_test.dart';

/// The [TestVariant] that represents the variant for the
///  widget test cases.
class TeamsFuseTestVariant extends TestVariant<void> {
  /// A const constructor for a [DefaultTestVariant].
  const TeamsFuseTestVariant();

  @override
  Iterable<void> get values => const <void>[null];

  @override
  String describeValue(void value) => 'teamsFuse';

  @override
  Future<void> setUp(void value) async {}

  @override
  Future<void> tearDown(void value, void memento) async {
    SingleBlocProvider.clearBlocs();
  }
}
