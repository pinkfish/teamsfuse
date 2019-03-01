import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

@Component(
  selector: 'my-not-found',
  template: '<h2>Page not found</h2>',
)
class NotFoundComponent implements OnActivate {
  @override
  void onActivate(RouterState previous, RouterState current) {
    print('Main Activated [${current.path}]');
  }
}
