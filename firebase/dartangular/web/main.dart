import 'injector_dev.dart' as dev;
import 'injector_prod.dart' as prod;
import 'main_shared.dart';

void main() async {
  if (const bool.fromEnvironment('prod')) {
    print('Prod setup');
    mainShared(prod.injector);
  } else {
    print('Dev setup');
    mainShared(dev.injector);
  }
}
