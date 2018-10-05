import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart';

import 'main.template.dart' as self;
import 'main_shared.dart';

const useHashLS = false;
@GenerateInjector([
  const ClassProvider(Client, useClass: BrowserClient),
  routerProviders,
])
final InjectorFactory injectorProd = self.injectorProd$Injector;

@GenerateInjector([
  const ClassProvider(Client, useClass: BrowserClient),
  routerProviders,
])
final InjectorFactory injectorHash = self.injectorHash$Injector;

void main() async {
  if (const bool.fromEnvironment('prod')) {
    print('Prod setup');
    mainShared(injectorProd);
  } else {
    print('Dev setup');
    mainShared(injectorHash);
  }
}
