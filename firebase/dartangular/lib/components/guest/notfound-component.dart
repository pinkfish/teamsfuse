import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

@Component(
  selector: 'guest-not-found',
  template: '<h2>Page not found</h2>',
)
class GuestNotFoundComponent implements OnActivate  {


  @override
  void onActivate(RouterState previous, RouterState current) {
    print('Guest Activated [${current.path}]');
  }
}