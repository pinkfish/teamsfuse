import 'package:angular/angular.dart';

import 'routes.dart';
import 'package:teamfuse/components/guest/pieces/header.dart';
import 'package:teamfuse/components/guest/pieces/footer.dart';
import 'package:angular_router/angular_router.dart';

@Component(
  selector: 'my-guest',
  templateUrl: 'guest-component.html',
  directives: [
    GuestHeaderComponent,
    GuestFooterComponent,
    RouterOutlet,
  ],
  providers: [
    const ClassProvider(GuestRoutes),
  ],
)
class GuestComponent {
  final GuestRoutes routes;

  GuestComponent(this.routes);
}
