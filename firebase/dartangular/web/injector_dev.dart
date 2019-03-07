import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart';

import 'injector_dev.template.dart' as self;

const useHashLS = false;
@GenerateInjector([
  const ClassProvider(Client, useClass: BrowserClient),
  routerProvidersHash,
])
final InjectorFactory injector = self.injector$Injector as InjectorFactory;
