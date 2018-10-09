import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart';

import 'injector_prod.template.dart' as self;

@GenerateInjector([
  const ClassProvider(Client, useClass: BrowserClient),
  routerProviders,
])
final InjectorFactory injector = self.injector$Injector;

