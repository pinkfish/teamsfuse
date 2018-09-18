import 'package:test/test.dart';

import 'package:fusemodel/fusemodel.dart';

void main() {
  test('Game updateFirestore', () {
    final game = new Game(null, null);
    game.updateFirestore(true);
  });
}
