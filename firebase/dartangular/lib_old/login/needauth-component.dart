import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'routes.dart';

@Component(selector: 'need-auth', directives: [
  coreDirectives,
  RouterOutlet
], providers: [
  const ClassProvider(Routes),
], template: '''
        <router-outlet [routes]="routes.all"></router-outlet>
  ''')
class NeedAuthComponent {
  final Routes routes;

  NeedAuthComponent(this.routes);
}
